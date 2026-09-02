/**
 * Plugin-side SlotMap merge for the Host-owned turn-stats seat.
 * The Host patch declares the same key; this keeps the plugin's Client
 * program type-complete even before Host declarations are rebuilt.
 */
import type { TurnTailOwnerProps } from '@deepseek-ai/dsh-client-ui-chat/client';
declare module '@deepseek-ai/dsh-client-ui-slots' {
    interface SlotMap {
        /**
         * Ordered turn-stat pills before the shipped usage/time triggers.
         * Declared by the Host patch; this plugin registers the model pill.
         */
        'conversation.chat.turn-stats': {
            kind: 'list';
            scope: 'session';
            owner: TurnTailOwnerProps;
        };
    }
}
export type { TurnTailOwnerProps };
