#!/usr/bin/env node

// ============================================================
// watch-assets.mjs — brand icon hot-reload
// ============================================================
// Drop a new assets/icon.svg and every PWA size + manifest
// regenerates into web/frontend/backend public dirs while this
// runs. Ctrl-C to stop. (chokidar ships in the workspace root.)

import chokidar from 'chokidar'
import { execSync } from 'node:child_process'

const run = () => {
  try {
    execSync('pnpm generate:assets', { stdio: 'inherit' })
    console.log('\x1b[2m◆ assets regenerated\x1b[0m')
  } catch {
    console.log('\x1b[31m✖ generation failed\x1b[0m')
  }
}

console.log('◆ watching assets/icon.svg — save a new icon to regenerate')
run()

chokidar
  .watch('assets/icon.svg', { ignoreInitial: true })
  .on('change', run)
  .on('add', run)
