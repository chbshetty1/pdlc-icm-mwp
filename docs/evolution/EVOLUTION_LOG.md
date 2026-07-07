# Evolution Log

This is the running record of how this framework's design has been challenged, revised, or deliberately left alone. It exists so future readers (including future us) can see *why* the framework looks the way it does, not just what it currently looks like.

## Convention

- Every substantive design analysis, critique, or change gets its own file in `docs/evolution/`, named `NNNN-slug.md` (zero-padded, sequential, never reused or renumbered).
- Each entry is added to the table below. Never edit or delete a past entry's content — if a conclusion later turns out wrong, add a new entry that supersedes it and note that in the "Status" column. The log is append-only, same as the framework's own philosophy of preserving intermediate state.
- Status values: `proposed` (analysis exists, no action taken yet), `adopted` (changed the shipped framework), `rejected` (considered, explicitly not doing it, with reasons), `superseded` (an entry that later analysis overrode).

## Log

| # | Date | Title | Status | Overall Rank | Batch Priority | Summary |
|---|---|---|---|---|---|---|
| 0001 | 2026-07-07 | [First-Principles Analysis](0001-first-principles-analysis.md) | proposed | unranked (standing reference) | — | Strips the v1 framework to fundamental truths (context-as-tokens economics, decisions-not-stages, irreversibility over effort, single-writer concurrency). Concludes v1's fixed 6-stage pipeline, Micro/Agile/Lean labels, and C-V-R bypass rule are practical approximations of a more general "Decision Node DAG" model — flags concrete trigger conditions for when to migrate. No changes made to the shipped framework yet. |
| 0002 | 2026-07-08 | [Cross-Platform Script Verification](0002-cross-platform-script-verification.md) | proposed | **1** | 1 of 5 | Automation scripts are bash-only; actual usage environment is Windows PowerShell. Potential live blocker — needs verification via Git Bash/WSL before anything else here matters in practice. |
| 0003 | 2026-07-08 | [Computed Priority Registry](0003-computed-priority-registry.md) | proposed | **4** | 2 of 5 | `FEATURE_PRIORITY_REGISTRY.md` is hand-edited shared state — the same coordination-cost problem the framework warns against for shared schemas, self-inflicted in its own bookkeeping. Proposes generating it from per-feature metadata instead. |
| 0004 | 2026-07-08 | [Enforce Token Guardrails](0004-enforce-token-guardrails.md) | proposed | **7** | 3 of 5 | Every `CONTEXT.md` declares a token ceiling but nothing measures it. Proposes a lightweight check in `sync.sh` so the stated discipline is actually verified. |
| 0005 | 2026-07-08 | [Automate Shared-Schema Collision Check](0005-automate-shared-schema-collision-check.md) | proposed | **5** | 4 of 5 | "Shared Architecture Sync" is currently a prompt-level rule with no mechanical backstop. Proposes a pre-sync check against a formal `shared_paths` list. |
| 0006 | 2026-07-08 | [Test `--sprint` Mode](0006-test-sprint-mode.md) | proposed | **17** | 5 of 5 | `--feature` mode was tested end-to-end this session; `--sprint` shares the code path but was never exercised. Test-coverage gap, not a design problem. |
| 0007 | 2026-07-09 | [Product-Level Decision Log](0007-product-level-decision-log.md) | proposed | **14** | 1 of 6 | Products built from this framework have no equivalent of `docs/evolution/` for their own architecture decisions. Proposes shipping a blank decision-log template with every new product instead of leaving it as a suggestion. |
| 0008 | 2026-07-09 | [Lessons-Learned Register](0008-lessons-learned-register.md) | proposed | **9** | 2 of 6 | Pivoted features get archived but not summarized — nothing stops a disproven hypothesis from being retried later. Proposes `pivot.sh` auto-appending to a running `LESSONS_LEARNED.md`. |
| 0009 | 2026-07-09 | [Sync Audit Trail](0009-sync-audit-trail.md) | proposed | **8** | 3 of 6 | `sync.sh` advances stage outputs but records no approval trail. Proposes an optional approver argument and a `SYNC_LOG.md` append on every successful sync. |
| 0010 | 2026-07-09 | [Archive, Don't Delete, Escalations](0010-archive-not-delete-escalations.md) | proposed | **10** | 4 of 6 | `CRITICAL_ESCALATION.md` currently allows deleting a resolved `BLOCKED_REASON.md`, losing failure-mode history. Proposes archive-only, never delete. |
| 0011 | 2026-07-09 | [Generalize FAQ-Capture Wording](0011-generalize-faq-capture-wording.md) | proposed | **13** | 5 of 6 | `CLAUDE.md`'s FAQ-capture instruction says "the framework," which could be read too narrowly once copied into a product repo. Proposes wording that covers both cases. |
| 0012 | 2026-07-09 | [Shared-Learnings File](0012-shared-learnings-file.md) | proposed | **15** | 6 of 6 | No home exists for incidental cross-feature discoveries (rate limits, library quirks) distinct from `GLOBAL_CONTEXT.md`'s deliberate constraints. Proposes a `LEARNINGS.md` any stage can append to. |
| 0013 | 2026-07-09 | [Verify the Tooling Matrix Actually Works](0013-verify-tooling-matrix.md) | proposed | **2** | high | `TOOLING_MATRIX.md` documents a tool stack that's never actually been installed or run. Proposes verifying each tool for real (split sandbox-testable vs. user-machine-only), plus a `doctor.sh` two-layer check (on-demand full scan + lazy per-stage check reusing the escalation contract) with auto-install strictly opt-in via `--install-missing`, never on by default. |
| 0014 | 2026-07-09 | [Minimal Operational Log](0014-minimal-operational-log.md) | proposed | **18** | moderate | Scripts echo to stdout but nothing persists it. Proposes a single always-on `.mwp/framework.log` (one line per invocation, no levels, no per-stage config) — deliberately rejects configurable logging as reintroducing the "coordination requires software" dogma entry 0001 already flagged. |
| 0015 | 2026-07-09 | [Framework-Level Version + Per-Template Version Markers](0015-framework-and-template-versioning.md) | proposed | **16** | moderate | Propagation is a plain `cp`, severing git history the moment a product copies `.mwp-templates/`. Proposes a root `VERSION` file plus a per-file `template-version` marker — deliberately no semver ceremony or auto-upgrade tooling until there's a concrete need. |
| 0016 | 2026-07-09 | [On-Demand Status/Monitoring Script](0016-status-monitoring-script.md) | proposed | **6** | moderate-high | No at-a-glance view exists of what's blocked or in-progress across active features. Proposes `scripts/status.sh`: per-feature stage/blocked status plus a stage-level rollup, on-demand only, no alerting. Shares scan logic with 0003. Resurrects an idea dropped from the original 0002-0006 batch. |
| 0017 | 2026-07-09 | [Consolidated CONSTRAINTS.md](0017-consolidated-constraints-doc.md) | proposed | **11** | low-moderate | Framework-level non-negotiables (no auto-install, no configurable logging, no alerting, directory containment) are scattered across several files. Proposes one consolidated `docs/CONSTRAINTS.md` — documentation only, no behavior change. |
| 0018 | 2026-07-09 | [Verify Scope/Directory Containment](0018-scope-containment-verification.md) | proposed | **3** | high | The single most foundational constraint in the framework — an agent only reads its declared scope — has zero verification, unlike the artifact-level checks in 0004/0005. Proposes a self-reported Context Manifest reviewed at the human gate; explicitly not airtight, with mechanical file-access tracing noted as a future escalation only if needed. |
| 0019 | 2026-07-09 | [Unified Backlog Re-Prioritization](0019-unified-backlog-reprioritization.md) | **superseded by 0021** | ~~n/a~~ | — | Reconciles four incompatible batch-relative priority scales into a single 1–17 cross-batch ranking. Superseded once entry 0020 needed a slot — see 0021. |
| 0020 | 2026-07-09 | [Framework Development Documentation](0020-framework-development-doc.md) | proposed | **12** | — | Script conventions and the evolution-log process exist but are scattered; no doc states them explicitly. Proposes one framework-repo-only `docs/DEVELOPMENT.md` (conventions + doc map), not per-script/per-stage documentation. |
| 0021 | 2026-07-09 | [Unified Backlog Re-Prioritization v2](0021-unified-backlog-reprioritization-v2.md) | proposed | n/a (this is the re-prioritization) | — | Supersedes 0019 to slot in 0020 at rank 12 (same class as 0017 — cheap documentation consolidation), shifting ranks 12–17 down by one to 13–18. |

*"Batch Priority" preserves each entry's original within-batch ranking as historically written (append-only, per the log's own convention). "Overall Rank" is the current single cross-batch ordering from entry 0021 (0019 is superseded) — use this column to decide what to pick up next.*

## How to use this when evolving the framework

1. Before changing a core mechanic (stage count, scoring formula, isolation model), write an entry here first — dogma / fundamentals / rebuild for big structural questions, or problem / proposed change / stepwise plan for smaller tactical ones — even if the answer is "keep it as is, and here's why."
2. If an entry leads to an actual change, update the relevant file (`docs/PRIORITIZATION_GUIDE.md`, stage `CONTEXT.md` templates, etc.) in the same commit, and mark the entry `adopted`.
3. If you later reverse a decision, don't rewrite history — add a new numbered entry and mark the old one `superseded`, with a one-line pointer to the new entry.

## Proposed → Adopted workflow

Every entry above is currently `proposed`: the analysis and a stepwise plan exist, but no code or template has changed. To move one forward:

1. **Pick one entry**, starting from its priority rank unless something more urgent has surfaced since.
2. **Run its stepwise plan** as written (each entry already lists the exact steps — no re-planning needed).
3. **Record the outcome** in the same entry file: append what actually happened, especially if reality diverged from the plan.
4. **Update the entry's Status** to `adopted` (change made, working as intended), `rejected` (tried or reconsidered, explicitly not doing it — say why), or leave as `proposed` if paused mid-way.
5. **Update `EVOLUTION_LOG.md`'s table row** to match the new status.
6. **If adopted**, the actual framework files (`scripts/*.sh`, `.mwp-templates/*`, `docs/*`) get edited in the same commit as the status change — the evolution entry and the shipped change land together, never separately.
