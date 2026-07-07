# 0022 — Unified Backlog Re-Prioritization v3 (supersedes 0021)

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** n/a — this entry is the re-prioritization itself.
- **Supersedes:** [0021](0021-unified-backlog-reprioritization-v2.md)

## What changed, and why (not just a reshuffle — two concrete, irreversibility-driven reasons)

**1. Entry 0015 (versioning) moves from rank 16 to rank 3.**

Working out entry 0020's cross-entry collision map (see its "Known cross-entry collisions" section) surfaced something the original ranking missed: seven entries in this backlog modify files inside `.mwp-templates/` — 0003 (registry template), 0005 (`GLOBAL_CONTEXT.template.md`), 0007 (new template), 0008 (stage 01 template), 0010 (escalation template), 0012 (all six stage templates + new template), and 0018 (all six stage templates + escalation template). Under the old ranking, five of those (0018, 0003, 0005, 0008, 0010) would land *before* 0015 ever gets adopted. Since 0015's whole mechanism is a per-template version marker, adopting it late means those five changes happened with no version tracking at all — information that can't be reconstructed afterward, only assigned an arbitrary "version 1" starting point once tracking finally begins. That's a real, one-directional loss, not just a nice-to-have done sooner. Moving 0015 ahead of every template-touching entry means every subsequent template change gets a clean, accurate version bump from the start.

**2. Entries 0009 and 0016 swap (0009 now ranks just above 0016).**

0016's status script includes a "last synced" column that reads 0009's `SYNC_LOG.md`. 0016's own plan already says to degrade gracefully if `SYNC_LOG.md` doesn't exist yet — so this isn't a hard blocker — but 0009 is cheap (a small addition to `sync.sh`), and doing it first means 0016 ships complete the first time instead of needing a follow-up pass later to add the column it was always designed to have.

**What did *not* change:** the 0018/0012 and 0007/0008/0012 collisions noted in 0020 are real, but don't independently justify moving 0012 or 0007 up — both remain low-value until an actual product exists to generate cross-feature learnings or architecture decisions. The batching insight there is "if you ever do these, edit the shared files once," not "do them sooner." Reordering backlog items for editing convenience alone, without an underlying value or information-loss argument, would be optimizing the wrong thing.

## Unified ranking (1 = do first)

1. **0002** — Cross-platform script verification.
2. **0013** — Verify the tooling matrix.
3. **0015** — Framework/template versioning *(moved up from 16 — must exist before template-touching entries land)*.
4. **0018** — Scope-containment verification.
5. **0003** — Computed priority registry.
6. **0005** — Shared-schema collision check.
7. **0009** — Sync audit trail *(moved up — feeds 0016)*.
8. **0016** — Status/monitoring script *(moved down one slot — now ships complete on first build)*.
9. **0004** — Enforce token guardrails.
10. **0008** — Lessons-learned register.
11. **0010** — Archive, don't delete, escalations.
12. **0017** — Consolidated `CONSTRAINTS.md`.
13. **0020** — Framework development documentation.
14. **0011** — Generalize FAQ-capture wording.
15. **0007** — Product-level decision log.
16. **0012** — Shared-learnings file.
17. **0006** — Test `--sprint` mode.
18. **0014** — Minimal operational log.

`0001` remains unranked. Reasoning for items not called out above as moved is unchanged from 0019/0021 — not repeated here.

## Note

Same closing note as 0019 and 0021: this is a snapshot. Re-rank in a new numbered entry if something changes; don't edit this one in place.
