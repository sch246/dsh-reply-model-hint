/**
 * Per-turn reply-model Definition.
 *
 * Tracks the provider/model that produced the closing assistant message of a
 * Turn from the durable `assistant/message` source, and publishes it as the
 * turn-scoped `reply-model` Location value. The turnTail hint reads that value.
 */
import type {
  ConversationNodeContext,
  ConversationNodeDefinition,
} from '@deepseek-ai/dsh-client-ui-conversation/client'

/** Provider/model identity reported for one reply. */
export interface ReplyModel {
  readonly provider: string
  readonly model: string
}

declare module '@deepseek-ai/dsh-client-ui-conversation/client' {
  interface ConversationTurnDataMap {
    /** Provider/model that produced the closing assistant message of this Turn. */
    'reply-model': ReplyModel
  }
}

interface ReplyModelState {
  readonly turn: number
  readonly replyModel?: ReplyModel
}

/** State-only Definition publishing the closing reply model at Turn scope. */
export const replyModelDefinition: ConversationNodeDefinition<ReplyModelState> = {
  kind: 'reply-model',
  match: (event) => {
    if (event.type === 'turn/start') return { id: String(event.data.turn), role: 'start' }
    if (event.type === 'assistant/message') return { id: String(event.data.turn), role: 'update' }
    return null
  },
  start: (_context, match) => {
    if (match.event.type !== 'turn/start') throw new Error('reply-model start requires turn/start')
    return { turn: match.event.data.turn }
  },
  update: (context, match) => {
    if (match.event.type !== 'assistant/message') return context.state
    const { provider, model } = match.event.data.message.source
    return { ...context.state, replyModel: { provider, model } }
  },
  publication: match => match.event.type === 'assistant/message' ? 'immediate' : 'none',
  buildLocationData: (context: ConversationNodeContext<ReplyModelState>, scope) => {
    if (scope !== 'turn') return null
    const replyModel = context.state?.replyModel
    if (replyModel === undefined) return null
    return {
      kind: 'turn',
      turn: context.state!.turn,
      key: 'reply-model',
      value: replyModel,
    }
  },
}
