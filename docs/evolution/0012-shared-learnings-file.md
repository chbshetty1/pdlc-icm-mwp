# 0012 — Shared-Learnings File, Distinct from GLOBAL_CONTEXT.md

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 6 of 6 — genuinely useful, but the least urgent: nothing currently breaks without it, it just means duplicated discovery effort across features.

## Problem

`GLOBAL_CONTEXT.md` captures constraints and anchors (stack, brand rules, shared schemas) — stable, deliberate decisions. There's no equivalent file for "things we discovered the hard way" during a feature's work — a third-party API's undocumented rate limit, a footgun in a library, a quirk of the deployment environment. Without a home for this, the next feature's `01_discovery_ideation` stage may re-learn the same lesson from scratch, burning tokens and time on something already known.

## Proposed change

Add a `LEARNINGS.md` at the product root — distinct from both `GLOBAL_CONTEXT.md` (deliberate constraints) and `LESSONS_LEARNED.md` from entry 0008 (why a whole feature was pivoted). This one is for incidental discoveries worth remembering, appendable from any stage.

## Stepwise implementation plan (not yet executed)

1. Add a `LEARNINGS.md` template to `.mwp-templates/` (simple append-only list: date, feature, discovery, one line each), created at product init alongside `GLOBAL_CONTEXT.md`.
2. Add a line to each stage's `CONTEXT.md` "Expected deliverables" section: "if you discover something outside this feature's own scope that a future feature would benefit from knowing, append one line to `../../LEARNINGS.md`."
3. Reference `LEARNINGS.md` as optional-but-recommended reading in `01_discovery_ideation/CONTEXT.md`, same pattern as entry 0008's `LESSONS_LEARNED.md` reference.
4. Keep entries append-only and one-line to avoid this becoming an unbounded, un-curated dumping ground — if it grows large, that's itself a signal worth a future evolution entry (e.g. periodic curation or categorization).

## What happens if adopted

Reduces duplicated discovery work across features at low cost — the main risk is the file growing unbounded and noisy over time, which is worth watching rather than solving upfront.
