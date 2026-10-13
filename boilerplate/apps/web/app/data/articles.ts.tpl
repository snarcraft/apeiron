// ============================================================
// articles.ts — the content-page registry
// ============================================================
// Content pages (guides, posts, legal…) are ONE FILE PER
// LANGUAGE at the page root, named by slugifying the title in
// that language. The copy lives raw inside the page so it can
// embed any markup — the shell guarantees the same design.
//
// This registry is the only mapping surface: translations link
// to each other, the sitemap and llms.txt list every slug, and
// the language switcher navigates between translated slugs.

export interface Article {
  /** the page slug — must match the file name in app/pages/ */
  slug: string
  /** IETF lang of this edition */
  lang: string
  title: string
  description: string
  date?: string
  /** lang → slug of the other editions */
  translations: Record<string, string>
}

export const articles: Article[] = [
  {
    slug: 'getting-started',
    lang: '{{DEFAULT_LOCALE}}',
    title: 'Getting started with {{APP_TITLE}}',
    description: 'From scaffold to first feature — the ten-minute tour of the platform.',
    date: '{{YEAR}}-01-15',
    translations: { fr: 'demarrer' }
  },
  {
    slug: 'demarrer',
    lang: 'fr',
    title: 'Démarrer avec {{APP_TITLE}}',
    description: 'Du scaffold à la première fonctionnalité — la visite de dix minutes de la plateforme.',
    date: '{{YEAR}}-01-15',
    translations: { en: 'getting-started' }
  }
]

export function findArticle(slug: string): Article | undefined {
  return articles.find(article => article.slug === slug)
}

export function articleAlternates(article: Article) {
  return Object.entries(article.translations).map(([lang, slug]) => ({
    lang,
    to: `/${slug}`
  }))
}
