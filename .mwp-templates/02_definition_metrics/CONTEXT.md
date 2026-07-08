# STAGE CONTRACT: 02_definition_metrics ({{FEATURE_NAME}})

## 1. Objective

Define the single metric that validates or invalidates the riskiest assumption from stage 01. Lock objectives before any spec work begins.

## 2. Input scope

- READ ONLY: `../01_discovery_ideation/outputs/Riskiest_Assumption.md`
- READ ONLY: `./inputs/`
- READ ONLY: `../../../.mwp/GLOBAL_CONTEXT.md`

## 3. Execution rules

- Define exactly one primary success metric and its target threshold. Secondary metrics only if directly load-bearing.
- Do not restate the assumption; build on it.
- Refuse to proceed if `Riskiest_Assumption.md` is missing or unfalsifiable — escalate instead.

## 4. Expected deliverables

- `./outputs/OKR_Framework.md` — objective + key result(s) for this feature.
- `./outputs/Core_Metrics_KPIs.md` — the primary metric, target, and measurement method.
- `./outputs/Context_Manifest.md` — every file this stage actually read (paths only), self-reported, for human cross-check against this contract's declared READ ONLY scope (see `CRITICAL_ESCALATION.md`).
- If you discover something outside this feature's own scope that a future feature would benefit from knowing, add a one-line note to `./outputs/Learnings_Note.md` (plain text, one discovery per line) — `sync.sh` folds it into the product's `LEARNINGS.md` automatically when this stage's outputs sync forward. Never write to `LEARNINGS.md` directly from this stage.

## 5. Token guardrails

- Max 1000 tokens per output file. This stage should be short.

## 6. On failure

Two failed attempts to define a measurable target → write `BLOCKED_REASON.md` per `../../../.mwp-templates/CRITICAL_ESCALATION.md`.

<!-- template-version: 4 -->
