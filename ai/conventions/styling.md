# Styling conventions — all surfaces

Tailwind v4, CSS-first. The design system is **tokens → souls →
semantic utilities**.

## Tokens

`apps/*/app/assets/css/main.css` holds the generated palette:

```css
@theme static {
  --font-sans: …;
  --color-primary-50: oklch(97.7% 0.014 300);
  /* … 50 → 950 */
}
```

Rules:

1. Never hardcode `#hex` or `oklch(...)` inside components —
   reference `primary-*`/`secondary-*` or Nuxt UI semantic vars.
2. Retune palettes by editing the token block only.
3. Fonts: `--font-sans` / `--font-mono` (+ `--font-display` for
   editorial souls). Self-hosted automatically by @nuxt/fonts.

## Souls

The landing's skin is one of four souls (aurora, blueprint,
editorial, neon). Souls implement the class contract
(`soul-card`, `soul-hero-bg`, `soul-grad-text`, `soul-chip`,
`soul-ghost`, `soul-mono`) — shared components never know which
soul is live.

## Idioms (every soul)

- Cards hover: lift or edge-change, never color-flip.
- Ghost numerals (`soul-ghost`) for section rhythm and stat bands.
- One gradient text span per viewport, maximum.
- Icon chips grow/tilt on `group-hover`.
- Motion always opt-out safe (`motion-safe:` / `motion-reduce:`).
- Dark mode via tokens — `dark:` overrides are a smell; fix the
  token instead.

## Formatting

Prettier + `prettier-plugin-tailwindcss` (anchored to
`apps/frontend/app/assets/css/main.css`) sorts classes — never
reorder by hand. `singleAttributePerLine: true` in templates.
