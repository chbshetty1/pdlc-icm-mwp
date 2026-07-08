# 0032 — Stage-01/02 Survey: OKF, Performance Tracking, End-to-End Pilot, Product-Level Requirements

- **Date:** 2026-07-08
- **Status:** rejected (2026-07-08) — three of four surveyed items are firm "not doing this" answers (with reasoning and, where applicable, a trigger condition); see the Outcome section for the one deferred sub-item.
- **Priority:** directly requested (a user-initiated stage-01/02 discovery pass), not from the ranked backlog.

## Problem

An informal discovery/definition pass was requested, seeded with candidate topics, to survey what's still thin in this framework — no pilot has run it end-to-end on a real product yet (README's own "Status" section). Four of the seven candidate topics surveyed don't resolve to a buildable change right now, but per `EVOLUTION_LOG.md`'s own convention ("even if the answer is 'keep it as is, and here's why'"), that conclusion gets logged, not silently dropped. Grouped into one entry since all four share the same underlying reasoning: building more framework machinery doesn't substitute for the one thing actually missing (real usage), and building it anyway would be premature.

## The four items and their disposition

**1. OKF (Open Knowledge Format) compatibility.** Google's spec for packaging RAG knowledge bases (documents, chunks, embeddings, manifest) — published 2026-06-12, under a month old at time of writing. Researched directly (web search + fetch of the spec explainer). This framework's `docs/` is plain markdown with no frontmatter, manifest, or chunk/embedding metadata — not compliant. **Rejected for now**, not deferred-and-forgotten: OKF solves semantic search over large document corpora, a problem this framework's `CONTEXT.md`-declared-scope model deliberately doesn't have (entry `0001`'s "context is computed, not curated" — an agent is told exactly which files to read, no retrieval step exists to standardize). Adopting OKF's chunking/embedding layer would be new coupling to a single-vendor, unproven-adoption format, which entry `0031`'s new composability/anti-lock-in rules now explicitly cover. **Trigger condition to revisit:** OKF gains multi-vendor adoption (the way schema.org did), or a product built from this framework has a concrete need to export its docs into an external LLM knowledge tool that requires OKF specifically.

**2. Framework performance tracking.** The framework has no runtime component — no server, nothing to benchmark in the classical (latency/throughput/APM) sense, confirmed while reviewing the same monitoring research that fed entries `0029`/`0030`. The one thing that would be meaningful — lead time from `scaffold.sh` to stage-06 completion, computable today from `SYNC_LOG.md` timestamps without any new instrumentation — has no real data to trend against, since no pilot has completed a cycle. **Deferred, not rejected: no code needed yet, but the data source (`SYNC_LOG.md`) already exists** for whenever this becomes worth computing. **Trigger condition:** at least one real product has completed a full 6-stage cycle.

**3. End-to-end pilot testing.** The single most-repeated open item across this session (README's "Status," entry `0001`'s trigger conditions, entry `0032`'s own item 2 above). Explicitly **not fixable by another evolution entry** — `CLAUDE.md` and `README.md` both deliberately forbid building product data inside this framework repo, so there is no scaffolding change that substitutes for a real product actually running through all 6 stages. Logged here so it's stated plainly rather than implicitly assumed someone's tracking it: this is the framework's own riskiest assumption, still open, and stays open until a real pilot happens outside this repo.

**4. Product-level requirements as part of the framework.** No, by design, not a gap. `.mwp/GLOBAL_CONTEXT.md` is deliberately where product-specific constraints (auth pattern, data residency, brand guidelines) live — folding any of that into `.mwp-templates/` would defeat the framework's entire reason to exist as a reusable template, and is exactly the lock-in entry `0031`'s new rules warn against. **Rejected, not deferred** — this isn't a maturity gap, it's a correctly-drawn boundary. See `docs/CONSTRAINTS.md`'s scope & containment section and the existing FAQ entry "Can I just build my product directly inside this framework repo instead of copying it elsewhere?"

## What happens if adopted

Nothing changes in shipped behavior. Four open questions get a documented, reasoned answer instead of silence, each with an explicit trigger condition (or explicit "this isn't a gap") so a future pass doesn't have to re-derive the same reasoning from scratch.

## Outcome (2026-07-08)

Logged as written — this entry's content *is* its own outcome, since it's a survey/decision record, not a code change. `docs/FAQ.md` gets one new entry summarizing items 1–3 with pointers here (item 4 already has FAQ coverage, cross-referenced rather than duplicated). `EVOLUTION_LOG.md` row added with Status `rejected` (items 1 and 4 are rejected outright; item 3 can't be resolved by this repo at all; item 2 is the one genuinely `deferred` sub-item) — using `rejected` for the entry as a whole since three of the four dispositions are firm "not doing this" answers, with the deferred one's trigger condition stated plainly in the text above.

No `VERSION` bump for the entry file itself (`docs/evolution/` is framework-repo-only), but `docs/FAQ.md` (a "Travels with new products" doc) gained a new entry — MINOR bump per entry `0029`'s tiers, folded into the same version bump as entry `0031` since both landed in the same batch.
