# PDLC – ICM/MWP Framework

A reusable, standalone framework that applies the **Interpretable Context Methodology (ICM)** and its **Model Workspace Protocol (MWP)** — Van Clief & McDermott, arXiv 2603.16021 — to a full **Product Development Life Cycle (PDLC)**.

This repo is the **engine block**, not a product. It contains no live product data. When you start a new product, run `scripts/scaffold.sh` against a *new, separate* product repository — never directly inside this one — to generate that product's active workspace from these templates.

## Prerequisites

`scripts/*.sh` are bash scripts. On Windows, run them from **Git Bash** or **WSL** — plain PowerShell/cmd cannot execute `.sh` files directly. Verified working from Git Bash (`bash scripts/scaffold.sh ...`, `bash scripts/sync.sh ...`, `bash scripts/pivot.sh ...`) — see `docs/evolution/0002-cross-platform-script-verification.md`.

The optional per-stage tools (Fabric, Graphify, Repomix, Mermaid CLI, DuckDB, Obsidian) are a separate set of prerequisites with their own install steps — see `docs/TOOLING_MATRIX.md` (includes a Windows `winget` PATH gotcha found while verifying this). Verification status: `docs/evolution/0013-verify-tooling-matrix.md`.

## What's in here

| Path | Purpose |
|---|---|
| `.mwp-templates/` | Blueprint files copied into every new product workspace: global identity, stage contracts (6 PDLC stages), escalation template, feature-metadata template, and a reference copy of the generated priority-registry format. |
| `scripts/` | Automation: `scaffold.sh` (spin up a new feature/sprint workspace, including its `FEATURE_META.md`), `sync.sh` (advance approved outputs to the next stage, with a shared-path collision check and an optional `[approver]` argument logged to `SYNC_LOG.md`), `pivot.sh` (Lean kill-switch), `compact.sh` (context compaction), `doctor.sh` (check, and optionally install, the tool stack in `docs/TOOLING_MATRIX.md`), `registry.sh` (regenerate `.mwp/FEATURE_PRIORITY_REGISTRY.md` from every feature's `FEATURE_META.md` — never hand-edit the registry). |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Optional — which Claude surface to use per stage, if you're using Claude. **Travels with new products.** |
| `docs/PRIORITIZATION_GUIDE.md` | C-V-R scoring for product features. **Travels with new products.** |
| `docs/TOOLING_MATRIX.md` | Free/open-source tool stack. **Travels with new products.** |
| `docs/FAQ.md` | Answers to recurring meta-questions (is Claude required, can the framework develop itself, is that a PDLC, git/repo operational lessons). **Travels with new products.** |
| `hooks/post-commit` | Sample git hook a product repo can adopt to auto-refresh Graphify/Repomix on relevant commits. |
| `CLAUDE.md` | Root automation-routing rules Claude Code reads when working inside a product workspace built from this template. |
| `VERSION` | Plain incrementing number, bumped whenever an adopted change ships to `.mwp-templates/`, `scripts/`, or `CLAUDE.md`. Tells a product repo what point in this framework's history it started from — not whether it's current. **Travels with new products.** |
| `PROJECT_PLAN.md` | Planning history — how this framework's design decisions were made. **Framework-repo only, does not travel.** |
| `docs/evolution/` | Append-only log of this framework template's own design analyses, critiques, and changes — see `EVOLUTION_LOG.md` for the convention. **Framework-repo only, does not travel** (the convention is reusable for your own product if you want it — the specific entries aren't). |

## Core design

- **6 PDLC stages:** `01_discovery_ideation` → `02_definition_metrics` → `03_requirements_specs` → `04_architecture_design` → `05_development_test` → `06_validation_gtm`.
- **Micro-PDLC by default:** each feature gets its own isolated 01–06 pipeline under `features/FEAT-xxx/`. `scaffold.sh --sprint` supports Agile-PDLC (shared, time-boxed folders) as a fallback mode — same templates, different flag.
- **Lean overlay:** every stage contract forces a single riskiest-assumption / minimum-scope framing (Build → Measure → Learn), with `pivot.sh` as the kill-switch.
- **C-V-R prioritization:** score = (Context Cleanliness × Value Velocity) / Refactoring Risk. Foundational "Core Data Anchor" work bypasses the score and runs first, unconditionally.
- **Claude modality mapping (optional):** the folder/`CONTEXT.md` mechanism is agent-agnostic — any LLM agent that respects a stage's declared input scope can run it. If you're using Claude specifically, `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` suggests Chat/Desktop for stages 01–02, Cowork/Projects for 03–04, and Claude Code CLI for 05–06. This is a reference workflow, not a requirement — nothing in the scripts or stage contracts depends on it.
- **Token discipline:** every `CONTEXT.md` declares an explicit read-only input scope and an output token ceiling. Claude only ever sees the active stage folder plus declared upstream references — never the whole repo.

## Using this framework for a new product

```bash
# 1. Create a new, separate product repo (do not build inside this one)
mkdir ../my-new-product && cd ../my-new-product && git init

# 2. Copy the framework in
cp -r ../"PDLC - ICM-MWP"/.mwp-templates ./.mwp-templates
cp -r ../"PDLC - ICM-MWP"/scripts ./scripts
cp ../"PDLC - ICM-MWP"/CLAUDE.md ./CLAUDE.md
cp ../"PDLC - ICM-MWP"/VERSION ./VERSION
# The root VERSION file and each .mwp-templates/ file's `template-version`
# comment travel with this copy. They tell you what point in the framework's
# history you started from — not whether you're still current. There's no
# tooling yet that checks your copy against a newer framework version; that's
# a manual diff for now (see docs/evolution/0015-framework-and-template-versioning.md).

# 3. Copy the reference docs a product team actually needs day-to-day
mkdir -p ./docs
cp ../"PDLC - ICM-MWP"/docs/FAQ.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/CLAUDE_WORKFLOW_PLAYBOOK.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/PRIORITIZATION_GUIDE.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/TOOLING_MATRIX.md ./docs/
# note: docs/evolution/ and PROJECT_PLAN.md stay behind — they're about this
# framework template's own design history, not your product's. If you want to
# track your own product/architecture decisions the same way, start a fresh
# docs/evolution/ in your new repo — the convention travels even though the
# specific entries shouldn't.

# 4. Write your product's global context
cp .mwp-templates/GLOBAL_CONTEXT.template.md .mwp/GLOBAL_CONTEXT.md
# edit .mwp/GLOBAL_CONTEXT.md with your real stack, product name, constraints

# 5. Spin up your first feature (always a Core Data Anchor first)
bash scripts/scaffold.sh --feature FEAT-001_core_architecture_and_schema
```

## Known gaps this v1 addresses

The original design brainstorm flagged four production gaps; all four are implemented here rather than deferred:

1. **State sync** between stage `outputs/` and the next stage's `inputs/` → `scripts/sync.sh`.
2. **Context compaction** as a feature's files grow across iterations → `scripts/compact.sh`.
3. **Escalation on failure** instead of silent conversational loops → `.mwp-templates/CRITICAL_ESCALATION.md`, referenced by every stage contract.
4. **Shared/upstream sync** for schemas or components touched by multiple parallel features → documented in `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` under "Shared Architecture Sync."

## Status

v1 scaffold. Not yet pilot-tested end-to-end. Treat stage contracts and scripts as a strong starting point — expect to revise them after the first real feature runs through all 6 stages.

A first-principles critique of this v1 design already exists at `docs/evolution/0001-first-principles-analysis.md` — it identifies concrete trigger conditions for when the fixed 6-stage/C-V-R model should be replaced with a more general decision-dependency graph. No action needed until one of those triggers actually shows up.
