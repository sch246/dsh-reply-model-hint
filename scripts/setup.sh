#!/usr/bin/env bash
# Install dsh-reply-model-hint: Host turn-stats patch + plugin build + profile link.
# Does NOT restart the web surface — the user restarts manually.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${DSH_PROFILE:-web}"
CHECKOUT="${DSH_CHECKOUT:-}"
for CANDIDATE in "$CHECKOUT" /root/deepseek-harness "$HOME/deepseek-harness"; do
  if [ -n "$CANDIDATE" ] && [ -d "$CANDIDATE/packages" ]; then
    CHECKOUT="$CANDIDATE"
    break
  fi
done
if [ -z "${CHECKOUT:-}" ] || [ ! -d "$CHECKOUT/packages" ]; then
  echo "setup: cannot locate the dsh checkout (set DSH_CHECKOUT)" >&2
  exit 1
fi
if ! git -C "$CHECKOUT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "setup: $CHECKOUT is not a git checkout" >&2
  exit 1
fi

PATCH="$REPO_DIR/patches/deepseek-harness.patch"
if [ ! -f "$PATCH" ]; then
  echo "setup: tracked harness patch is missing: $PATCH" >&2
  exit 1
fi

PATCH_SHA="$(sha256sum "$PATCH" | awk '{print $1}')"
STATE_FILE="$(git -C "$CHECKOUT" rev-parse --git-path dsh-reply-model-hint.patch-state)"
if [[ "$STATE_FILE" != /* ]]; then STATE_FILE="$CHECKOUT/$STATE_FILE"; fi
RECORDED_SHA=""
RECORDED_OWNED=""
if [ -f "$STATE_FILE" ]; then
  RECORDED_SHA="$(sed -n 's/^patch_sha256=//p' "$STATE_FILE")"
  RECORDED_OWNED="$(sed -n 's/^patch_applied_by_setup=//p' "$STATE_FILE")"
fi
PATCH_APPLIED_BY_SETUP=false

verify_source_markers() {
  local needle='@meta-intent:begin dsh-reply-model-hint'
  local paths=(
    packages/client/ui-chat/src/client/contract/slots.ts
    packages/client/ui-chat/src/client/chat/register-node-renderers.ts
    packages/client/ui-chat/src/client/chat/TurnTailNodeView.tsx
  )
  for path in "${paths[@]}"; do
    if ! grep -Fq "$needle" "$CHECKOUT/$path"; then
      echo "setup: ownership marker missing from $path" >&2
      return 1
    fi
  done
}

echo "checking tracked harness patch against $CHECKOUT..."
if git -C "$CHECKOUT" apply --unidiff-zero --check --reverse "$PATCH" 2>/dev/null; then
  if [ "$RECORDED_SHA" = "$PATCH_SHA" ] && [ "$RECORDED_OWNED" = "true" ]; then
    PATCH_APPLIED_BY_SETUP=true
    echo "harness patch already applied by an earlier run of this exact setup"
  else
    echo "harness patch already present; preserving ownership"
    PATCH_APPLIED_BY_SETUP=true
  fi
elif git -C "$CHECKOUT" apply --unidiff-zero --check "$PATCH"; then
  echo "applying harness patch..."
  git -C "$CHECKOUT" apply --unidiff-zero "$PATCH"
  PATCH_APPLIED_BY_SETUP=true
else
  echo "setup: neither the patch nor its exact reverse applies" >&2
  echo "setup: the target files overlap local changes or this DSH revision is unsupported" >&2
  exit 1
fi

verify_source_markers

{
  echo "patch_sha256=$PATCH_SHA"
  echo "patch_applied_by_setup=$PATCH_APPLIED_BY_SETUP"
  echo "host_head=$(git -C "$CHECKOUT" rev-parse HEAD)"
  echo "marker_schema=meta-intent-source-region/0.1"
  echo "regions=ui-chat.turn-stats"
} > "$STATE_FILE"

echo "regenerating shared client catalogs..."
(cd "$CHECKOUT" && pnpm run gen-client-catalog)

echo "rebuilding Host ui-chat + web frontend..."
(cd "$CHECKOUT" && pnpm --filter @deepseek-ai/dsh-client-ui-chat bundle)
(cd "$CHECKOUT" && pnpm run build:web)

echo "building dsh-reply-model-hint..."
DSH_CHECKOUT="$CHECKOUT" bash "$REPO_DIR/scripts/build.sh"

PROFILE_DIR="${DSH_HOME:-$HOME/.dsh}/profiles/$PROFILE"
if [ ! -f "$PROFILE_DIR/package.json" ]; then
  echo "setup: profile package missing: $PROFILE_DIR/package.json" >&2
  exit 1
fi

PKG_NAME='@dsh-external/dsh-reply-model-hint'
CHECKOUT_CLI="$CHECKOUT/apps/cli/lib/bin.js"

# Atomic profile transaction: dependency + lockfile + node_modules + Bundle
# together. Do not hand-edit package.json then hope pnpm install finishes —
# that is the Bundle-without-resolution half-install failure mode.
echo "registering bundle into profile '$PROFILE'..."
if command -v dsh >/dev/null 2>&1; then
  (cd "$REPO_DIR" && dsh plugin --profile "$PROFILE" add .)
elif command -v node >/dev/null 2>&1 && [ -f "$CHECKOUT_CLI" ]; then
  (cd "$REPO_DIR" && node "$CHECKOUT_CLI" plugin --profile "$PROFILE" add .)
elif command -v pnpm >/dev/null 2>&1; then
  (cd "$REPO_DIR" && pnpm --dir "$CHECKOUT" dsh plugin --profile "$PROFILE" add .)
else
  echo "setup: neither dsh nor pnpm is available; refuse hand-editing the profile" >&2
  echo "setup: install the CLI, then: cd $CHECKOUT && pnpm dsh plugin --profile $PROFILE add $REPO_DIR" >&2
  exit 1
fi

echo "cheap post-commit gates for $PKG_NAME..."
node - "$PROFILE_DIR/package.json" "$PROFILE_DIR/pnpm-lock.yaml" "$PROFILE_DIR/node_modules/$PKG_NAME" "$REPO_DIR" "$PKG_NAME" <<'NODE'
const fs = require('fs')
const path = require('path')
const [pkgPath, lockPath, nmPath, repo, name] = process.argv.slice(2)
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'))
const dep = pkg.dependencies?.[name]
const bundles = pkg.dsh?.profile?.bundles ?? []
const expectedLink = `link:${repo}`
const failures = []
if (dep !== expectedLink && dep !== `link:${path.resolve(repo)}`) {
  // accept either the raw path setup used or a resolved absolute link
  if (typeof dep !== 'string' || !dep.startsWith('link:')) {
    failures.push(`dependencies[${name}] missing or not a link: (got ${JSON.stringify(dep)})`)
  }
}
if (!bundles.includes(name)) {
  failures.push(`${name} absent from dsh.profile.bundles`)
}
if (!fs.existsSync(lockPath) || !fs.readFileSync(lockPath, 'utf8').includes(name)) {
  failures.push(`${name} absent from pnpm-lock.yaml (Bundle-without-resolution risk)`)
}
let resolved
try {
  resolved = fs.realpathSync(nmPath)
} catch {
  failures.push(`node_modules/${name} missing`)
}
if (resolved !== undefined) {
  const want = fs.realpathSync(repo)
  if (resolved !== want) {
    failures.push(`node_modules/${name} resolves to ${resolved}, expected ${want}`)
  }
}
if (failures.length) {
  console.error('setup: cheap gates failed:')
  for (const line of failures) console.error(`  - ${line}`)
  console.error('setup: profile is in a mixed state; reconcile before any web restart')
  process.exit(1)
}
console.log(`gates ok: dep=${dep}; bundle listed; lock+node_modules resolve to ${resolved}`)
NODE

if command -v dsh >/dev/null 2>&1; then
  dsh plugin --profile "$PROFILE" why "$PKG_NAME" || true
elif [ -f "$CHECKOUT_CLI" ]; then
  node "$CHECKOUT_CLI" plugin --profile "$PROFILE" why "$PKG_NAME" || true
fi

echo "setup complete. Restart the web surface manually to load the model pill."
echo "Expected order after restart: 模型名 · 用量 · 用时 · 时间"
