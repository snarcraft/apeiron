// ============================================================
// render.mjs — boilerplate renderer
// ============================================================
// Walks template/boilerplate, copies every file to the target
// project while resolving {{TOKEN}} placeholders and stripping
// {{#if TOGGLE}} … {{/if}} blocks for disabled integrations.
// Files ending in `.tpl` are rendered; the suffix is dropped.

import { readdir, readFile, writeFile, mkdir, cp } from 'node:fs/promises'
import { dirname, join, relative } from 'node:path'
import { existsSync } from 'node:fs'

const TOKEN_RE = /\{\{([A-Z0-9_]+)\}\}/g
const IF_RE = /^\s*\{\{#(if|unless)\s+([A-Z0-9_]+)\}\}\s*$/
const END_RE = /^\s*\{\{\/(if|unless)\}\}\s*$/
const ONLY_RE = /^\{\{!only\s+([A-Z0-9_]+)\}\}\s*\n/
const INLINE_IF_RE = /\{\{#(if|unless)\s+([A-Z0-9_]+)\}\}(.*?)\{\{\/(if|unless)\}\}/g

export function renderString(content, tokens) {
  // File-level gate: `{{!only TOGGLE}}` as the very first line —
  // when the toggle is off the whole file is skipped.
  const only = content.match(ONLY_RE)
  if (only && !tokens[only[1]]) {
    return null
  }
  if (only) {
    content = content.slice(only[0].length)
  }

  // Single-line inline conditionals: `...{{#if X}} a b{{/if}}...`
  // resolve in place — used inside strings like SERVICES="...".
  const resolveInline = (line) =>
    line.replace(INLINE_IF_RE, (match, kind, toggle, inner) => {
      const value = Boolean(tokens[toggle])
      return kind === 'if' ? (value ? inner : '') : (!value ? inner : '')
    })

  const lines = content.split('\n')
  const out = []
  let skipUntil = null

  for (const line of lines) {
    const open = line.match(IF_RE)
    if (open) {
      const value = Boolean(tokens[open[2]])
      const keep = open[1] === 'if' ? value : !value
      if (!keep) skipUntil = open[2]
      continue
    }
    if (END_RE.test(line)) {
      skipUntil = null
      continue
    }
    if (skipUntil !== null) {
      // Nested conditionals inside a skipped block: swallow their
      // markers so the outer block still terminates correctly.
      continue
    }
    out.push(resolveInline(line))
  }

  return out
    .join('\n')
    .replace(TOKEN_RE, (match, key) => {
      if (!(key in tokens)) return match
      return String(tokens[key])
    })
}

export async function renderTree({ source, target, tokens, skip, log = () => {} }) {
  const created = []

  async function walk(dir) {
    const entries = await readdir(dir, { withFileTypes: true })

    for (const entry of entries) {
      const from = join(dir, entry.name)
      const rel = relative(source, from)
      let to = join(target, rel)

      if (skip?.(rel)) {
        continue
      }

      if (entry.isDirectory()) {
        // Skip whole directories when a marker file disables them.
        if (entry.name.endsWith('.skip')) continue
        await walk(from)
        continue
      }

      const isTpl = entry.name.endsWith('.tpl')
      if (isTpl) to = to.replace(/\.tpl$/, '')

      if (isTpl || /\.(md|json|ya?ml|ts|js|mjs|vue|css|html|txt|sh|php|xml|svg|gitignore|webmanifest|editorconfig|example|env|conf|ico|stub|lock|yml\.tpl)?$/.test(entry.name) || !entry.name.includes('.')) {
        const content = await readFile(from, 'utf8')
        const rendered = renderString(content, tokens)

        if (rendered === null) {
          continue // file gated off by {{!only TOGGLE}}
        }

        await mkdir(dirname(to), { recursive: true })
        await writeFile(to, rendered)
      } else {
        // Binary assets (png, ico, pdf…) copy verbatim.
        await mkdir(dirname(to), { recursive: true })
        await cp(from, to)
      }

      created.push(to)
      log(rel)
    }
  }

  await walk(source)
  return created
}

// Convenience: write a generated file (already-rendered content).
export async function writeGenerated(target, content) {
  await mkdir(dirname(target), { recursive: true })
  await writeFile(target, content)
}

export function assertEmptyDir(dir) {
  if (existsSync(dir)) {
    throw new Error(`Target directory already exists: ${dir}`)
  }
}
