# 0012 — Shared-Learnings File, Distinct from GLOBAL_CONTEXT.md

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** 6 of 6 — genuinely useful, but the least urgent: nothing currently breaks without it, it just means duplicated discovery effort across features. Ranked 18 of 20 by entry `0026`'s unified backlog re-prioritization.

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

## Outcome (2026-07-08)

Implemented, but with the mechanism redesigned mid-implementation after a real conflict surfaced — not with the entry's literal step 2.

**The conflict:** step 2 as written asked each stage's agent to directly append a line to `../../LEARNINGS.md` from inside its own stage. Two problems, discovered while implementing: (1) that path used the pre-`0025` depth and would have resolved one level short even if the mechanism were otherwise fine; (2) more fundamentally, `LEARNINGS.md` sits outside every stage's `outputs/`, and the framework's write-containment rule (`CLAUDE.md`'s "Structural constraints," `docs/CONSTRAINTS.md`) has no "except as declared" exception for writes the way it does for reads — an agent directly appending to it would violate the framework's own most load-bearing rule, the same one entry `0018` built a whole verification mechanism around.

**Resolution (confirmed with a human before proceeding, given the scope of the redesign):** each stage now writes a plain-text `./outputs/Learnings_Note.md` (one discovery per line) — fully inside its own declared scope, no violation. `sync.sh` was extended to fold each non-empty, non-comment line into `<product-root>/LEARNINGS.md` as a table row at every stage transition (01→02 through 05→06), mirroring `pivot.sh`'s existing `LESSONS_LEARNED.md` extraction pattern from entry `0008`: the agent never leaves its sandbox, the script performs the actual cross-boundary write. Stage 06 is terminal — nothing syncs past it — so `pivot.sh` was extended instead, folding stage 06's `Learnings_Note.md` in on **both** `--pivot` (before the `rm -rf` purges it, same ordering as the existing `Validation_Report.md` extraction) and `--persevere` (previously a no-op branch).

All 4 of the entry's original steps map onto this redesigned mechanism:

1. `.mwp-templates/LEARNINGS.template.md` added — append-only `| Date | Feature | Discovery |` table, created at product init alongside `GLOBAL_CONTEXT.md` (`README.md`'s copy step 5, shared with `GLOBAL_CONTEXT.template.md`).
2. Each stage `CONTEXT.md`'s "Expected deliverables" section gained the discovery-note instruction — reworded from the original plan to route through `./outputs/Learnings_Note.md` + `sync.sh`/`pivot.sh` rather than a direct write, with an explicit "never write to `LEARNINGS.md` directly from this stage" line. `template-version` bumped on all 6 files (01: 4→5, 02: 3→4, 03: 3→4, 04: 3→4, 05: 3→4, 06: 3→4).
3. `LEARNINGS.md` referenced as optional-but-recommended reading in stage 01's `CONTEXT.md` input scope (a **read** exception, which the framework's rule does allow), same pattern as entry 0008's `LESSONS_LEARNED.md` reference, at the correct `../../../` depth per entry 0025.
4. Kept append-only and one-line per discovery, same unbounded-growth caveat as originally planned (noted in the template's own header comment) — not solved upfront, consistent with the entry's own reasoning.

**Tested in a sandbox** (fresh copies written directly into sandbox scratch space, not through the live mount): a 01→02 `sync.sh` transition with a 2-line `Learnings_Note.md` (including a comment line, a blank line, and a line with a literal `|` character) folded correctly with proper escaping; a stage-06 `--persevere` correctly folded via `pivot.sh`; a stage-06 `--pivot` correctly folded before the purge, with no regression to the existing `LESSONS_LEARNED.md` row; a sync with no `Learnings_Note.md` present at all produced no error and created no `LEARNINGS.md`.

Root `VERSION` bumped 14→15 — new `.mwp-templates/LEARNINGS.template.md` file, 6 touched stage `CONTEXT.md` files, `scripts/sync.sh`, `scripts/pivot.sh`, and a `README.md` copy-step addition all ship to new products.

**Also updated as part of this adoption:** `docs/CONSTRAINTS.md` gained a new "Cross-boundary writes go through a script, never directly through an agent" bullet under "Scope & containment," generalizing this pattern beyond just `LESSONS_LEARNED.md`/`LEARNINGS.md`. `docs/DEVELOPMENT.md`'s "Known cross-entry collisions" list updated — the pre-existing 0007/0012 README collision and the 0025-path-depth caution are both resolved (differently than the caution predicted).
