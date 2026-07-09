# 0028 — Unified Backlog Re-Prioritization v6 (supersedes 0026)

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-09)
- **Supersedes:** [0026](0026-unified-backlog-reprioritization-v5.md)

## What changed

Entry 0027 slots in at rank 21 — the only unranked item, appended after every previously-ranked entry (1–20), all of which are now `adopted`. Reasoning:

- **No dependencies either direction:** nothing in the (now fully-adopted) 1–20 ranking depends on 0027, and 0027 doesn't depend on anything unfinished — it's a self-contained fix to `scaffold.sh`'s `--sprint` mode (or `registry.sh`, depending which of its two candidate resolutions gets picked).
- **Low urgency, matching its own stated priority:** it's a real but low-stakes point of confusion (a dead-weight file plus a misleading printed message) affecting only `--sprint`/Agile-PDLC users, not a correctness or safety gap. Nothing else in the backlog is waiting on it.
- **Not yet ready to implement blind:** step 1 of its own plan requires a human decision (skip `FEATURE_META.md` creation for sprints, vs. make `registry.sh` sprint-aware) before any code changes — same "confirm before mass-editing" pattern entry 0025 used, and 0012 used mid-implementation.

No other reordering — there's nothing left to reorder among; 1–20 are all `adopted`.

## Unified ranking (1 = do first; 1–20 shown adopted for continuity)

1. **0002** — Cross-platform script verification *(adopted)*.
2. **0013** — Verify the tooling matrix *(adopted)*.
3. **0015** — Framework/template versioning *(adopted)*.
4. **0018** — Scope-containment verification *(adopted)*.
5. **0003** — Computed priority registry *(adopted)*.
6. **0005** — Shared-schema collision check *(adopted)*.
7. **0009** — Sync audit trail *(adopted)*.
8. **0023** — PowerShell bash pre-flight check *(adopted)*.
9. **0016** — Status/monitoring script *(adopted)*.
10. **0004** — Enforce token guardrails *(adopted)*.
11. **0008** — Lessons-learned register *(adopted)*.
12. **0025** — Relative-path depth audit *(adopted)*.
13. **0010** — Archive, don't delete, escalations *(adopted)*.
14. **0017** — Consolidated `CONSTRAINTS.md` *(adopted)*.
15. **0020** — Framework development documentation *(adopted)*.
16. **0011** — Generalize FAQ-capture wording *(adopted)*.
17. **0007** — Product-level decision log *(adopted)*.
18. **0012** — Shared-learnings file *(adopted)*.
19. **0006** — Test `--sprint` mode *(adopted)*.
20. **0014** — Minimal operational log *(adopted)*.
21. **0027** — `scaffold.sh --sprint` creates a dead-weight `FEATURE_META.md` *(adopted)*.

`0001` remains unranked (standing reference, not queued). With 1–20 adopted and 0027 now ranked, the entire backlog as of this pass has exactly one open item.

## Outcome (2026-07-09)

Entry 0027 was subsequently adopted at rank 21, as this entry proposed — resolution (a): `scaffold.sh` skips `FEATURE_META.md` creation for `--sprint` mode entirely rather than making `registry.sh` sprint-aware, per 0027's own Outcome. That closed out every ranked item (1–21); no further reordering has been needed since, since nothing has re-entered the backlog with a rank rather than being logged as its own standalone entry (0029 onward). This entry's `Status` was left at `proposed` after that happened — a pure bookkeeping gap, not a sign 0027 wasn't actually acted on — caught during a later documentation-consistency check and closed out here. No functional change; `EVOLUTION_LOG.md`'s row updated to match. No `VERSION` bump: this entry only reorders/documents the backlog itself, same as `0021`/`0022`/`0024`/`0026` before it, and `docs/evolution/` is framework-repo-only (doesn't travel to new products).
