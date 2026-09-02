# Formal checkout selection

Record ID: `SRC-2026-09-02-FORMAL-CHECKOUT-SELECTION`

Status: observed deployment-path correction on DeepSeek Harness `dsh-v0.1.2-alpha.2` (`0a53fb55bea101816fa226bb964ae2bed71c343b`).

## Observed event

The alpha.2 migration was validated in `/root/worktrees/harness-alpha2-candidate` and later recomposed into the formal checkout at `/root/deepseek-harness`. The plugin installer and build script still probed the candidate path before the formal checkout. While that temporary worktree existed, an invocation without `DSH_CHECKOUT` therefore continued to modify and build the candidate instead of the formal source selected for future service starts.

## User decision

The formal checkout is the default local installation target. A caller may select another valid checkout explicitly through `DSH_CHECKOUT`; temporary candidate worktrees are not implicit fallback targets.

## Evidence boundary

This record establishes checkout-selection order only. It does not establish browser acceptance of the model hint or authorize a managed-service restart.
