# 0016 — On-Demand Status/Monitoring Script

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** moderate-high — a resurrected gap. This was originally brainstormed alongside 0002–0006 but dropped when that batch got narrowed to five; worth logging properly now under the monitoring question that surfaced it again.
- **Status:** adopted (2026-07-07)

## Problem

Nothing currently gives an at-a-glance view of what's happening across active features. To know whether anything is blocked, someone has to manually open every `features/*/*/outputs/` folder and check for `BLOCKED_REASON.md`. With more than a couple of features in flight (the framework's own recommended pattern — run high-C-V-R features in parallel), this doesn't scale as a manual check, and a stuck feature can go unnoticed for a long time.

There's also no way to see systemic patterns — e.g. if features keep stalling at the same stage, that's a signal the stage's contract or tooling has a structural problem, not that each feature independently had bad luck.

## Proposed change

A `scripts/status.sh` that scans `features/*/` (and `sprints/*/` in sprint mode) once, on demand, and reports two views from the same scan:

1. **Per-feature:** current stage (inferred from which `outputs/` folders are populated), blocked or not (`BLOCKED_REASON.md` present), last-sync timestamp (once entry 0009's `SYNC_LOG.md` exists).
2. **Stage-level rollup:** count of features currently sitting at each of the 6 stages, and count of blocked features per stage — the view that surfaces systemic bottlenecks.

Explicitly not in scope: any alerting (Slack, email, "notify if blocked > N days"). This framework has no running service to host that kind of watcher, and inventing one would be the same category of overreach already rejected for auto-install (0013) and configurable logging (0014). `status.sh` is checked when a human wants to know, not something that watches continuously.

## Relationship to entry 0003

Both this and 0003 (computed priority registry) walk `features/*/`, but answer different questions — 0003 answers "what should we work on next" (priority-sorted), this answers "what's stuck or in-progress right now" (health). They should share a common scan/parsing utility rather than duplicating the folder-walk logic twice; whichever gets implemented first should factor that part out for the other to reuse.

## Stepwise implementation plan (not yet executed)

1. Write `scripts/status.sh`: walk `features/*/` (and `sprints/*/`), for each determine current stage by checking which stage folders have non-empty `outputs/`, and check for `BLOCKED_REASON.md` in each stage's `outputs/`.
2. Print a per-feature table (name, current stage, blocked y/n) and a stage-level summary (counts per stage, counts blocked per stage).
3. If entry 0009 (sync audit trail) is implemented first, also read each feature's `SYNC_LOG.md` for a last-moved-forward timestamp; if not, skip that column gracefully rather than failing.
4. If entry 0003 is implemented first, factor its `features/*/` scanning logic into a shared helper both scripts call; if this one lands first, write it so 0003 can reuse it later.
5. Test against the sandbox features used for earlier script verification, including at least one deliberately left with a `BLOCKED_REASON.md` to confirm it's correctly surfaced in both the per-feature and stage-rollup views.

## What happens if adopted

Replaces "manually open every folder to check for problems" with a single on-demand command, and surfaces stage-level bottlenecks that wouldn't be visible from any single feature's perspective — without adding any always-on watching process the framework has no natural home for.

## Outcome (2026-07-07)

All 5 steps implemented, including the cross-entry factoring called for in step 4:

1. `scripts/status.sh` written: walks `features/*/` and `sprints/*/`, infers each workspace's current stage as the highest-numbered stage with a non-empty `outputs/`, and checks every stage's `outputs/` for `BLOCKED_REASON.md`.
2. Prints a per-workspace table (name, current stage, blocked yes/no, blocked-at stage, last sync) and a stage-level rollup (active count and blocked count per stage) — separately for Features and Sprints, each section skipped entirely if that directory doesn't exist or is empty.
3. Since entry 0009 (`SYNC_LOG.md`) already landed, the last-sync column reads real data — the "skip gracefully if 0009 isn't implemented" fallback in the original plan wasn't needed, but the column still degrades to `—` for any workspace that hasn't synced yet.
4. **Cross-entry factoring done as instructed:** since entry 0003 (`registry.sh`) landed first, its `features/*/` glob loop was extracted into a new `scripts/lib/scan_features.sh` (a `list_workspace_dirs` helper), and `registry.sh` was retrofitted to source and use it instead of its own inline loop. `status.sh` uses the same helper for both `features/` and `sprints/`. Confirmed no regression: re-ran `registry.sh` against a test Core Anchor after the refactor and the output matched pre-refactor behavior exactly.
5. Tested in a sandbox with three features (one mid-pipeline with a `SYNC_LOG.md`, one deliberately left with a `BLOCKED_REASON.md` at stage 04, one freshly scaffolded with no outputs yet) plus one sprint. All three feature states and the sprint were surfaced correctly in both the per-workspace table and the stage-level rollup (04_architecture_design correctly showed 1 active / 1 blocked).

One deviation from the first draft, caught during testing: an initial single "Blocked" column showing `yes (04_architecture_design)` inline overflowed the fixed-width table for longer stage names, misaligning subsequent columns. Split into two columns (`Blocked` yes/no, `Blocked at` stage-or-—) instead — cleaner and consistent with the fixed-width table style used elsewhere (`registry.sh`'s output, `PRIORITIZATION_GUIDE.md`'s worked example).

Per the versioning workflow from entry `0015`: no `.mwp-templates/` file touched, so no `template-version` bump applies — root `VERSION` bumped from `6` to `7` since `scripts/status.sh`, `scripts/lib/scan_features.sh`, and the `scripts/registry.sh` refactor all ship to products.
