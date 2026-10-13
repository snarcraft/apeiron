// ============================================================
// oklch.mjs — perceptual palette engine (zero dependencies)
// ============================================================
// Generates a full 50–950 oklch scale from a single hue, with
// gamut mapping so every step is a displayable sRGB color. The
// output strings drop straight into Tailwind v4 `@theme` blocks:
//
//   --color-primary-500: oklch(64.5% 0.222 286);
//
// Lightness and chroma curves follow hand-tuned ramps (peak
// chroma at 600, deep saturated 950) so palettes feel like a
// designer made them, not a linear interpolation.

const GAMMA = 2.4
const EOTF = 0.2126 / 0.0521 // linear threshold helper constants
const ALPHA = 1.055
const BETA = 0.055

export function srgbTransfer(v) {
  if (v <= 0.0031308) return 12.92 * v
  return ALPHA * Math.pow(v, 1 / GAMMA) - BETA
}

export function oklabToLinearSrgb(L, a, b) {
  const l_ = L + 0.3963377774 * a + 0.2158037573 * b
  const m_ = L - 0.1055613458 * a - 0.0638541728 * b
  const s_ = L - 0.0894841775 * a - 1.291485548 * b

  const l = l_ * l_ * l_
  const m = m_ * m_ * m_
  const s = s_ * s_ * s_

  return [
    +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s,
  ]
}

export function oklchToRgb(L, C, H) {
  const rad = (H * Math.PI) / 180
  const linear = oklabToLinearSrgb(L, Math.cos(rad) * C, Math.sin(rad) * C)
  return linear.map((v) => {
    const e = srgbTransfer(v)
    return Math.min(1, Math.max(0, e)) * 255
  })
}

function inGamut(L, C, H) {
  const linear = oklabToLinearSrgb(L, Math.cos((H * Math.PI) / 180) * C, Math.sin((H * Math.PI) / 180) * C)
  return linear.every((v) => v >= -0.001 && v <= 1.001)
}

// Binary-search the largest chroma that stays inside sRGB.
function gamutFit(L, C, H) {
  if (inGamut(L, C, H)) return C
  let lo = 0
  let hi = C
  for (let i = 0; i < 22; i++) {
    const mid = (lo + hi) / 2
    if (inGamut(L, mid, H)) lo = mid
    else hi = mid
  }
  return lo
}

// Hand-tuned ramp: [step, lightness, target chroma]. Chroma peaks
// at 600 (the vivid zone) and recovers at 950 (deep but saturated).
const RAMP = [
  [50, 0.977, 0.018],
  [100, 0.946, 0.034],
  [200, 0.901, 0.058],
  [300, 0.846, 0.094],
  [400, 0.778, 0.132],
  [500, 0.702, 0.166],
  [600, 0.626, 0.185],
  [700, 0.551, 0.178],
  [800, 0.482, 0.158],
  [900, 0.423, 0.142],
  [950, 0.298, 0.112],
]

function fmt(n) {
  // Three decimals — light steps carry chroma as fine as 0.014,
  // and rounding those away flattens the whole ramp.
  return String(Math.round(n * 1000) / 1000)
}

export function scale(hue, { vibrancy = 1 } = {}) {
  const steps = {}
  for (const [step, L, C] of RAMP) {
    const c = gamutFit(L, C * vibrancy, hue)
    steps[step] = {
      oklch: `oklch(${Math.round(L * 1000) / 10}% ${fmt(c)} ${Math.round(hue)})`,
      rgb: oklchToRgb(L, c, hue),
    }
  }
  return steps
}

export function toHex([r, g, b]) {
  return (
    '#' +
    [r, g, b]
      .map((v) => Math.round(v).toString(16).padStart(2, '0'))
      .join('')
  )
}

// Tailwind @theme block, ready to paste into main.css.
export function themeBlock(name, steps) {
  return RAMP.map(([step]) => `  --color-${name}-${step}: ${steps[step].oklch};`).join('\n')
}

// Truecolor ANSI ramp — prints the palette in the terminal.
export function ansiRamp(steps, width = 3) {
  return RAMP.map(([step]) => {
    const [r, g, b] = steps[step].rgb.map(Math.round)
    return `\x1b[48;2;${r};${g};${b}m${' '.repeat(width)}\x1b[0m`
  }).join('')
}

export function ansiSwatch([r, g, b], char = '█') {
  return `\x1b[38;2;${Math.round(r)};${Math.round(g)};${Math.round(b)}m${char}\x1b[0m`
}

// Named hues tuned to feel premium; keys are shown in the CLI.
export const NAMED_HUES = {
  iris: { hue: 286, hint: 'electric violet — the Normatek signature' },
  violet: { hue: 300, hint: 'regal purple' },
  indigo: { hue: 268, hint: 'deep blue-violet' },
  blue: { hue: 255, hint: 'confident product blue' },
  sky: { hue: 212, hint: 'light, airy interface blue' },
  teal: { hue: 190, hint: 'calm technical cyan-teal' },
  emerald: { hue: 160, hint: 'growth green' },
  lime: { hue: 125, hint: 'energetic yellow-green' },
  amber: { hue: 75, hint: 'warm golden accent' },
  orange: { hue: 55, hint: 'friendly high-energy' },
  crimson: { hue: 22, hint: 'urgent, passionate red' },
  rose: { hue: 8, hint: 'soft warm pink-red' },
  magenta: { hue: 330, hint: 'bold statement pink' },
}

export function suggestSecondaryHue(hue) {
  // Complementary-ish split: +150° keeps both colors related but distinct.
  return (hue + 150) % 360
}

export function randomHuePair() {
  const hue = Math.floor(Math.random() * 360)
  return [hue, suggestSecondaryHue(hue)]
}
