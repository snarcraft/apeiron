# Website conventions — apps/web

Nuxt static · Nuxt UI · prerendered + CDN'd assets.

## Content: two tiers

| Tier | Examples | How |
|---|---|---|
| **Common pages** | landing (`index`), contact | Translatable components — copy via `t('…')` from `i18n/locales/*.json` |
| **Content pages** | guides, articles, legal | ONE FILE PER LANGUAGE at the page root, named by slugifying the title in that language (e.g. `getting-started.vue` / `demarrer.vue`). Copy lives **raw** in the file so any markup embeds directly |

Content-page rules:

1. Every edition uses `ArticleShell` — the shell owns typography
   and spacing, so **every language renders the same design**.
2. Register each edition in `app/data/articles.ts` (slug, lang,
   title, description, date, `translations` map). The registry
   drives the sitemap, `llms.txt` and the per-article language
   switcher; `ArticleShell` emits `hreflang` alternates +
   canonical automatically.
3. Raw means raw: write the text with inline tags
   (`<strong>`, `<a>`, `<blockquote>`…) inside the shell's slot —
   never wrap prose in components.
4. Slugs are the title, slugified, in the page's own language —
   never machine-translated paths.

## Anatomy (fixed)

`Hero → Features → Steps → Pricing → FAQ → Contact` — the section
order never changes across projects; the **soul** changes how each
looks. Components reference only `soul-*` classes + Nuxt UI
utilities, so a soul swap restyles the whole site.

## House rules

- **Static only**: everything prerenders (`crawlLinks: true`).
  The single runtime dependency is the contact form →
  `/api/contacts` (proxied). If a page needs an API at runtime,
  it belongs in the webapp, not here.
- **Copy IS design — and it is translated**: every user-facing
  string goes through `t('…')`; the dictionary lives in
  `i18n/locales/<locale>.json` (generated at scaffold, en + fr
  seeded). Sections reference keys, never literals. Short lines,
  confident tone, no exclamation marks.
- **Motion**: CSS keyframes + `motion-safe:` always paired with
  `motion-reduce:` handling. `Reveal.vue` (IntersectionObserver)
  for scroll entrances. No JS animation libraries.
- **SEO per page**: `useSeoMeta` + canonical + FAQPage JSON-LD on
  the landing. `server/routes/` provides `sitemap.xml`,
  `robots.txt` (AI-crawler friendly) and `llms.txt`.
- **Icons**: lucide (`i-lucide-*`), sized `size-4/5`, colored by
  currentColor.
- **Fonts self-host** via @nuxt/fonts — never link Google Fonts.
- **Definition of Done**: `lint`, `typecheck`, `generate` all
  green; meta complete; no runtime console errors; the page works
  with JS disabled except the contact form.

## Commands

```bash
pnpm --filter "@{{APP_NAME}}/web" dev         # http://localhost:3001
pnpm --filter "@{{APP_NAME}}/web" generate    # static build
```
