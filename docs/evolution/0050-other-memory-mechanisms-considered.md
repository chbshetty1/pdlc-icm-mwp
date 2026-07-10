# 0050 — Other Candidate "Memory" Mechanisms Considered, None Adopted Yet (Including a Self-Organizing Domain Glossary)

- **Date:** 2026-07-10
- **Status:** adopted (2026-07-10) — analysis and documentation only, nothing built, same posture as `0046`/`0047`/`0049`.
- **Priority:** direct follow-up to explaining `docs/FAQ.md`'s role — a natural "what else is like this" question, plus one substantive candidate raised by the user.

## Problem

After explaining `docs/FAQ.md`'s role and how it travels to product repos, the natural next question: what other framework-repo-level or product-repo-level "memory" mechanisms are worth considering, and does anything add real value at this stage of the first pilot? One specific candidate was raised: a system-specific (product/technology/domain) glossary of terms and definitions that "self-organizes" and "self-learns," growing and evolving with the product.

For context, not as a gap: six distinct, non-overlapping memory mechanisms already exist — `docs/FAQ.md` (mechanics reasoning), `docs/evolution/EVOLUTION_LOG.md` (decision history), `LEARNINGS.md` (incidental discoveries), `LESSONS_LEARNED.md` (failed-hypothesis outcomes), `docs/CONSTRAINTS.md` (codified rules, no reasoning attached), `.escalations_archive/` (failure-mode history, archived not deleted). Each answers a different question; none of the candidates below duplicate an existing one.

## Candidates considered

1. **Glossary of framework terms** (C-V-R, Core Data Anchor, Micro- vs. Agile-PDLC) — **rejected.** Already reasonably covered by `README.md`'s "Core design" section; no actual confusion has surfaced in this pilot or otherwise.
2. **A "common mistakes per stage" doc** — **rejected.** This is exactly what `docs/FAQ.md` already becomes organically as real mistakes get found (see entries `0025`, `0048`'s Windows gotchas). A preemptive version would mean guessing what future mistakes will be — the same "add machinery ahead of evidence" pattern rejected everywhere else this session.
3. **Search/indexing over `docs/FAQ.md` as it grows** — **rejected.** Still well under the size where grep-and-skim is painful (50 entries as of this writing). Revisit only once that stops being true.
4. **A consolidated onboarding doc** tying `README.md`/`FAQ.md`/`CONSTRAINTS.md`/`CLAUDE_WORKFLOW_PLAYBOOK.md` together — **rejected.** No one has hit "I don't know where to start" friction yet — the current pilot user is this framework's first real external user, and hasn't reported this as a problem.
5. **A product-specific, self-organizing, self-learning domain glossary** (user-proposed) — the most substantive candidate, addressed in full below.

## The glossary proposal, in two parts

**Plain version: a per-product `GLOSSARY.md`.** A manually-appended file disambiguating domain terms as they come up in a specific product's own context — e.g., what "chunk," "session," or "top-k" specifically mean inside `research-kb`'s own architecture, where that might diverge from the generic ML/LlamaIndex meaning. Same shape as `LEARNINGS.md`: append-only, one line or short entry per term, written by a human or an agent when a real ambiguity is hit, zero new machinery. This is a reasonable, cheap, Tier-2-style candidate — **once a product actually shows term-confusion friction.** Not yet demonstrated in this pilot; nothing suggests it's needed today rather than hypothetically useful.

**"Self-organizing and self-learning" version — rejected as premature and structurally risky, not just unproven.** Those two words imply ongoing automated maintenance: some process that extracts, clusters, or updates terminology on its own rather than a human or agent choosing to append a line. That's exactly the "coordination requires software" default entry `0001` already named and rejected as unexamined dogma, and it edges directly into the continuous/polling machinery `docs/CONSTRAINTS.md`'s no-alerting/no-watcher-process rules exist specifically to keep out. No concrete need for *automation* has been shown — a human or agent noticing a term is confusing and writing one line costs nothing more than a "smart" system trying to detect that same thing automatically, and the automated version adds real surface area (what triggers an update, what counts as "self-organizing," who reviews what it produces) for no demonstrated benefit over the plain version.

## Decision

None of the five adopted now. The plain per-product glossary is the one genuinely promising candidate out of everything considered — named and parked here for `research-kb` (or any product built from this framework) to adopt on its own the moment real term-confusion friction actually shows up, using the same `LEARNINGS.md`-style shape already established elsewhere in this framework. The "self-organizing/self-learning" framing is explicitly not the recommended path if this is ever built — start plain, add automation only if the plain version's own friction later justifies it, the same escalation path every other Tier 2 addition in this framework has followed.

## What happened

`docs/FAQ.md` gained one entry summarizing this analysis. No script or `.mwp-templates/` change. `VERSION` bumped MINOR (new FAQ entry, a travel-doc).

## Outcome (2026-07-10)

Documentation only — no test-suite impact expected, confirmed by re-running the full suite.
