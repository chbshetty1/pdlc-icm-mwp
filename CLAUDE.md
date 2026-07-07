# Model Workspace Protocol (MWP) — Automation Guide

This file is read by Claude Code at the root of any product workspace built from this framework.

## Structural constraints

This workspace operates under the Interpretable Context Methodology (ICM). Respect stage boundaries strictly:

- Never read files outside the active stage folder except the explicit `READ ONLY` references listed in that stage's `CONTEXT.md`.
- Never write outside the active stage's `outputs/` (or `src/` / `tests/` in `05_development_test/`).
- If launched at the workspace root rather than inside a specific stage folder, ask which stage you are operating in before doing anything — do not assume you may read the whole tree.

## Automated skill routing

- **01_discovery_ideation / 02_definition_metrics:** pipe unstructured input (transcripts, notes) through `fabric` patterns before writing output markdown. Keep outputs to a single riskiest-assumption framing, not a full research report.
- **04_architecture_design:** before proposing structural changes, run `graphify .` and read `graphify-out/GRAPH_REPORT.md`. Use Mermaid syntax for any diagram committed to markdown.
- **05_development_test:** run `repomix` to bundle source before large contextual queries. Use `duckdb` for local data aggregation rather than ingesting raw CSV/SQL dumps.
- **06_validation_gtm:** summarize telemetry with `duckdb` before writing `Validation_Report.md`. Never paste raw logs into context.

## Failure handling

If a stage's validation or test step fails twice consecutively, stop. Write `BLOCKED_REASON.md` in the active stage's `outputs/` describing the failure per `.mwp-templates/CRITICAL_ESCALATION.md`, and end the session. Do not retry a third time unattended.

## Direct commands

- Re-index knowledge graph: `graphify .`
- Compress code context: `repomix`
- Advance approved outputs to next stage: `./scripts/sync.sh <feature_path> <from_stage> <to_stage>`
- Compact a growing feature: `./scripts/compact.sh <feature_path>`
- Kill a failed hypothesis: `./scripts/pivot.sh <feature_name> --pivot`
