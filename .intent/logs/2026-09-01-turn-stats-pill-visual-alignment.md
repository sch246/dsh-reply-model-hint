# Turn-stats model pill visual alignment (alpha.2)

Record ID: `SRC-2026-09-01-TURN-STATS-PILL-VISUAL-ALIGNMENT`

Status: user visual acceptance after a hover-size mismatch on DeepSeek Harness `dsh-v0.1.2-alpha.2` (`0a53fb55bea101816fa226bb964ae2bed71c343b`).

## User observation

On the completed-turn IconActions row, the model hint's hover capsule looked one size larger than the shipped 用量 / 用时 pills beside it — read as a heavier "shadow" — even though the hint reused the same height, padding, radius, and hover token names.

## Checked cause (this host revision)

- Stock `TurnUsagePanel` / `TurnTimePanel` triggers are `<button>` elements. Chromium's UA stylesheet puts buttons on `box-sizing: border-box`, so their declared `height: 28px` already includes `padding: 6px`.
- This plugin's hint is a `<span>` (default `content-box`). The same numbers therefore painted ~40px tall hover fill.
- Pixel samples of the user's crop showed soft hover fill ~40px high on the model side vs ~28px siblings — not an extra `box-shadow`.
- Separately, adjacent usage/time pills rebate `margin-left: -6px` (TurnUsagePanel `.root + .root`) so the row's 8px flex gap leaves 2px between hover backgrounds. The model pill needed the same rebate toward its next sibling to sit in that cluster.

## Selected realization detail (alpha.2 only)

Keep matching the stock pill geometry; do not invent a parallel chrome:

- set `box-sizing: border-box` on `.dsh-reply-model-hint` so the span shares the button box model;
- keep the same height / padding / radius / tertiary→secondary hover tokens as `TurnUsagePanel.module.css` `.trigger`;
- apply `.dsh-reply-model-hint + * { margin-left: -6px }` (cleared under 480px) to join the usage/time rebate;
- leave the element a non-button `<span>` (display-only; no dialog).

These CSS facts are evidence for this Host + browser baseline. They are not a portable styling law: if a later Harness ships a shared border-box reset, or seats turn-stats through a different element, re-check siblings and revise realization — do not copy these properties into STATE as eternal requirements.

## Cache note for Agents

Plugin combo URLs are served `Cache-Control: public, max-age=31536000, immutable` keyed by content `rev`. After rebuilding `lib/client.js`, a soft reload may keep the old capsule until the HTML `rev` changes (HMR/`onRebuilt`, hard refresh, or an authorized web restart). Stale cache is not evidence that the alignment fix failed.

## Evidence boundary

Source CSS and served `lib/client.js` can prove the declarations. Final "融洽" acceptance is a live-browser observation against the stock 用量 / 用时 / 时间 cluster.
