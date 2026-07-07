# 0001 — First-Principles Analysis of the v1 Framework

- **Date:** 2026-07-07
- **Status:** proposed (no changes made to the shipped framework as a result of this entry)
- **Trigger:** requested review — "strip the framework of assumptions/tradition/analogy and rebuild from fundamental truths."
- **Scope reviewed:** the v1 framework as shipped — 6 fixed PDLC stages, Micro-PDLC/Agile-PDLC/Lean-PDLC as named variants, C-V-R prioritization scoring, folder-based context isolation.

## 1. Current dogma

Three unexamined beliefs sit underneath the v1 framework, independent of tool names:

- **Coordination requires software.** The industry default (LangChain, CrewAI, multi-agent orchestrators) assumes reliable multi-step AI work needs a program managing state and routing. v1 rejects the *code* version of this but still assumes some fixed external structure (folders) has to exist to constrain the agent — a smaller instance of the same belief.
- **Product development is phase-shaped.** Discovery → definition → spec → architecture → build → validate is treated as the natural shape of building something, with six being the "right" number of stages run in that order.
- **Prioritization is a scoring formula.** RICE, MoSCoW, and v1's own C-V-R all assume priority is computed from a small set of numbers on a fixed scale, applied uniformly to every unit of work.

Every patch already bolted onto v1 (Core Data Anchors "bypass the formula," the escalation contract, the shared-schema exception) is a symptom of these three beliefs cracking under real conditions, not evidence they're structurally correct.

## 2. Fundamental truths

Stripped of branding, tooling, and prior art:

- LLM output quality is bounded by which tokens are in context at inference time. Irrelevant tokens cost money and measurably degrade accuracy — a physical/economic constraint, not a style preference.
- Step ordering in product work is information dependency, not methodology: you can't validate a metric before knowing the assumption it tests, can't spec a build before knowing what's being validated. Input to step N must be output of step N−1, by logical necessity.
- Irreversibility, not effort, should govern how much scrutiny a decision gets. Cheap-to-reverse mistakes should be made fast and often; expensive-to-reverse ones validated hard before committing. This is optionality theory, not "Lean" or "Agile" as brands.
- Coordination cost between any two workers (human-human, human-AI, AI-AI) scales with how much shared, mutable state they both touch — not with whether they sit in the same folder.
- A "feature" or a "stage" is not a natural unit — it's an arbitrary cut through a messier web of dependent decisions. Folders impose a line on something that is actually a graph.
- Plain text/markdown is simply the intersection of "human-readable" and "machine-parseable" at near-zero tooling cost. It's correct because it's the cheapest thing satisfying two hard constraints, not because any methodology invented it.
- Prioritization is fundamentally maximizing expected value of information per unit of scarce resource (tokens, time, risk capital). Any formula is a proxy for this — when a proxy gives an obviously wrong answer (schema work scoring near zero because R=5), the proxy is broken, not exception-worthy.

## 3. Rebuilt from scratch

Discard the six named folders, the Micro/Agile/Lean labels, and the C-V-R formula. What remains, built only from the truths above, is a single recursive primitive: a **Decision Node** — an assumption, the cost if it's wrong, the cheapest experiment that would prove it right or wrong, and dependency edges to other nodes it needs resolved first. These form a DAG, not a pipeline.

Four consequences fall out without needing patches:

1. **Context is computed, not curated.** The tokens exposed to an agent working a node = the transitive closure of its dependency edges, computed fresh from the graph every time — never stale, never leaky, no human remembering to run `sync.sh`.
2. **Sequencing is continuous, not staged.** Priority = (cost if wrong × probability of being wrong) ÷ (cost to find out). A foundational schema change naturally sorts to the top because its cost-if-wrong is enormous — no special-cased bypass rule needed. v1's bypass rule is itself evidence C-V-R was measuring the wrong thing.
3. **Process intensity scales with irreversibility, not with folder position.** A trivial additive change and a schema migration shouldn't get marched through the same fixed gates. Uniform ceremony per stage is the "analysis paralysis" the framework claims to solve, reintroduced one level down.
4. **Concurrency is single-writer ownership, not folder isolation.** Identify shared mutable state up front (a schema, an auth model), give it one owner and one queue of proposed changes; everything read-only runs parallel forever. "Micro-PDLC vs. Agile-PDLC" collapses into one number — how much shared state a node's blast radius touches — computed per decision, not chosen as a global posture upfront.

Tooling (Obsidian, Repomix, Graphify, Fabric) reduces to three swappable functions underneath all of this: render text for humans, compress text to a budget, extract structure from noise. None of it is fundamental — vendor names are the least durable part of what's shipped.

## Where this leaves v1

v1 is a legitimate, low-cost, immediately usable approximation of the Decision Node model above — folders and a fixed 6-stage pipeline are what you get implementing a decision DAG with free, universal, git-compatible primitives instead of a real graph engine. That's a reasonable trade for something usable today.

### Trigger conditions for migrating toward the Decision Node model

Concrete signals that v1's approximation is leaking and a v2 (graph-based) redesign is worth the cost:

- The C-V-R bypass rule gets invoked more than occasionally (a sign the formula, not just the anchor case, is wrong).
- A feature repeatedly needs to read further upstream than one stage back (e.g. `05_development_test` needing raw `01_discovery_ideation` inputs directly) — a sign the dependency graph isn't actually linear.
- Two features that should have been sequential get run in parallel anyway because folder isolation didn't surface the shared-state conflict until late.
- The fixed 6-gate ceremony is being skipped or rubber-stamped for low-stakes changes because it's clearly disproportionate to the risk.
- You're maintaining this framework across more than one product and the "Micro vs. Agile" choice per product stops being a one-time decision and starts needing to vary per-feature within a single product.

Until one of these shows up in practice, keep v1 as shipped — this entry is a map for *when* to reach for something else, not a mandate to rebuild now.
