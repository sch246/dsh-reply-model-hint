/**
 * Per-turn reply-model Definition.
 *
 * Tracks the provider/model that produced the closing assistant message of a
 * Turn from the durable `assistant/message` source, and publishes it as the
 * turn-scoped `reply-model` Location value. The turnTail hint reads that value.
 */
import type { ConversationNodeDefinition } from '@deepseek-ai/dsh-client-ui-conversation/client';
/** Provider/model identity reported for one reply. */
export interface ReplyModel {
    readonly provider: string;
    readonly model: string;
}
declare module '@deepseek-ai/dsh-client-ui-conversation/client' {
    interface ConversationTurnDataMap {
        /** Provider/model that produced the closing assistant message of this Turn. */
        'reply-model': ReplyModel;
    }
}
interface ReplyModelState {
    readonly turn: number;
    readonly replyModel?: ReplyModel;
}
/** State-only Definition publishing the closing reply model at Turn scope. */
export declare const replyModelDefinition: ConversationNodeDefinition<ReplyModelState>;
export {};
