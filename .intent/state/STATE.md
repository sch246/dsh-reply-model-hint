# dsh-reply-model-hint intent

Status: live install guide for DeepSeek Harness `dsh-v0.1.2-alpha.2` (`0a53fb55bea101816fa226bb964ae2bed71c343b`).

## Map entry

Use [Agent install](#agent-install-do-not-restart-unless-asked), [Changed Host and composition](#changed-host-and-composition) and [Uninstall route](#uninstall-route) for the selected deployment. This repository has a Markdown STATE without STATE.json or a selected protocol.

## Workspace operations

The repository root is a private development workspace; `packages/dsh-reply-model-hint/` is the sole installable package. The npm name, package version, Bundle identity and public exports remain independent of other repositories. Source, build configs, tests, resources and output belong to that package; `.intent/`, Agent guidance and operation scripts stay at the repository root. There is no runtime forwarding package at the root. Self-owned code uses MIT; Host patch excerpts retain their upstream license where present.

Run the following from this repository root, with absolute paths for the selected Harness checkout and Home and one explicit profile name:

```sh
export DSH_CHECKOUT=/absolute/harness
export DSH_HOME=/absolute/home
export DSH_PROFILE=web
npm run build
npm run setup
npm run setup -- --install
npm run inspect
npm run remove
npm run remove -- --remove
```

`setup` and `remove` default to checks; only `--install` and `--remove` write. `inspect` reads the profile manifest, lockfile and resolved package without initializing the profile or reconciling its Bundle list. Build requires prepared Host declarations and this workspace's installed development tools; prepare dependencies explicitly with `pnpm install --ignore-scripts`. Local TypeScript is pinned to 5.9.3 and tsdown, where used, to 0.22.14; commands invoke Node tools directly and do not install dependencies.

Installation uses the built CLI at `$DSH_CHECKOUT/apps/cli/lib/bin.js` and the selected `DSH_HOME`/`DSH_PROFILE`, never an unrelated PATH CLI. It adds the absolute `packages/dsh-reply-model-hint/` path through `dsh plugin`; removal uses the same transaction. The transaction owns dependency, pnpm lockfile, resolution and Bundle changes. When the selected Host support is already prepared and its ownership has been checked, `node scripts/profile.mjs setup --install` performs only the profile transaction; `node scripts/profile.mjs remove --remove` removes only that profile policy while retaining shared Host support. After installation, `inspect` must name the selected package directory, one Bundle and a matching lock entry. After removal, dependency, resolution and Bundle must be absent; retained transitive consumers require investigation. No operation restarts a service.

For an existing root-package installation, inspect the current profile and retain its overrides, runtime data and existing Host receipt. Build the candidate, then use `setup --install` to replace the old root `link:`/`file:` coordinate with the child package through the selected CLI. Do not hand-edit only the Bundle or manifest. Update consumer-owned build aliases, scripts and paths that read the old root `src/`, `lib/` or patch locations; stable npm imports remain unchanged. A prior build or historical receipt does not establish acceptance of the changed profile. Probe changed composition in a private Home with the target package set before an authorized managed activation.

## Intent

Show which model produced each completed assistant reply, as a muted pill in the same IconActions row as the shipped usage / duration / clock, in this order:

`模型名 · 用量 · 用时 · 时间`

The pill must read as part of that stock stats cluster — same visual weight, hover geometry, and spacing rhythm as the neighboring usage/time controls — not as a heavier or larger capsule beside them. Exact CSS that achieves the match is Host-revision evidence (see Resources), not a portable styling checklist.

## Why a Host patch exists

On the recorded alpha.2 target, `TurnTailNodeView` hardcodes `TurnUsagePanel` / `TurnTimePanel` inside `usageAction`. The public `assistant-actions` list renders *before* that whole `usageAction` block, so a plugin cannot sit between model and 用量 without a Host change. Realization therefore owns a small list slot `conversation.chat.turn-stats`, rendered **inside** `usageAction` immediately before usage/time. A future native slot may replace the patch if it preserves the same placement; the alpha.2 `assistant-actions` and `turnTail` positions do not.

## Acceptance

- `HINT-001`: Every completed turn with an `assistant/message` shows that message's `source.model` as a pill immediately before the usage pill.
- `HINT-002`: Hover title shows `provider · model`.
- `HINT-003`: Turns whose `turn/start` is outside the loaded window may omit the pill (no crash).
- `HINT-004`: Uninstall restores the stock usage/time row and removes this package’s unused owned slot declaration. A native or shared slot remains with its owner and remaining consumers.
- `HINT-005`: At rest and on hover, the model pill matches the shipped 用量 / 用时 pills' visual weight and cluster spacing so the four-part row looks cohesive; a one-size-larger hover capsule fails this criterion.

## Realization (alpha.2)

### Host patch

- File: [patches/deepseek-harness.patch](../../packages/dsh-reply-model-hint/patches/deepseek-harness.patch), recorded against the HEAD above. Recheck actual Host source and applicability on each target; a matching diff alone does not establish equivalent behavior.
- Owned paths (markers `@meta-intent:begin/end dsh-reply-model-hint …`):
  - `packages/client/ui-chat/src/client/contract/slots.ts` — declares `conversation.chat.turn-stats`
  - `packages/client/ui-chat/src/client/chat/register-node-renderers.ts` — child of turn-tail
  - `packages/client/ui-chat/src/client/chat/TurnTailNodeView.tsx` — renders the list before usage/time
- Setup writes a receipt at the checkout git path `dsh-reply-model-hint.patch-state` (patch sha + Host HEAD). An exact patch that predates setup without an owned receipt retains external ownership. Historical receipts that claimed ownership for such a patch require pre-install evidence; their flag alone cannot establish removal authority.

### Plugin package

- Path: `packages/dsh-reply-model-hint/` (profile `link:` target)
- Browser half: Conversation Definition kind/key `reply-model` (reads `assistant/message` → `source.{provider,model}`) + list entry `id: reply-model` on `conversation.chat.turn-stats`
- Bundle patch: `cordis.patch.yml` inserts row `reply-model-hint`
- Official out-of-tree path only (`dsh.bundle.patch` + `dsh.client` + profile `link:` + `dsh.profile.bundles`). No super-injector / `dev_*`.

## Agent install (do not restart unless asked)

For the matching alpha.2 route, use the [owned installer](../../scripts/setup.sh); inspect a changed Host before reusing its steps. Profile registration must go through `dsh plugin` (atomic dependency + lockfile + `node_modules` + Bundle). Do not hand-edit `package.json` then `pnpm install` — that half-install left a Bundle row without resolution and knocked over managed web once already.

Use `npm run setup` to check the selected target, or `npm run setup -- --install` to apply the owned patch, regenerate the shared client catalog, rebuild ui-chat/Web and the plugin, then transact the child package into the profile. All three environment variables in Workspace operations are required. Setup reports a missing, overlapping or unsupported patch without silently choosing another checkout. It preserves an already present patch's external ownership and never restarts Web.

Use the deployment’s applicable installation policy for first-time live Bundle changes. Its policy and existing task authorization govern the operation; this map does not create a permanent risk tier or a new approval requirement.

After setup: **user** restarts web and checks `HINT-001`…`HINT-002` and `HINT-005`. Agent diagnoses only if the pill is still missing or visually off post-restart (profile boot / served `lib/client.js` / console / stale immutable `rev` cache) — still no restart unless asked.

## Changed Host and composition

Inspect the current turn-tail renderer, action slots, message provenance and stock usage/time styling. If an upstream slot now provides the required placement, consume it and retire this package's redundant declaration/rendering patch instead of maintaining two slots. Otherwise adapt only the missing slot. Other chat plugins can share those source files and list entries; preserve their contributions and regenerate `gen-client-catalog` from all current source. Keep one `reply-model` definition/list entry and one profile Bundle row.

For a source/build change, [build.sh](../../scripts/build.mjs) compiles Host/browser declarations and bundles. Observe HINT-001–005 in the loaded window, including a missing turn-start and hover at narrow width; use the model recorded on the completed assistant message rather than a currently selected composer model. On a missing or stale pill, inspect the served client and content revision before assuming a source failure. A map-only edit requires link/diff checks, not a live rebuild or browser restart.

## Uninstall route

`npm run remove -- --remove` removes this plugin through the selected profile transaction and retains Host support. For complete owned-source removal, inspect the receipt, pre-install evidence and current consumers before reversing source; an exact reverse check proves byte applicability, not ownership. Where this package demonstrably owns the complete unchanged patch, use the same zero-context mode as setup from this repository root:

```sh
git -C /root/deepseek-harness apply --unidiff-zero --check --reverse "$PWD/packages/dsh-reply-model-hint/patches/deepseek-harness.patch"
git -C /root/deepseek-harness apply --unidiff-zero --reverse "$PWD/packages/dsh-reply-model-hint/patches/deepseek-harness.patch"
```

Then, in the selected checkout, run `pnpm run gen-client-catalog`, `pnpm --filter @deepseek-ai/dsh-client-ui-chat bundle` and `pnpm run build:web`. Remove the selected profile package with `dsh plugin --profile web remove @dsh-external/dsh-reply-model-hint`, using the selected checkout CLI. Confirm package absence from dependency/lock/resolution/Bundle and no model pill after authorized activation. Remove the obsolete private receipt only after successful owned removal. If the slot predates this package or another consumer needs it, preserve it and remove only this plugin's contribution; investigate ambiguous ownership or drift instead of reversing third-party changes.

## Resources

- Visual cohesion for the model pill is required by Intent / `HINT-005`. The alpha.2 CSS that satisfied it (span `border-box`, usage/time-matched geometry, `-6px` adjacent rebate, immutable-rev cache note) is recorded in [`.intent/logs/2026-09-01-turn-stats-pill-visual-alignment.md`](../logs/2026-09-01-turn-stats-pill-visual-alignment.md) (`SRC-2026-09-01-TURN-STATS-PILL-VISUAL-ALIGNMENT`). Treat that log as revision-bound evidence: re-check siblings on a new Host instead of promoting its properties into this state.
- The current [setup gates](../../scripts/setup.sh) check dependency, lockfile, resolved package and Bundle agreement after the profile transaction. Their failure indicates a partial installation; repair that state before activation.
- The [formal checkout decision](../logs/2026-09-02-formal-checkout-selection.md) preserves the user’s explicit default-target choice.
- The [2026-09-06 map review](../logs/2026-09-06-installation-maintenance-map.md) records source inspection and remaining evidence limits.

## Non-goals

- Replacing TurnUsagePanel / TurnTimePanel.
- Session-header / composer model seat.
- Super-injector / `dev_*` injection path.
