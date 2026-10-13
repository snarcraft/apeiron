# Styling — the design system

Every project gets a **different face on the same skeleton**. The
skeleton (anatomy, conventions, utilities) is fixed; the face
(palette, type, texture, motion) is generated per project at
scaffold time and lives here as **souls**.

## The two layers

| Layer | Where | Changes per project? |
|---|---|---|
| Anatomy | `boilerplate/apps/web` components | No — Hero → Marquee → Features → Steps → Pricing → FAQ → Contact |
| Skin | `souls/<name>/{web.css, app.css, Hero.vue}` | Yes — palette, fonts, keyframes, surfaces |

A soul restyles the shared components through a small contract of
CSS classes that every soul must define:

- `.soul-card` — the surface for feature/pricing cards (hover included)
- `.soul-hero-bg` — hero background texture
- `.soul-grad-text` — the accent span inside the H1
- `.soul-chip` — icon chip (hover via `.group:hover`)
- `.soul-ghost` — oversized ghost numerals
- `.soul-mono` — the section eyebrow label
- `.soul-display` — display type (only editorial uses a second face)
- `.bg-dots` — dotted texture (auth screens, empty states)
- `hero-rise` keyframe — entrance animation for hero children

Components reference only these + Nuxt UI semantic utilities
(`text-muted`, `text-highlighted`, `border-default`, `bg-elevated`
…). No soul ships hardcoded hex below the token layer.

## Palettes

Palettes are generated in **oklch** with gamut mapping
(`lib/oklch.mjs`) — pick a hue, receive a full 50–950 scale that
is guaranteed displayable. Both `apps/web` and `apps/frontend`
receive the same tokens, so the product and its website read as
one brand. The webapp can override tokens per tenant at runtime
(`:root` injection in `app.vue`).

To retune a palette later: edit the oklch values in
`apps/*/app/assets/css/main.css` — nothing else needs to move.

## The souls

| Soul | Color mode | Type | Mood |
|---|---|---|---|
| `aurora` | system | Geist | floating light orbs, glass, gradient headlines — calm premium |
| `blueprint` | light | IBM Plex | fine grids, mono labels, square corners — engineered |
| `editorial` | light | Inter + DM Serif Display | journal rules, serif display — gravitas |
| `neon` | dark | Space Grotesk + JetBrains Mono | glow borders, electric gradients — devtools nightlife |

Adding a soul: new folder with `web.css`, `app.css`, `Hero.vue`
implementing the contract above, plus an entry in the `SOULS`
table of `scaffold.mjs`.

## House rules (all souls)

1. Motion is always opt-out safe: every animation pairs with
   `motion-safe:` or `prefers-reduced-motion` handling.
2. `singleAttributePerLine` in templates; Prettier owns layout.
3. Icons are lucide (`i-lucide-*`), colored via currentColor.
4. Ghost numbers and stat bands for rhythm; never more than one
   gradient text span per viewport.
5. Copy IS design: short lines, confident tone, no exclamation
   marks.
