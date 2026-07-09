# 0042 — Critical-Theory Audit of the Shipped Framework

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-09) — standing reference, same posture as `0001`; the corrective actions below are what got adopted, not a rebuild of the core model
- **Trigger:** requested review — analyze the framework's documentation and self-hosting evidence the way an academic critical theorist would, across five lenses: argument & evidence, methodology & framework, context & bias, limitations & gaps, significance.
- **Scope reviewed:** `README.md`, `PROJECT_PLAN.md`, `docs/evolution/0001-first-principles-analysis.md`, `docs/CONSTRAINTS.md`, `docs/PRIORITIZATION_GUIDE.md`, `docs/FAQ.md`, `CLAUDE.md` — the framework's documentation and self-generated test evidence as shipped through entry `0041`. No feature built with the framework exists yet, so nothing product-level was in scope.

## What this entry is, and isn't

Companion to `0001`, not a duplicate of it. `0001` is an internal critique from the framework's own designer, stripping assumptions to find what's load-bearing — it concludes the shipped 6-stage/C-V-R model is a legitimate, low-cost *approximation* of a more general Decision Node DAG, and sets trigger conditions for when to rebuild toward that model. This entry applies a different, external critical apparatus (evidentiary standards, methodological objectivity, bias/context, unstated limitations, real-world significance) to the same object, and finds a different class of gap: not "is the formula theoretically correct" but "does any of the evidence gathered so far actually test the framework's central claim."

## 1. Core finding: the framework's evidence doesn't test its own thesis

The implicit thesis — folder-scoped, human-gated context beats the alternatives for AI-agent-driven product development — has never been tested. All 203 `tests/run_tests.sh` assertions verify that scripts behave correctly against synthetic scratch data (does `sync.sh` rename a file, does `registry.sh` sort correctly). None of them measure agent output quality, and no pilot data exists yet — `README.md`'s own "Status" section already says so. Passing tests have nonetheless functioned, informally, as if they were evidence for the methodology, not just the plumbing. That conflation was never previously named anywhere in the corpus.

## 2. Core finding: self-critique alone missed it

`0001` is a rigorous internal audit — it correctly identifies and rejects the C-V-R bypass rule as question-begging, and correctly flags the 6-stage model as an arbitrary cut through a dependency graph. But it never surfaces the finding above, because it critiques the framework's *design*, not its *evidentiary basis*. A same-author, same-session critique — however sharp — has a structural blind spot a differently-shaped critical lens exists to catch. Worth treating as a standing practice, not a one-off: this entry is that second lens, logged the same way `0001` was.

## 3. Core finding: default posture leans one vendor despite stated policy

`docs/CONSTRAINTS.md` (entry `0031`) states "no proposal may hard-couple the framework to one vendor, model, or proprietary format." The mechanism (plain markdown, folder scoping) satisfies that. The *defaults* don't: `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` and the root `CLAUDE.md` routing file default every stage to one vendor's specific products, and the framework itself was built inside that vendor's own coding-agent tooling. The FAQ's "agent-agnostic, no Claude required" claim is true of the mechanism and misleading about the defaults.

## 4. Core finding: every adoption is self-graded

The same agent that implements an entry also writes its test suite and marks it `adopted`, every time, across all 41 prior entries. No external or adversarial review has occurred at any point. Not necessarily wrong for the low-stakes, easily-reversible changes this framework has adopted so far — but it's a real, previously unnamed limit on how much confidence "adopted" should carry.

## Assumptions this entry surfaces

Not a repeat of `0001`'s "Current dogma" — that section names the framework's *design* assumptions. This one names the assumptions its own evidentiary base rests on, several of which were never stated anywhere before this audit.

| # | Assumption | Status |
|---|---|---|
| A1 | Coordination needs *some* fixed structure (folders) to constrain an agent | Already partially rejected by `0001` — kept as a pragmatic approximation, not a truth |
| A2 | 6 fixed stages correctly capture product-development information dependency | Already flagged **wrong** by `0001` ("a feature or stage is not a natural unit"). Kept anyway for cost |
| A3 | A small numeric formula (C-V-R) can proxy priority uniformly | Already flagged **wrong** by `0001` (the bypass rule is "evidence C-V-R was measuring the wrong thing"). Kept anyway |
| A4 | Internal test-suite passage validates the *methodology*, not just the scripts | **Wrong, and never previously stated as an assumption at all** — this entry's finding #1. It was operating silently until named here |
| A5 | Markdown+folders being agent-agnostic means the framework *behaves* agent-agnostically | **Partially wrong** — finding #3. Mechanism is agent-agnostic, defaults aren't |
| A6 | Same-agent implement→test→grade-`adopted` is adequate quality control | Never stated as an assumption, but has been the practice for 41 prior entries — finding #4 |

New assumptions adopted going forward, to keep the corpus honest about its own current status:

- **NA1:** Test-suite passage certifies script correctness only. Methodological efficacy is a separate, currently unmeasured claim — stated explicitly now in `tests/run_tests.sh` and `docs/DEVELOPMENT.md` (see corrective action #3 below).
- **NA2:** This framework's design legitimacy currently rests on internal coherence and self-consistency, not external validation. That's the honest current status, not a temporary footnote to be quietly outgrown.
- **NA3:** Default tool/vendor recommendations in `CLAUDE_WORKFLOW_PLAYBOOK.md` are convenience defaults, not endorsements, and must remain trivially swappable in practice, not just in stated policy.
- **NA4:** A real pilot's evidentiary bar is comparison against a stated counterfactual (a non-framework attempt, a different orchestration approach, even a rough estimate) — not the framework's own internal test suite passing.

## Corrective actions adopted alongside this entry

Four cheap, doc-only fixes that directly close the gaps above, adopted now rather than deferred, since none require touching script behavior:

1. `docs/FAQ.md` gained a Q&A entry surfacing this audit and its findings — same discoverability treatment `0001` already has.
2. `README.md`'s "Status" section now points to this entry alongside `0001`.
3. `tests/run_tests.sh`'s summary output and `docs/DEVELOPMENT.md`'s "Testing this framework" section now state explicitly that a passing suite certifies script correctness, not methodology efficacy — closing finding #1 at the point anyone actually reads a test result.
4. `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`'s opening line now restates, at the point of actual friction (not just buried in the FAQ), that its Claude-surface mapping is a swappable default, not a requirement — closing finding #3.

No change was made to the 6-stage/C-V-R core, the self-hosting adoption process, or anything `0001` already governs — those stay gated by `0001`'s own trigger conditions, which this entry doesn't move.

## Trigger conditions for acting further on this audit

- If a real end-to-end pilot completes without capturing any counterfactual (token/time cost measured against *something* — a non-framework attempt, a different orchestration approach, even a rough estimate) — that's finding #1 going unaddressed by design. Flag before the pilot starts, not after.
- If a future evolution entry cites "N/N tests passing" as evidence the *methodology* works, rather than the scripts — that's the exact conflation finding #1 names, worth catching at review time even after the labeling fix above.
- If a second, independent reviewer (human or a different agent — not the one that implemented, tested, and marked an entry `adopted`) is ever brought into the adoption process, that's the point to revisit whether self-graded review remains adequate for anything beyond doc-only fixes (finding #4).
- If `CLAUDE_WORKFLOW_PLAYBOOK.md`'s Claude-surface recommendations are ever treated as a requirement rather than a swappable default — by this repo or a product copied from it — that's finding #3 actually biting despite the corrective line above.
- If the framework is used across more than one product or team at once, revisit whether same-agent self-review is still adequate — sharpens `0001`'s own "more than one product" trigger condition with this entry's specific finding on self-grading.

Until one of these fires, the four corrective actions above are treated as sufficient — this entry doesn't mandate a structural rebuild, only honesty about what's actually been demonstrated versus claimed.

## Planned actions: medium and long term

Documented here as *plan*, not as done — unlike the corrective actions above, none of this has been executed. Kept as a written commitment rather than left to memory, since this entry's own finding #1 is exactly about things being treated as settled when they weren't checked.

**Medium term, tied to the already-planned end-to-end pilot:**
- Design the pilot's data capture *before* it starts, not after: log token usage and time-to-stage-6, and if feasible run one comparable task outside the framework for contrast — satisfying NA4 above, so the pilot produces a comparison, not just an existence proof.
- Treat the pilot's `SYNC_LOG.md`/`status.sh` output as the first real, non-synthetic evidence gathered so far, and revisit `0001`'s trigger conditions (not just this entry's) against what actually happens during it.
- **Update, same day:** formalized as `docs/evolution/0043-pilot-measurement-plan.md` and `docs/PILOT_MEASUREMENT_PLAN.md` — a tiered, prioritized version of this bullet, plus a direct answer to whether any of it needs an exception to the anti-bloat constraint (no).

**Long term, contingent — not scheduled, not owed a date:**
- Only if the framework is ever used across more than one product or team: consider adding an external-review gate to the adoption checklist, since same-agent self-grading (finding #4) is the weakest link this audit found. Per this framework's own "don't build until concrete need" discipline (`docs/CONSTRAINTS.md`), not before that actually bites.
- Only revisit the Decision Node DAG rebuild (`0001`'s "v2") if `0001`'s own trigger conditions fire. This entry reinforces that gate is correctly placed — it doesn't add urgency or move it.

## Outcome (2026-07-09)

Implemented as written: entry logged, `EVOLUTION_LOG.md` row added, `docs/FAQ.md` entry added, `README.md` pointer added, `tests/run_tests.sh` + `docs/DEVELOPMENT.md` labeling added, `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` opening line strengthened. Addendum, same day: the assumptions table and the medium/long-term action plan above were caught missing from the initial version of this entry (they'd only been stated in conversation, not written down) and added on follow-up — worth noting since it's a small, direct instance of finding #1's pattern (something treated as settled that hadn't actually been checked/recorded). `VERSION` bumped MINOR (`docs/FAQ.md` gaining a new entry and `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` being edited are both changes to docs marked "Travels with new products" per `docs/DEVELOPMENT.md`'s checklist — a new FAQ entry is explicitly named as a MINOR-tier example there). No `template-version` marker changes (nothing in `.mwp-templates/` touched). `tests/run_tests.sh` re-run after the labeling change to confirm the new output line doesn't break `run_suite()`'s summary-parsing regex in `tests/run_tests.sh` itself (it doesn't — the new line isn't a `SUMMARY:`-prefixed line, so it's inert to every existing test's log-scraping logic).
