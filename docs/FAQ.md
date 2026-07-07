# FAQ

Questions that came up while building and reasoning about this framework, kept here because the answers involve context that doesn't fit naturally into `README.md` or the other reference docs.

## Do I have to use Claude specifically?

No. The folder + `CONTEXT.md` mechanism is agent-agnostic — any LLM agent that respects a stage's declared input scope can run it. `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` is a reference workflow for teams using Claude (which Chat/Cowork/Code CLI surface fits which stage), not a requirement. Swap in a different agent and the rest of the framework works unchanged.

## Can I use this framework to develop the framework itself?

Yes, with one boundary: this repo is meant to stay a clean, product-agnostic template (`features/` and `sprints/` are gitignored so no live workspace data accumulates here). So "self-hosting" happens one of two ways:

- **Most changes** (a `CONTEXT.md` tweak, a script fix, a doc update): use `docs/evolution/` directly, in this repo. Write an entry, edit the actual file in the same commit, mark it `adopted`.
- **Bigger, genuinely uncertain structural changes** (e.g. testing a new scoring model): pilot it in a separate sandbox workspace using `scaffold.sh --feature` against a copy of the templates, run it through a real Build-Measure-Learn cycle, then fold only the validated result back into this repo as an evolution entry. Never commit the scaffolded feature folder itself here.

## Is developing the framework itself a PDLC process?

Yes — concretely, not just by analogy. The session that produced v1 of this framework maps onto all 6 stages: the original brainstorm and grounding it against reality (01), the design decisions that got locked in (02), the stage contracts and templates (03), the folder/script architecture (04), writing and actually testing the scripts end-to-end (05), and publishing to GitHub (06, in progress — the "go-to-market" half). The one thing not yet done is the "validation" half of stage 06: running a real product feature through the framework to test whether folder isolation and `CONTEXT.md` contracts are actually sufficient without a heavier orchestration layer. That's the framework's own riskiest assumption, and it's still open — see `docs/evolution/0001-first-principles-analysis.md`'s trigger conditions.

## Is `docs/evolution/` part of the framework, or something separate?

Both — it's a shipped, committed part of the repo (listed in `README.md`'s file map), but it's a parallel track to the 6-stage product pipeline, not a stage inside it. The 6 numbered stages are how a *product built with this framework* moves from assumption to validated ship. `docs/evolution/` is how the *framework itself* moves from assumption to validated change — deliberately lighter-weight, since framework tweaks are usually lower-stakes than shipping a product feature. Entries there (like 0002–0006) are shaped like Lean discovery candidates — a stated problem, a proposed fix, a stepwise plan — but they aren't literal `01_discovery_ideation` stage outputs from a scaffolded feature folder, because nobody ran `scaffold.sh --feature` for them.

## Why isn't the C-V-R prioritization formula used for framework-evolution entries?

C-V-R scores product features against business/engineering risk. Evolution entries are scored informally by priority rank (see each entry's "Priority: N of 5") based on how much real friction they remove versus how speculative they are — closer to expected-value-of-information than to C-V-R's specific formula. If this framework migrates toward the Decision Node model described in entry 0001, both product features and framework-evolution entries would likely score the same way.
