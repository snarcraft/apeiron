#!/usr/bin/env node

// ============================================================
// lang.mjs — sync i18n keys between frontend and backend
// ============================================================
// Scans apps/frontend for t('...') usages and merges any missing
// key into apps/backend/storage/app/lang/<locale>.json (as
// path→path placeholders to be translated later).
//
//   pnpm lang:extract

import { readFileSync, writeFileSync, existsSync, readdirSync } from 'node:fs'
import { join } from 'node:path'
import { argv, exit } from 'node:process'

const FRONTEND_DIR = 'apps/frontend/app'
const LANG_DIR = 'apps/backend/storage/app/lang'

function collectFiles(dir, exts, acc = []) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name)
    if (entry.isDirectory()) collectFiles(full, exts, acc)
    else if (exts.some((ext) => entry.name.endsWith(ext))) acc.push(full)
  }
  return acc
}

function extractKeys() {
  const keys = new Set()
  const files = collectFiles(FRONTEND_DIR, ['.vue', '.ts'])

  for (const file of files) {
    const source = readFileSync(file, 'utf8')
    const patterns = [/\bt\(\s*'([^']+)'/g, /\bt\(\s*"([^"]+)"/g, /\bi18n\.t\(\s*'([^']+)'/g]

    for (const pattern of patterns) {
      for (const match of source.matchAll(pattern)) {
        if (!match[1].includes('{')) keys.add(match[1])
      }
    }
  }

  return [...keys]
}

function mergeLocale(locale, keys) {
  const file = join(LANG_DIR, `${locale}.json`)
  if (!existsSync(file)) return { file, added: 0 }

  const dict = JSON.parse(readFileSync(file, 'utf8'))
  let added = 0

  for (const key of keys) {
    const parts = key.split('.')
    let node = dict

    for (let i = 0; i < parts.length - 1; i++) {
      node[parts[i]] ??= {}
      node = node[parts[i]]
    }

    const leaf = parts.at(-1)
    if (!(leaf in node)) {
      node[leaf] = key
      added++
    }
  }

  if (added) writeFileSync(file, JSON.stringify(dict, null, 4) + '\n')
  return { file, added }
}

if (!existsSync(LANG_DIR)) {
  console.error(`✖ ${LANG_DIR} not found — run the backend first.`)
  exit(1)
}

const keys = extractKeys()
console.log(`◆ ${keys.length} keys found in ${FRONTEND_DIR}`)

for (const file of readdirSync(LANG_DIR).filter((f) => f.endsWith('.json'))) {
  const locale = file.replace('.json', '')
  const { added } = mergeLocale(locale, keys)
  console.log(`${added ? '✔' : '·'} ${locale}: ${added} keys added`)
}

void argv
