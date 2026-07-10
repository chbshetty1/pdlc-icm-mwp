# 0047 — Pilot Setup: A Mechanical Gate for the Estimate-First Counterfactual (Pattern Documented, Not Shipped)

- **Date:** 2026-07-10
- **Status:** adopted (2026-07-10)
- **Priority:** surfaced directly while bootstrapping the framework's first real pilot's product repo — a concrete finding, not a speculative survey.

## Problem

`docs/PILOT_MEASUREMENT_PLAN.md` (entry `0043`, decision confirmed `0046`) requires the "estimate first" counterfactual — a predicted lead time and token/context cost for building the pilot feature without the framework — to be written down before `scaffold.sh` runs, since it can't be reconstructed honestly afterward. The plan states this as a discipline to remember; nothing checks it.

That gap showed up immediately in practice: while filling in a pilot's `PILOT_METRICS.md`, a first attempt added three blank lines under the Counterfactual section's instructional comment instead of writing an estimate onto the three actual label lines. Nothing in the setup process would have caught this before `scaffold.sh` ran, had it not been caught by inspection first.

## Decision

Don't add this check to the framework's own `scripts/scaffold.sh`. That script runs inside every product repo, for every feature a product ever scaffolds — not just a first pilot's. Adding always-on counterfactual-checking logic there would be new, permanent machinery justified by exactly one use case (a single pilot's setup), which is the same "don't build ahead of evidence" reasoning entry `0046` already applied to rejecting sub-agent delegation. One pilot isn't enough signal that this particular friction recurs often enough to be worth shipped code.

Instead: document the pattern as something a product repo can adopt on its own, at pilot-setup time, if useful. Not new framework tooling.

## The pattern

Split a pilot's product-repo setup into two scripts instead of one:

1. **A fully automated setup script** — creates the repo, copies the framework in, writes `.mwp/GLOBAL_CONTEXT.md` and a starter `PILOT_METRICS.md` with the Counterfactual section's label lines present but unfilled, runs `doctor.sh`. No manual step inside it.
2. **A separate, gated scaffold script** — runs `scripts/scaffold.sh` for the first feature, but only after mechanically checking `PILOT_METRICS.md`'s Counterfactual section actually has content: grep for a label line (`- ...:`) with nothing but whitespace after the colon, and refuse to proceed (exit 1, explain why) if one's found.

This turns "remember to fill this in first" from an instruction into a hard gate, at the cost of two files instead of one and a human still having to fill in real values by hand in between — the gate only proves the fields are non-empty, not that the estimate is honest.

## What happened

- `docs/FAQ.md` — new entry describing the pattern and pointing here, framed generically (not tied to any specific product's pilot).
- `docs/PILOT_MEASUREMENT_PLAN.md` — one-line "Implementation tip" added after the counterfactual decision, pointing to the FAQ entry.
- No change to `scripts/`, `.mwp-templates/`, or any stage `CONTEXT.md` — this entry ships no code.

## Outcome (2026-07-10)

Not yet validated beyond a single pilot's setup. Worth revisiting once the pilot concludes: if the gate demonstrably prevented a real mistake (as it did here) across more than one pilot, promoting a generic version into `.mwp-templates/` as an optional reference script becomes a reasonable next entry. Until then, this stays documentation a product repo can copy, not framework machinery — same posture entry `0046` took toward sub-agents, applied here to a smaller, already-concretely-motivated case rather than a speculative one.
