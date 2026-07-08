# 0039 — `FEATURE_META.md` C/V/R Validation in `registry.sh`

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a second stage-01/02 discovery pass (survey of what's still thin, user-requested).

## Problem

`registry.sh` never validates that a feature's `c`/`v`/`r` fields in `FEATURE_META.md` are actually numeric, let alone within `docs/PRIORITIZATION_GUIDE.md`'s documented 1-5 scale. If a human types "high" instead of a number, or transposes a field, the `SCORE` calculation's `awk -v c="$C" -v v="$V" -v r="$R" '... (c*v)/r'` line silently coerces any non-numeric string to `0` in arithmetic context — the feature ends up scored as if it were the lowest possible priority, with nothing distinguishing "genuinely low-value" from "somebody fat-fingered the metadata." Entry 0033 already validated that the *templates* match the patterns scripts parse; this is the runtime-data counterpart — validating what a human actually fills in, not just the template shape.

## Proposed change

After `registry.sh`'s existing blank-field check (which correctly routes a feature with any missing `c`/`v`/`r` to "Not yet scored" — that behavior is unchanged), add a second check: if all three fields are present but any fails `^[1-5]$` (the documented integer 1-5 contract), route the feature to a new "Malformed (needs attention)" bucket instead of computing a score. The malformed row names exactly which field(s) failed and their actual (bad) value, so a human sees why the feature isn't scored rather than assuming it's just low-priority.

## Stepwise implementation plan

1. Add a `MALFORMED_ROWS` array and the validation block to `registry.sh`, after the existing blank-field `continue` and before the `SCORE=$(awk ...)` line.
2. Add a new "## Malformed (needs attention)" section to the generated `FEATURE_PRIORITY_REGISTRY.md`, rendered only when non-empty (same pattern as the existing "Not yet scored" section), plus a 4th line in the "## Rules" section explaining the distinction from being scored as 0.
3. Include `MALFORMED_ROWS` in the total feature count reported at the end.
4. Extend `tests/test_registry_status.sh` with a malformed fixture (`r: high`) and assertions that it lands in its own section, is named with its bad field value, and does NOT silently appear in the Active queue.
5. Run the full `tests/run_tests.sh` suite — this specifically includes entry 0037's scale-smoke test, which deliberately generates synthetic features with `R=0` (originally to exercise the `awk` divide-by-zero guard). `R=0` fails the new `1-5` check, so that suite's own bucket-count expectations needed updating to match — see that entry's test file for the detail; this is a real, useful interaction between the two entries, not a regression.

## What happens if adopted

A malformed `FEATURE_META.md` value gets surfaced explicitly the next time `registry.sh` runs, instead of the feature quietly sinking to the bottom of nowhere as an apparent score-0 entry indistinguishable from a real low-priority feature.

## Outcome (2026-07-08)

Implemented as written. Step 5's prediction held exactly: re-running the full suite after this change surfaced 2 failures in `tests/test_scale_smoke.sh` (entry 0037) — its synthetic `R=0` features, previously counted as "Active" with a score of `0`, are now correctly routed to Malformed, so the Active/Not-yet-scored bucket counts that test asserted no longer matched. This wasn't a bug in the new validation; it was the test's own expectations needing to catch up to a genuinely more correct classification. Fixed by updating `test_scale_smoke.sh`'s generation loop to track `EXPECTED_MALFORMED` separately, and — the actual root cause of one of the two failures — fixing an open-ended `awk '/^## Not yet scored/,0'` range in that test that unintentionally absorbed the new "## Malformed" section's rows into its count once Malformed started appearing after Not-yet-scored in the generated file. Bounded it to stop at `## Malformed|^## Rules` instead.

`tests/test_registry_status.sh` gained 5 new assertions (malformed section presence, the feature listed, the bad field named, correct section placement, and NOT appearing in Active). `tests/test_scale_smoke.sh`'s fix added 1 new assertion (malformed count) on top of correcting 2 existing ones. Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome). Full suite: **197 assertions across 11 suites, 0 failures** (186 prior + 11 net new, after this entry's own regression-and-fix cycle).

`scripts/registry.sh` ships to every new product — `VERSION` bumped MINOR per entry `0029`'s tiers (backward-compatible: every existing valid `FEATURE_META.md` scores identically; only a previously-silent-garbage value now surfaces differently).
