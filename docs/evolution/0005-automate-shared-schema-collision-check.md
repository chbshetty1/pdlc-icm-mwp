# 0005 — Automate Shared-Schema Collision Detection

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 4 of 5 — real gap, but lower frequency risk than 0003 until multiple features are genuinely running in parallel.
- **Status:** adopted (2026-07-07)

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

## Outcome (2026-07-07)

All 4 steps implemented as written:

1. `.mwp-templates/GLOBAL_CONTEXT.template.md` gained a "Shared paths (collision detection)" section with a parseable `- shared_path: <path>` line format (one per line), defaulting to `shared_schemas/` as the example/starting entry.
2. `scripts/sync.sh` extended: at the `04_architecture_design` → `05_development_test` transition it checks `04_architecture_design/outputs/`; at `05_development_test` → `06_validation_gtm` it checks `05_development_test/src/` (not `outputs/`, per the original plan). Each declared `shared_path` is checked two ways — file path match and file content match — via `grep`/`find`, so both "a file was literally created under that path" and "a doc/file mentions that path by name" are caught.
3. On any match, `sync.sh` refuses to sync (nothing is copied to the next stage's `inputs/`) and auto-writes a `BLOCKED_REASON.md` into the *source* stage's `outputs/`, pre-filled with the flagged file(s), what was attempted, and what a human needs to decide — following `CRITICAL_ESCALATION.md`'s template shape.
4. Tested in a sandbox with a dummy `shared_path: shared_schemas/` entry across 4 scenarios: a clean sync with no collision (passed through normally), a 04→05 collision via a content reference (blocked, manifest usable), a 05→06 collision via a `src/` file (blocked, manifest usable), and resolving a flagged file then re-running (synced successfully). All 4 behaved as expected.

`docs/CLAUDE_WORKFLOW_PLAYBOOK.md`'s "Shared Architecture Sync" section updated to describe this as a mechanical check now, not just a stated convention — and stated plainly that it's not airtight (a shared path not literally referenced by name won't be caught, same honesty framing as entry 0018's Context Manifest).

**Mount-staleness recurred during testing** (same class of issue documented in the FAQ from entry 0003's testing): after editing `GLOBAL_CONTEXT.template.md` and `sync.sh`, a fresh `cp` from the live mounted repo still served stale/pre-edit content. Worked around the same way — wrote the exact current file contents directly into the sandbox's scratch space and tested from there, rather than trusting the mount mid-session.

Per the versioning workflow from entry `0015`: `.mwp-templates/GLOBAL_CONTEXT.template.md` bumped from `template-version: 1` to `2`; root `VERSION` bumped from `3` to `4`.
