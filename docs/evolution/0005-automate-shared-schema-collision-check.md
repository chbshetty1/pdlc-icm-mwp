# 0005 — Automate Shared-Schema Collision Detection

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 4 of 5 — real gap, but lower frequency risk than 0003 until multiple features are genuinely running in parallel.

## Problem

`CLAUDE_WORKFLOW_PLAYBOOK.md`'s "Shared Architecture Sync" section states a rule — don't edit a shared schema directly from an isolated feature's context, escalate instead — but nothing checks that the rule was followed. It's a prompt-level instruction the agent is trusted to remember, with no mechanical backstop. This is the same category of problem as 0004 (stated discipline vs. enforced discipline), applied to concurrency instead of tokens.

## Proposed change

Add a pre-sync or pre-commit check that flags when a feature's changed files overlap with anything listed as shared in `.mwp/GLOBAL_CONTEXT.md` (e.g. a `shared_schemas/` path list), so a collision is caught mechanically rather than relying on the agent to self-report via `BLOCKED_REASON.md`.

## Stepwise implementation plan (not yet executed)

1. Formalize a `shared_paths:` list in `GLOBAL_CONTEXT.md` (currently just prose — needs to become a parseable list).
2. Add a check to `sync.sh` (stage 04→05 and 05→06 transitions specifically) that diffs the feature's touched files in `04_architecture_design/outputs/` and `05_development_test/src/` against that shared-paths list.
3. On overlap: refuse to sync, and auto-generate a `BLOCKED_REASON.md` pre-filled with the conflicting path(s), rather than waiting for the agent to notice and write one manually.
4. Test with a dummy shared path and a test feature that deliberately references it, confirming the block fires and the pre-filled escalation file is usable.

## What happens if adopted

Turns a documented convention into an actual gate — meaningful once more than one feature is being run in parallel, which is the framework's own recommended pattern for high-C-V-R work. Lower priority than 0003 only because the collision risk is zero until parallel execution is actually happening.
