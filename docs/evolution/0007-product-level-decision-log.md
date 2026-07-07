# 0007 — Product-Level Decision Log

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 1 of 6 — highest, because it's the same gap 0001–0006 already fixed for the framework itself, just missing one level down.

## Problem

`docs/evolution/` captures why *this framework template* looks the way it does. A product built from the framework has no equivalent — no committed place to record "why we chose Postgres over Mongo for FEAT-003," or "why FEAT-005's architecture rejected the obvious approach." That reasoning either lives in someone's memory or in a chat transcript nobody will reopen. Right now `docs/FAQ.md` only *suggests* a product team start their own evolution log; it isn't handed to them.

## Proposed change

Add a blank, product-scoped decision-log template to `.mwp-templates/` (mirroring this repo's own `docs/evolution/EVOLUTION_LOG.md` convention) so every new product gets one automatically, pre-populated with the convention but with zero entries — ready to use from feature one.

## Stepwise implementation plan (not yet executed)

1. Add `.mwp-templates/PRODUCT_EVOLUTION_LOG_TEMPLATE.md` — same structure as this repo's `EVOLUTION_LOG.md` (convention, log table, proposed→adopted workflow), reworded to be about product/architecture decisions rather than framework design.
2. Update the README's "Using this framework for a new product" copy steps to create `docs/evolution/EVOLUTION_LOG.md` from that template in the new product repo.
3. Update `docs/FAQ.md`'s existing note (in "Which docs travel...") to say this now ships automatically rather than "start a fresh one yourself."
4. Test by running through the new-product copy steps in a scratch directory and confirming the generated file reads sensibly with zero entries.

## What happens if adopted

Every product built from this framework starts with the same discipline this framework used on itself — a running, append-only record of *why*, not just *what* — instead of leaving it as an opt-in suggestion that most teams under time pressure will skip.
