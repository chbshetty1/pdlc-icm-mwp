# Claude Workflow Playbook

**Optional.** The framework's folder/`CONTEXT.md` mechanism is agent-agnostic — nothing here is required by the scripts or stage contracts. This is a reference workflow for teams using Claude specifically: how to run a single feature through all 6 stages using Claude Chat, Claude Cowork, and Claude Code CLI as specialized workers, keeping each bounded to its stage folder. Swap in a different agent and the rest of the framework works unchanged.

## Modality map

| Claude surface | Best for | Stages |
|---|---|---|
| Claude Chat / Desktop | High-level synthesis, unstructured input parsing | 01_discovery_ideation, 02_definition_metrics |
| Claude Cowork / Projects | Multi-file coordination, drafting specs and architecture | 03_requirements_specs, 04_architecture_design |
| Claude Code CLI | Native filesystem execution, code, tests, git | 05_development_test, 06_validation_gtm |

## Step-by-step

### Stage 01–02: Claude Chat/Desktop
1. Human: `./scripts/scaffold.sh --feature FEAT-xxx_name`. Drop raw notes into `01_discovery_ideation/inputs/`.
2. Open a clean Claude Chat. Paste `.mwp/IDENTITY.md` + `01_discovery_ideation/CONTEXT.md` + the raw inputs.
3. Review `Riskiest_Assumption.md` in Obsidian. Run `./scripts/sync.sh <feature_path> 01_discovery_ideation 02_definition_metrics` once approved, repeat for stage 02's output into stage 03.

### Stage 03–04: Claude Cowork / Project Spaces
1. Human: confirm `sync.sh` has moved approved 02 outputs into `03_requirements_specs/inputs/`.
2. Attach `03_requirements_specs/CONTEXT.md` as the project's working instructions. Only load that stage's `inputs/` files into context — not the whole repo.
3. Review specs and architecture output in Obsidian before syncing into stage 05.

### Stage 05: Claude Code CLI
1. Human: `cd features/FEAT-xxx_name/05_development_test/` — always launch Claude Code from inside this folder, never from the workspace root.
2. Prompt: "Read `../03_requirements_specs/outputs/BDD_Gherkin_Specs.md` and `../04_architecture_design/outputs/System_Architecture.md`. Write source and tests into `./src` and `./tests` only."
3. Run tests locally. On repeated failure, let the escalation contract trigger (`BLOCKED_REASON.md`) rather than looping.

### Stage 06: Claude Code CLI + Obsidian
1. Deploy, collect telemetry, pre-aggregate with `duckdb` into `06_validation_gtm/validation_data/`.
2. Run Claude Code inside `06_validation_gtm/` to compare results against `02_definition_metrics/outputs/Core_Metrics_KPIs.md` and produce `Validation_Report.md`.
3. Pivot or Persevere. On Pivot, run `./scripts/pivot.sh FEAT-xxx_name --pivot`.

## Shared Architecture Sync (parallel-feature collision handling)

Micro-PDLC isolates features, but two features can still need the same shared schema or core module (e.g. the `User` model). Rule:

1. Shared/global definitions live only in `.mwp/GLOBAL_CONTEXT.md` or a `shared_schemas/` directory at the workspace root — never duplicated inside a feature folder.
2. A feature's `04_architecture_design` or `05_development_test` stage must never edit a shared definition directly from its isolated context. If a change is needed, it writes `BLOCKED_REASON.md` requesting the change, per `CRITICAL_ESCALATION.md`.
3. A human (or a dedicated "Core Data Anchor" feature) makes the shared-definition change once, commits it, and updates `.mwp/GLOBAL_CONTEXT.md`. All active feature folders then pull the updated baseline before their next run.
4. Two features with R ≥ 4 that touch the same shared subsystem are never run in parallel — see the Deep Context Backlog rule in `FEATURE_PRIORITY_REGISTRY.md`.

## Why this stays token-efficient

Each