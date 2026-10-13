export default defineEventHandler((event) => {
  setHeader(event, 'Content-Type', 'text/plain')

  return `User-agent: *
Allow: /

# AI crawlers are welcome — llms.txt describes the product.
User-agent: GPTBot
Allow: /
User-agent: ClaudeBot
Allow: /
User-agent: Google-Extended
Allow: /

Sitemap: https://{{DOMAIN}}/sitemap.xml
`
})
