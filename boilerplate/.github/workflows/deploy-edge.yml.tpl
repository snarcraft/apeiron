name: Deploy (edge)

# Website-only platforms ship as static files to Cloudflare
# Pages — the free, global edge. No Docker, no EC2, no swarm:
# generate, upload, done. main and tags both land on the
# production channel.

on:
  workflow_dispatch:
  push:
    branches:
      - main
    tags:
      - 'v*'

concurrency:
  group: deploy
  cancel-in-progress: false

jobs:
  deploy:
    name: Cloudflare Pages
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: pnpm

      - name: Install dependencies
        run: pnpm install

      - name: Generate the static site
        run: pnpm --filter "@{{APP_NAME}}/web" generate

      - name: Ensure pages project + custom domain
        id: edge
        env:
          CF_DNS_API_TOKEN: ${{ secrets.CF_DNS_API_TOKEN }}
        run: node scripts/edge.mjs

      - name: Upload to the edge
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CF_DNS_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ steps.edge.outputs.account }}
        run: npx wrangler pages deploy apps/web/.output/public --project-name {{APP_NAME}}-web --branch main

      - name: Notify Discord
        uses: ./.github/actions/notify-discord
        if: always()
        with:
          service: web (edge)
          sha: ${{ github.sha }}
          branch: ${{ github.ref_name }}
          registry: pages
          repository: ${{ github.repository }}
          app-name: ${{ vars.APP_NAME }}
          app-env: production
          app-version: ${{ vars.APP_VERSION }}
          discord-webhook-url: ${{ secrets.DISCORD_SERVER_WEBHOOK_URL }}
          discord-user-id: ${{ secrets.DISCORD_USER_ID }}
