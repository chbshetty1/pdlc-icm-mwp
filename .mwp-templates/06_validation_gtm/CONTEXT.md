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
- `./outputs/Context_Manifest.md` — every file this stage actually read (paths only), self-reported, for human cross-check against this contract's declared READ ONLY scope (see `CRITICAL_ESCALATION.md`).
- If you discover something outside this feature's own scope that a future feature would benefit from knowing, add a one-line note to `./outputs/Learnings_Note.md` (plain text, one discovery per line) — this stage is terminal, so `pivot.sh` (not `sync.sh`) folds it into the product's `LEARNINGS.md` automatically on either `--pivot` or `--persevere`. Never write to `LEARNINGS.md` directly from this stage.

## 5. Token guardrails

- Max 1500 tokens for `Validation_Report.md`.

## 6. On Pivot

If the recommendation is Pivot, run `../../../scripts/pivot.sh {{FEATURE_NAME}} --pivot` to archive learnings and purge the feature's dead code/specs. Do not leave a pivoted feature's stale files in the active `features/` tree.

<!-- template-version: 4 -->
