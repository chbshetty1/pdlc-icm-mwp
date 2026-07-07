# STAGE CONTRACT: 05_development_test ({{FEATURE_NAME}})

## 1. Objective

Write the minimum code and tests to satisfy the specs and architecture — nothing beyond the hypothesis being tested.

## 2. Input scope

- READ ONLY: `../03_requirements_specs/outputs/BDD_Gherkin_Specs.md`
- READ ONLY: `../04_architecture_design/outputs/System_Architecture.md`
- READ/WRITE: `./src/`, `./tests/`
- Do not read or write files outside this feature's folder tree.

## 3. Execution rules

- Run `repomix` on `./src/` before large contextual queries to keep token usage bounded.
- Write unit tests for every BDD scenario before or alongside implementation.
- If you need to modify a shared/global module (auth, core schema), stop and escalate rather than editing it in-place from this feature's isolated context — see "Shared Architecture Sync."
- If a Claude Code CLI session is launched at the workspace root instead of inside this folder, `cd` into this folder before proceeding.

## 4. Expected deliverables

- Working code in `./src/`
- Passing tests in `./tests/`
- `./outputs/Dev_Summary.md` — what was built, what was deliberately left out per Lean scope.

## 5. Token guardrails

- Bundle via `repomix` rather than reading raw source files directly once `./src/` exceeds ~15 files.

## 6. On failure

If tests fail twice consecutively after fix attempts, stop. Write `BLOCKED_REASON.md` per `../../.mwp-templates/CRITICAL_ESCALATION.md` with the failing test output attached. Do not attempt a third fix unattended.
