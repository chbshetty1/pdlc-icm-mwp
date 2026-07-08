# 0029 — Tiered (SemVer-Style) VERSION Scheme

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** surfaced via external research (a user-supplied Google AI Mode transcript on framework versioning/migration practice), not from the existing ranked backlog — this is a fresh entry, not a re-prioritization of 0001–0028.

## Problem

Entry `0015` deliberately gave `VERSION` the simplest possible shape: a plain incrementing integer, explicitly "not `x.y.z` semver," bumped whenever anything ships to `.mwp-templates/`, `scripts/`, `CLAUDE.md`, or a doc marked "Travels with new products." That was the right call at the time — no product repo existed yet, so there was nothing concrete to migrate.

Two things have since made the gap real rather than theoretical:

1. `README.md`'s own product-init walkthrough already admits the limitation in its own words: "There's no tooling yet that checks your copy against a newer framework version; that's a manual diff for now."
2. A flat integer carries no information about *how risky* an upgrade is. `VERSION` has gone from `1` to `19` across this session alone (entries 0002–0027), mixing pure documentation rewrites (e.g. entry 0011's wording generalization) with structurally breaking changes (e.g. entry 0025's relative-path depth fix, which would silently break `CRITICAL_ESCALATION.md`/`CLAUDE_WORKFLOW_PLAYBOOK.md`/`GLOBAL_CONTEXT.md` references in any product repo copied before it landed). A product team looking at "we started at 9, framework is now at 19" has no way to tell whether that gap is ten harmless doc tweaks or one silent breaking change, without reading all ten entries.

## Proposed change

Adopt a lightweight three-tier scheme — `MAJOR.MINOR.PATCH` — for the root `VERSION` file, plus a new `docs/MIGRATIONS.md` that only gets a row on a MAJOR bump (minor/patch bumps are backward-compatible by definition and need no migration instructions).

Bump rules, added to `docs/DEVELOPMENT.md`'s adoption checklist:

- **PATCH:** doc-only wording/typo/comment fixes in a "Travels with new products" file, or any change with zero behavioral or structural effect on an already-scaffolded product.
- **MINOR:** backward-compatible additions — a new optional script flag, a new template file, a new FAQ entry, a new optional `CONTEXT.md` reference. Nothing already scaffolded from an older version breaks by staying on it.
- **MAJOR:** anything that could break or silently miscopy an in-flight feature/sprint scaffolded from an older version — a renamed or removed template file, changed script argument behavior, a changed `CONTEXT.md` contract shape, a corrected-but-load-bearing path fix (entry 0025 would have qualified). Requires a new row in `docs/MIGRATIONS.md` describing what changed and what a product repo must do about it.

This mirrors the transcript's general migration workflow (read what changed → address anything deprecated/removed → apply any mechanical fix available → re-verify) without adopting any of the automated-codemod tooling the transcript describes — same "no automated upgrade tool yet, no concrete need shown" reasoning entry 0015 already used, extended rather than reversed.

## Stepwise implementation plan

1. Convert root `VERSION` from a flat integer to `MAJOR.MINOR.PATCH`. Baseline: since this change itself alters the *meaning* of the file — any tooling or human process that expected a plain integer now sees a three-part string — it is itself a MAJOR bump under the new rule. Old value `19` becomes `20.0.0`.
2. Create `docs/MIGRATIONS.md` — "Travels with new products" doc, only lists MAJOR bumps, one row each: version, one-line description of the break, what a product repo on an older version must do. Seed it with a first row for this entry's own `20.0.0` bump (trivial: "no action needed, the VERSION file's format itself changed but nothing else did").
3. Update `docs/DEVELOPMENT.md`'s adoption checklist step 6 with the three-tier bump rules above, and a new step: "if MAJOR, add a row to `docs/MIGRATIONS.md`."
4. Update `README.md`: VERSION table row description, the "manual diff for now" comment in the product-init walkthrough (point at `docs/MIGRATIONS.md` for MAJOR jumps instead), and add `docs/MIGRATIONS.md` to the copy-steps block alongside `FAQ.md`/`CONSTRAINTS.md`/etc.
5. Update `docs/FAQ.md`'s existing versioning entry (the "no full semver" answer) to describe the new tiered scheme instead of contradicting it.
6. Update `EVOLUTION_LOG.md`'s table row and `docs/DEVELOPMENT.md`'s "Known cross-entry collisions" list.

## What happens if adopted

A product team can look at a version jump (e.g. `20.0.0` → `21.3.2`) and immediately know whether anything requires action — check `docs/MIGRATIONS.md` for `21.x.x` rows, or skip straight past if the major number didn't move. Closes the gap `README.md` already admits exists, without building any auto-upgrade tooling neither entry 0015 nor this entry has a concrete trigger for yet.

## Outcome (2026-07-08)

All 6 steps implemented as written, no deviations.

1. `VERSION` changed from `19` to `20.0.0`.
2. `docs/MIGRATIONS.md` created with a header explaining the convention (MAJOR bumps only; MINOR/PATCH are backward-compatible by definition and don't get rows) and a seed row for `20.0.0` itself.
3. `docs/DEVELOPMENT.md` checklist step 6 rewritten with the three explicit tiers and a new step 7 ("if MAJOR, add a row to `docs/MIGRATIONS.md`"); old step 7 (cross-entry collisions) renumbered to 8.
4. `README.md` updated: `VERSION` row now describes the tiered scheme; product-init walkthrough's "manual diff for now" line now points at `docs/MIGRATIONS.md`; `docs/MIGRATIONS.md` added to the doc-copy block.
5. `docs/FAQ.md`'s versioning entry rewritten to describe the tiered scheme and link both `0015` (why versioning exists at all) and this entry (why it's tiered).
6. `EVOLUTION_LOG.md` row added; `docs/DEVELOPMENT.md`'s collisions list updated — no collision, since this entry doesn't touch any file entry 0030 (test harness) also touches.

No script parses `VERSION` programmatically (confirmed by grep before implementing) — every reference is documentation-only, so the format change is safe with no code-side fallout.
