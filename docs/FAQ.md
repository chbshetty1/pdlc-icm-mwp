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

## When does the framework check whether a required tool (Fabric, Graphify, Repomix, DuckDB) is installed — and does it install missing ones automatically?

Two layers, once entry `0013` is implemented: an on-demand `doctor.sh` that scans the whole tool matrix at once (run manually, whenever), and a lazy per-stage check right before `CLAUDE.md`'s automation routing tries to invoke a tool — if it's missing, that check fails clearly via the existing escalation contract (`BLOCKED_REASON.md`) instead of a cryptic "command not found" mid-task. Nothing checks at `scaffold.sh` time, since a feature might not reach the stage that needs a given tool for a while.

No auto-install by default. Installing software is a bigger side effect than anything else this framework does — everything else is scoped to reading/writing markdown in a declared folder. A missing tool escalates with the exact install command; a human decides whether to run it. `doctor.sh --install-missing` exists as an explicit opt-in for anyone who wants the convenience, but it's never the default behavior. See `docs/evolution/0013-verify-tooling-matrix.md`.

## Does the framework support configurable logging (log levels, per-stage verbosity)?

No, deliberately. What exists (once entry `0014` is implemented) is a single always-on operational log — one line per script invocation, no levels, no per-stage config — because a configurable logging subsystem is exactly the kind of machinery entry `0001`'s first-principles analysis already flagged as the "coordination requires software" dogma this framework rejects. It would also add more surface area that context-bundling tools (Repomix, Graphify) have to be told to ignore, and a shared config file editable by multiple features risks becoming the same class of coordination-cost problem entry `0003` is trying to fix for the priority registry. See `docs/evolution/0014-minimal-operational-log.md`.

## Is the framework itself versioned? Are individual stages versioned?

Yes to both, but lightly — no full semver, no automated upgrade tool. A root `VERSION` file (a plain incrementing number) gets bumped whenever an evolution entry is adopted and changes something shipped. Each file in `.mwp-templates/` carries its own one-line version marker, incremented independently, since stages evolve at different rates. This exists specifically because propagation to new products is a plain file copy, not a git submodule — the moment a product repo copies `.mwp-templates/`, it loses this repo's git history, so a version marker is the only way to later tell "what did we start from." There's deliberately no automated tool yet that pulls newer templates into an existing product and merges them against that product's own changes — no concrete need for that has shown up. See `docs/evolution/0015-framework-and-template-versioning.md`.

## The evolution log has entries ranked "1 of 5," "1 of 6," and unscaled adjectives like "high" — what's actually the single most important one to do next?

Check `EVOLUTION_LOG.md`'s "Overall Rank" column rather than the "Batch Priority" column — the batch numbers were each only ranked against the other items written in the same brainstorming pass, not against the whole backlog. Entry `0024` (the fourth version — it superseded `0022`, which superseded `0021`, which superseded `0019`, each time a new entry needed a slot or a dependency surfaced) reconciles all of them into one 1–19 ordering (0001 is left unranked, since it's a standing reference analysis rather than a queued task). As of that entry: 0002 (verify scripts run, adopted) ranks first, 0013 (verify tools work, in progress) second, 0015 (versioning) third, and 0018 (scope-containment verification) fourth as the most foundational design gap. 0023 (PowerShell bash pre-flight check) slotted in at rank 8, shifting everything from 0016 downward by one. Re-prioritizations happen as new numbered entries superseding the old one, never by editing a ranking entry in place — expect this entry to need another update the next time a new backlog item needs a slot.

## If I start implementing entries from the backlog, do the other changes happen automatically, or do I need to execute each one individually?

Individually — nothing cascades. Each entry in `docs/evolution/` is implemented and marked `adopted` on its own, following the "Proposed → Adopted workflow" in `EVOLUTION_LOG.md`: pick one (by Overall Rank, normally), run its stepwise plan, record the outcome, update its status, update the log table row. Finishing one entry never automatically triggers, half-implements, or invalidates another, even entries that are related.

"Related" is worth being careful with, though: entry `0020`'s "Known cross-entry collisions" section documents cases where two entries touch the same file (`0018` and `0012` both edit all six stage `CONTEXT.md` files) or where one depends on another's output existing first (`0016`'s status script depends on `0009`'s `SYNC_LOG.md`). Overall Rank already sequences around most of that, but before starting an entry it's worth a quick check of whether anything it depends on is still unimplemented — the rank alone doesn't encode dependencies, just relative priority.

## Is there documentation for developing this framework itself (not just using it)?

Partially, and it's getting consolidated. `EVOLUTION_LOG.md`'s "How to use this" section already covers the change process, and script conventions (`set -euo pipefail`, validating args before doing anything destructive, testing changes in a scratch copy before touching committed files) have been used consistently but were never written down. Once entry `0020` is implemented, `docs/DEVELOPMENT.md` consolidates that — conventions plus a short map of what each doc file is for — framework-repo-only, like `docs/evolution/` and `PROJECT_PLAN.md`; it doesn't travel to new products. It deliberately doesn't add per-script or per-stage documentation beyond what already exists — the scripts are short enough to read directly, and the "why" for any non-obvious choice already lives in the relevant evolution entry. See `docs/evolution/0020-framework-development-doc.md`.

## Is there a single place that lists all of this framework's constraints?

Not yet, but there should be — once entry `0017` is implemented, `docs/CONSTRAINTS.md` will consolidate every framework-level non-negotiable (directory containment, no auto-install, no configurable logging, no alerting) in one place with a pointer to where each is actually declared or enforced. Until then, they're spread across `IDENTITY.md`, `CLAUDE.md`, and individual evolution entries.

## Are the framework's constraints actually enforced, or just stated as instructions?

Mostly just stated, and the most important one has zero enforcement at all — worth knowing plainly rather than assuming otherwise. Token guardrails (`0004`) and shared-schema collisions (`0005`) are proposed artifact-level checks (easy, since the evidence is a file you can inspect after the fact). But the single most foundational constraint — that an agent only reads the files explicitly declared in its stage's `CONTEXT.md` — currently has **no verification at all**, just the agent being asked to comply in `IDENTITY.md`. Building real technical enforcement for that (file-access tracing) would be significant infrastructure this framework has deliberately avoided elsewhere. The proposed middle ground (entry `0018`) is a self-reported "Context Manifest" the agent produces and a human checks against the declared scope at the same review gate everything else already goes through — better than nothing, explicitly not airtight. See `docs/evolution/0018-scope-containment-verification.md`.

## Does the framework monitor active features, and does that happen per-stage?

Yes to both, but only as an on-demand check, not a running/alerting system — there's no daemon or service in this framework for a monitor to live in. Once entry `0016` is implemented, `scripts/status.sh` scans all active features on request and reports two views from one scan: per-feature (current stage, blocked or not) and a stage-level rollup (how many features are sitting at, or blocked at, each of the 6 stages). The stage-level view is what surfaces systemic problems — if features keep stalling at the same stage, that's a signal the stage's contract or tooling needs attention, not that each feature independently had bad luck.

No alerting (Slack pings, "notify if blocked > N days") is planned — same reasoning as no-auto-install (`0013`) and no-configurable-logging (`0014`): building a watcher implies a running system this framework doesn't have, and there's no concrete need for one yet. See `docs/evolution/0016-status-monitoring-script.md`.
