# 0038 — `sync.sh`/`pivot.sh` `Learnings_Note.md` Idempotency Fix

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a second stage-01/02 discovery pass (survey of what's still thin, user-requested), directly reasoning about the actual script behavior rather than found via a bug report.

## Problem

Neither `sync.sh` (entry 0012) nor `pivot.sh`'s `fold_learnings_note()` (also entry 0012) is idempotent for `Learnings_Note.md`. Re-running the same stage transition — a mistake, or a deliberate re-sync after fixing something upstream — re-appends the exact same discovery lines into `LEARNINGS.md` every time, since nothing ever marks the note as already folded. `SYNC_LOG.md` re-appending on a rerun is arguably correct (it's a literal audit trail of invocations, and a second real invocation is a second real event worth logging), but `LEARNINGS.md` duplicating the same discovery is a genuine correctness bug: the register's whole purpose is "record this incidental discovery once," not "record it once per re-sync." Nothing had hit this yet because no test or real usage had re-run the same transition twice.

## Proposed change

After a successful fold in both `sync.sh` and `pivot.sh`'s `fold_learnings_note()`, rename `Learnings_Note.md` to `Learnings_Note.md.folded` rather than leaving it in place. A subsequent run's `[ -f "$LEARNINGS_NOTE" ]` (or equivalent) check then finds nothing and skips folding entirely. Rename, not delete — same archive-not-delete reasoning entry 0010 already established for `BLOCKED_REASON.md`: the content stays available for a human to inspect, it's just marked as already-processed.

## Stepwise implementation plan

1. Add the rename to `sync.sh`'s Learnings capture block, immediately after the existing fold loop and its "Folded N discovery line(s)..." message.
2. Add the identical rename to `pivot.sh`'s `fold_learnings_note()` function (the same logic, deliberately duplicated per `docs/DEVELOPMENT.md`'s script conventions rather than factored into a shared lib for a block this small — matching how the original fold logic was already duplicated).
3. Extend `tests/test_sync.sh` and `tests/test_pivot.sh`: assert the note file is renamed after the first fold, then re-run the same sync/persevere a second time and assert the discovery line's count in `LEARNINGS.md` didn't increase.
4. Run the full `tests/run_tests.sh` suite to confirm no regression.

## What happens if adopted

Re-running `sync.sh` for a transition that already folded a `Learnings_Note.md`, or calling `pivot.sh --persevere` more than once, no longer duplicates rows in `LEARNINGS.md`. The renamed `.folded` file is still copied forward through `sync.sh`'s wholesale `cp -r` (unchanged — it already ran before the rename), so nothing about the sync mechanics themselves changed, only the fold step's own re-entrancy.

## Outcome (2026-07-08)

Implemented exactly as written in both files, no deviations. `tests/test_sync.sh` gained 3 new assertions (the `.folded` rename, the original name's absence, and the duplicate-free re-run count check); `tests/test_pivot.sh` gained 2 (the rename, and the duplicate-free re-run count check on a second `--persevere`). All passed on the first real run. Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome for why that matters).

`scripts/sync.sh` and `scripts/pivot.sh` both ship to every new product — `VERSION` bumped MINOR per entry `0029`'s tiers (backward-compatible: a fresh sync/persevere on a note that hasn't been folded yet behaves identically to before; only a *second* run against the same already-folded note now behaves differently, and that behavior was a bug, not a documented contract).
