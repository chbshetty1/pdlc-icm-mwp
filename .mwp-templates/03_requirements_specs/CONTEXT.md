# STAGE CONTRACT: 03_requirements_specs ({{FEATURE_NAME}})

## 1. Objective

Convert the locked objective and metric into minimal, testable engineering specifications. Lean rule: no "nice-to-have" scope.

## 2. Input scope

- READ ONLY: `../02_definition_metrics/outputs/OKR_Framework.md`
- READ ONLY: `../02_definition_metrics/outputs/Core_Metrics_KPIs.md`
- READ ONLY: `./inputs/`
- READ ONLY: `../../../.mwp/GLOBAL_CONTEXT.md`

## 3. Execution rules

- You are strictly forbidden from writing specs for anything not required to test the core hypothesis.
- Generate exactly one user story per functional item; back each with a BDD scenario in clean Gherkin (Given/When/Then only).
- Every use case must map to a metric in `Core_Metrics_KPIs.md`. Refuse any requirement that contradicts `OKR_Framework.md`.

## 4. Expected deliverables

- `./outputs/BDD_Gherkin_Specs.md`
- `./outputs/Spec_DD_Use_Cases.md`
- `./outputs/Context_Manifest.md` — every file this stage actually read (paths only), self-reported, for human cross-check against this contract's declared READ ONLY scope (see `CRITICAL_ESCALATION.md`).
- If you discover something outside this feature's own scope that a future feature would benefit from knowing, add a one-line note to `./outputs/Learnings_Note.md` (plain text, one discovery per line) — `sync.sh` folds it into the product's `LEARNINGS.md` automatically when this stage's outputs sync forward. Never write to `LEARNINGS.md` directly from this stage.

## 5. Token guardrails

- Max 2500 tokens total output for this stage.

## 6. On failure

If a spec can't be made to map to a defined metric after two attempts, write `BLOCKED_REASON.md` per `../../../.mwp-templates/CRITICAL_ESCALATION.md`.

<!-- template-version: 4 -->
