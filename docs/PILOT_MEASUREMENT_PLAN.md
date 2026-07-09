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

### Tier 2 — needs a small, narrow, non-configurable addition (not yet built)

Each of these is a single-purpose plain-text log or one-off script, matching the shape `SYNC_LOG.md`/`framework.log` already use — not a general metrics subsystem. See `docs/CONSTRAINTS.md`'s clarification (entry `0043`) for why this doesn't need to be treated as an exception to the anti-bloat rule.

| Metric | What it measures | What's missing today |
|---|---|---|
| Guardrail hit rate (token + secrets), real content | How often the token-ceiling warning and secrets block actually fire outside synthetic test fixtures, and the false-positive rate | `sync.sh` currently prints these to stdout only — nothing persists them. Needs one appended line per event, same shape as `SYNC_LOG.md` |
| Context Manifest overreach rate | How often a stage's self-reported `Context_Manifest.md` lists files outside its `CONTEXT.md`'s declared `READ ONLY` scope | No script currently diffs the two — would need a small on-demand audit script, run manually at review time, not automatically |
| Ceremony overhead ratio | Time spent on `CONTEXT.md` inputs, C-V-R scoring, and manifest review versus actual build time | Not derivable from any file — needs the human running the pilot to note a couple of timestamps manually; not worth automating for a single pilot |

### Tier 3 — explicitly out of scope for this pilot

Continuous UX/product-growth telemetry, usage dashboards, or anything that polls or runs in the background. Not because they're uninteresting, but because they're the actual "watcher process" pattern `docs/CONSTRAINTS.md` already rejects, and there's no concrete need for a running system to check one pilot on demand. Revisit only if the framework is ever used across enough concurrent features that on-demand checking (`status.sh`'s existing model) genuinely stops being sufficient.

## The counterfactual — a decision, not a metric

Assumption NA4 (`0042`) requires comparing pilot results against *something*, or none of the Tier 1/2 numbers mean anything on their own. Pick one before the pilot starts:

- **Estimate first:** before scaffolding the feature, write down a predicted lead time and rough token/context cost for building it *without* the framework — even a rough gut number is better than nothing, since it can't be reconstructed honestly after the fact.
- **Parallel run:** build one comparable, low-stakes feature the same size without the framework (or with a different orchestration approach), and compare directly. More rigorous, more expensive — worth it only if the first pilot feature is a good match for a fair comparison.

Whichever is chosen, write it down in the pilot's own product repo before `scaffold.sh` runs — this can't be done retroactively.

## Where the actual data lives

This file is guidance, not a data store. The pilot's own product repo should record results — either a dedicated `PILOT_METRICS.md` at that repo's root, or folded into that product's own `docs/evolution/EVOLUTION_LOG.md` as part of whatever entry documents the pilot's outcome. Either is fine; what matters is writing it down somewhere durable in that repo, not leaving it to be reconstructed from memory afterward.

## TODO — before the pilot starts

- [ ] Decide the counterfactual approach (estimate vs. parallel run) and write it down in the pilot's product repo.
- [ ] Spot-check that `SYNC_LOG.md`/`framework.log` timestamp granularity is actually sufficient for lead-time computation (confirm, don't assume).
- [ ] Build: persistent logging for guardrail warn/block events in `sync.sh` (currently stdout-only) — a small, narrow addition, not yet built.
- [ ] Build: on-demand Context-Manifest-overreach audit script — not yet built.
- [ ] Decide where in the pilot's product repo the Tier 1/2 results actually get recorded (`PILOT_METRICS.md` vs. folded into that repo's evolution log).
- [ ] Once the pilot generates real data, revisit `0001`'s trigger conditions (not just `0042`'s) against what actually happened — this plan measures the framework's efficacy, not its theoretical correctness, and the two entries govern different questions.

## Relationship to the anti-bloat constraint

Nothing in this plan requires configurable logging or an alerting/watcher process — the two things `docs/CONSTRAINTS.md` actually rules out. Tier 1 is pure computation over logs that already exist. Tier 2 is narrow, single-purpose, non-configurable additions in the same shape as `SYNC_LOG.md`. Tier 3 — the part that *would* need a running system — is the part explicitly deferred. See `docs/CONSTRAINTS.md`'s "Complexity & coordination" section and `docs/evolution/0043-pilot-measurement-plan.md` for the full reasoning.
