# 0037 — Scale Smoke Test for `registry.sh`/`status.sh`

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a stage-01/02 discovery pass (performance-boundaries question) and user-approved for implementation.

## Problem

`registry.sh` and `status.sh` are only ever exercised in the existing test suites against 2-4 synthetic features — nowhere close to what a real, long-running product workspace would accumulate. Neither script has been checked at a scale where bash-array bugs, sort-order issues, or the `R=0` divide-by-zero guard in `registry.sh`'s score formula would actually be exposed. No pilot has run this framework end-to-end on a real product yet (per README's own "Status" note), so this is a real untested surface, not a hypothetical one.

## Proposed change

Add `tests/test_scale_smoke.sh`: generate 60 synthetic features (mixing a Core Data Anchor, unscored features, and scored features with a range of C/V/R values including `R=0`) and 8 sprints, run both scripts against that set, and assert correctness — not just "didn't crash." Checks bucket counts (anchor/active/deep/unscored) against what was generated, sort-order correctness at the top of each scored table, `status.sh`'s per-stage rollup counts, and a generous completion-time ceiling (smoke check, not a strict timed benchmark — this sandbox isn't a stable enough baseline to assert a tight threshold against).

## Stepwise implementation plan

1. Write `tests/test_scale_smoke.sh`, generating synthetic data deterministically (not randomly) so failures are reproducible.
2. Run it in a sandbox scratch copy; fix anything it finds.
3. Verify against the real repo's scripts via `tests/run_tests.sh`.
4. No wiring needed — `run_tests.sh` auto-discovers `test_*.sh`.

## What happens if adopted

A future change to `registry.sh` or `status.sh` that only breaks at scale (an off-by-one in a loop that happens not to trigger at N=2-4, a sort regression, an array-growth bug) gets caught here instead of surfacing for the first time against a real product's growing feature set.

## Outcome (2026-07-08)

Implemented and found one genuine thing worth recording, though not a script bug: the first version of the sort-order assertion asserted a *specific feature ID* must sort first in each table. Two of the 60 synthetic features were given deliberately-colliding scores to exercise the tie case, and `registry.sh`'s `sort -t$'\t' -k1,1 -rn` (no `-s`/`--stable` flag) breaks ties by comparing the full line lexicographically rather than preserving insertion order — which put a different (but equally-valid, equally-maximal) ID first than the test expected. This isn't a bug: the framework has never defined a tiebreak rule for equal C-V-R scores, so any deterministic ordering among ties is acceptable. Fixed by asserting the *score* at row 1 matches the computed maximum instead of a specific ID — still a meaningful sort-correctness check, without depending on undefined tiebreak behavior.

Everything else passed clean on the first run: bucket counts (1 anchor / 33 active / 18 deep / 8 unscored, matching generation-time expectations exactly), `status.sh`'s six-way per-stage rollup (10 features per stage, matching the `i % 6` distribution used to generate them), the `R=0` edge case scoring as `0` per the existing `awk` guard rather than erroring, and both scripts completing in 1-2 seconds against 60 features + 8 sprints (well under the 30s smoke-check ceiling — no scaling concern found at this size).

Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome). Final run: 21 assertions, 0 failures. Full suite re-run after: **175 assertions across 10 suites, 0 failures** (154 prior + 21 new).

`tests/` is framework-repo-only (per entry 0030) — no `VERSION` bump.
