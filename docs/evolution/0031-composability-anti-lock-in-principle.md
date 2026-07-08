# 0031 — Composability & Anti-Lock-In as Explicit Constraints

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** directly requested (user-supplied "general pointers" during a stage-01/02 discovery pass), not from the ranked backlog.

## Problem

Two rules have been followed implicitly throughout this session — every "no auto-install," "no configurable logging," "no alerting" decision in `docs/CONSTRAINTS.md` is really an application of "don't add machinery without a concrete need," and the framework has stayed agent-agnostic (`docs/FAQ.md`'s first entry) and format-agnostic (plain markdown, per entry `0001`) throughout — but neither rule is written down as a rule. It's pattern-matched from precedent, not checkable against a stated principle. That gap became concrete just now while triaging OKF (entry `0032`): the reasoning for deferring it ("this is a single-vendor, five-week-old spec, and adopting its chunking/embedding machinery would recreate exactly the 'coordination requires software' dogma entry 0001 already rejected") had to be reconstructed from first principles in the moment rather than checked against an existing rule.

## Proposed change

Add two rules to `docs/CONSTRAINTS.md`, under a new "Extensibility & composability" section:

1. **New capability, not new coupling.** When a proposed change would only be useful to a subset of products built from this framework, or requires meaningfully different machinery than the folder/`CONTEXT.md` model already has, prefer shipping it as something separate (a standalone script, a companion tool, a plugin a product can opt into) over folding it into the framework's core. The core stays the smallest thing that makes the 6-stage/`CONTEXT.md` model work.
2. **No proposal may hard-couple the framework to one vendor, model, or proprietary format.** Every existing dependency already satisfies this (plain markdown, any LLM agent per the folder contract, free/open-source tools in `docs/TOOLING_MATRIX.md`) — this makes that property explicit and reviewable, rather than an accident of what happened to get chosen. A new, single-vendor standard (however well-marketed) needs either broad multi-vendor adoption or a concrete, currently-unmet need before this framework adopts it as a dependency.

## Stepwise implementation plan

1. Add the "Extensibility & composability" section to `docs/CONSTRAINTS.md`, each rule with a one-line reason, following the file's existing format (rule, why, where it's enforced/reviewed — "at evolution-entry review" for both, since these are judgment calls, not mechanically checkable).
2. Cross-reference from `docs/evolution/0001-first-principles-analysis.md`'s dogma section, since both rules are direct restatements of truths already identified there ("coordination requires software" as unexamined dogma; plain text/markdown being correct because it's the cheapest thing satisfying two hard constraints, not because of any specific vendor).
3. Update `docs/FAQ.md` with a short entry explaining why these rules exist and pointing at this entry and entry `0032` as the first real application of them.
4. Update `EVOLUTION_LOG.md`'s table row and `docs/DEVELOPMENT.md`'s adoption checklist / collisions list per the standard process.

## What happens if adopted

Future entries (including the very next few in this batch) get judged against a written standard instead of an implicitly-reconstructed one. Doesn't change any existing behavior — this is the same category of change as entry `0017` (consolidating `CONSTRAINTS.md` itself): pure discoverability, no new enforcement mechanism.

## Outcome (2026-07-08)

All 4 steps implemented as written, no deviations.

1. New "Extensibility & composability" section added to `docs/CONSTRAINTS.md` with both rules.
2. Cross-referenced entry `0001`'s dogma section directly in the rule text.
3. `docs/FAQ.md` entry added.
4. `EVOLUTION_LOG.md` and `docs/DEVELOPMENT.md` updated.

`docs/CONSTRAINTS.md` is a "Travels with new products" doc, so this ships to every new product going forward — VERSION bumped as a MINOR change (backward-compatible addition, nothing already scaffolded breaks by staying on an older version, per entry `0029`'s tiers).
