#!/bin/bash
# One-time helper: splits the working-tree changes into two commits, one for
# entry 0029 (tiered VERSION scheme) and one for entry 0030 (test harness),
# even though both touched docs/DEVELOPMENT.md, README.md, docs/FAQ.md, and
# docs/evolution/EVOLUTION_LOG.md. Run this once from Git Bash at the repo
# root, then delete it (it deletes itself at the end).
set -euo pipefail

if [ ! -f "VERSION" ] || [ ! -d "docs/evolution" ]; then
  echo "Run this from the PDLC - ICM-MWP repo root." >&2
  exit 1
fi

# --- Back up the current (final, post-0030) shared files ---
cp docs/DEVELOPMENT.md docs/DEVELOPMENT.md.final
cp README.md README.md.final
cp docs/FAQ.md docs/FAQ.md.final
cp docs/evolution/EVOLUTION_LOG.md docs/evolution/EVOLUTION_LOG.md.final

# --- Rewrite the 4 shared files back to their "after 0029, before 0030" state ---

cat > docs/DEVELOPMENT.md <<'DEVEOF'
# Developing This Framework

This file is about *developing this framework template itself* — not about using it to build a product. If you're building a product with this framework, you don't need this file; see `README.md` instead. Framework-repo-only: like `docs/evolution/` and `PROJECT_PLAN.md`, this does not travel to new products.

## Change process

Every substantive change to this framework goes through `docs/evolution/` first — write an entry, then implement it in the same commit as marking it `adopted`. The full convention, status values, and the "Proposed → Adopted workflow" (pick an entry, run its plan, record the outcome, update statuses, bump versions) already live in `docs/evolution/EVOLUTION_LOG.md`'s "How to use this when evolving the framework" and "Proposed → Adopted workflow" sections — this file doesn't repeat that, it just points to it.

## Script conventions

Established through practice across every script in `scripts/`, stated explicitly here so they don't have to be reverse-engineered from example:

- **`set -euo pipefail`** at the top of every script — fail fast and loud rather than continuing past an error or an unset variable.
- **A `usage()` function plus argument validation** before doing anything destructive (creating directories, deleting files, writing output). If required arguments are missing or malformed, print usage and exit non-zero before touching the filesystem.
- **Test in a scratch copy, never against the committed repo directly.** The pattern used throughout this framework's own development: copy the relevant scripts/templates into a temporary directory (or the agent sandbox's own scratch space — see the FAQ's note on sandbox-mount staleness if testing from an agent environment), run the change there, confirm the output, only then consider it verified. Never `rm -rf` or mutate this repo's own tree as a test.
- **Fail via the escalation contract, not silently.** A script hitting a genuinely blocking condition (missing dependency, ambiguous state) should point at `CRITICAL_ESCALATION.md`'s pattern rather than a bare stack trace or "command not found."
- **Log every invocation via `trap ... EXIT`, not manual calls before each exit point.** `scripts/lib/log.sh`'s `log_invocation` is wired into every script this way (entry `0014`) so it fires exactly once regardless of which exit path a script takes — success, an early usage-error `exit 1`, or `set -e` catching an unhandled error — without needing to track down every scattered `exit` statement by hand. **Known gotcha, worth remembering:** capture `$?` into a variable as its own statement first — `trap 'EC=$?; log_invocation ... "$EC"' EXIT` — never reference `"$?"` directly inside a trap command string that also contains a command substitution like `$(basename "$0")` earlier in the same argument list. Word expansions happen left to right, and the command substitution's own exit status silently overwrites `$?` before it gets read, always logging `exit=0` regardless of what actually happened. Caught this exact bug while testing entry `0014` — a bad-usage call was logging as a success until the capture-first fix went in.

## Documentation map

| File | Audience | What belongs here |
|---|---|---|
| `README.md` | Anyone new to the framework | What it is, prerequisites, file map, how to start a new product from it. |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Teams using Claude specifically | Which Claude surface to use per stage — optional reference, not required by the scripts. |
| `docs/PRIORITIZATION_GUIDE.md` | Anyone scoring features | The C-V-R formula, worked examples. |
| `docs/TOOLING_MATRIX.md` | Anyone setting up the optional tool stack | Per-stage tool list, verified install commands. |
| `docs/CONSTRAINTS.md` | Anyone extending or auditing the framework | Every hard non-negotiable rule, why it exists, where it's enforced. |
| `docs/FAQ.md` | Anyone with a "why does it work this way" question | Recurring meta-questions and operational lessons that don't fit neatly elsewhere. |
| `docs/MIGRATIONS.md` | Anyone upgrading a product repo's copy of the framework | One row per MAJOR `VERSION` bump — what broke, what to do about it. See entry `0029`. |
| `docs/evolution/` (this file's sibling, `EVOLUTION_LOG.md` + numbered entries) | Framework contributors | The append-only record of every design decision — what changed, why, and what it superseded. |
| `docs/DEVELOPMENT.md` (this file) | Framework contributors | How to actually make a change — script conventions, doc map, adoption checklist. |
| `PROJECT_PLAN.md` | Framework contributors, historical reference | How this framework's original design decisions were made, pre-`docs/evolution/`. |

## General adoption checklist

Applies to *every* adopted entry, not just entries specifically about documentation or versioning:

1. Update the entry file itself: append an "Outcome" section, change `Status` to `adopted`.
2. Update `docs/evolution/EVOLUTION_LOG.md`'s table row to match.
3. If a new script or doc file was created, add it to `README.md`'s file table.
4. If user-facing behavior changed (a script's output, a template's contract), check whether `docs/FAQ.md` needs a new or updated entry.
5. If a new non-negotiable rule was established (or an existing one changed), update `docs/CONSTRAINTS.md`.
6. Bump versions per entry `0015`'s system (tiered per entry `0029`): `template-version` on any touched `.mwp-templates/` file, and root `VERSION` — `MAJOR.MINOR.PATCH` — on any change shipped to `.mwp-templates/`, `scripts/`, `CLAUDE.md`, or a doc marked "Travels with new products." Pick the tier honestly, don't default to the smallest:
   - **PATCH** — doc-only wording/typo/comment fixes, zero behavioral or structural effect on an already-scaffolded product.
   - **MINOR** — backward-compatible additions (new optional script flag, new template file, new FAQ entry, new optional `CONTEXT.md` reference). Nothing already scaffolded breaks by staying on an older minor version.
   - **MAJOR** — could break or silently miscopy something already scaffolded (renamed/removed template file, changed script argument behavior, changed `CONTEXT.md` contract shape, a load-bearing path/logic fix — entry `0025` would have qualified had this scheme existed then).
   This is mandatory for every adoption now, not just versioning-related ones.
7. If the bump was MAJOR, add a row to `docs/MIGRATIONS.md` describing what changed and what a product repo on an older version must do about it. PATCH/MINOR bumps don't get a row — they're backward-compatible by definition.
8. Revisit the "Known cross-entry collisions" list below — remove anything just resolved, add anything a newly-logged entry surfaces.

## Known cross-entry collisions

A living list of backlog entries that touch the same files, so they get planned around rather than each independently colliding. Revisited on every adoption per checklist step 7 above — entries move off this list once adopted and their collision is resolved.

*As of 2026-07-08 (all 21 ranked backlog entries, 0001–0028, are resolved — adopted or superseded; entries 0029+ are additional, logged from external research rather than the ranked backlog):*

- **0030** (bats-core test harness, if/when logged) will touch every file under `scripts/` to add coverage — no behavioral edits expected, but read each script's current post-0014/0027 shape directly before writing assertions against it, same caution as every entry in this list gets. Not a collision with 0029, since 0029 touches only `VERSION`, `docs/MIGRATIONS.md`, `docs/DEVELOPMENT.md`, `README.md`, and `docs/FAQ.md` — no shared files with a test harness entry.

*Resolved and removed from this list since the entry was first logged:* 0018 and 0012 both editing all six stage `CONTEXT.md` templates (both landed) · 0003/0016 sharing `features/*/` scan logic (both landed, factored into `scripts/lib/scan_features.sh`) · 0016's last-sync column depending on 0009's `SYNC_LOG.md` (0009 landed first) · 0007/0012 both touching the same `README.md` copy-steps block (both landed sequentially without conflict) · 0012's stepwise plan pre-dating entry 0025's path-depth fix (resolved differently than originally expected — see `docs/evolution/0012-shared-learnings-file.md`'s Outcome) · 0014 touching every script in `scripts/` (landed; `sync.sh`/`pivot.sh`'s post-0012 shape was read directly rather than assumed, as this list itself had flagged) · 0027 (`scaffold.sh --sprint` dead-weight `FEATURE_META.md`, resolved by skipping creation for sprint mode).

<!-- Not versioned via template-version — this file is framework-repo-only and doesn't travel to new products, but IS covered by an evolution-entry outcome each time it's updated. -->
DEVEOF

cat > README.md <<'READMEEOF'
# PDLC – ICM/MWP Framework

A reusable, standalone framework that applies the **Interpretable Context Methodology (ICM)** and its **Model Workspace Protocol (MWP)** — Van Clief & McDermott, arXiv 2603.16021 — to a full **Product Development Life Cycle (PDLC)**.

This repo is the **engine block**, not a product. It contains no live product data. When you start a new product, run `scripts/scaffold.sh` against a *new, separate* product repository — never directly inside this one — to generate that product's active workspace from these templates.

## Prerequisites

`scripts/*.sh` are bash scripts. On Windows, run them from **Git Bash** or **WSL** — plain PowerShell/cmd cannot execute `.sh` files directly. Verified working from Git Bash (`bash scripts/scaffold.sh ...`, `bash scripts/sync.sh ...`, `bash scripts/pivot.sh ...`) — see `docs/evolution/0002-cross-platform-script-verification.md`.

On Windows, if you're not sure whether Git Bash or WSL is even installed, run `.\scripts\preflight.ps1` from plain PowerShell first — it checks for `bash` on PATH and prints install guidance if it's missing, instead of you hitting a raw "command not found" the first time you try a `scripts/*.sh` file. Detection only, doesn't install anything for you. See `docs/evolution/0023-powershell-bash-preflight-check.md`.

The optional per-stage tools (Fabric, Graphify, Repomix, Mermaid CLI, DuckDB, Obsidian) are a separate set of prerequisites with their own install steps — see `docs/TOOLING_MATRIX.md` (includes a Windows `winget` PATH gotcha found while verifying this). Verification status: `docs/evolution/0013-verify-tooling-matrix.md`.

## What's in here

| Path | Purpose |
|---|---|
| `.mwp-templates/` | Blueprint files copied into every new product workspace: global identity, stage contracts (6 PDLC stages), escalation template, feature-metadata template, lessons-learned register template, and a reference copy of the generated priority-registry format. |
| `scripts/` | Automation: `scaffold.sh` (spin up a new feature/sprint workspace — features also get a `FEATURE_META.md` for C-V-R scoring; sprints don't, since they aren't a single scored hypothesis the way a feature is), `sync.sh` (advance approved outputs to the next stage — warns on token-guardrail overruns, checks for shared-path collisions, folds each stage's `Learnings_Note.md` into `LEARNINGS.md`, logs an optional `[approver]` to `SYNC_LOG.md`), `pivot.sh` (Lean kill-switch — also distills a summary row into `LESSONS_LEARNED.md` and folds stage 06's `Learnings_Note.md` into `LEARNINGS.md` before purging a killed feature), `compact.sh` (context compaction), `doctor.sh` (check, and optionally install, the tool stack in `docs/TOOLING_MATRIX.md`), `registry.sh` (regenerate `.mwp/FEATURE_PRIORITY_REGISTRY.md` from every feature's `FEATURE_META.md` — never hand-edit the registry), `status.sh` (on-demand per-feature + stage-level rollup of what's blocked or in-progress, no alerting), `lib/scan_features.sh` (shared `features/*/`/`sprints/*/` scan helper used by `registry.sh` and `status.sh`), `lib/log.sh` (shared operational-log helper — every script above appends one line per invocation to `.mwp/framework.log` via a `trap ... EXIT`, no levels, no per-stage config). |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Optional — which Claude surface to use per stage, if you're using Claude. **Travels with new products.** |
| `docs/PRIORITIZATION_GUIDE.md` | C-V-R scoring for product features. **Travels with new products.** |
| `docs/TOOLING_MATRIX.md` | Free/open-source tool stack. **Travels with new products.** |
| `docs/CONSTRAINTS.md` | Every framework-level non-negotiable in one place (scope containment, no auto-install, no alerting, escalation rules, etc.), each with a reason and a pointer to where it's actually enforced. **Travels with new products.** |
| `docs/FAQ.md` | Answers to recurring meta-questions (is Claude required, can the framework develop itself, is that a PDLC, git/repo operational lessons). **Travels with new products.** |
| `docs/MIGRATIONS.md` | One row per MAJOR `VERSION` bump — what broke, what a product repo on an older version needs to do about it. See `docs/evolution/0029-tiered-version-scheme.md`. **Travels with new products.** |
| `hooks/post-commit` | Sample git hook a product repo can adopt to auto-refresh Graphify/Repomix on relevant commits. |
| `CLAUDE.md` | Root automation-routing rules Claude Code reads when working inside a product workspace built from this template. |
| `VERSION` | `MAJOR.MINOR.PATCH`, bumped whenever an adopted change ships to `.mwp-templates/`, `scripts/`, or `CLAUDE.md` — tier chosen per entry `0029`'s rules (patch = doc wording only, minor = backward-compatible addition, major = could break something already scaffolded). Tells a product repo what point in this framework's history it started from — not whether it's current. Check `docs/MIGRATIONS.md` if the major number is behind. **Travels with new products.** |
| `PROJECT_PLAN.md` | Planning history — how this framework's design decisions were made. **Framework-repo only, does not travel.** |
| `docs/evolution/` | Append-only log of this framework template's own design analyses, critiques, and changes — see `EVOLUTION_LOG.md` for the convention. **Framework-repo only, does not travel** (the convention is reusable for your own product if you want it — the specific entries aren't). |
| `docs/DEVELOPMENT.md` | How to develop *this framework itself* — change process, script conventions, doc map, adoption checklist, known cross-entry collisions. **Framework-repo only, does not travel.** |

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

# 3. Copy the reference docs a product team actually needs day-to-day
mkdir -p ./docs
cp ../"PDLC - ICM-MWP"/docs/FAQ.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/CLAUDE_WORKFLOW_PLAYBOOK.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/PRIORITIZATION_GUIDE.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/TOOLING_MATRIX.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/CONSTRAINTS.md ./docs/
cp ../"PDLC - ICM-MWP"/docs/MIGRATIONS.md ./docs/

# 4. Set up this product's own evolution log (its architecture/decision
# history — separate from the framework's own docs/evolution/, which stays
# behind and does not copy over). Starts empty; only the convention travels,
# not the framework's specific entries.
mkdir -p ./docs/evolution
cp .mwp-templates/PRODUCT_EVOLUTION_LOG_TEMPLATE.md ./docs/evolution/EVOLUTION_LOG.md

# 5. Write your product's global context, and set up the incidental-
# learnings register alongside it (append-only, distinct from
# GLOBAL_CONTEXT.md's deliberate constraints — see LEARNINGS.md's own header)
cp .mwp-templates/GLOBAL_CONTEXT.template.md .mwp/GLOBAL_CONTEXT.md
cp .mwp-templates/LEARNINGS.template.md ./LEARNINGS.md
# edit .mwp/GLOBAL_CONTEXT.md with your real stack, product name, constraints

# 6. Set up the lessons-learned register (pivot.sh will also self-create this
# on the first --pivot if you skip this step, but copying it now keeps its
# header/instructions intact from the start)
cp .mwp-templates/LESSONS_LEARNED.template.md ./LESSONS_LEARNED.md

# 7. Spin up your first feature (always a Core Data Anchor first)
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
READMEEOF

# docs/FAQ.md and docs/evolution/EVOLUTION_LOG.md: strip out the 0030-era
# (and later) additions via sed rather than a full rewrite, since they're
# large and this is safer than retyping them by hand.
sed -i '/under any kind of automated test coverage/,/Can I `--pivot` a sprint the same way/{ /Can I `--pivot` a sprint the same way/!d }' docs/FAQ.md
sed -i '/How do we come up with requirements for this framework/,/Where does that operational log actually live/{ /Where does that operational log actually live/!d }' docs/FAQ.md
sed -i '/^| 0030 |/d' docs/evolution/EVOLUTION_LOG.md

# --- Commit 1: entry 0029 ---
git add VERSION docs/MIGRATIONS.md docs/evolution/0029-tiered-version-scheme.md \
        docs/DEVELOPMENT.md README.md docs/FAQ.md docs/evolution/EVOLUTION_LOG.md
git commit -F - <<'MSG1EOF'
Adopt entry 0029: tiered (SemVer-style) VERSION scheme

- VERSION changed from a flat integer to MAJOR.MINOR.PATCH (19 -> 20.0.0)
- New docs/MIGRATIONS.md: one row per MAJOR bump, what broke and what a
  product repo on an older version needs to do about it
- docs/DEVELOPMENT.md: explicit patch/minor/major bump criteria added to
  the adoption checklist
- README.md, docs/FAQ.md updated to match

No script parses VERSION programmatically (confirmed before implementing),
so the format change has no code-side fallout. Surfaced from external
research (a user-supplied source), not the ranked backlog -- see
docs/evolution/EVOLUTION_LOG.md's footer note.
MSG1EOF

# --- Restore final (post-0030) shared-file state for commit 2 ---
mv docs/DEVELOPMENT.md.final docs/DEVELOPMENT.md
mv README.md.final README.md
mv docs/FAQ.md.final docs/FAQ.md
mv docs/evolution/EVOLUTION_LOG.md.final docs/evolution/EVOLUTION_LOG.md

# --- Commit 2: entry 0030 (+ the follow-up FAQ addition) ---
git add -A
git commit -F - <<'MSG2EOF'
Adopt entry 0030: dependency-free test harness for scripts/*.sh

- New tests/ directory: bash-only test harness (no bats-core -- couldn't
  be installed in the dev sandbox, no root/network egress to any package
  registry) covering all 7 scripts/*.sh files
- 7 suites, 62 assertions: prioritizes regression protection for entry
  0014's $?-trap logging bug and entry 0027's --sprint FEATURE_META.md
  fix, plus core-contract coverage for the rest (token guardrail, shared-
  path collision, learnings folding, C-V-R sorting, etc.)
- docs/DEVELOPMENT.md: new "Testing this framework" section, adoption
  checklist step to run tests/run_tests.sh, doc map + collisions list
  updated
- README.md, docs/FAQ.md updated to match

Also includes a follow-up docs/FAQ.md entry (not part of entry 0030's own
plan): where this framework's own requirements come from, and whether now
is a good time to gather them deliberately -- prompted by a question in
the same session, answered from entries 0001, 0025, 0027, 0029, 0030.
MSG2EOF

# --- Clean up ---
rm -f "$0"
echo "Done. Two commits created. This script has deleted itself."
