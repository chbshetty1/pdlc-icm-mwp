# 0004 — Enforce Declared Token Guardrails Instead of Just Stating Them

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 3 of 5 — closes a real gap between stated discipline and actual behavior, but lower urgency than 0002/0003.

## Problem

Every stage `CONTEXT.md` declares a token ceiling ("Max 2500 tokens per output file"), but nothing measures or enforces it. An agent can silently blow past its own contract, and the only way anyone would notice is a output that "feels" bloated. The framework's core selling point — token discipline — is currently a convention an agent is asked to follow, not something the tooling checks.

## Proposed change

Add a lightweight check in `sync.sh` (the natural checkpoint, since it already runs every time a stage's output is approved forward) that estimates token count on files being synced and warns — or optionally blocks — if a file exceeds the ceiling declared in its stage's `CONTEXT.md`.

## Stepwise implementation plan (not yet executed)

1. Decide on a token-estimation method that doesn't require a real tokenizer dependency: a simple `word_count * 1.3` heuristic is close enough for a guardrail, not a precise budget.
2. Add a small `check_token_guardrail()` function to `sync.sh` that reads the ceiling from the `from_stage`'s `CONTEXT.md` (parse the "Max N tokens" line) and compares it against each file in `outputs/`.
3. Default behavior: warn and continue (don't block sync) — escalate to a hard block only if this proves necessary in practice.
4. Test against the sandbox feature used for 0001/0002 testing with a deliberately oversized dummy output file to confirm the warning fires correctly.
5. Document the check in `CLAUDE.md`'s automation routing section.

## What happens if adopted

Token discipline becomes something the tooling actually verifies, closing the gap between what the framework claims (up to 60% token reduction per the original design brainstorm) and what it currently measures (nothing).
