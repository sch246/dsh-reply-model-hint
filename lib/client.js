window.__ModuleLoader__.load({
	id: "@dsh-external/dsh-reply-model-hint",
	factory: (require) => {
		var module = { exports: {} };
		var exports = module.exports;
		Object.defineProperty(exports, Symbol.toStringTag, { value: "Module" });
		let react = require("react");
		let react_jsx_runtime = require("react/jsx-runtime");
		//#region src/client/ModelHint.tsx
		/**
		* One model pill seated before the shipped usage/time triggers.
		* Visible text is the model id; provider rides the hover title.
		*/
		const ModelHint = (0, react.memo)(function ModelHint({ turn }) {
			const replyModel = turn.data.get("reply-model");
			if (replyModel === void 0) return null;
			return /* @__PURE__ */ (0, react_jsx_runtime.jsx)("span", {
				className: "dsh-reply-model-hint",
				"data-dsh-reply-model-hint": "",
				title: `${replyModel.provider} · ${replyModel.model}`,
				children: replyModel.model
			});
		});
		//#endregion
		//#region src/client/reply-model.ts
		/** State-only Definition publishing the closing reply model at Turn scope. */
		const replyModelDefinition = {
			kind: "reply-model",
			match: (event) => {
				if (event.type === "turn/start") return {
					id: String(event.data.turn),
					role: "start"
				};
				if (event.type === "assistant/message") return {
					id: String(event.data.turn),
					role: "update"
				};
				return null;
			},
			start: (_context, match) => {
				if (match.event.type !== "turn/start") throw new Error("reply-model start requires turn/start");
				return { turn: match.event.data.turn };
			},
			update: (context, match) => {
				if (match.event.type !== "assistant/message") return context.state;
				const { provider, model } = match.event.data.message.source;
				return {
					...context.state,
					replyModel: {
						provider,
						model
					}
				};
			},
			publication: (match) => match.event.type === "assistant/message" ? "immediate" : "none",
			buildLocationData: (context, scope) => {
				if (scope !== "turn") return null;
				const replyModel = context.state?.replyModel;
				if (replyModel === void 0) return null;
				return {
					kind: "turn",
					turn: context.state.turn,
					key: "reply-model",
					value: replyModel
				};
			}
		};
		//#endregion
		//#region src/client/hint.css.ts
		/**
		* Plugin-owned stylesheet (injected as one tagged <style> by the client
		* apply; removed on unload). Matches the shipped TurnUsagePanel pill geometry
		* so the model name sits in the same cluster as 用量 / 用时 / 时间.
		*/
		const HINT_CSS = `
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
`;
		//#endregion
		//#region src/client/index.ts
		/** Required services: renderer-owned slots and the Conversation registry. */
		const inject = ["slots", "uiConversation"];
		function apply(ctx) {
			ctx.effect(() => {
				const offDefinition = ctx.uiConversation.events.register(replyModelDefinition);
				const style = document.createElement("style");
				style.dataset.pluginCss = "@dsh-external/dsh-reply-model-hint";
				style.textContent = HINT_CSS;
				document.head.appendChild(style);
				const offHint = ctx.slots.inject("conversation.chat.turn-stats", () => ctx.slots.register({
					name: "conversation.chat.turn-stats",
					id: "reply-model",
					order: 0
				}, ModelHint));
				return () => {
					offHint();
					style.remove();
					offDefinition();
				};
			}, "reply-model-hint: definition + turn-stats + styles");
		}
		//#endregion
		exports.apply = apply;
		exports.inject = inject;
		return module.exports;
	}
});

//# sourceMappingURL=client.js.map