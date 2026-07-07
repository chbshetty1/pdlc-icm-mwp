# Feature Priority Registry

<!-- Copy to <product-repo>/.mwp/FEATURE_PRIORITY_REGISTRY.md. Scoring method: docs/PRIORITIZATION_GUIDE.md -->

## Phase 0 — Core Data Anchors (bypass C-V-R scoring, run first, unconditionally)

| Feature ID | Name | Status | Workspace Path |
|---|---|---|---|
| FEAT-001 | e.g. Core DB & Auth schema | not started | `./features/FEAT-001_...` |

## Active execution queue (scored, C-V-R = (C × V) / R)

| Feature ID | Name | C | V | R | Score | Status | Workspace Path |
|---|---|---|---|---|---|---|---|
| | | | | | | queued | |

## Deep context backlog (R ≥ 4 — sequential, human-gated, not parallelized)

| Feature ID | Name | C | V | R | Score | Status | Notes |
|---|---|---|---|---|---|---|---|
| | | | | | | blocked | |

## Rules

1. Core Data Anchors always run first and are never scored.
2. Features with R ≥ 4 move to the Deep Context Backlog and run sequentially with mandatory human review at every stage gate — never in parallel with other features touching the same subsystem.
3. Everything else runs in the Active Execution Queue, highest score first, and can be parallelized across separate terminal/agent sessions since Micro-PDLC isolates each feature's folder.

<!-- template-version: 1 -->
