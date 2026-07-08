# 0035 — Factor the Duplicated STAGES Array into One Shared Source

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a stage-01/02 discovery pass (core-engine extensibility question), confirmed by directly reading both files before proposing a fix.

## Problem

`scaffold.sh` and `status.sh` each hardcode the identical 6-line stage list:

```bash
STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)
```

Confirmed by reading both files directly — byte-for-byte the same line, in two places. If a stage is ever renamed, added, or removed, both copies have to be edited correctly and consistently, by hand, with nothing catching a mismatch — `tests/run_tests.sh` (entry `0030`) exercises both scripts' current behavior but doesn't guard against them drifting apart if one is edited and the other forgotten. `registry.sh` doesn't need this list (it scans `features/*/` generically via `scan_features.sh` rather than iterating named stages) and `sync.sh` takes stage names as CLI arguments rather than declaring them, so this is specifically a `scaffold.sh`/`status.sh` duplication, not a wider pattern.

## Proposed change

Add `scripts/lib/stages.sh` (alongside the existing `scripts/lib/log.sh` and `scripts/lib/scan_features.sh`) declaring `STAGES` once. Both `scaffold.sh` and `status.sh` source it instead of declaring their own copy.

## Stepwise implementation plan

1. Create `scripts/lib/stages.sh`, meant to be sourced (same convention as `log.sh`/`scan_features.sh`): a single `STAGES=(...)` array declaration plus a one-line comment pointing at this entry.
2. Replace the hardcoded array line in `scaffold.sh` with `source "$SCRIPT_DIR/lib/stages.sh"`, placed alongside its existing `lib/log.sh` source.
3. Replace the hardcoded array line in `status.sh` the same way.
4. Test in a sandbox scratch copy: confirm `scaffold.sh --feature`/`--sprint` still produce the identical 6-stage structure, and `status.sh` still reports correctly.
5. Run `tests/run_tests.sh` (full suite) to confirm no regression, since `test_scaffold.sh` and `test_registry_status.sh` both already exercise stage-dependent behavior.

## What happens if adopted

A future stage-count or stage-naming change becomes a one-line edit instead of a two-file, easy-to-desync edit. No behavior change for existing users — the stage names and order are identical, just declared once.

## Outcome (2026-07-08)

All 5 steps implemented as written, no deviations.

1. `scripts/lib/stages.sh` created.
2. `scaffold.sh`'s hardcoded `STAGES=(...)` line replaced with a `source` call.
3. `status.sh`'s hardcoded `STAGES=(...)` line replaced with a `source` call.
4. Verified in a sandbox scratch copy: `scaffold.sh --feature` and `--sprint` produce identical structure to before; `status.sh` reports identically.
5. Full `tests/run_tests.sh` suite run: all suites still pass (see this entry's file-list — `test_scaffold.sh` and `test_registry_status.sh` both exercise this path directly).

`scripts/` ships to every new product, so `VERSION` bumped MINOR per entry `0029`'s tiers — backward-compatible internal refactor, nothing already scaffolded from an older version breaks or needs to change.
