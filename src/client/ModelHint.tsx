import { memo } from 'react'
import type { PropsRuntime } from '@deepseek-ai/dsh-client-ui-slots'
import type {} from './contract'
import type { ReplyModel } from './reply-model'

/** List-entry props for the turn-stats model pill. */
type ModelHintProps = PropsRuntime<'conversation.chat.turn-stats'>

/**
 * One model pill seated before the shipped usage/time triggers.
 * Visible text is the model id; provider rides the hover title.
 */
export const ModelHint = memo(function ModelHint({ turn }: ModelHintProps) {
  const replyModel = turn.data.get('reply-model') as ReplyModel | undefined
  if (replyModel === undefined) return null
  return (
    <span
      className="dsh-reply-model-hint"
      data-dsh-reply-model-hint=""
      title={`${replyModel.provider} · ${replyModel.model}`}
    >
      {replyModel.model}
    </span>
  )
})
