# Prioritization Guide — C-V-R Scoring

Traditional prioritization (RICE, MoSCoW) assumes large horizontal batches of work. Micro-PDLC processes isolated feature verticals, so priority should reflect how cleanly and cheaply a feature can move through an AI-augmented pipeline, not just business value.

## The formula

```
Priority Score = (Context Cleanliness × Value Velocity) / Refactoring Risk
```

Score each 1–5:

**Context Cleanliness (C)** — how ready are the inputs for Claude?
- 5: inputs are already structured markdown, APIs documented, success criteria binary.
- 1: ambiguous requirements, heavy human discovery needed first.

**Value Velocity (V)** — how fast can this clear folders 01→06?
- 5: fully decoupled (independent microservice, isolated UI component, standalone utility).
- 1: sprawling, many cross-team dependencies, many migrations.

**Refactoring Risk (R)** — if Claude gets the architecture wrong, how expensive is the fix?
- 5: touches core schemas, auth, or global state.
- 1: pure additive, zero side effects on existing code.

## Critical exception: Core Data Anchors bypass the formula

Foundational work (database schemas, auth, shared types) always carries R=5 by nature, which would mathematically bury it at the bottom of the queue — exactly backwards. Core Data Anchors are Phase 0: they are never scored, they always run first, and nothing else starts until they're stable.

## Execution rules once scored

1. **Core Data Anchor first** (unconditional, unscored) — see `FEATURE_PRIORITY_REGISTRY.md`.
2. **High C-V-R features run in parallel** — separate terminal/agent sessions across separate `features/FEAT-xxx/` folders, no cross-contamination because Micro-PDLC isolates each folder.
3. **R ≥ 4 features run sequentially with mandatory human gates** between every stage — never in parallel with each other or with anything touching the same shared subsystem (see Shared Architecture Sync in `CLAUDE_WORKFLOW_PLAYBOOK.md`).

## Worked example

| Feature | C | V | R | Score | Queue |
|---|---|---|---|---|---|
| Core DB & Auth Anchors | – | – | – | – | Phase 0 (unscored) |
| Magic Link Login | 5 | 4 | 2 | 10.0 | Active, high priority |
| PDF Invoice Export | 4 | 5 | 2 | 10.0 | Active, high priority |
| Multi-Tenant Data Isolation | 2 | 2 | 5 | 0.8 | Deep Context Backlog, blocked until anchors stable |
