# 0049 — The Counterfactual Is One-Sided: "Without the Framework" Is Estimated, "With the Framework" Is Never Measured

- **Date:** 2026-07-10
- **Status:** adopted (2026-07-10) — analysis and documentation only, no instrumentation built, by explicit user decision.
- **Priority:** surfaced directly while reasoning through the pilot's own measurement plan, mid-pilot.

## Problem

`docs/PILOT_MEASUREMENT_PLAN.md`'s counterfactual (entries `0043`/`0046`) asks whoever runs the pilot to write down a predicted lead time and token/context cost for building the feature *without* the framework, before `scaffold.sh` runs. Re-reading the plan closely surfaces something it never states outright: nothing anywhere measures the token/context cost of actually building the feature *with* the framework. Lead time has a real number on both sides (the estimate, and `SYNC_LOG.md` timestamps once the pilot runs) — token/cost only ever has the one-time upfront guess. The comparison this plan exists to enable (`0042`'s NA4) is only half-built for that dimension.

## What's actually derivable, and what isn't

A lower-bound proxy for "with framework" token cost is computable from files the framework already writes, zero new instrumentation, in the same spirit as every other Tier 1 metric:

- Sum of output-file token estimates per stage, using `sync.sh`'s own existing heuristic (`word_count × 1.3`) against every stage's real output files.
- Sync retry count and escalation count (already Tier 1) as friction multipliers — more retries/escalations implies more re-work, hence more tokens, without quantifying how much.

This systematically undercounts, and the gap is structural, not a rounding error: it only counts the *final* output that landed, never the input context re-supplied every session, the debugging/clarifying exchanges, discarded drafts, or tool calls. A stage that failed twice before syncing looks identical to a first-try success under this proxy — the real cost of the two failed attempts is invisible to it.

## Decision

Don't build anything now. The cheapest real fix — a manual, freeform per-stage token/cost note, mirroring `sync.sh`'s existing optional `[approver]` argument pattern — was identified but explicitly not adopted, on the user's own instruction ("I am not going to change anything now") and independently for the same "don't add machinery ahead of evidence" reasoning entries `0046`/`0047` already established: one pilot hasn't yet shown this gap is worth closing with new tooling, only worth naming so it isn't silently assumed to be already covered.

## What happened

- `docs/PILOT_MEASUREMENT_PLAN.md`: new note under the counterfactual section stating the one-sidedness plainly, describing the derivable lower-bound proxy and its limits, and naming the manual-note fallback as documented-but-not-built.
- `docs/FAQ.md`: new entry covering the same ground for anyone who assumes the counterfactual comparison is already symmetric.
- No script, template, or `PILOT_METRICS.md` structure change.

## Outcome (2026-07-10)

Purely a documentation/analysis entry — confirmed no test-suite impact, since nothing shipped touches `scripts/`, `.mwp-templates/`, or any file `tests/` covers. Revisit if a future pilot (this one or a later one) actually wants the truer number badly enough to justify the freeform per-stage note — at that point it's a small, well-scoped Tier 2 addition, not a new decision to make from scratch.
