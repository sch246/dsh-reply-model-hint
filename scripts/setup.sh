#!/usr/bin/env bash
# Install dsh-reply-model-hint: Host turn-stats patch + plugin build + profile link.
# Does NOT restart the web surface — the user restarts manually.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${DSH_PROFILE:?set DSH_PROFILE}"
CHECKOUT="${DSH_CHECKOUT:?set DSH_CHECKOUT}"
: "${DSH_HOME:?set DSH_HOME}"
MODE="${1:---check}"
if [ "$#" -gt 1 ] || { [ "$MODE" != --check ] && [ "$MODE" != --install ]; }; then
  echo "usage: setup.sh [--check|--install]" >&2; exit 1
fi
node "$REPO_DIR/scripts/profile.mjs" inspect
PACKAGE_DIR="$REPO_DIR/packages/dsh-reply-model-hint"
if ! git -C "$CHECKOUT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "setup: $CHECKOUT is not a git checkout" >&2
  exit 1
fi

PATCH="$PACKAGE_DIR/patches/deepseek-harness.patch"
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
    PATCH_APPLIED_BY_SETUP=false
  fi
elif git -C "$CHECKOUT" apply --unidiff-zero --check "$PATCH"; then
  if [ "$MODE" = --check ]; then echo "setup: Host patch is applicable; no changes made"; exit 0; fi
  echo "applying harness patch..."
  git -C "$CHECKOUT" apply --unidiff-zero "$PATCH"
  PATCH_APPLIED_BY_SETUP=true
else
  echo "setup: neither the patch nor its exact reverse applies" >&2
  echo "setup: the target files overlap local changes or this DSH revision is unsupported" >&2
  exit 1
fi

verify_source_markers
if [ "$MODE" = --check ]; then echo "setup: Host patch is present; no changes made"; exit 0; fi

{
  echo "patch_sha256=$PATCH_SHA"
  echo "patch_applied_by_setup=$PATCH_APPLIED_BY_SETUP"
  echo "host_head=$(git -C "$CHECKOUT" rev-parse HEAD)"
  echo "marker_schema=meta-intent-source-region/0.1"
  echo "regions=ui-chat.turn-stats"
} > "$STATE_FILE"

echo "regenerating shared client catalogs..."
(cd "$CHECKOUT" && node --import tsx/esm scripts/gen-client-catalog.ts)

echo "rebuilding Host ui-chat + web frontend..."
(cd "$CHECKOUT" && node ./node_modules/tsdown/dist/run.mjs --config packages/client/ui-chat/tsdown.config.ts)
(cd "$CHECKOUT/apps/web" && node ./node_modules/vite/bin/vite.js build)

echo "building dsh-reply-model-hint..."
DSH_CHECKOUT="$CHECKOUT" node "$REPO_DIR/scripts/build.mjs"

node "$REPO_DIR/scripts/profile.mjs" setup --install

echo "setup complete; activation requires a separate authorized restart."
