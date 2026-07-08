# 0026 — Unified Backlog Re-Prioritization v5 (supersedes 0024)

- **Date:** 2026-07-08
- **Status:** proposed
- **Supersedes:** [0024](0024-unified-backlog-reprioritization-v4.md)

## What changed

Entry 0025 slots in at rank 12 — right after the last currently-adopted entry (0008) and ahead of 0010. Reasoning:

- **Foundational, not incidental:** it's about whether the actual instructions in every stage `CONTEXT.md`, for every stage, of every feature, in every product ever scaffolded from this framework, point at the right file. That's a wider blast radius than most remaining entries, even though the day-to-day symptom (an agent silently self-correcting a wrong relative path) has been mild so far.
- **Cheap once confirmed:** the fix itself is a small, mechanical edit across 6 files plus version bumps — most of the work is the confirmation step (0025's own step 1), not the edit.
- **No dependencies either direction:** nothing else in the backlog depends on this being fixed first, and this doesn't depend on anything else landing first (unlike, say, 0018's earlier dependency on 0017 for its disclosure's permanent home).

This pushes 0010 and everything below it down by one slot. No other reordering — the reasoning for 0010 through 0014's relative order is unchanged from 0022/0024.

## Unified ranking (1 = do first; adopted entries shown for continuity)

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
12. **0025** — Relative-path depth audit *(new)*.
13. **0010** — Archive, don't delete, escalations.
14. **0017** — Consolidated `CONSTRAINTS.md`.
15. **0020** — Framework development documentation.
16. **0011** — Generalize FAQ-capture wording.
17. **0007** — Product-level decision log.
18. **0012** — Shared-learnings file.
19. **0006** — Test `--sprint` mode.
20. **0014** — Minimal operational log.

`0001` remains unranked (standing reference, not queued). Reasoning for 0010 through 0014's relative order is unchanged from 0022/0024 — only 0025's insertion is new here.
