#!/bin/bash
# Build the Node no-op entry, browser declarations, and browser bundle against
# the linked DeepSeek Harness checkout.
# Requires DSH_CHECKOUT pointing at a dsh source checkout (auto-probe below).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CHECKOUT="${DSH_CHECKOUT:-}"
if [ -z "$CHECKOUT" ] || [ ! -d "$CHECKOUT/packages" ]; then
  for candidate in \
    "/root/deepseek-harness" \
    "$HOME/deepseek-harness" "$HOME/dsh-harness" "$HOME/dsh" "$HOME/.dsh/dsh-harness"; do
    if [ -d "$candidate/packages" ]; then CHECKOUT="$candidate"; break; fi
  done
fi
if [ -z "$CHECKOUT" ] || [ ! -d "$CHECKOUT/packages" ]; then
  echo "build: cannot locate the dsh checkout (set DSH_CHECKOUT)" >&2
  exit 1
fi

TSC="$CHECKOUT/node_modules/.bin/tsc"
TSDOWN="$CHECKOUT/node_modules/.bin/tsdown"
if [ ! -x "$TSC" ] && [ ! -f "$TSC.cmd" ]; then echo "build: tsc missing at $TSC" >&2; exit 1; fi
if [ ! -x "$TSDOWN" ] && [ ! -f "$TSDOWN.cmd" ]; then echo "build: tsdown missing at $TSDOWN" >&2; exit 1; fi

echo "=== Linking build dependencies (checkout: $CHECKOUT) ==="
node - "$CHECKOUT" <<'NODE'
const fs = require('fs')
const path = require('path')
const checkout = process.argv[2]
const nm = path.resolve('node_modules')
const aiDir = path.join(nm, '@deepseek-ai')

function link(relLinkDir, target) {
  const linkPath = path.resolve(relLinkDir)
  const targetPath = path.resolve(target)
  if (!fs.existsSync(targetPath)) {
    console.warn(`  skip missing: ${target} (${targetPath})`)
    return
  }
  fs.mkdirSync(path.dirname(linkPath), { recursive: true })
  fs.rmSync(linkPath, { recursive: true, force: true })
  fs.symlinkSync(targetPath, linkPath, process.platform === 'win32' ? 'junction' : 'dir')
}

// Link every @deepseek-ai/* workspace and vendor package by its package.json name.
function scanGroup(dir) {
  if (!fs.existsSync(dir)) return
  for (const group of fs.readdirSync(dir)) {
    const gd = path.join(dir, group)
    if (!fs.statSync(gd).isDirectory()) continue
    for (const pkg of fs.readdirSync(gd)) {
      const pd = path.join(gd, pkg)
      const pj = path.join(pd, 'package.json')
      if (!fs.existsSync(pj)) continue
      let name
      try { name = JSON.parse(fs.readFileSync(pj, 'utf8')).name } catch { continue }
      if (!name || !name.startsWith('@deepseek-ai/')) continue
      link(path.join(aiDir, name.slice('@deepseek-ai/'.length)), pd)
    }
  }
}
scanGroup(path.join(checkout, 'packages'))

// Vendor is flat: vendor/<pkg>/package.json.
if (fs.existsSync(path.join(checkout, 'vendor'))) {
  for (const pkg of fs.readdirSync(path.join(checkout, 'vendor'))) {
    const pd = path.join(checkout, 'vendor', pkg)
    const pj = path.join(pd, 'package.json')
    if (!fs.existsSync(pj)) continue
    let name
    try { name = JSON.parse(fs.readFileSync(pj, 'utf8')).name } catch { continue }
    if (!name || !name.startsWith('@deepseek-ai/')) continue
    link(path.join(aiDir, name.slice('@deepseek-ai/'.length)), pd)
  }
}

// React and ambient types, borrowed from the checkout's own node_modules.
link('node_modules/react', path.join(checkout, 'packages/client/ui-layout/node_modules/react'))
link('node_modules/@types/react', path.join(checkout, 'packages/client/ui-layout/node_modules/@types/react'))
link('node_modules/@types/node', path.join(checkout, 'node_modules/@types/node'))

// Make sure we have the expected deepseek-cordis link for host build.
if (!fs.existsSync(path.join(aiDir, 'cordis'))) {
  link(path.join(aiDir, 'cordis'), path.join(checkout, 'vendor/cordis'))
}
NODE

echo "=== Compiling src -> lib ==="
node -e "require('fs').rmSync('lib', { recursive: true, force: true })"
"$TSC" -p tsconfig.json
"$TSC" -p tsconfig.client.json --emitDeclarationOnly
"$TSDOWN" --config tsdown.config.ts
echo "=== Build complete ==="
