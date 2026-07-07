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

## Can I just build my product directly inside this framework repo instead of copying it elsewhere?

Don't. Nothing technically stops you, but `features/` and `sprints/` are gitignored specifically so this repo stays reusable across every future product. Build directly here and you lose the ability to cleanly reuse the framework next time — you'd have to manually pick the generic parts back out of a repo full of one product's history. Always copy `.mwp-templates/`, `scripts/`, and `CLAUDE.md` into a new, separate product repo, per the README's "Using this framework for a new product" steps.

## Should I let an AI agent (Claude Code, Cowork, etc.) run git commands directly against my working folder?

Be cautious about this, especially since Claude Code CLI is one of the three surfaces this framework's own playbook recommends for stages 05–06. While building this repo, running `git init`/`git commit` through a sandboxed AI environment against a folder synced from a real disk caused real corruption — `.git/config` came back zero-filled, and stale lock files (`index.lock`) were left behind, blocking all future git operations until manually cleared. The sandbox's file-sync mechanism didn't handle git's atomic rename/lock-file writes correctly, even though plain file reads/writes/deletes worked fine.

The safe pattern that worked: do git operations (`init`, `add`, `commit`, `push`) from your own terminal, on your own machine, using your own git installation. If an agent needs to prepare a repo on your behalf, it should build it in an isolated scratch location first and copy only the *finished* `.git` directory over as a whole-file copy — never run git commands incrementally against a live, synced working folder.

## My first `git push` to a freshly created GitHub repo was rejected as "non-fast-forward" — why?

GitHub can add an initial commit (e.g. a license file) even when you think every "initialize this repository" checkbox was left unchecked — this happened during this framework's own setup. Check what's actually on the remote before assuming a real conflict:

```
git fetch origin
git show origin/main --stat
```

If it's just a placeholder file with nothing you need, it's safe to overwrite:

```
git push --force-with-lease --set-upstream origin main
```

`--force-with-lease` is safer than plain `--force` — it double-checks the remote hasn't changed unexpectedly since your last fetch before overwriting anything.

## Which docs travel with a new product built from this framework, and which stay behind?

**Travels:** `docs/FAQ.md`, `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`, `docs/PRIORITIZATION_GUIDE.md`, `docs/TOOLING_MATRIX.md` — these are reference material a product team actually needs day-to-day, regardless of which product they're building. The README's "Using this framework for a new product" copy commands include them.

**Stays behind:** `docs/evolution/` and `PROJECT_PLAN.md` — these are about *this framework template's own* design history (why it has 6 stages, why C-V-R has a bypass rule, why the scripts are shaped the way they are). None of that is about your product. If you want to track your own product's architecture decisions the same append-only way, start a fresh `docs/evolution/` in your new repo — copy the convention (see `EVOLUTION_LOG.md`'s "How to use this" section), not the specific entries.

## Can VS Code (or Claude Code CLI) automatically capture FAQ-worthy conversations into this file?

Yes, going forward — `CLAUDE.md`'s root instructions now tell Claude Code (CLI or the VS Code extension, both read the file the same way) to proactively append reusable Q&A to this file whenever a conversation in this repo resolves one, without waiting to be asked. This only fires while Claude Code is actually working inside this repo (or a product repo copied from it) — it doesn't reach into Claude Chat conversations or retroactively pull in past sessions. Anything from before this instruction existed, or from a different surface (Chat, a different project), still needs to be pasted in manually.

## How should I name and describe a repo built from this framework?

Lowercase, hyphenated (`your-product-name`, not `YourProductName`) — GitHub URLs are case-insensitive anyway, and it matches the near-universal convention plus any tooling that assumes lowercase paths. For the repo's top-line description, keep it agent-agnostic even if you use Claude day-to-day — the core folder/`CONTEXT.md` mechanism works with any LLM agent, and naming one product in the front-door pitch narrows your audience and can read like an implied endorsement you don't have. Save Claude-specific detail for `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`, where it's accurately scoped to where it actually applies.
