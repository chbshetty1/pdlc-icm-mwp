# Pilot Measurement Plan

Framework-repo-only — like `docs/DEVELOPMENT.md` and `docs/evolution/`, this describes how to develop/validate *this framework*, not a product. It doesn't travel to new products, and no data is collected here: `CLAUDE.md` and `README.md` both forbid building product data inside this repo, so the actual pilot runs in a separate product repo. This document is what that pilot should set up and track before it starts.

## Why this exists

`docs/evolution/0042-critical-theory-audit.md` (finding #1, assumption NA4) established that no evidence gathered so far — 203 passing `tests/run_tests.sh` assertions included — tests the framework's actual thesis: that folder-scoped, human-gated context produces better AI-agent-driven product development than the alternatives. A pilot that completes without deliberately capturing comparable data produces an *existence proof* (the framework is usable) again, not the *evidence* that's actually missing (the framework is better than the alternatives, by some measured amount). This plan exists so that distinction gets acted on before the pilot starts, not noticed afterward.

## Metrics, prioritized

### Tier 1 — ready now, zero new instrumentation

Computable entirely from files the framework already writes. No script changes needed — just read the existing logs after (or during) the pilot.

| Metric | What it measures | Source |
|---|---|---|
| Lead time, `scaffold.sh` → stage 06 completion | Overall pipeline speed | `SYNC_LOG.md` timestamps |
| Sync retry/friction count per transition | How often a stage transition needed more than one attempt | `.mwp/framework.log` (one line per invocation, with exit code) |
| Escalation count and resolution time | How often the agent got stuck, and how long a human took to unblock it | `BLOCKED_REASON.md` creation timestamp → its move into `.escalations_archive/` |
| Pivot vs. persevere outcome, and at which stage | Whether/where the riskiest assumption failed | `LESSONS_LEARNED.md` |
| Stage turnaround time, commit-to-commit | Per-stage speed, not just end-to-end pipeline lead time — where the pipeline is actually slow | `SYNC_LOG.md` timestamps between successive transitions for the same feature (added entry `0046`) |

### Tier 2 — needs a small, narrow, non-configurable addition

Each of these is a single-purpose plain-text log or one-off script, matching the shape `SYNC_LOG.md`/`framework.log` already use — not a general metrics subsystem. See `docs/CONSTRAINTS.md`'s clarification (entry `0043`) for why this doesn't need to be treated as an exception to the anti-bloat rule.

| Metric | What it measures | Status |
|---|---|---|
| Guardrail hit rate (token + secrets), real content | How often the token-ceiling warning and secrets block actually fire outside synthetic test fixtures, and the false-positive rate | **Built (entry 0044).** `sync.sh` appends one line per event to `<workspace>/GUARDRAIL_LOG.md`. |
| Context Manifest overreach rate | How often a stage's self-reported `Context_Manifest.md` lists files outside its `CONTEXT.md`'s declared `READ ONLY` scope | **Built (entry 0044).** `scripts/audit_manifest.sh <workspace> [stage]` — on-demand, advisory only. |
| Ceremony overhead ratio | Time spent on `CONTEXT.md` inputs, C-V-R scoring, and manifest review versus actual build time | Not derivable from any file — needs the human running the pilot to note a couple of timestamps manually; not worth automating for a single pilot. Still not built. |

### Tier 3 — explicitly out of scope for this pilot

Continuous UX/product-growth telemetry, usage dashboards, or anything that polls or runs in the background. Not because they're uninteresting, but because they're the actual "watcher process" pattern `docs/CONSTRAINTS.md` already rejects, and there's no concrete need for a running system to check one pilot on demand. Revisit only if the framework is ever used across enough concurrent features that on-demand checking (`status.sh`'s existing model) genuinely stops being sufficient.

## The counterfactual — a decision, not a metric

Assumption NA4 (`0042`) requires comparing pilot results against *something*, or none of the Tier 1/2 numbers mean anything on their own. Pick one before the pilot starts:

- **Estimate first:** before scaffolding the feature, write down a predicted lead time and rough token/context cost for building it *without* the framework — even a rough gut number is better than nothing, since it can't be reconstructed honestly after the fact.
- **Parallel run:** build one comparable, low-stakes feature the same size without the framework (or with a different orchestration approach), and compare directly. More rigorous, more expensive — worth it only if the first pilot feature is a good match for a fair comparison.

**Decided (2026-07-09): estimate first.** Whoever runs the pilot writes the predicted lead time and rough token/context cost down in that pilot's own product repo before `scaffold.sh` runs — not done here, since no product data belongs in this repo. This can't be done retroactively, so it's the first thing to do once a real pilot feature is chosen.

**Implementation tip (entry `0047`):** nothing in the framework's own scripts stops this from silently staying blank when `scaffold.sh` runs — it's a stated discipline, not a checked one. See `docs/FAQ.md`'s entry on a two-script pilot-setup pattern (one fully automated setup step, one gated scaffold step that mechanically refuses to run against a blank Counterfactual section) if you'd rather that mistake be prevented than just remembered. Documentation only — nothing shipped in `scripts/` checks this.

**The comparison this enables is one-sided (entry `0049`).** The counterfactual only ever captures a one-time upfront estimate of the *without*-framework cost. Nothing measures the *with*-framework token/context cost actually spent building the feature — lead time gets a real number on both sides once the pilot runs (the estimate, and `SYNC_LOG.md` timestamps), token/cost never does. A lower-bound proxy is derivable with zero new instrumentation — sum each stage's output-file token estimates via `sync.sh`'s own `word_count × 1.3` heuristic, and treat sync retry/escalation counts as rough friction multipliers — but it systematically undercounts: it only sees the final output that landed, never the re-supplied input context, debugging exchanges, or discarded drafts along the way. The cheapest real fix would be a manual, freeform per-stage note mirroring `sync.sh`'s existing optional `[approver]` argument — identified, deliberately not built, same "don't add machinery ahead of evidence" reasoning as `0046`/`0047`.

## Where the actual data lives

This file is guidance, not a data store. **Decided (2026-07-10, entry `0046`): `PILOT_METRICS.md` at the pilot repo's root** — not folded into that product's `docs/evolution/EVOLUTION_LOG.md`, so the numbers are findable without reading entry-by-entry. What matters is writing it down somewhere durable in that repo, not leaving it to be reconstructed from memory afterward; this file still doesn't create it, since that's blocked on the pilot repo existing.

## TODO — before the pilot starts

- [x] Decide the counterfactual approach — **estimate first** (2026-07-09). Still needs to be actually written down in the pilot's own product repo once that repo exists — that part can't be done here.
- [x] Spot-check that `SYNC_LOG.md`/`framework.log` timestamp granularity is actually sufficient for lead-time computation (entry 0044's dry run). `SYNC_LOG.md`/`GUARDRAIL_LOG.md` are minute-granularity, `framework.log` is second-granularity — sufficient for realistic pilot timescales (hours/days between stage transitions); line order still preserves sequence for same-minute ties in a fast synthetic test.
- [x] Build: persistent logging for guardrail warn/block events in `sync.sh` — done, entry 0044. `<workspace>/GUARDRAIL_LOG.md`.
- [x] Build: on-demand Context-Manifest-overreach audit script — done, entry 0044. `scripts/audit_manifest.sh`.
- [x] Decide where in the pilot's product repo the Tier 1/2 results actually get recorded — **`PILOT_METRICS.md` at that repo's root** (entry `0046`, 2026-07-10). Still needs to actually be created once that repo exists — that part can't be done here.
- [ ] Once the pilot generates real data, revisit `0001`'s trigger conditions (not just `0042`'s) against what actually happened — this plan measures the framework's efficacy, not its theoretical correctness, and the two entries govern different questions.

A dry run (entry 0044) exercised the full Tier 1 + Tier 2 setup against a synthetic feature before any of this is trusted on the real pilot, and found one real bug along the way (a logging gap in `sync.sh`/`scaffold.sh` predating this plan, now fixed) — see that entry for the full account. Only the counterfactual write-up remains, and it's blocked on the pilot's product repo actually existing, not on anything left to build here.

## Relationship to the anti-bloat constraint

Nothing in this plan requires configurable logging or an alerting/watcher process — the two things `docs/CONSTRAINTS.md` actually rules out. Tier 1 is pure computation over logs that already exist. Tier 2 is narrow, single-purpose, non-configurable additions in the same shape as `SYNC_LOG.md`. Tier 3 — the part that *would* need a running system — is the part explicitly deferred. See `docs/CONSTRAINTS.md`'s "Complexity & coordination" section and `docs/evolution/0043-pilot-measurement-plan.md` for the full reasoning.
