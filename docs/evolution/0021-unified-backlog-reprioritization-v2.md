# 0021 — Unified Backlog Re-Prioritization v2 (supersedes 0019)

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** n/a — this entry is the re-prioritization itself.
- **Supersedes:** [0019](0019-unified-backlog-reprioritization.md)

## Why a new entry instead of editing 0019

Entry 0019 itself said: "if... a real pilot feature changes what's urgent, re-rank in a new numbered entry rather than editing this one." The trigger here is smaller than a pilot result — just a new entry (0020) needing a slot — but the same rule applies: re-ranking is a new entry, not an edit to the old one.

## What changed

Entry 0020 (framework development documentation) is inserted at **rank 12**, immediately after 0017 (consolidated `CONSTRAINTS.md`) — both are the same class of item: consolidating already-scattered documentation, zero functional risk, no behavior change, cheap. Everything previously ranked 12–17 shifts down by one.

## Unified ranking (1 = do first)

1. **0002** — Cross-platform script verification.
2. **0013** — Verify the tooling matrix.
3. **0018** — Scope-containment verification.
4. **0003** — Computed priority registry.
5. **0005** — Shared-schema collision check.
6. **0016** — Status/monitoring script.
7. **0004** — Enforce token guardrails.
8. **0009** — Sync audit trail.
9. **0008** — Lessons-learned register.
10. **0010** — Archive, don't delete, escalations.
11. **0017** — Consolidated `CONSTRAINTS.md`.
12. **0020** — Framework development documentation *(new — same class as 0017: cheap, zero functional risk, consolidates scattered documentation)*.
13. **0011** — Generalize FAQ-capture wording.
14. **0007** — Product-level decision log.
15. **0012** — Shared-learnings file.
16. **0015** — Framework/template versioning.
17. **0006** — Test `--sprint` mode.
18. **0014** — Minimal operational log.

`0001` remains unranked (standing reference analysis, not a queued task). Reasoning for items 1–11 and 13–18 is unchanged from 0019 — see that entry for the per-item rationale; it isn't repeated here.

## Note

Same as 0019's own closing note: this is a snapshot, not permanent. Re-rank in a new numbered entry when something changes, don't edit this one in place.
