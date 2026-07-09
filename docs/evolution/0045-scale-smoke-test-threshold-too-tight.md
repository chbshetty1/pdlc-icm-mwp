# 0045 — `test_scale_smoke.sh`'s 30s Ceiling Was Too Tight for Real Hardware

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-09)
- **Priority:** direct bugfix, surfaced by the user running `tests/run_tests.sh` on their actual machine after the entry 0044 batch.

## Problem

`tests/test_scale_smoke.sh` (entry 0037) asserts `registry.sh` and `status.sh` each finish in under 30s against 60 synthetic features, explicitly documented in its own header as "a smoke check, not a strict benchmark" because the authoring sandbox wasn't a stable baseline to time against. That caveat turned out to be load-bearing: run on the user's real Windows machine (Git Bash), `registry.sh` took 32s and failed the assertion. Neither script's logic changed — `registry.sh` was untouched by entry 0044 — this is Windows' much heavier `fork()`/subprocess overhead showing up against a test that spawns a new process (`mkdir`, `awk`, `cat` heredocs) per synthetic feature, 60+ times, on top of `registry.sh`'s own per-feature `awk` calls.

## Proposed change

Loosen both timing ceilings (`registry.sh`'s and `status.sh`'s) from 30s to 90s. This stays a smoke check against catastrophic scaling bugs (an O(n²) regression would still blow well past 90s), not a tightened performance benchmark — the test's own stated purpose was never to assert a specific speed, only that nothing pathological happens at 60-feature scale.

## What happened

Two-line threshold edit (`-lt 30` → `-lt 90`, both occurrences) plus a comment explaining why, so a future reader hitting this again on slower hardware isn't left re-deriving the reasoning. `tests/` is framework-repo-only (entry 0030) — no `VERSION` bump, matching entry 0037's own precedent.

## Outcome (2026-07-09)

Not independently re-verified end-to-end in this session (no sandbox rebuild performed for this fix) — the user's original failure was a clean single-assertion miss (`expected [0], got [1]` on the 30s check only, nothing else in the suite reported failing), and the fix is a direct threshold change addressing exactly that. Worth a `tests/run_tests.sh` run on the user's own machine to confirm before treating this as closed.
