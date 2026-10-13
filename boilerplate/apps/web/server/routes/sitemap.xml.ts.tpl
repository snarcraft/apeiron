import { articles } from '~~/app/data/articles'

const routes = ['/', ...articles.map(article => `/${article.slug}`)]

export default defineEventHandler((event) => {
  setHeader(event, 'Content-Type', 'application/xml')

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${routes.map((route) => `  <url><loc>https://{{DOMAIN}}${route}</loc></url>`).join('\n')}
</urlset>`
}
