# 0020 — Framework Development Documentation (`docs/DEVELOPMENT.md`)

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** ranked 15 of 20 by entry `0026`'s unified backlog re-prioritization (superseding the earlier 0021 reference above, which is itself superseded).

## Problem

Documentation for *developing this framework itself* (as opposed to using it) is scattered rather than missing outright: `EVOLUTION_LOG.md`'s "How to use this when evolving the framework" section covers the change-process, `FAQ.md`'s self-hosting answer covers the two contribution paths, and script conventions (`set -euo pipefail`, argument validation via a `usage()` function, testing changes in a scratch copy before touching committed files) were established through practice this session but never written down anywhere. Someone — including future sessions — has to reverse-engineer the pattern from reading every script rather than being told it once.

## Proposed change

One consolidated `docs/DEVELOPMENT.md`, framework-repo-only (like `docs/evolution/` and `PROJECT_PLAN.md` — it does not travel to new products, since it's about developing this framework, not building a product with it). It should not duplicate the evolution-log process already documented in `EVOLUTION_LOG.md` — it should point to that section rather than restate it.

Explicitly not in scope: per-script or per-stage-template documentation beyond what already exists (a short header comment per script, and the evolution entry that explains any non-obvious design choice). Adding a heavier documentation layer per component would cut against the same anti-bloat principle already applied to rejecting configurable logging and heavy inline comments elsewhere — the scripts are short enough to read directly.

## Stepwise implementation plan (not yet executed)

1. Write `docs/DEVELOPMENT.md` with five sections:
   - **Change process:** one paragraph, linking to `EVOLUTION_LOG.md`'s existing "How to use this" and "Proposed → Adopted workflow" sections rather than repeating them.
   - **Script conventions:** state explicitly what's been done implicitly — `set -euo pipefail` at the top of every script, a `usage()` function and argument validation before doing anything destructive, and the test pattern used throughout this session (copy the framework into a scratch directory, verify there, never test by mutating the committed repo directly).
   - **Documentation map:** a short table — one line per doc file (`README.md`, `docs/FAQ.md`, `docs/CONSTRAINTS.md` once 0017 lands, `docs/evolution/`, `PROJECT_PLAN.md`, this file) stating who it's for and what belongs in it, so future additions land in the right place on the first try.
   - **General adoption checklist:** the set of docs to check for *any* adopted entry, not just specific ones — `README.md`'s file table (if a new script/doc was created), `docs/FAQ.md` (if user-facing behavior changed), `docs/CONSTRAINTS.md` (if a new non-negotiable was established), and — once entry 0015 lands — bumping `VERSION` and/or the relevant `template-version` marker, which becomes a mandatory step for every subsequent adoption, not just entries about versioning.
   - **Known cross-entry collisions:** a short list of backlog entries that touch the same files, so they get batched rather than edited twice — as of this writing: 0018 and 0012 both edit all six stage `CONTEXT.md` templates; 0007, 0008, and 0012 each add a new product-init template file and all touch the same section of `README.md`'s copy steps; 0003 and 0016 share `features/*/` scan logic and should share a helper; 0016's last-synced column depends on 0009's `SYNC_LOG.md` existing (it degrades gracefully if not, per 0016's own plan, but is more complete if 0009 lands first — see entry 0022's re-prioritization).
2. Link `docs/DEVELOPMENT.md` from `README.md`'s file table, marked framework-repo-only alongside `docs/evolution/` and `PROJECT_PLAN.md`.
3. Cross-check it doesn't restate anything `EVOLUTION_LOG.md` or `FAQ.md` already say — link, don't duplicate.
4. Revisit the "Known cross-entry collisions" list each time a new entry is logged — it's expected to grow and shrink as entries get adopted.

## What happens if adopted

Anyone (including a future Claude session) who wants to modify this framework's own scripts or templates has one place to learn the conventions already in use, instead of inferring them from example — same discoverability benefit as 0017's `CONSTRAINTS.md`, applied to contribution mechanics instead of behavioral non-negotiables.

## Outcome (2026-07-08)

All 4 steps executed, with the collision list rewritten rather than copied verbatim:

1. `docs/DEVELOPMENT.md` written with the five planned sections. Change process links to `EVOLUTION_LOG.md` rather than restating it. Script conventions state the `set -euo pipefail` / `usage()` + validation / scratch-copy-testing pattern explicitly for the first time. Documentation map covers all 9 doc files currently in the repo, including `docs/CONSTRAINTS.md` (landed via entry 0017, after this entry was originally written) and this file itself. General adoption checklist folds in entry 0015's versioning step as mandatory, per the original plan's instruction.
2. Linked from `README.md`'s file table, marked framework-repo-only alongside `docs/evolution/` and `PROJECT_PLAN.md`.
3. Cross-checked against `EVOLUTION_LOG.md` and `docs/FAQ.md` for duplication — none found; `docs/FAQ.md`'s self-hosting answer updated with a one-line pointer to this file instead (whether/when to self-host stays in the FAQ, how stays here).
4. **Known cross-entry collisions rewritten for current state**, not copied from the entry's original text — most of the originally-listed collisions (0018/0012 on stage `CONTEXT.md`, 0003/0016 sharing scan logic, 0016 depending on 0009's `SYNC_LOG.md`) are now resolved since those entries have since landed. Replaced with what's actually still live: 0007 and 0012 both still pending, both adding a template file and touching the same `README.md` copy-steps block; and a new one surfaced during this review — entry 0012's own stepwise plan pre-dates entry 0025's path-depth fix and still models its `CONTEXT.md` reference on the old `../../` pattern, so whoever implements 0012 needs to use the corrected `../../../` depth rather than the entry's literal original wording.

No `template-version` or root `VERSION` bump — `docs/DEVELOPMENT.md` and the `README.md` edit are both framework-repo-only and don't travel to new products, so nothing shipped per entry `0015`'s versioning rule.
