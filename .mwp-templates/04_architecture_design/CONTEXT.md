# STAGE CONTRACT: 04_architecture_design ({{FEATURE_NAME}})

## 1. Objective

Convert specs into a static, minimal system design. Check for collisions with shared/global architecture before proposing anything.

## 2. Input scope

- READ ONLY: `../03_requirements_specs/outputs/BDD_Gherkin_Specs.md`
- READ ONLY: `../03_requirements_specs/outputs/Spec_DD_Use_Cases.md`
- READ ONLY: `../../.mwp/GLOBAL_CONTEXT.md` (shared schemas / Core Data Anchor references)
- READ ONLY: `./inputs/`

## 3. Execution rules

- Before proposing any structural change, run `graphify .` and read `./graphify-out/GRAPH_REPORT.md` if present.
- If this feature touches a shared schema or component also used by another active feature, do not modify it directly — see "Shared Architecture Sync" in `../../docs/CLAUDE_WORKFLOW_PLAYBOOK.md` and escalate for a human-reviewed upstream change instead.
- Render structural diagrams as Mermaid syntax inside the markdown output, not as prose descriptions.

## 4. Expected deliverables

- `./outputs/System_Architecture.md`
- `./outputs/API_Contracts.md` (if applicable)
- `./outputs/Schema_Design.md` (if applicable — flag as a shared-schema change if it touches global state)

## 5. Token guardrails

- Max 2500 tokens per output file.

## 6. On failure / conflict

If a proposed change conflicts with an existing shared schema, do not silently override it. Write `BLOCKED_REASON.md` per `../../.mwp-templates/CRITICAL_ESCALATION.md` describing the conflict and stop.
