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

## Documentation map

| File | Audience | What belongs here |
|---|---|---|
| `README.md` | Anyone new to the framework | What it is, prerequisites, file map, how to start a new product from it. |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Teams using Claude specifically | Which Claude surface to use per stage — optional reference, not required by the scripts. |
| `docs/PRIORITIZATION_GUIDE.md` | Anyone scoring features | The C-V-R formula, worked examples. |
| `docs/TOOLING_MATRIX.md` | Anyone setting up the optional tool stack | Per-stage tool list, verified install commands. |
| `docs/CONSTRAINTS.md` | Anyone extending or auditing the framework | Every hard non-negotiable rule, why it exists, where it's enforced. |
| `docs/FAQ.md` | Anyone with a "why does it work this way" question | Recurring meta-questions and operational lessons that don't fit neatly elsewhere. |
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
6. Bump versions per entry `0015`'s system: `template-version` on any touched `.mwp-templates/` file, and root `VERSION` on any change shipped to `.mwp-templates/`, `scripts/`, `CLAUDE.md`, or a doc marked "Travels with new products." This is mandatory for every adoption now, not just versioning-related ones.
7. Revisit the "Known cross-entry collisions" list below — remove anything just resolved, add anything a newly-logged entry surfaces.

## Known cross-entry collisions

A living list of backlog entries that touch the same files, so they get planned around rather than each independently colliding. Revisited on every adoption per checklist step 7 above — entries move off this list once adopted and their collision is resolved.

*As of 2026-07-08 (post entries 0002–0005, 0008–0010, 0013, 0015–0018, 0023, 0025 adopted):*

- **0007 and 0012** both add a new `.mwp-templates/` product-init file (`PRODUCT_EVOLUTION_LOG_TEMPLATE.md` and a `LEARNINGS.md` template respectively) and both touch the same "Using this framework for a new product" copy-steps block in `README.md`. Batch their README edits rather than editing the same block twice independently.
- **0012's own stepwise plan pre-dates entry 0025's path-depth fix.** Its step 2 (add a `LEARNINGS.md` reference to each stage `CONTEXT.md`) was written using the old, now-corrected `../../` pattern as its implicit model. Whoever implements 0012 needs to use the current `../../../` depth (see `docs/evolution/0025-relative-path-depth-audit.md`), not copy the entry's literal old wording — a general risk worth watching for any older proposed entry that references a stage-relative path.
- **0011** edits `CLAUDE.md`'s "FAQ capture" section wording only — no file overlap with anything else currently in the backlog, but worth checking against whatever `CLAUDE.md` section the next entry to touch that file changes, since it's a single shared file.

*Resolved and removed from this list since the entry was first logged:* 0018 and 0012 both editing all six stage `CONTEXT.md` templates (0018 already landed; 0012's remaining edit is now tracked above as a path-depth caution instead) · 0003/0016 sharing `features/*/` scan logic (both landed, factored into `scripts/lib/scan_features.sh`) · 0016's last-sync column depending on 0009's `SYNC_LOG.md` (0009 landed first, so 0016 never needed its fallback path).

<!-- Not versioned via template-version — this file is framework-repo-only and doesn't travel to new products, but IS covered by an evolution-entry outcome each time it's updated. -->
