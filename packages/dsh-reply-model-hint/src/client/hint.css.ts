/**
 * Plugin-owned stylesheet (injected as one tagged <style> by the client
 * apply; removed on unload). Matches the shipped TurnUsagePanel pill geometry
 * so the model name sits in the same cluster as 用量 / 用时 / 时间.
 */
export const HINT_CSS = `
/* box-sizing:border-box is load-bearing: TurnUsagePanel's trigger is a
   <button>, and Chromium's UA sheet puts buttons on border-box so its
   height:28px already includes the 6px padding. This hint is a <span>
   (content-box by default); without the same box model, the same numbers
   paint a ~40px capsule — the "shadow one size larger" look. */
.dsh-reply-model-hint{box-sizing:border-box;display:inline-flex;align-items:center;gap:4px;min-width:0;height:calc(28px + var(--dsh-content-font-delta, 0px));padding:6px 8px;border:none;border-radius:28px;background:transparent;color:var(--dsw-alias-label-tertiary,inherit);font-size:var(--dsh-content-font-size-secondary,13px);font-variant-numeric:tabular-nums;line-height:calc(24px + var(--dsh-content-font-delta, 0px));white-space:nowrap;}
.dsh-reply-model-hint::before{content:'';width:6px;height:6px;border-radius:50%;background:var(--dsw-alias-brand-primary,currentColor);opacity:.7;flex:none;}
.dsh-reply-model-hint:hover{background:var(--dsw-alias-interactive-bg-hover,transparent);color:var(--dsw-alias-label-secondary,inherit);}
/* Same adjacent-pill rebate as TurnUsagePanel .root + .root: eat 6px of the
   row's 8px flex gap so model · 用量 · 用时 read as one cluster (2px clear
   between hover backgrounds). */
.dsh-reply-model-hint + *{margin-left:-6px;}
@media (max-width:480px){.dsh-reply-model-hint + *{margin-left:0;}}
`
