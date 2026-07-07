# STAGE CONTRACT: 06_validation_gtm ({{FEATURE_NAME}})

## 1. Objective

Determine Pivot or Persevere against the metric defined in stage 02, using aggregated (not raw) telemetry.

## 2. Input scope

- READ ONLY: `../02_definition_metrics/outputs/Core_Metrics_KPIs.md`
- READ ONLY: `./validation_data/` (pre-aggregated only — never raw SQL dumps or full logs)
- READ ONLY: `./inputs/`

## 3. Execution rules

- Never ingest raw CSV/SQL dumps or full log files. Use `duckdb` to pre-aggregate into averages, trends, and error counts before this stage reads anything.
- Compare actual results directly against the target threshold from `Core_Metrics_KPIs.md`. State Pivot or Persevere explicitly — no hedging.

## 4. Expected deliverables

- `./outputs/Validation_Report.md` — result vs. target, and an explicit Pivot/Persevere recommendation.
- `./outputs/Product_Launch_Kit.md` (only if Persevere)

## 5. Token guardrails

- Max 1500 tokens for `Validation_Report.md`.

## 6. On Pivot

If the recommendation is Pivot, run `../../scripts/pivot.sh {{FEATURE_NAME}} --pivot` to archive learnings and purge the feature's dead code/specs. Do not leave a pivoted feature's stale files in the active `features/` tree.

<!-- template-version: 1 -->
