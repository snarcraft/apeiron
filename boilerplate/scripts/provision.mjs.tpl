#!/usr/bin/env node

// ============================================================
// provision.mjs — AWS + Cloudflare + GitHub, from zero to platform
// ============================================================
// Idempotent provisioner for a scaffolded project. Uses the aws
// CLI (ambient credentials) + curl for the Cloudflare API + gh
// CLI when authenticated. Dry-run by default; --apply executes.
//
//   node scripts/provision.mjs                       plan only
//   node scripts/provision.mjs --apply               everything below
//   node scripts/provision.mjs --apply --bootstrap    also ssh into the
//                                       fresh instances and lay down
//                                       docker + swarm + infra stack
//
// What it creates (idempotent — existing resources are reused):
//   1. S3 buckets        <slug>-assets, <slug>-media (+ CORS policy)
//   2. IAM users         <slug>-github, <slug>-media (+ policies,
//                        access keys land in secrets/)
//   3. EC2 per env       keypair, security group (22/80/443),
//                        Ubuntu 24.04 instance tagged by env
//   4. Cloudflare DNS    @, www, app, socket, grafana, staging set
//                        (+ wildcards) pointing at the instances
//   5. GitHub env vars   printed (or set with --github) per env
//   6. --bootstrap       scp server/ + docker.sh + infra.sh + swarm.sh

import { parseArgs } from 'node:util'
import { execFileSync, spawnSync } from 'node:child_process'
import { readFileSync, writeFileSync, mkdirSync, chmodSync, existsSync } from 'node:fs'
import { resolve, dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = dirname(fileURLToPath(import.meta.url))
const root = resolve(here, '..')

const { values: args } = parseArgs({
  options: {
    apply: { type: 'boolean' },
    bootstrap: { type: 'boolean' },
    github: { type: 'boolean' },
    envs: { type: 'string', default: 'staging,production' },
    instance: { type: 'string', default: 't3.small' },
    region: { type: 'string' },
    zone: { type: 'string' },
    'cf-token': { type: 'string' },
    help: { type: 'boolean' },
  },
})

if (args.help) {
  console.log(`usage: node scripts/provision.mjs [--apply] [--bootstrap] [--github]
                 [--envs staging,production] [--instance t3.small]
                 [--region eu-west-3] [--zone <cloudflare-zone-id>]
                 [--cf-token <token>]

env (any of, later ones override): CF_DNS_API_TOKEN, AWS_DEFAULT_REGION`)
  process.exit(0)
}

// ------------------------------------------------------------
// config from the project
// ------------------------------------------------------------
const slug = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8')).name
const envFile = join(root, 'secrets', 'provision.env')
const plan = []
let failed = 0

const ok = (msg) => console.log(`  \x1b[32m✔\x1b[0m ${msg}`)
const skip = (msg) => console.log(`  \x1b[2m·\x1b[0m ${msg} (exists)`)
const step = (msg) => console.log(`\n\x1b[36m◆\x1b[0m ${msg}`)
const fail = (msg) => { console.log(`  \x1b[31m✖\x1b[0m ${msg}`); failed++ }
const willRun = (cmd) => plan.push(cmd)

function sh(cmd, { check = true, dry = !args.apply } = {}) {
  if (dry) {
    willRun(cmd)
    return ''
  }
  try {
    return execFileSync(cmd, { shell: '/bin/bash', encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim()
  } catch (error) {
    if (check) throw error
    return error.stdout?.trim() ?? ''
  }
}

function shOk(cmd) {
  return sh(cmd, { check: false }) !== ''
}

const saveSecret = (key, value) => {
  if (!value) return
  mkdirSync(join(root, 'secrets'), { recursive: true })
  const line = `${key}=${value}\n`
  const current = existsSync(envFile) ? readFileSync(envFile, 'utf8') : ''
  if (!current.includes(`${key}=`)) {
    writeFileSync(envFile, current + line)
    chmodSync(envFile, 0o600)
    console.log(`  \x1b[2m+ ${key} → secrets/provision.env\x1b[0m`)
  }
}

// ------------------------------------------------------------
// preflight
// ------------------------------------------------------------
const cfToken = args['cf-token'] || process.env.CF_DNS_API_TOKEN || ''
const region = args.region || process.env.AWS_DEFAULT_REGION || 'eu-west-3'
const envs = args.envs.split(',').map((e) => e.trim()).filter(Boolean)

console.log(`\n\x1b[1m${args.apply ? 'Provisioning' : 'Planning (dry-run)'} ${slug}\x1b[0m`)
console.log(`  envs: ${envs.join(', ')} · region: ${region} · dns: ${cfToken ? 'cloudflare' : 'skipped (no token)'}\n`)

if (!shOk('command -v aws')) {
  fail('aws CLI not found — install it or run with AWS credentials configured')
  process.exit(1)
}

const accountId = sh('aws sts get-caller-identity --query Account --output text')
const caller = sh('aws sts get-caller-identity --query Arn --output text')
console.log(`  account: ${accountId} (${caller})`)

// ------------------------------------------------------------
// 1. buckets + CORS
// ------------------------------------------------------------
step('S3 buckets')

for (const bucket of [`${slug}-assets`, `${slug}-media`]) {
  if (shOk(`aws s3api head-bucket --bucket ${bucket} 2>/dev/null`)) {
    skip(`${bucket}`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m ${bucket}`)
    sh(`aws s3api create-bucket --bucket ${bucket} --region ${region} --create-bucket-configuration LocationConstraint=${region}`)
    // assets are served publicly-read by the CI sync
    sh(`aws s3api put-public-access-block --bucket ${bucket} --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=true,RestrictPublicBuckets=false`)
    sh(`aws s3api put-bucket-ownership-controls --bucket ${bucket} --ownership-controls Rules=[{ObjectOwnership=BucketOwnerPreferred}]`)
    saveSecret(`S3_BUCKET_${bucket === `${slug}-assets` ? 'ASSETS' : 'MEDIA'}`, bucket)
  }
}

if (existsSync(join(root, 'config', 'asset-cors.json'))) {
  console.log('  \x1b[36m+\x1b[0m CORS on assets bucket')
  sh(`aws s3api put-bucket-cors --bucket ${slug}-assets --cors-configuration file://${join(root, 'config', 'asset-cors.json')}`)
}

// ------------------------------------------------------------
// 2. IAM users + policies + keys
// ------------------------------------------------------------
step('IAM users')

const provisionUser = (name, policyFile, secretKeyPrefix) => {
  if (shOk(`aws iam get-user --user-name ${name} 2>/dev/null`)) {
    skip(`${name}`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m ${name}`)
    sh(`aws iam create-user --user-name ${name}`)
  }

  const policyName = `${name}-policy`
  const policyArn = `arn:aws:iam::${accountId}:policy/${policyName}`
  if (shOk(`aws iam get-policy --policy-arn ${policyArn} 2>/dev/null`)) {
    skip(`${policyName}`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m ${policyName}`)
    sh(`aws iam create-policy --policy-name ${policyName} --policy-document file://${join(root, 'config', policyFile)}`)
  }
  sh(`aws iam attach-user-policy --user-name ${name} --policy-arn ${policyArn}`)

  const keys = JSON.parse(sh(`aws iam list-access-keys --user-name ${name} --query 'AccessKeyMetadata' --output json`) || '[]')
  if (keys.length) {
    skip(`${name} access key`)
  } else {
    const key = JSON.parse(sh(`aws iam create-access-key --user-name ${name} --output json`))
    saveSecret(`${secretKeyPrefix}_AWS_ACCESS_KEY_ID`, key.AccessKey.AccessKeyId)
    saveSecret(`${secretKeyPrefix}_AWS_SECRET_ACCESS_KEY`, key.AccessKey.SecretAccessKey)
    console.log(`  \x1b[32m✔\x1b[0m ${name} access key → secrets/provision.env`)
  }
}

provisionUser(`${slug}-github`, 'github-policy.json', 'CI')
provisionUser(`${slug}-media`, 'media-policy.json', 'APP')

// ------------------------------------------------------------
// 3. EC2 per environment
// ------------------------------------------------------------
step('EC2 instances')

const instances = {}

for (const env of envs) {
  const keyName = `${slug}-${env}`
  const sgName = `${slug}-${env}-sg`
  const keyPath = join(root, 'secrets', `id_rsa_${env}`)

  // keypair
  if (existsSync(keyPath)) {
    skip(`${keyName} keypair (local file)`)
  } else if (shOk(`aws ec2 describe-key-pairs --key-names ${keyName} 2>/dev/null`)) {
    skip(`${keyName} keypair (aws, no local file — reusing not possible, skipping)`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m keypair ${keyName}`)
    const material = sh(`aws ec2 create-key-pair --key-name ${keyName} --query 'KeyMaterial' --output text`)
    writeFileSync(keyPath, material)
    chmodSync(keyPath, 0o600)
    console.log(`  \x1b[32m✔\x1b[0m ${keyPath}`)
  }

  // security group
  let sgId = sh(`aws ec2 describe-security-groups --group-names ${sgName} --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null`)
  if (sgId) {
    skip(`${sgName}`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m ${sgName} (22/80/443)`)
    sgId = sh(`aws ec2 create-security-group --group-name ${sgName} --description '${slug} ${env}' --query GroupId --output text`)
    for (const port of [22, 80, 443]) {
      sh(`aws ec2 authorize-security-group-ingress --group-id ${sgId} --protocol tcp --port ${port} --cidr 0.0.0.0/0`)
    }
  }
  saveSecret(`SG_${env.toUpperCase()}`, sgId)

  // instance (tagged, reused if it already exists)
  const existing = JSON.parse(sh(
    `aws ec2 describe-instances --filters Name=tag:${slug}-env,Values=${env} Name=instance-state-name,Values=running --query 'Reservations[].Instances[0]' --output json 2>/dev/null`,
  ) || '[]')

  if (existing.length) {
    instances[env] = existing[0]
    skip(`${slug}-${env} instance (${instances[env].PublicIpAddress})`)
  } else {
    console.log(`  \x1b[36m+\x1b[0m launching ${slug}-${env} (${args.instance})`)
    const ami = sh(`aws ssm get-parameters --names /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp2/ami-id --query 'Parameters[0].Value' --output text`)
    const userData = Buffer.from(`#!/bin/bash
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
docker swarm init || true
docker network create --driver overlay --attachable cluster || true
`).toString('base64')

    const instanceId = sh(
      `aws ec2 run-instances --image-id ${ami} --instance-type ${args.instance} --key-name ${keyName} --security-group-ids ${sgId} --user-data '${userData}' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=${slug}-${env}},{Key=${slug}-env,Value=${env}]' --count 1 --query 'Instances[0].InstanceId --output text`,
    )

    console.log(`  … ${instanceId} booting`)
    let ip = ''
    for (let i = 0; i < 40 && args.apply; i++) {
      ip = sh(`aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text 2>/dev/null`)
      if (ip && !ip.startsWith('None')) break
      spawnSync('sleep', ['5'])
    }
    instances[env] = { InstanceId: instanceId, PublicIpAddress: ip }
    ok(`${slug}-${env} → ${ip || '(ip pending)'}`)
  }

  saveSecret(`HOST_${env.toUpperCase()}`, instances[env].PublicIpAddress)
}

// ------------------------------------------------------------
// 4. Cloudflare DNS
// ------------------------------------------------------------
step('Cloudflare DNS')

if (!cfToken) {
  console.log('  \x1b[2m· skipped — set CF_DNS_API_TOKEN or --cf-token\x1b[0m')
} else {
  const cf = (method, path, body) =>
    JSON.parse(sh(
      `curl -sf -X ${method} 'https://api.cloudflare.com/client/v4${path}' -H 'Authorization: Bearer ${cfToken}' -H 'Content-Type: application/json' ${body ? `-d '${JSON.stringify(body)}'` : ''}`,
    ))

  const domain = envs.includes('production') && instances.production ? null : null
  void domain

  let zoneId = args.zone
  if (!zoneId) {
    // derive from any existing record lookup: use the config/asset-cors origin
    const cors = JSON.parse(readFileSync(join(root, 'config', 'asset-cors.json'), 'utf8'))
    const origin = new URL(cors.CORSRules[0].AllowedOrigins[0]).hostname
    const rootDomain = origin.split('.').slice(-2).join('.')
    const zones = cf('GET', `/zones?name=${rootDomain}`)
    zoneId = zones?.result?.[0]?.id
  }

  if (!zoneId) {
    fail('could not resolve Cloudflare zone — pass --zone <id>')
  } else {
    const records = cf('GET', `/zones/${zoneId}/dns_records?per_page=100`).result.map((r) => ({ name: r.name, id: r.id, type: r.type }))
    const find = (name, type) => records.find((r) => r.name === name && r.type === type)

    const rootDomain = cf('GET', `/zones/${zoneId}`).result.name
    const stagingIp = instances.staging?.PublicIpAddress
    const productionIp = instances.production?.PublicIpAddress

    const wanted = []
    if (productionIp) {
      wanted.push({ name: rootDomain, type: 'A', content: productionIp, proxied: false })
      wanted.push({ name: `www.${rootDomain}`, type: 'CNAME', content: rootDomain, proxied: false })
      wanted.push({ name: `app.${rootDomain}`, type: 'A', content: productionIp, proxied: false })
      wanted.push({ name: `socket.${rootDomain}`, type: 'A', content: productionIp, proxied: false })
      wanted.push({ name: `grafana.${rootDomain}`, type: 'A', content: productionIp, proxied: false })
      wanted.push({ name: `api.${rootDomain}`, type: 'A', content: productionIp, proxied: false })
      wanted.push({ name: `*.${rootDomain}`, type: 'A', content: productionIp, proxied: false })
    }
    if (stagingIp) {
      wanted.push({ name: `staging.${rootDomain}`, type: 'A', content: stagingIp, proxied: false })
      wanted.push({ name: `app.staging.${rootDomain}`, type: 'A', content: stagingIp, proxied: false })
      wanted.push({ name: `socket.staging.${rootDomain}`, type: 'A', content: stagingIp, proxied: false })
      wanted.push({ name: `*.staging.${rootDomain}`, type: 'A', content: stagingIp, proxied: false })
    }

    for (const record of wanted) {
      const existingRecord = find(record.name, record.type)
      if (existingRecord) {
        skip(`${record.type} ${record.name}`)
      } else {
        console.log(`  \x1b[36m+\x1b[0m ${record.type} ${record.name} → ${record.content}`)
        cf('POST', `/zones/${zoneId}/dns_records`, { type: record.type, name: record.name, content: record.content, proxied: record.proxied, ttl: 300 })
      }
    }
    ok(`zone ${rootDomain}`)
  }
}

// ------------------------------------------------------------
// 5. GitHub vars/secrets (printed, or set with --github)
// ------------------------------------------------------------
step('GitHub environment values')

const ghLines = []
for (const env of envs) {
  const host = instances[env]?.PublicIpAddress
  ghLines.push({ env, kind: 'secret', key: 'SERVER_HOST', value: host })
  ghLines.push({ env, kind: 'secret', key: 'SERVER_USER', value: 'ubuntu' })
  ghLines.push({ env, kind: 'secret', key: 'SERVER_KEY', value: `contents of secrets/id_rsa_${env}` })
  ghLines.push({ env, kind: 'secret', key: 'AWS_SECURITY_GROUP_ID', value: `see secrets/provision.env SG_${env.toUpperCase()}` })
  ghLines.push({ env, kind: 'variable', key: 'APP_ENV', value: env })
}

for (const line of ghLines) {
  const command = `gh ${line.kind === 'secret' ? 'secret' : 'variable'} set ${line.key} --env ${line.env}`
  if (args.github && args.apply) {
    if (line.value?.startsWith('contents of')) {
      console.log(`  \x1b[2m○ ${command}  # ${line.value}\x1b[0m`)
    } else {
      console.log(`  \x1b[36m+\x1b[0m ${command}`)
      sh(`${command} --body "${line.value}"`)
    }
  } else {
    console.log(`  \x1b[2m$ ${command}  # ${line.value ?? ''}\x1b[0m`)
  }
}

// ------------------------------------------------------------
// 6. optional bootstrap (ssh into fresh hosts)
// ------------------------------------------------------------
if (args.bootstrap && args.apply) {
  step('Bootstrapping hosts (docker + swarm + infra stack)')

  for (const env of envs) {
    const host = instances[env]?.PublicIpAddress
    const key = join(root, 'secrets', `id_rsa_${env}`)
    if (!host || !existsSync(key)) {
      fail(`${env}: missing host or key — skip`)
      continue
    }

    const ssh = (cmd) => sh(`ssh -i ${key} -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 ubuntu@${host} '${cmd.replace(/'/g, "'\\''")}'`)
    const scp = () => sh(`scp -i ${key} -o StrictHostKeyChecking=accept-new -r ${join(root, 'server')} ubuntu@${host}:~/{{APP_NAME}}`)

    console.log(`  \x1b[36m→\x1b[0m ${env}: ${host}`)
    if (!args.apply) {
      willRun(`scp server/ ubuntu@${host}:~/{{APP_NAME}} && ssh … 'docker.sh && infra.sh'`)
    } else {
      scp()
      const dbPassword = execFileSync('openssl', ['rand', '-base64', '24'], { encoding: 'utf8' }).trim()
      const redisPassword = execFileSync('openssl', ['rand', '-base64', '24'], { encoding: 'utf8' }).trim()
      const gfPassword = execFileSync('openssl', ['rand', '-base64', '24'], { encoding: 'utf8' }).trim()
      saveSecret(`DB_PASSWORD_${env.toUpperCase()}`, dbPassword)
      saveSecret(`REDIS_PASSWORD_${env.toUpperCase()}`, redisPassword)

      ssh(`cd ~/{{APP_NAME}} && sudo -E bash ./docker.sh`)
      ssh(`cd ~/{{APP_NAME}} && VAR_DB_PASSWORD='${dbPassword}' VAR_REDIS_PASSWORD='${redisPassword}' VAR_GF_SECURITY_ADMIN_PASSWORD='${gfPassword}' bash ./infra.sh || true`)
      ok(`${env} host ready`)
    }
  }
}

// ------------------------------------------------------------
// summary
// ------------------------------------------------------------
console.log(`\n\x1b[2m──────────────────────────────────────────────\x1b[0m`)
if (!args.apply) {
  console.log(`\x1b[2mDry run — ${plan.length} commands planned. Re-run with --apply.\x1b[0m`)
} else if (failed) {
  console.log(`\x1b[31m${failed} step(s) failed — fix and re-run (idempotent).\x1b[0m`)
} else {
  console.log(`\x1b[32mDone. Next:\x1b[0m`)
  console.log(`  1. merge secrets/provision.env values into secrets/<env>.env`)
  console.log(`  2. push a tag → publish images → Actions "Swarm up"`)
  if (!args.bootstrap) console.log(`  3. (or re-run with --bootstrap to lay down docker now)`)
}
console.log('')
