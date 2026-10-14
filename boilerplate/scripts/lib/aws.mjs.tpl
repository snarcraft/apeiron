// ============================================================
// lib/aws.mjs — AWS API surface via SigV4-signed fetch (zero deps)
// ============================================================
// The aws CLI signs with credentials on a host; actions and
// scripts sign with these. Minimal SigV4 over fetch — the same
// dance the CLI does, in sixty readable lines.

import { createHmac, createHash } from 'node:crypto'

const encode = (s) => encodeURIComponent(String(s)).replace(/[!'()*]/g, (ch) => '%' + ch.charCodeAt(0).toString(16).toUpperCase())

async function awsFetch({ service, region, method = 'GET', path = '/', query = {}, body = '', headers = {}, credentials = {} }) {
  const accessKeyId = credentials.accessKeyId || process.env.AWS_ACCESS_KEY_ID
  const secretAccessKey = credentials.secretAccessKey || process.env.AWS_SECRET_ACCESS_KEY

  if (!accessKeyId || !secretAccessKey) {
    throw new Error('aws credentials missing — set AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY')
  }

  const host = `${service}.${region}.amazonaws.com`
  const amzDate = new Date().toISOString().replace(/[:-]|\.\d{3}/g, '')
  const dateStamp = amzDate.slice(0, 8)

  const canonicalQuery = Object.keys(query).sort().map((k) => `${encode(k)}=${encode(query[k])}`).join('&')
  const payloadHash = createHash('sha256').update(body).digest('hex')
  const allHeaders = { host, 'x-amz-date': amzDate, 'x-amz-content-sha256': payloadHash, ...headers }
  const signedHeaders = Object.keys(allHeaders).sort()
  const canonicalHeaders = signedHeaders.map((h) => `${h}:${allHeaders[h]}\n`).join('')

  const canonicalRequest = [method, path, canonicalQuery, canonicalHeaders, signedHeaders.join(';'), payloadHash].join('\n')
  const scope = `${dateStamp}/${region}/${service}/aws4_request`
  const stringToSign = [
    'AWS4-HMAC-SHA256',
    amzDate,
    scope,
    createHash('sha256').update(canonicalRequest).digest('hex'),
  ].join('\n')

  const hmac = (key, data) => createHmac('sha256', key).update(data).digest()
  const signingKey = hmac(hmac(hmac(hmac(`AWS4${secretAccessKey}`, dateStamp), region), service), 'aws4_request')
  const signature = createHmac('sha256', signingKey).update(stringToSign).digest('hex')

  const authorization = `AWS4-HMAC-SHA256 Credential=${accessKeyId}/${scope}, SignedHeaders=${signedHeaders.join(';')}, Signature=${signature}`
  const url = `https://${host}${path}${canonicalQuery ? `?${canonicalQuery}` : ''}`

  const response = await fetch(url, {
    method,
    headers: { ...allHeaders, Authorization: authorization },
    body: body || undefined,
  })

  if (!response.ok) {
    throw new Error(`aws ${service} ${response.status}: ${(await response.text()).slice(0, 200)}`)
  }
  return response.json()
}

export const aws = {
  // "who am I" — the credential preflight
  callerIdentity: (region, credentials) =>
    awsFetch({ service: 'sts', region, credentials, query: { Action: 'GetCallerIdentity', Version: '2011-06-15' } }),

  // extend here as actions need more: ec2 describe, s3 head, iam get-user…
  request: awsFetch,
}
