# PDLC – ICM/MWP Framework: Project Plan

Status: draft v0.1 — for review before any scaffolding begins.
Source: synthesized from the 9-part Gemini brainstorming transcript (`PDLC - ICM-MWP Framework - 1.md`).

## 1. Grounding

ICM and MWP are real, and the transcript describes them accurately:

- Paper: "Interpretable Context Methodology: Folder Structure as Agentic Architecture," Jake Van Clief & David McDermott, arXiv 2603.16021 (Mar 2026).
- Reference templates: `github.com/RinDig/Interpreted-Context-Methodology`, `github.com/ktnCodes/icm-template`.
- Tools referenced are real: Repomix (`repomix.com`), Graphify (PyPI package `graphifyy`, CLI `graphify`), Obsidian, Mermaid CLI, DuckDB, Fabric.
- The rest of the transcript (PDLC mapping, Micro-PDLC, Lean overlay, C-V-R scoring, tool automation) is original synthesis by you + Gemini, not from the paper — it's a reasonable extension, not an established standard. Treat it as v1 of your own methodology, not a citation.

## 2. What this project is

Turn the brainstorm into a working system with two layers:

1. A **framework scaffold** — reusable folder templates, stage contracts, and scripts implementing ICM/MWP for a 6-stage PDLC.
2. An **active workspace** — where a real product's features get run through that scaffold.

## 3. Design decisions already made in the transcript

- **6 PDLC stages:** `01_discovery_&_ideation` → `02_definition_&_metrics` → `03_requirements_&_specs` → `04_architecture_&_design` → `05_development_&_test` → `06_validation_&_go_to_market`.
- **Execution mode:** Micro-PDLC (each feature gets its own isolated 01–06 pipeline) as the default. Agile-PDLC (sprint-horizontal, shared folders) is a documented fallback for later, via a dual-mode `--feature` / `--sprint` scaffold flag — not a separate framework.
- **Lean overlay:** stage contracts are constrained to a single riskiest-assumption / minimum-scope hypothesis test (Build→Measure→Learn), with a `pivot.sh` kill-switch that archives learnings and purges dead feature folders.
- **Prioritization:** C-V-R score = (Context Cleanliness × Value Velocity) / Refactoring Risk, 1–5 each. Foundational "Core Data Anchor" work (schemas, auth) bypasses the score and runs first as Phase 0.
- **Tool stack → stage mapping:** Fabric (01/02, raw-text triage), Graphify (04, AST/knowledge graph), Repomix (05, context bundling), DuckDB (06, data aggregation), Obsidian (all stages, human review UI), Mermaid (04, diagrams).
- **Claude modality mapping:** Claude Chat/Desktop for 01–02 (synthesis), Claude Cowork/Projects for 03–04 (multi-file drafting), Claude Code CLI for 05–06 (filesystem-native execution), each scoped to its stage folder to bound context.
- **Four known gaps** (flagged in the transcript, not yet solved): state-sync between stage `outputs/` and the next stage's `inputs/`; context compaction as feature folders grow; a shared/upstream sync protocol so parallel features don't clobber shared schemas; and a fail-fast escalation contract for when Claude gets stuck.

## 4. Open decisions before scaffolding

These change what gets built, so I'm holding off until you weigh in (see questions below):

- Is this folder the reusable **framework repo**, or the **active product workspace** that consumes the framework, or both combined for now?
- What's the first real feature/product this framework will run — needed to write `GLOBAL_CONTEXT.md` and the Phase-0 Core Data Anchor?
- Do you want the 4 known gaps (sync.sh, compaction, upstream sync, escalation contract) built into v1, or deferred until the first pilot surfaces which ones actually bite?

## 5. Proposed build phases (after decisions above are made)

1. **Charter & conventions** — README, naming conventions, repo-split decision recorded.
2. **Core scaffold** — `.mwp/IDENTITY.md`, `.mwp/GLOBAL_CONTEXT.md`, `.mwp-templates/` per-stage `CONTEXT.md`, dual-mode `scaffold.sh`.
3. **Operational scripts** — `sync.sh`, `pivot.sh`, compaction rule, `CRITICAL_ESCALATION.md`, git `post-commit` hook.
4. **Prioritization** — `FEATURE_PRIORITY_REGISTRY.md` + C-V-R scoring guide.
5. **Claude workflow playbook** — standalone doc mapping Chat/Cowork/Code to each stage.
6. **Tooling setup** — install/verify Obsidian, Repomix, Graphify, Mermaid CLI, DuckDB, Fabric; `CLAUDE.md` automation routing rules.
7. **Pilot run** — take the first real feature end-to-end through all 6 stages, capture friction, revise templates before wider rollout.

## 6. Next step

Answer the open decisions in section 4, and I'll scaffold phases 1–2 directly into this folder.

## 7. Decisions made (v1 shipped)

- **Repo split:** framework-only. This folder stays a clean, reusable, product-agnostic template — no live product data. It's intended to be pushed to its own GitHub repo and reused to bootstrap each new product.
- **v1 scope:** all four known gaps (sync.sh, compaction, upstream/shared-schema sync, escalation contract) were built now rather than deferred.
- Phases 1–4 (core scaffold, operational scripts, prioritization templates, Claude workflow playbook) are done and tested — see `README.md` for the full file map. Phases 5 (tooling install) and 6 (pilot run) happen inside a real product repo created *from* this framework, not in this repo itself.
