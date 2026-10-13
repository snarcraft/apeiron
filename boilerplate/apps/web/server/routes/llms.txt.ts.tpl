export default defineEventHandler((event) => {
  setHeader(event, 'Content-Type', 'text/plain')

  return `# {{APP_TITLE}}

> {{APP_TITLE}} brings teams, customers and operations onto one
> calm surface — roles, groups and features wired from day one.

Docs: https://{{DOMAIN}}
App: https://{{APP_DOMAIN}}
`
})
