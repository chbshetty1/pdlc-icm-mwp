# 0003 — Replace Hand-Maintained Priority Registry with a Computed View

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 2 of 5 — highest-value design fix; it's the framework violating its own stated principle.

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
