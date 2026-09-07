/**
 * @dsh-external/dsh-reply-model-hint browser half.
 *
 * Adds a model pill before the shipped usage/time triggers on each completed
 * turn's IconActions row:
 *
 * - registers a state-only Conversation Definition that publishes the closing
 *   assistant message's provider/model as turn-scoped `reply-model` data;
 * - registers a `conversation.chat.turn-stats` list entry that renders that
 *   value as a muted pill (Host patch seats this slot before 用量/用时).
 */
import type { Context as ClientContext } from '@deepseek-ai/cordis'
import type {} from '@deepseek-ai/dsh-client-ui-renderer/client'
import type {} from '@deepseek-ai/dsh-client-ui-conversation/client'
import type {} from '@deepseek-ai/dsh-client-ui-chat/client'
import type {} from './contract'
import { ModelHint } from './ModelHint'
import { replyModelDefinition } from './reply-model'
import { HINT_CSS } from './hint.css'

/** Required services: renderer-owned slots and the Conversation registry. */
export const inject = ['slots', 'uiConversation']

export function apply(ctx: ClientContext): void {
  ctx.effect(() => {
    const offDefinition = ctx.uiConversation.events.register(replyModelDefinition)
    const style = document.createElement('style')
    style.dataset.pluginCss = '@dsh-external/dsh-reply-model-hint'
    style.textContent = HINT_CSS
    document.head.appendChild(style)
    const offHint = ctx.slots.inject('conversation.chat.turn-stats', () => ctx.slots.register({
      name: 'conversation.chat.turn-stats',
      id: 'reply-model',
      order: 0,
    }, ModelHint))
    return () => {
      offHint()
      style.remove()
      offDefinition()
    }
  }, 'reply-model-hint: definition + turn-stats + styles')
}
