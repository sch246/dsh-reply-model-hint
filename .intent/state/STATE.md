# dsh-reply-model-hint intent

Status: live install guide for DeepSeek Harness `dsh-v0.1.2-alpha.2` (`0a53fb55bea101816fa226bb964ae2bed71c343b`).

## Intent

Show which model produced each completed assistant reply, as a muted pill in the same IconActions row as the shipped usage / duration / clock, in this order:

`模型名 · 用量 · 用时 · 时间`

The pill must read as part of that stock stats cluster — same visual weight, hover geometry, and spacing rhythm as the neighboring usage/time controls — not as a heavier or larger capsule beside them. Exact CSS that achieves the match is Host-revision evidence (see Resources), not a portable styling checklist.

## Why a Host patch exists

Stock `TurnTailNodeView` hardcodes `TurnUsagePanel` / `TurnTimePanel` inside `usageAction`. The public `assistant-actions` list renders *before* that whole `usageAction` block, so a plugin cannot sit between model and 用量 without a Host change. Realization therefore owns a small list slot `conversation.chat.turn-stats`, rendered **inside** `usageAction` immediately before usage/time. Do not “simplify” back onto `assistant-actions` or `turnTail` — that reorders the row wrong.

## Acceptance

- `HINT-001`: Every completed turn with an `assistant/message` shows that message's `source.model` as a pill immediately before the usage pill.
- `HINT-002`: Hover title shows `provider · model`.
- `HINT-003`: Turns whose `turn/start` is outside the loaded window may omit the pill (no crash).
- `HINT-004`: Uninstall / reverse of the Host patch restores the stock usage/time row with no leftover slot declaration.
- `HINT-005`: At rest and on hover, the model pill matches the shipped 用量 / 用时 pills' visual weight and cluster spacing so the four-part row looks cohesive; a one-size-larger hover capsule fails this criterion.

## Realization (alpha.2)

### Host patch

- File: `patches/deepseek-harness.patch` (apply only against the pinned HEAD above)
- Owned paths (markers `@meta-intent:begin/end dsh-reply-model-hint …`):
  - `packages/client/ui-chat/src/client/contract/slots.ts` — declares `conversation.chat.turn-stats`
  - `packages/client/ui-chat/src/client/chat/register-node-renderers.ts` — child of turn-tail
  - `packages/client/ui-chat/src/client/chat/TurnTailNodeView.tsx` — renders the list before usage/time
- Setup writes an ownership receipt at the checkout git path `dsh-reply-model-hint.patch-state` (patch sha + Host HEAD). Prefer that receipt over re-deriving ownership.

### Plugin package

- Path: this repo (profile `link:` target)
- Browser half: Conversation Definition kind/key `reply-model` (reads `assistant/message` → `source.{provider,model}`) + list entry `id: reply-model` on `conversation.chat.turn-stats`
- Bundle patch: `cordis.patch.yml` inserts row `reply-model-hint`
- Official out-of-tree path only (`dsh.bundle.patch` + `dsh.client` + profile `link:` + `dsh.profile.bundles`). No super-injector / `dev_*`.

## Agent install (do not restart unless asked)

Authority: run the owned installer; do not hand-replay its steps unless it fails. Profile registration must go through `dsh plugin` (atomic dependency + lockfile + `node_modules` + Bundle). Do not hand-edit `package.json` then `pnpm install` — that half-install left a Bundle row without resolution and knocked over managed web once already.

```sh
DSH_CHECKOUT=/root/deepseek-harness bash /root/dsh-reply-model-hint/scripts/setup.sh
```

Checkout selection inside the script: an explicit valid `DSH_CHECKOUT` → `/root/deepseek-harness` (or the equivalent home checkout). Temporary candidate worktrees are never implicit fallback targets. Profile defaults to `web` under `$DSH_HOME` (else `~/.dsh`).

What setup already does: reverse-check or apply the Host patch → verify markers → `gen-client-catalog` → rebuild `@deepseek-ai/dsh-client-ui-chat` + `build:web` → `scripts/build.sh` for this plugin → `dsh plugin --profile <name> add .` → cheap gates (`why` / lock / `node_modules` / Bundle). It never restarts the web surface. Gate failure means mixed state: reconcile before any restart discussion.

First-time Bundle membership on a managed Web host is **high-risk** under `dsh-manage-plugin-changes` (private-Home boot probe before touching live profile when that skill applies). Routine rebuilds of this already-bundled package are low-risk but still need the cheap gates if the profile is mutated.

After setup: **user** restarts web and checks `HINT-001`…`HINT-002` and `HINT-005`. Agent diagnoses only if the pill is still missing or visually off post-restart (profile boot / served `lib/client.js` / console / stale immutable `rev` cache) — still no restart unless asked.

## Uninstall sketch

No dedicated uninstall script yet. Reverse the Host patch (or `git apply --reverse` the tracked patch when markers still match), regenerate catalogs, rebuild ui-chat + web, then `dsh plugin --profile <name> remove @dsh-external/dsh-reply-model-hint` (not hand-editing Bundle alone). Confirm markers gone, cheap gates show the package absent from Bundle + lock + `node_modules`, and the stock row has no model pill. If the ownership receipt disagrees with the tree, stop and report drift — do not force-overwrite third-party edits.

## Resources

- Visual cohesion for the model pill is required by Intent / `HINT-005`. The alpha.2 CSS that satisfied it (span `border-box`, usage/time-matched geometry, `-6px` adjacent rebate, immutable-rev cache note) is recorded in [`.intent/logs/2026-09-01-turn-stats-pill-visual-alignment.md`](../logs/2026-09-01-turn-stats-pill-visual-alignment.md) (`SRC-2026-09-01-TURN-STATS-PILL-VISUAL-ALIGNMENT`). Treat that log as revision-bound evidence: re-check siblings on a new Host instead of promoting its properties into this state.
- Profile half-install / Bundle-without-resolution incident and the skill risk-tier response: skill log `dsh-manage-plugin-changes` → `.intent/logs/2026-09-01-half-install-and-risk-tiers.md`.

## Non-goals

- Replacing TurnUsagePanel / TurnTimePanel.
- Session-header / composer model seat.
- Super-injector / `dev_*` injection path.
