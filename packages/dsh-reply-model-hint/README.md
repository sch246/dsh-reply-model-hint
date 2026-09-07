# dsh-reply-model-hint

DeepSeek Harness Web client plugin: a muted pill in each completed reply's
action row showing the model that produced it (hover for `provider · model`).

Order after install: `模型名 · 用量 · 用时 · 时间`.

Browser-only bundle plugin for the `web` profile. Needs a small Host patch so
the pill can sit *inside* the usage/time action (before 用量), not on the
public `assistant-actions` list.

## Install and maintain

Use the [root operation table](../../README.md) and [STATE](../../.intent/state/STATE.md). The installable coordinate is this child package; the root owns build/setup/inspect/remove scripts. Profile operations require explicit `DSH_CHECKOUT`, `DSH_HOME` and `DSH_PROFILE`; setup checks by default and writes only with `--install`. Removal retains shared Host support unless the separate owned-source removal route applies.
