# dsh-reply-model-hint

DeepSeek Harness Web client plugin: a muted pill in each completed reply's
action row showing the model that produced it (hover for `provider · model`).

Order after install: `模型名 · 用量 · 用时 · 时间`.

Browser-only bundle plugin for the `web` profile. Needs a small Host patch so
the pill can sit *inside* the usage/time action (before 用量), not on the
public `assistant-actions` list.

## Install

Follow `.intent/state/STATE.md`. Short path on this machine:

```sh
DSH_CHECKOUT=/root/deepseek-harness bash scripts/setup.sh
```

Then restart the web surface manually. Do not restart from the agent unless asked.

## Build only

```sh
DSH_CHECKOUT=/root/deepseek-harness bash scripts/build.sh
```
