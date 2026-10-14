// ============================================================
// prompts.mjs — zero-dependency interactive prompts (node >= 20)
// ============================================================
// text · confirm · select · multiselect · secret, plus small
// formatting helpers. Raw-mode key handling gives a real CLI feel
// (arrows, space-to-toggle, backspace editing) without any deps.

import readline from 'node:readline'
import process from 'node:process'

const ESC = '\x1b'
const CSI = '\x1b['
const isEscape = (s) => s === '\x1b' || s.startsWith('\x1b')

export const c = {
  reset: (s) => `\x1b[0m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
  dim: (s) => `\x1b[2m${s}\x1b[0m`,
  italic: (s) => `\x1b[3m${s}\x1b[0m`,
  underline: (s) => `\x1b[4m${s}\x1b[0m`,
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  red: (s) => `\x1b[31m${s}\x1b[0m`,
  magenta: (s) => `\x1b[35m${s}\x1b[0m`,
  true: (r, g, b, s) => `\x1b[38;2;${r};${g};${b}m${s}\x1b[0m`,
}

// Gradient text: interpolate [r,g,b] → [r,g,b] across characters.
export function gradient(text, from, to) {
  const chars = [...text]
  const n = Math.max(chars.length - 1, 1)
  return chars
    .map((ch, i) => {
      const t = i / n
      const r = Math.round(from[0] + (to[0] - from[0]) * t)
      const g = Math.round(from[1] + (to[1] - from[1]) * t)
      const b = Math.round(from[2] + (to[2] - from[2]) * t)
      return ch === ' ' ? ' ' : c.true(r, g, b, ch)
    })
    .join('')
}

// Single live status line (TTY only) — \r-rewrite in place.
export function live(text) {
  if (process.stdout.isTTY) process.stdout.write(`\r\x1b[2K${text}`)
}

export function liveEnd() {
  if (process.stdout.isTTY) process.stdout.write('\r\x1b[2K')
}

export const sym = {
  pointer: '❯',
  dot: '◆',
  check: '✔',
  cross: '✖',
  bar: '─',
  arrow: '→',
}

export function hr(char = sym.bar, width = 62) {
  return c.dim(char.repeat(width))
}

export function title(text) {
  console.log(`\n${c.bold(c.cyan(`${sym.dot} ${text}`))}`)
}

export function note(text) {
  console.log(c.dim(`  ${text}`))
}

export function done(text) {
  console.log(`${c.green(sym.check)} ${text}`)
}

export function fail(text) {
  console.log(`${c.red(sym.cross)} ${text}`)
}

function setRaw(on) {
  if (process.stdin.isTTY) process.stdin.setRawMode(on)
}

function hideCursor() {
  process.stdout.write(`${CSI}?25l`)
}

function showCursor() {
  process.stdout.write(`${CSI}?25h`)
}

async function keypress() {
  return new Promise((resolve) => {
    const onData = (buf) => {
      process.stdin.removeListener('data', onData)
      resolve(buf.toString())
    }
    process.stdin.once('data', onData)
  })
}

function clearLines(n) {
  process.stdout.write(`${CSI}${n}A${CSI}J`)
}

// ------------------------------------------------------------
// text
// ------------------------------------------------------------
export async function text({ label, placeholder = '', default: def = '', validate } = {}) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })
  const suffix = def ? c.dim(` (${def})`) : ''
  let answer
  while (true) {
    answer = await rl.question(`${c.cyan(sym.pointer)} ${c.bold(label)}${suffix} `)
    answer = answer.trim() || def
    if (!validate || validate(answer)) break
    fail(validate.message ?? 'Invalid value')
  }
  rl.close()
  console.log(`${c.dim(`  ${sym.check}`)} ${label}: ${c.bold(answer || c.dim('(empty)'))}`)
  return answer
}

// ------------------------------------------------------------
// secret (masked input)
// ------------------------------------------------------------
export async function secret({ label, placeholder = '' } = {}) {
  hideCursor()
  let value = ''
  const prompt = `${c.cyan(sym.pointer)} ${c.bold(label)} ${c.dim('(input hidden, enter to skip)')} `
  process.stdout.write(prompt)

  while (true) {
    const key = await keypress()
    if (key === '\r' || key === '\n') break
    if (key === '\u0003') {
      showCursor()
      setRaw(false)
      process.exit(130)
    }
    if (key === '\x7f' || key === '\b') {
      if (value.length) {
        value = value.slice(0, -1)
        process.stdout.write(`${CSI}1D${CSI}0K`)
        const masked = '*'.repeat(value.length)
        process.stdout.write(`${CSI}2K${CSI}0G${prompt}${masked}`)
      }
      continue
    }
    if (key.startsWith(ESC)) continue
    if (key < ' ') continue
    value += key
    const masked = '*'.repeat(value.length)
    process.stdout.write(`${CSI}2K${CSI}0G${prompt}${masked}`)
  }
  setRaw(false)
  showCursor()
  console.log(`\n${c.dim(`  ${sym.check}`)} ${label}: ${value ? c.dim('••••••') : c.dim('(skipped)')}`)
  return value
}

// ------------------------------------------------------------
// confirm
// ------------------------------------------------------------
export async function confirm({ label, default: def = true } = {}) {
  const yn = def ? 'Y/n' : 'y/N'
  hideCursor()
  process.stdout.write(`${c.cyan(sym.pointer)} ${c.bold(label)} ${c.dim(`[${yn}]`)} `)
  setRaw(true)
  let result = def
  while (true) {
    const key = await keypress()
    if (key === '\r' || key === '\n') break
    if (key === '\u0003') {
      setRaw(false)
      showCursor()
      process.exit(130)
    }
    if (key.toLowerCase() === 'y') {
      result = true
      break
    }
    if (key.toLowerCase() === 'n') {
      result = false
      break
    }
  }
  setRaw(false)
  showCursor()
  console.log(`${result ? c.green('yes') : c.yellow('no')}`)
  return result
}

// ------------------------------------------------------------
// select
// ------------------------------------------------------------
export async function select({ label, options, defaultIndex = 0 }) {
  const startRow = process.stdout.rows
  let cursor = defaultIndex
  const total = options.length

  const render = (first = false) => {
    if (!first) clearLines(total)
    const header = `${c.cyan(sym.pointer)} ${c.bold(label)}`
    console.log(header)
    options.forEach((opt, i) => {
      const isCursor = i === cursor
      const prefix = isCursor ? `${c.cyan(sym.pointer)} ` : '  '
      const hint = opt.hint ? c.dim(` — ${opt.hint}`) : ''
      const body = isCursor ? c.bold(c.cyan(opt.label)) : opt.label
      console.log(`${prefix}${body}${hint}`)
    })
  }

  hideCursor()
  setRaw(true)
  render(true)

  while (true) {
    const key = await keypress()
    if (key === '\u0003') {
      setRaw(false)
      showCursor()
      process.exit(130)
    }
    if (key === `${CSI}A`) cursor = (cursor - 1 + total) % total
    else if (key === `${CSI}B`) cursor = (cursor + 1) % total
    else if (key === '\r' || key === '\n') break
    else if (/^[0-9]$/.test(key)) {
      const n = Number(key) - 1
      if (n >= 0 && n < total) cursor = n
    }
    render()
  }

  setRaw(false)
  const chosen = options[cursor]
  clearLines(total)
  console.log(`${c.cyan(sym.pointer)} ${c.bold(label)} ${c.dim(sym.arrow)} ${c.bold(chosen.label)}`)
  showCursor()
  void startRow
  return chosen.value
}

// ------------------------------------------------------------
// multiselect
// ------------------------------------------------------------
export async function multiselect({ label, options, required = false }) {
  const state = options.map((o) => ({ ...o, selected: Boolean(o.checked) }))
  const total = state.length + 1
  let cursor = 0

  const render = (first = false) => {
    if (!first) clearLines(total)
    console.log(`${c.cyan(sym.pointer)} ${c.bold(label)} ${c.dim('(space = toggle · a = all · enter = confirm)')}`)
    state.forEach((opt, i) => {
      const isCursor = i === cursor
      const prefix = isCursor ? `${c.cyan(sym.pointer)} ` : '  '
      const box = opt.selected ? c.green(`[${sym.check}]`) : c.dim('[ ]')
      const hint = opt.hint ? c.dim(` — ${opt.hint}`) : ''
      const body = isCursor ? c.bold(c.cyan(opt.label)) : opt.label
      console.log(`${prefix}${box} ${body}${hint}`)
    })
    console.log(c.dim(`  ${state.filter((o) => o.selected).length} selected`))
  }

  hideCursor()
  setRaw(true)
  render(true)

  while (true) {
    const key = await keypress()
    if (key === '\u0003') {
      setRaw(false)
      showCursor()
      process.exit(130)
    }
    if (key === `${CSI}A`) cursor = (cursor - 1 + state.length) % state.length
    else if (key === `${CSI}B`) cursor = (cursor + 1) % state.length
    else if (key === ' ') state[cursor].selected = !state[cursor].selected
    else if (key.toLowerCase() === 'a') {
      const all = state.every((o) => o.selected)
      state.forEach((o) => (o.selected = !all))
    }
    else if (key === '\r' || key === '\n') {
      if (required && !state.some((o) => o.selected)) continue
      break
    }
    render()
  }

  setRaw(false)
  const picked = state.filter((o) => o.selected).map((o) => o.value)
  clearLines(total)
  console.log(`${c.cyan(sym.pointer)} ${c.bold(label)} ${c.dim(sym.arrow)} ${picked.length ? picked.join(', ') : c.dim('none')}`)
  showCursor()
  return picked
}
