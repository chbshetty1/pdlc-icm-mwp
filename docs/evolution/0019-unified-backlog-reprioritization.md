# 0019 — Unified Backlog Re-Prioritization

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** n/a — this entry is the re-prioritization itself.

## Problem

Entries 0002–0018 accumulated across four separate brainstorming passes, each ranked only *within its own batch* ("1 of 5," "1 of 6," or an unscaled adjective like "high"/"moderate"). There was no single ordering across all of them — someone wanting to know "what's the single most valuable thing to do next" had to reconcile four incompatible scales by hand.

## Criteria used

Consistent with how `docs/FAQ.md` already describes evolution-entry prioritization (informal expected-value-of-fixing, not the product-facing C-V-R formula): each entry was weighed on how foundational/blocking the gap is, how likely it is to actually bite given the framework hasn't been pilot-tested yet, and how cheap the fix or verification is — foundational-and-cheap ranks above valuable-but-only-matters-later.

`0001` is deliberately left unranked — it's a standing reference analysis with its own trigger conditions, not a queued task competing for the same attention.

## Unified ranking (1 = do first)

1. **0002** — Cross-platform script verification. Cheapest possible check, and blocks meaningfully testing almost everything else on this list for real.
2. **0013** — Verify the tooling matrix. Same class of gap as 0002 (assumed-but-unverified infrastructure), and several `CLAUDE.md` instructions silently depend on it.
3. **0018** — Scope-containment verification. The most foundational *design* gap in the backlog — the manifest requirement can be adopted immediately; full verification of it benefits from 0002/0013 being done first so there's something real to pilot it against.
4. **0003** — Computed priority registry. Fixes a self-inflicted shared-mutable-state problem; matters as soon as two features exist side by side.
5. **0005** — Shared-schema collision check. Same category as 0003, same trigger condition (parallel features touching shared state).
6. **0016** — Status/monitoring script. Shares scan logic with 0003; worth building near it rather than much later.
7. **0004** — Enforce token guardrails. Real but lower-blast-radius than 0003/0005 — a cost overrun, not a coordination failure.
8. **0009** — Sync audit trail. Cheap, good traceability, no blocking urgency.
9. **0008** — Lessons-learned register. Real value, but only bites after the first pivot actually happens.
10. **0010** — Archive, don't delete, escalations. Trivial one-line policy fix, essentially free.
11. **0017** — Consolidated `CONSTRAINTS.md`. Cheap, zero functional risk either way — a quick win whenever there's spare time, not urgent.
12. **0011** — Generalize FAQ-capture wording. Trivial, cheap, low stakes.
13. **0007** — Product-level decision log. Good practice, but zero urgency while no product has been built from this framework yet.
14. **0012** — Shared-learnings file. Nice-to-have, avoids duplicated discovery, low urgency.
15. **0015** — Framework/template versioning. Only matters once multiple products or template revisions exist — neither does yet.
16. **0006** — Test `--sprint` mode. Test coverage on a mode nobody's used — Micro-PDLC is the recommended default.
17. **0014** — Minimal operational log. Nice-to-have; there's no real usage yet generating anything worth logging.

## How this is reflected in the log

`EVOLUTION_LOG.md`'s table gets a new "Overall Rank" column pointing here, rather than rewriting each entry's own historical "Priority: N of 5"-style line — those stay as the accurate record of what was ranked against what at the time they were written, per the log's own append-only convention.

## Note

This ranking is a snapshot, not permanent. If 0002 or 0013 surface something unexpected once actually run, or a real pilot feature changes what's urgent, re-rank in a new numbered entry rather than editing this one.
