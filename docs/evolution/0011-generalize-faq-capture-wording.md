# 0011 — Generalize FAQ-Capture Wording for Downstream Products

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** 5 of 6 — small wording fix, but affects every product this framework produces. Ranked 16 of 20 by entry `0026`'s unified backlog re-prioritization.

## Problem

The FAQ-capture instruction added to root `CLAUDE.md` says: "a reusable question-and-answer about how the framework works." That wording is correct here, in the framework template repo. But `CLAUDE.md` is copied verbatim into every new product repo. Read literally in a product repo, "the framework" could be interpreted narrowly as "the ICM/MWP methodology" rather than "this product" — meaning genuinely reusable product-specific Q&A (e.g. "why does our auth flow work this way") might not get captured, because the instruction doesn't clearly say it applies to product knowledge too.

## Proposed change

Reword the `CLAUDE.md` FAQ-capture instruction to explicitly cover both cases — framework mechanics *and* whatever system this copy of `CLAUDE.md` is actually governing — so the instruction is correct without editing, wherever it's copied.

## Stepwise implementation plan (not yet executed)

1. Edit the "FAQ capture" section of `CLAUDE.md`: change "about how the framework works" to something like "about how this repo/system works — the framework's own mechanics if this is the framework template, or the product's architecture/behavior if this is a product workspace built from it."
2. Re-read the rest of that section to confirm "Skip anything already covered there, or anything genuinely specific to one feature's implementation" still makes sense unchanged (it should — that clause is already generic).
3. No script changes needed — this is a documentation/instruction wording fix only.
4. Verify by re-reading the full `CLAUDE.md` file end to end for internal consistency once reworded.

## What happens if adopted

A one-line wording fix that makes the FAQ-capture behavior correct in every downstream product, not just in this template repo — cheap, and closes a real under-capture risk before any product has actually hit it.

## Outcome (2026-07-08)

All 4 steps executed:

1. `CLAUDE.md`'s "FAQ capture" section reworded: "about how the framework works" → "about how this repo/system works — the framework's own mechanics if this is the framework template repo, or this product's architecture/behavior if this is a product workspace built from it."
2. Re-read the rest of the section: the "skip anything already covered there, or anything genuinely specific to one feature's implementation" clause was already generic and needed no change. The following paragraph (line 32) already distinguished "this repo" from "a product repo copied from it" for a different reason (which `docs/FAQ.md` file is in play) — the new wording is consistent with that existing distinction rather than introducing a new one.
3. No script changes — documentation/instruction wording only, as planned.
4. Re-read `CLAUDE.md` end to end — internally consistent, no other section references "the framework" in a way that needed the same generalization (Structural constraints, Automated skill routing, and Failure handling are all already written generically, about "this workspace" and "a stage," not "the framework").

Root `VERSION` bumped 12→13 — `CLAUDE.md` ships to every new product per `README.md`'s copy steps (step 2), so this counts as a shipped change under entry `0015`'s versioning rule even though it carries no `template-version` marker of its own (only `.mwp-templates/` files do).
