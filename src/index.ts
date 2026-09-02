/**
 * @dsh-external/dsh-reply-model-hint Node half.
 *
 * Browser-only UI plugin: the host half is a no-op; the whole product lives in
 * ./client (see src/client/index.ts).
 */
import type { Context } from '@deepseek-ai/cordis'

export const name = '@dsh-external/dsh-reply-model-hint'
export const inject: string[] = []

export function apply(_ctx: Context): void {}
