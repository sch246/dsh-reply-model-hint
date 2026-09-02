import type { PropsRuntime } from '@deepseek-ai/dsh-client-ui-slots';
/** List-entry props for the turn-stats model pill. */
type ModelHintProps = PropsRuntime<'conversation.chat.turn-stats'>;
/**
 * One model pill seated before the shipped usage/time triggers.
 * Visible text is the model id; provider rides the hover title.
 */
export declare const ModelHint: import("react").MemoExoticComponent<({ turn }: ModelHintProps) => import("react").JSX.Element | null>;
export {};
