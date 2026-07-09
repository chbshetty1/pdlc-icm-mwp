# 0043 — Pilot Measurement Plan, and Clarifying the Anti-Bloat Constraint

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-09)
- **Trigger:** direct follow-up to `0042`'s assumption NA4 ("a real pilot's evidentiary bar is comparison against a stated counterfactual, not the framework's own internal test suite") and its "medium term" planned action (design the pilot's data capture before it starts). Prompted by two requests: first, a broader brainstorm of what metrics could be tracked (verification, observability, developer productivity, agentic-framework metrics, product/UX metrics); second, a direct question — does collecting any of this need to be treated as an exception to `docs/CONSTRAINTS.md`'s anti-bloat rules (no configurable logging, no alerting/watcher process)?
- **Scope:** which pilot metrics are worth tracking, how they're prioritized, and where the anti-bloat constraint's actual boundary sits relative to measurement.

## The bloat question, answered

No — and answering "yes, grant an exception" would have been the wrong move, since it invites building more than's needed under cover of the exception. The two constraints in question specifically target *configurability* (log levels, per-stage overrides — see entry `0014`) and *continuous/polling machinery* (an alerting or watcher process — see entry `0016`). Neither targets measurement itself. `.mwp/framework.log` already is a non-configurable, always-on, single-purpose log, adopted without anyone treating it as an exception, because it isn't one — it's exactly the shape this framework already uses for exactly this kind of need.

The dividing line that actually matters: does a given metric need (a) nothing new, just reading a file the framework already writes, (b) a narrow, single-purpose, non-configurable addition in the same shape as `SYNC_LOG.md`, or (c) something that would poll, alert, or run continuously. Only (c) is actually excluded by the existing rules — and (c) wasn't needed for anything on the metrics list this entry worked through.

## What changed

1. **`docs/CONSTRAINTS.md`** gained a new bullet under "Complexity & coordination," directly beside the existing "No configurable logging" / "No alerting or watcher process" rules, stating this dividing line explicitly — so the next person doesn't have to re-derive it from first principles the way this entry did.
2. **`docs/PILOT_MEASUREMENT_PLAN.md`** (new, framework-repo-only) — a prioritized, tiered metrics list for the upcoming pilot:
   - **Tier 1** (zero new instrumentation): lead time, sync retry/friction count, escalation count and resolution time, pivot/persevere outcome — all computable today from `SYNC_LOG.md`, `framework.log`, `BLOCKED_REASON.md` timestamps, and `LESSONS_LEARNED.md`.
   - **Tier 2** (small, narrow, non-configurable additions, not yet built): persistent logging for guardrail warn/block events (currently stdout-only in `sync.sh`), an on-demand Context-Manifest-overreach audit script, and a manually-tracked ceremony-overhead ratio.
   - **Tier 3** (explicitly deferred): continuous UX/product-growth telemetry, dashboards, anything that polls — the actual watcher-process pattern the constraint blocks, with no concrete need for it against a single pilot.
   - A dedicated section on the counterfactual requirement from `0042`'s NA4 (estimate-first vs. parallel run), framed as a decision to make and record *before* the pilot starts, since it can't be reconstructed afterward.
   - A pre-pilot TODO checklist (see below).
3. **`docs/FAQ.md`** gained a Q&A entry stating the same dividing line in FAQ form, cross-linked to both `docs/CONSTRAINTS.md` and `docs/PILOT_MEASUREMENT_PLAN.md`.

## TODO carried forward (not yet done — tracked in `docs/PILOT_MEASUREMENT_PLAN.md`, repeated here for visibility)

- [ ] Decide the counterfactual approach (estimate vs. parallel run) and record it in the pilot's own product repo before `scaffold.sh` runs.
- [ ] Spot-check `SYNC_LOG.md`/`framework.log` timestamp granularity is actually sufficient for lead-time computation.
- [ ] Build: persistent logging for guardrail warn/block events in `sync.sh` (Tier 2, currently stdout-only).
- [ ] Build: on-demand Context-Manifest-overreach audit script (Tier 2).
- [ ] Decide where in the pilot's product repo Tier 1/2 results get recorded.
- [ ] Once real pilot data exists, revisit `0001`'s trigger conditions (design correctness) separately from `0042`'s (evidentiary basis) — they govern different questions and shouldn't be conflated when reviewing pilot results.

None of these are implemented by this entry — this entry documents the plan and the constraint clarification only, consistent with `0042`'s own "medium term: planned, not done" framing.

## Outcome (2026-07-09)

Implemented as written: `docs/CONSTRAINTS.md` bullet added, `docs/PILOT_MEASUREMENT_PLAN.md` created, `docs/FAQ.md` entry added, `EVOLUTION_LOG.md` row added, `docs/DEVELOPMENT.md`'s documentation map and collisions-list date updated, `README.md`'s file table gained a row for the new doc. `VERSION` bumped MINOR: both `docs/CONSTRAINTS.md` (new bullet) and `docs/FAQ.md` (new entry) are docs marked "Travels with new products," and a new addition to either is explicitly MINOR-tier per `docs/DEVELOPMENT.md`'s checklist. `docs/PILOT_MEASUREMENT_PLAN.md` itself is framework-repo-only (like `docs/DEVELOPMENT.md`/`docs/evolution/`) and doesn't independently affect the tier — it describes validating this framework, not building a product.
