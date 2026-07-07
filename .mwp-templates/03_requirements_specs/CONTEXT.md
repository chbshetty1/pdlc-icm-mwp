# STAGE CONTRACT: 03_requirements_specs ({{FEATURE_NAME}})

## 1. Objective

Convert the locked objective and metric into minimal, testable engineering specifications. Lean rule: no "nice-to-have" scope.

## 2. Input scope

- READ ONLY: `../02_definition_metrics/outputs/OKR_Framework.md`
- READ ONLY: `../02_definition_metrics/outputs/Core_Metrics_KPIs.md`
- READ ONLY: `./inputs/`
- READ ONLY: `../../.mwp/GLOBAL_CONTEXT.md`

## 3. Execution rules

- You are strictly forbidden from writing specs for anything not required to test the core hypothesis.
- Generate exactly one user story per functional item; back each with a BDD scenario in clean Gherkin (Given/When/Then only).
- Every use case must map to a metric in `Core_Metrics_KPIs.md`. Refuse any requirement that contradicts `OKR_Framework.md`.

## 4. Expected deliverables

- `./outputs/BDD_Gherkin_Specs.md`
- `./outputs/Spec_DD_Use_Cases.md`

## 5. Token guardrails

- Max 2500 tokens total output for this stage.

## 6. On failure

If a spec can't be made to map to a defined metric after two attempts, write `BLOCKED_REASON.md` per `../../.mwp-templates/CRITICAL_ESCALATION.md`.

<!-- template-version: 1 -->
