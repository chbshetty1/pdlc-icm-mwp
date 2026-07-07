# 0015 — Framework-Level Version + Per-Template Version Markers

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** moderate — no active pain yet, but the gap gets more expensive to retrofit the more products get built from this framework.

## Problem

Two related gaps, one at each level:

1. **Framework level:** nothing marks which point in this repo's history a given product was built from. If a product team asks "are we on the latest framework," there's no answer short of manually diffing files.
2. **Template level:** propagation is a plain `cp` (`README.md`'s "Using this framework for a new product" step), not a git submodule or subtree — the moment a product repo copies `.mwp-templates/`, it severs all connection to this repo's git history. If this framework's stage 03 contract is later revised, a product repo copied six months earlier has no way to detect its copy is stale, because `git log` on their copy only shows their own commits.

## Proposed change

Two lightweight, independent markers — deliberately not a full semver contract or an automated upgrade/merge tool, since neither is needed yet:

1. A `VERSION` file at the framework repo root (a plain incrementing number, e.g. `3`, not `x.y.z` semver) — bumped whenever an evolution entry moves to `adopted` and something in `.mwp-templates/`, `scripts/`, or `CLAUDE.md` actually changed as a result.
2. A one-line version marker inside each file in `.mwp-templates/` (e.g. `<!-- template-version: 1 -->` as the last line), incremented independently per file — since stages evolve at different rates, a shared single number across all six stage contracts would be less precise than it looks.

Explicitly not building yet: any automated tool that pulls newer templates into an existing product repo and merges them against that product's own customizations. That's real complexity (conflict resolution) with no concrete trigger yet — same reasoning applied throughout this backlog (0001's trigger-conditions framing, the no-auto-install stance in 0013).

## Stepwise implementation plan (not yet executed)

1. Add `VERSION` (starting at `1`) to the framework repo root.
2. Add `<!-- template-version: 1 -->` as the last line of every file under `.mwp-templates/` (six `CONTEXT.md` files, `IDENTITY.md`, `GLOBAL_CONTEXT.template.md`, `CRITICAL_ESCALATION.md`, `FEATURE_PRIORITY_REGISTRY.template.md`).
3. Update `docs/evolution/EVOLUTION_LOG.md`'s "Proposed → Adopted workflow" section (step 4/5) to add: "if the change touched `.mwp-templates/`, bump that file's `template-version` line; if it changed anything shipped to products, bump the root `VERSION` file too."
4. Update `README.md`'s "Using this framework for a new product" copy steps with a one-line note: "these version markers travel with the copy — they tell you what you started from, not whether you're current."
5. No comparison/upgrade tooling yet — just the markers. Building a `doctor.sh`-style version-drift check is a natural future entry once there's at least one product repo old enough for staleness to be a real question.

## What happens if adopted

Answers "what did we start from" cheaply, without building the harder "how do we catch up" tooling before anyone actually needs it.
