# 0006 — Test `--sprint` Scaffold Mode

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 5 of 5 — lowest urgency; a test-coverage gap, not a design problem.

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
