# 0003 — Replace Hand-Maintained Priority Registry with a Computed View

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 2 of 5 — highest-value design fix; it's the framework violating its own stated principle.
- **Status:** adopted (2026-07-07)

## Problem

`FEATURE_PRIORITY_REGISTRY.md` is a single shared markdown file that every active feature's status change has to edit. This is exactly the "shared mutable state" pattern that entry 0001's fundamentals section identifies as the source of coordination cost — the same category of problem as two features colliding on a shared schema, just self-inflicted by the framework's own bookkeeping. Under real parallel usage (the framework's own recommended pattern — run high-C-V-R features in parallel), multiple terminal sessions editing the same registry file is a predictable source of merge conflicts and stale reads.

## Proposed change

Stop hand-editing the registry as the source of truth. Instead, each feature declares its own C/V/R score and status in a small metadata block inside its own `CONTEXT.md` (or a dedicated `FEATURE_META.md` inside its folder) — something only that feature's folder owns, no shared file touched. A small script walks `features/*/` at any time and regenerates `FEATURE_PRIORITY_REGISTRY.md` as a computed, disposable view — never hand-edited, safe to regenerate anytime, nothing to merge-conflict over.

## Stepwise implementation plan (not yet executed)

1. Add a `## Metadata` block to the `.mwp-templates` stage-01 (or feature-root) template: `feature_id`, `name`, `c`, `v`, `r`, `status`, `is_core_anchor`.
2. Write `scripts/registry.sh` (or extend `scaffold.sh`) that scans every `features/*/FEATURE_META.md`, computes the score, and writes a fresh `FEATURE_PRIORITY_REGISTRY.md` — sorted, split into Core Anchors / Active Queue / Deep Context Backlog per the existing rules in `PRIORITIZATION_GUIDE.md`.
3. Update `scaffold.sh` to create a blank `FEATURE_META.md` at scaffold time (unscored, status `not started`) instead of asking the human to add a row to the shared registry by hand.
4. Update `README.md`/`PRIORITIZATION_GUIDE.md` to describe the registry as generated, not edited, and gitignore any transient regeneration artifacts if needed.
5. Test with two or three scaffolded test features to confirm the aggregation logic matches the manual template's format and sorting rules.

## What happens if adopted

Removes a real, predictable failure mode (registry merge conflicts / stale status) before it's hit in practice, and makes the framework consistent with its own stated concurrency principle from entry 0001 — worth doing before running two features in parallel for real.

## Outcome (2026-07-07)

All 5 steps implemented, with the metadata block built as a dedicated file rather than embedded in stage 01's `CONTEXT.md`:

1. `.mwp-templates/FEATURE_META.template.md` added — `feature_id`, `name`, `c`, `v`, `r`, `status`, `is_core_anchor` as plain `key: value` lines (easy for a shell script to parse with `grep`/`sed`, no YAML/JSON parser needed).
2. `scripts/registry.sh` written: walks `features/*/FEATURE_META.md`, computes `(C × V) / R`, and writes a fresh `.mwp/FEATURE_PRIORITY_REGISTRY.md` split into Core Anchors / Active Queue (sorted by score, descending) / Deep Context Backlog (R ≥ 4) — plus a "Not yet scored" section for features whose `FEATURE_META.md` hasn't been filled in yet, so nothing silently disappears from view.
3. `scaffold.sh` updated to create a blank `FEATURE_META.md` at the feature root at scaffold time (status `not started`, unscored), and its "Next steps" output now points at filling in that file and running `registry.sh` instead of hand-editing the shared registry.
4. `README.md` and `docs/PRIORITIZATION_GUIDE.md` updated to describe the registry as generated, not edited. `.mwp-templates/FEATURE_PRIORITY_REGISTRY.template.md` kept as a human-readable reference of the format `registry.sh` produces, with its header comment updated to say so.
5. Tested in a sandbox with 5 scaffolded features (a Core Anchor, two equal-score Active Queue features, one R≥4 Deep Backlog feature, one deliberately left unscored) reproducing `PRIORITIZATION_GUIDE.md`'s worked example exactly — scores, sort order, and section placement all matched.

**Operational discovery made while testing, worth recording generally:** after editing `scripts/scaffold.sh` via the file-edit tool, a `cp` from the live mounted repo path inside the sandbox served a stale, truncated copy of the file (missing the tail end of the script) even though the actual file on disk was correct and complete. Re-copying didn't fix it — the mount stayed stale for the rest of the session. Confirmed correct behavior instead by writing the exact file contents directly into the sandbox's own scratch space and testing from there. This is a different failure mode than the previously-documented git corruption issue (that was about incremental git writes; this is a stale read of a plain file), but the same family of "don't fully trust the sandbox-to-Windows mount mid-session" caution. Logged as a new FAQ entry.

Per the versioning workflow from entry `0015`: `.mwp-templates/FEATURE_PRIORITY_REGISTRY.template.md` bumped from `template-version: 1` to `2`; root `VERSION` bumped from `2` to `3`. `FEATURE_META.template.md` is a new file, starting at `template-version: 1`.
