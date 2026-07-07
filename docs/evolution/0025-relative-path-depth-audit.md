# 0025 — Audit: Stage `CONTEXT.md` "Back to Root" Relative Paths May Be One Level Short

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** unranked — surfaced as a side-finding while implementing entry 0008, not yet slotted into the backlog ordering.

## Problem

Discovered while adding a `LESSONS_LEARNED.md` reference to `.mwp-templates/01_discovery_ideation/CONTEXT.md` (entry 0008, step 5): working out the correct relative path required counting directory depth from where a stage actually lives on disk, and the result doesn't match the depth already used elsewhere in the same file.

`scaffold.sh` creates each stage at `<product-root>/features/<FEATURE_NAME>/<stage>/`. That's three directory levels below product root. So from inside a stage folder, reaching something at product root (`.mwp/GLOBAL_CONTEXT.md`, `.mwp-templates/CRITICAL_ESCALATION.md`, `scripts/pivot.sh`, `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`) should need `../../../`, three levels up.

Every existing stage `CONTEXT.md` uses only `../../` (two levels) for these same references — e.g. stage 01's `READ ONLY: ../../.mwp/GLOBAL_CONTEXT.md` and `write BLOCKED_REASON.md per ../../.mwp-templates/CRITICAL_ESCALATION.md`. Two levels up from a stage folder lands in `features/`, not product root. By my count, that's one level short across the board:

- All 6 stages: the `CRITICAL_ESCALATION.md` reference in "On failure" (`../../.mwp-templates/CRITICAL_ESCALATION.md`).
- Stages 01–04: the `GLOBAL_CONTEXT.md` reference in "Input scope" (`../../.mwp/GLOBAL_CONTEXT.md`).
- Stage 04: the `CLAUDE_WORKFLOW_PLAYBOOK.md` reference (`../../docs/CLAUDE_WORKFLOW_PLAYBOOK.md`).
- Stage 06: the `pivot.sh` reference in "On Pivot" (`../../scripts/pivot.sh {{FEATURE_NAME}} --pivot`).

Sibling-stage references (e.g. stage 03's `READ ONLY: ../02_definition_metrics/outputs/OKR_Framework.md`) are internally consistent with a "stage folder is the working directory, one level up is the feature root" model — that part isn't in question. It's specifically the *product-root* references that look short by one level.

**Why this has gone unnoticed:** no script mechanically resolves these paths — they're prompt text an LLM agent reads and interprets, not something `scaffold.sh`/`sync.sh`/etc. ever opens as a real file path. A capable agent hitting a wrong relative path would likely just explore (`ls ../..`) and self-correct silently, so a real failure was never forced to the surface. This entry documents the finding; it does not fix it yet.

## Proposed change

Before editing anything, confirm the depth count against how an agent actually operates in practice (per `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`: Claude Code CLI is told to `cd` into the stage folder itself, e.g. stage 05's explicit instruction). If confirmed, change every "back to product root" reference across all 6 stage `CONTEXT.md` files from `../../` to `../../../`, bump each touched file's `template-version`, and bump root `VERSION`.

## Stepwise implementation plan (not yet executed)

1. Confirm the working-directory assumption with a human before mass-editing: is "stage folder is cwd" actually correct for every stage and every Claude surface (Chat/Cowork paste vs. Code CLI cd), or do Chat/Cowork's pasted-file workflows make the distinction moot for those stages (since there's no real filesystem cwd when content is pasted rather than navigated)?
2. If confirmed, update all 6 stage `CONTEXT.md` files: `../../.mwp/GLOBAL_CONTEXT.md` → `../../../.mwp/GLOBAL_CONTEXT.md` (stages 01–04), `../../.mwp-templates/CRITICAL_ESCALATION.md` → `../../../.mwp-templates/CRITICAL_ESCALATION.md` (all 6), `../../docs/CLAUDE_WORKFLOW_PLAYBOOK.md` → `../../../docs/CLAUDE_WORKFLOW_PLAYBOOK.md` (stage 04), `../../scripts/pivot.sh` → `../../../scripts/pivot.sh` (stage 06).
3. Bump `template-version` on every touched file; bump root `VERSION` once for the batch.
4. Spot-check by literally `cd`-ing into a scaffolded stage folder and resolving each corrected path with `ls` to confirm it lands on the right file, rather than trusting the arithmetic alone.
5. Note in the FAQ that this class of documentation-only path bug can exist silently because nothing mechanically checks it — worth remembering as a general caution, not just for this one fix.

## What happens if adopted

Fixes a documentation-accuracy gap that could cost a human or agent real time hunting for a file at a wrong path, especially for a newcomer to the framework who hasn't yet built the instinct to just `ls ../..` and self-correct. Low urgency (nothing has broken loudly from it yet) but low cost to fix once confirmed.
