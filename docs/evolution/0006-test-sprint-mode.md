# 0006 — Test `--sprint` Scaffold Mode

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** 5 of 5 — lowest urgency; a test-coverage gap, not a design problem. Ranked 19 of 20 by entry `0026`'s unified backlog re-prioritization.

## Problem

`scaffold.sh --feature` was tested end-to-end in this session (folder creation, `CONTEXT.md` substitution, `sync.sh`, `pivot.sh`, `compact.sh` all confirmed working against a feature workspace). `scaffold.sh --sprint` shares the same code path but was never actually exercised — it's an untested branch of a tested script.

## Proposed change

Run the same verification pass against `--sprint` mode that `--feature` mode already got.

## Stepwise implementation plan (not yet executed)

1. In a scratch directory, run `./scripts/scaffold.sh --sprint SPRINT-01_test`.
2. Confirm it creates `sprints/SPRINT-01_test/` with the same 6-stage structure as the feature path, and that `CONTEXT.md` substitution uses the sprint name correctly.
3. Confirm `sync.sh` and `compact.sh` work identically against a sprint path (they're written to take a generic `workspace_path` argument, so this should just work — confirm it does).
4. `pivot.sh` currently hardcodes `features/$FEATURE_NAME` — check whether a sprint-equivalent kill-switch is needed, or whether pivoting doesn't conceptually apply to sprint-mode (time-boxed batches aren't usually "killed" the way a single feature hypothesis is).

## What happens if adopted

Either confirms `--sprint` mode works as designed, or surfaces a real bug (most likely candidate: `pivot.sh`'s hardcoded `features/` path) before anyone relying on Agile-PDLC mode hits it first.

## Outcome (2026-07-08)

All 4 steps executed in a sandbox (fresh script copies written directly into sandbox scratch space rather than relying on the live mount — hit the documented mount-staleness issue twice mid-testing, once on `sync.sh`/`pivot.sh`/`scaffold.sh` from recent edits, and once on `registry.sh`, which hadn't even been touched this session, confirming the staleness is non-deterministic rather than tied to recency of edits):

1. `scaffold.sh --sprint SPRINT-01_test` ran cleanly, no errors beyond the expected "no `GLOBAL_CONTEXT.md`" warning (same as feature mode with no global context set up).
2. Structure confirmed identical to feature mode: all 6 stage folders, `05_development_test/src`+`tests`, `06_validation_gtm/validation_data`+`design_artifacts`, and `.escalations_archive/` (entry 0010) all created correctly. `CONTEXT.md` substitution confirmed correct — `{{FEATURE_NAME}}` replaced with `SPRINT-01_test` everywhere, zero unsubstituted placeholders.
3. `sync.sh` (01→02, with an approver) and `compact.sh` both confirmed working identically against a `sprints/` path — no code changes needed, exactly as predicted, since both already take a generic `workspace_path` argument.
4. `pivot.sh` confirmed to fail immediately against a sprint name (`Error: .../features/SPRINT-01_test not found`) — hardcoded to `features/$FEATURE_NAME`, exactly as the entry predicted. **Resolution (confirmed with a human):** no sprint-equivalent kill-switch needed — sprints are shared, time-boxed Agile-PDLC batches, not a single falsifiable hypothesis the way a Micro-PDLC feature is, so "pivot" doesn't conceptually map onto them. This is a deliberate non-gap, not a bug. No code change.

**Beyond the plan — a real bug surfaced, not anticipated by any of the 4 steps:** `scaffold.sh` creates a `FEATURE_META.md` (C-V-R scoring fields) unconditionally for sprints too, but `registry.sh` is hardcoded to only scan `features/` — confirmed empirically that a sprint's `FEATURE_META.md` produces zero effect on the regenerated priority registry, while `scaffold.sh`'s own printed next-steps message actively tells a sprint user to fill it in and run `registry.sh`, which will silently ignore it. Logged as its own entry, `0027`, rather than fixed here — per the same "log, don't silently patch" pattern used for entry `0025`'s discovery during `0008`. `0027` sits unranked until the next re-prioritization pass.

No `.mwp-templates/` file touched, so no `template-version` bump. Root `VERSION` bumped 15→16, though — `docs/FAQ.md` (a "Travels with new products" doc) gained two new entries documenting these findings, which counts as a shipped change under entry `0015`'s versioning rule even though this entry itself was pure verification.
