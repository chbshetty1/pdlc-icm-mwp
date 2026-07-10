# PDLC – ICM/MWP Framework

A reusable, standalone framework that applies the **Interpretable Context Methodology (ICM)** and its **Model Workspace Protocol (MWP)** — Van Clief & McDermott, arXiv 2603.16021 — to a full **Product Development Life Cycle (PDLC)**.

This repo is the **engine block**, not a product. It contains no live product data. When you start a new product, run `scripts/scaffold.sh` against a *new, separate* product repository — never directly inside this one — to generate that product's active workspace from these templates.

## Prerequisites

`scripts/*.sh` are bash scripts. On Windows, run them from **Git Bash** or **WSL** — plain PowerShell/cmd cannot execute `.sh` files directly. Verified working from Git Bash (`bash scripts/scaffold.sh ...`, `bash scripts/sync.sh ...`, `bash scripts/pivot.sh ...`) — see `docs/evolution/0002-cross-platform-script-verification.md`.

On Windows, if you're not sure whether Git Bash or WSL is even installed, run `.\scripts\preflight.ps1` from plain PowerShell first — it checks for `bash` on PATH and prints install guidance if it's missing, instead of you hitting a raw "command not found" the first time you try a `scripts/*.sh` file. Detection only, doesn't install anything for you. See `docs/evolution/0023-powershell-bash-preflight-check.md`.

The optional per-stage tools (Fabric, Graphify, Repomix, Mermaid CLI, DuckDB, Obsidian) are a separate set of prerequisites with their own install steps — see `docs/TOOLING_MATRIX.md` (includes a Windows `winget` PATH gotcha found while verifying this). Verification status: `docs/evolution/0013-verify-tooling-matrix.md`.

**Three first-run gotchas found actually using this on a real Windows machine, not just verifying it in a sandbox (entry `0048`):**

1. bash never treats `\` as a path separator — only `/`, on Windows or anywhere else. A path like `..\..\some folder\script.sh` passed to bash is treated as one literal filename containing backslash characters, not nested directories, and fails with a confusing "No such file or directory" even though the file genuinely exists. Use forward slashes in any path you hand to bash, regardless of what you're used to typing in Windows Explorer or PowerShell.
2. More than one program can answer to `bash` on a Windows PATH — Git Bash's own `bash.exe` and WSL's are both real possibilities, and they resolve the same drive differently (Git Bash: `/d/Projects/...`; WSL: `/mnt/d/Projects/...`). This repo's own verification (entry `0002`) was against Git Bash specifically — if something behaves unexpectedly, run `which bash` to confirm which one actually ran, or open an actual Git Bash terminal window rather than invoking `bash` as a one-off command from inside PowerShell.
3. A brand-new machine's first `git commit` anywhere fails with `Author identity unknown` until `git config --global user.name`/`user.email` are set once. Nothing specific to this framework, but easy to hit for the first time exactly when scaffolding a first product repo.

## What's in here

| Path | Purpose |
|---|---|
| `.mwp-templates/` | Blueprint files copied into every new product workspace: global identity, stage contracts (6 PDLC stages), escalation template, feature-metadata template, lessons-learned register template, a product-repo `.gitignore` template (see entry `0048` — deliberately not a copy of this repo's own `.gitignore`), and a reference copy of the generated priority-registry format. |
| `scripts/` | Automation: `scaffold.sh` (spin up a new feature/sprint workspace — features also get a `FEATURE_META.md` for C-V-R scoring; sprints don't, since they aren't a single scored hypothesis the way a feature is), `sync.sh` (advance approved outputs to the next stage — warns on token-guardrail overruns, blocks and auto-escalates on a shared-path collision or a detected hardcoded credential (both now also logged to `GUARDRAIL_LOG.md`, see entry 0044), folds each stage's `Learnings_Note.md` into `LEARNINGS.md`, logs an optional `[approver]` to `SYNC_LOG.md`), `pivot.sh` (Lean kill-switch — also distills a summary row into `LESSONS_LEARNED.md` and folds stage 06's `Learnings_Note.md` into `LEARNINGS.md` before purging a killed feature), `compact.sh` (context compaction), `doctor.sh` (check, and optionally install, the tool stack in `docs/TOOLING_MATRIX.md`), `registry.sh` (regenerate `.mwp/FEATURE_PRIORITY_REGISTRY.md` from every feature's `FEATURE_META.md` — never hand-edit the registry), `status.sh` (on-demand per-feature + stage-level rollup of what's blocked or in-progress, no alerting), `audit_manifest.sh` (on-demand: flags a stage's self-reported `Context_Manifest.md` reads not covered by its `CONTEXT.md`'s declared scope — advisory only, mechanizes entry 0018's existing human cross-check, see entry 0044), `lib/scan_features.sh` (shared `features/*/`/`sprints/*/` scan helper used by `registry.sh` and `status.sh`), `lib/stages.sh` (single source for the 6 stage names, used by `scaffold.sh` and `status.sh`), `lib/log.sh` (shared operational-log helper — every script above appends one line per invocation to `.mwp/framework.log` via a `trap ... EXIT`, no levels, no per-stage config). All 8 top-level scripts respond to `-h`/`--help`. |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Optional — which Claude surface to use per stage, if you're using Claude. **Travels with new products.** |
| `docs/PRIORITIZATION_GUIDE.md` | C-V-R scoring for product features. **Travels with new products.** |
| `docs/TOOLING_MATRIX.md` | Free/open-source tool stack. **Travels with new products.** |
| `docs/CONSTRAINTS.md` | Every framework-level non-negotiable in one place (scope containment, no auto-install, no alerting, escalation rules, etc.), each with a reason and a pointer to where it's actually enforced. **Travels with new products.** |
| `docs/FAQ.md` | Answers to recurring meta-questions (is Claude required, can the framework develop itself, is that a PDLC, git/repo operational lessons). **Travels with new products.** |
| `docs/MIGRATIONS.md` | One row per MAJOR `VERSION` bump — what broke, what a product repo on an older version needs to do about it. See `docs/evolution/0029-tiered-version-scheme.md`. **Travels with new products.** |
| `hooks/post-commit` | Sample git hook a product repo can adopt to auto-refresh Graphify/Repomix on relevant commits. |
| `hooks/pre-commit` | Sample git hook — blocks a commit containing a credential-shaped string (reuses `sync.sh`'s entry 0034 secrets-guardrail patterns). Optional, not auto-installed, bypass with `git commit --no-verify`. See `docs/evolution/0040-precommit-secrets-hook.md`. |
| `CLAUDE.md` | Root automation-routing rules Claude Code reads when working inside a product workspace built from this template. |
| `VERSION` | `MAJOR.MINOR.PATCH`, bumped whenever an adopted change ships to `.mwp-templates/`, `scripts/`, or `CLAUDE.md` — tier chosen per entry `0029`'s rules (patch = doc wording only, minor = backward-compatible addition, major = could break something already scaffolded). Tells a product repo what point in this framework's history it started from — not whether it's current. Check `docs/MIGRATIONS.md` if the major number is behind. **Travels with new products.** |
| `PROJECT_PLAN.md` | Planning history — how this framework's design decisions were made. **Framework-repo only, does not travel.** |
| `docs/evolution/` | Append-only log of this framework template's own design analyses, critiques, and changes — see `EVOLUTION_LOG.md` for the convention. **Framework-repo only, does not travel** (the convention is reusable for your own product if you want it — the specific entries aren't). |
| `docs/DEVELOPMENT.md` | How to develop *this framework itself* — change process, script conventions, doc map, adoption checklist, known cross-entry collisions, testing. **Framework-repo only, does not travel.** |
| `docs/PILOT_MEASUREMENT_PLAN.md` | Tiered metrics for the first real end-to-end pilot (what's free to compute today, what needs a small addition, what's deliberately deferred), plus the counterfactual decision entry `0042` requires and a pre-pilot TODO checklist. See `docs/evolution/0043-pilot-measurement-plan.md`. **Framework-repo only, does not travel.** |
| `tests/` | Dependency-free bash test harness (`run_tests.sh` + `test_*.sh` suites, no `bats-core`) covering `scripts/*.sh` — regression protection for previously-documented gotchas (e.g. entry `0014`'s `$?`-trap bug) plus smoke coverage for the rest. See `docs/evolution/0030-script-test-harness.md`. **Framework-repo only, does not travel.** |
| `.github/workflows/test.yml` | Runs `tests/run_tests.sh` on every push/PR to `main` — catches a script regression before it reaches `main` instead of relying on someone running the suite by hand. See `docs/evolution/0041-ci-workflow.md`. **Framework-repo only, does not travel** (meaningless without `tests/`, which doesn't travel either). |

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
# automated tooling yet that checks your copy against a newer framework
# version, but VERSION is now tiered (MAJOR.MINOR.PATCH, see
# docs/evolution/0029-tiered-version-scheme.md): if only the framework's
# minor/patch numbers moved since you copied, it's safe to skip straight to
# latest. If the major number moved, read docs/MIGRATIONS.md first — every
# breaking change gets a row there (see docs/evolution/0015-framework-and-template-versioning.md
# for why versioning exists at all).

# 3. Set up this product's own .gitignore -- NOT a copy of the framework
# repo's own .gitignore (that one deliberately ignores features/, sprints/,
# and .mwp/GLOBAL_CONTEXT.md, which is correct only because the framework
# repo must never accumulate live product data -- a product repo needs
# exactly those tracked). Do this before your first commit, not after.
# See docs/evolution/0048-product-gitignore-and-windows-first-run-gaps.md.
cp .mwp-templates/GITIGNORE.template ./.gitignore

# 4. Copy the reference docs a product team actually needs day-to-day
mkdir -p ./docs
cp ../"PDLC - ICM-MWP"/docs/FAQ.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/CLAUDE_WORKFLOW_PLAYBOOK.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/PRIORITIZATION_GUIDE.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/TOOLING_MATRIX.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/CONSTRAINTS.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/MIGRATIONS.md ./docs/

# 5. Set up this product's own evolution log (its architecture/decision
# history — separate from the framework's own docs/evolution/, which stays
# behind and does not copy over). Starts empty; only the convention travels,
# not the framework's specific entries.
mkdir -p ./docs/evolution
cp .mwp-templates/PRODUCT_EVOLUTION_LOG_TEMPLATE.md ./docs/evolution/EVOLUTION_LOG.md

# 6. Write your product's global context, and set up the incidental-
# learnings register alongside it (append-only, distinct from
# GLOBAL_CONTEXT.md's deliberate constraints — see LEARNINGS.md's own header)
cp .mwp-templates/GLOBAL_CONTEXT.template.md .mwp/GLOBAL_CONTEXT.md
cp .mwp-templates/LEARNINGS.template.md ./LEARNINGS.md
# edit .mwp/GLOBAL_CONTEXT.md with your real stack, product name, constraints

# 7. Set up the lessons-learned register (pivot.sh will also self-create this
# on the first --pivot if you skip this step, but copying it now keeps its
# header/instructions intact from the start)
cp .mwp-templates/LESSONS_LEARNED.template.md ./LESSONS_LEARNED.md

# 8. Spin up your first feature (always a Core Data Anchor first)
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

A second, differently-shaped critique — an external critical-theory audit rather than internal first-principles analysis — exists at `docs/evolution/0042-critical-theory-audit.md`. Its core finding: nothing built or tested so far (203 passing script assertions included) actually validates the framework's real thesis, that folder-scoped context outperforms the alternatives — that claim stays untested until a real pilot runs. See that entry for its own trigger conditions.
