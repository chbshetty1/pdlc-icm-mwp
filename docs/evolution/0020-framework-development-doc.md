# 0020 — Framework Development Documentation (`docs/DEVELOPMENT.md`)

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** see entry 0021 (unified ranking) — this entry doesn't carry its own standalone priority label, per the pattern already used for 0013–0018.

## Problem

Documentation for *developing this framework itself* (as opposed to using it) is scattered rather than missing outright: `EVOLUTION_LOG.md`'s "How to use this when evolving the framework" section covers the change-process, `FAQ.md`'s self-hosting answer covers the two contribution paths, and script conventions (`set -euo pipefail`, argument validation via a `usage()` function, testing changes in a scratch copy before touching committed files) were established through practice this session but never written down anywhere. Someone — including future sessions — has to reverse-engineer the pattern from reading every script rather than being told it once.

## Proposed change

One consolidated `docs/DEVELOPMENT.md`, framework-repo-only (like `docs/evolution/` and `PROJECT_PLAN.md` — it does not travel to new products, since it's about developing this framework, not building a product with it). It should not duplicate the evolution-log process already documented in `EVOLUTION_LOG.md` — it should point to that section rather than restate it.

Explicitly not in scope: per-script or per-stage-template documentation beyond what already exists (a short header comment per script, and the evolution entry that explains any non-obvious design choice). Adding a heavier documentation layer per component would cut against the same anti-bloat principle already applied to rejecting configurable logging and heavy inline comments elsewhere — the scripts are short enough to read directly.

## Stepwise implementation plan (not yet executed)

1. Write `docs/DEVELOPMENT.md` with three sections:
   - **Change process:** one paragraph, linking to `EVOLUTION_LOG.md`'s existing "How to use this" and "Proposed → Adopted workflow" sections rather than repeating them.
   - **Script conventions:** state explicitly what's been done implicitly — `set -euo pipefail` at the top of every script, a `usage()` function and argument validation before doing anything destructive, and the test pattern used throughout this session (copy the framework into a scratch directory, verify there, never test by mutating the committed repo directly).
   - **Documentation map:** a short table — one line per doc file (`README.md`, `docs/FAQ.md`, `docs/CONSTRAINTS.md` once 0017 lands, `docs/evolution/`, `PROJECT_PLAN.md`, this file) stating who it's for and what belongs in it, so future additions land in the right place on the first try.
2. Link `docs/DEVELOPMENT.md` from `README.md`'s file table, marked framework-repo-only alongside `docs/evolution/` and `PROJECT_PLAN.md`.
3. Cross-check it doesn't restate anything `EVOLUTION_LOG.md` or `FAQ.md` already say — link, don't duplicate.

## What happens if adopted

Anyone (including a future Claude session) who wants to modify this framework's own scripts or templates has one place to learn the conventions already in use, instead of inferring them from example — same discoverability benefit as 0017's `CONSTRAINTS.md`, applied to contribution mechanics instead of behavioral non-negotiables.
