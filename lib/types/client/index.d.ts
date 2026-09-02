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
import type { Context as ClientContext } from '@deepseek-ai/cordis';
/** Required services: renderer-owned slots and the Conversation registry. */
export declare const inject: string[];
export declare function apply(ctx: ClientContext): void;
