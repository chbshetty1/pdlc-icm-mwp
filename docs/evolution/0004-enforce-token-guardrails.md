# 0004 — Enforce Declared Token Guardrails Instead of Just Stating Them

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** 3 of 5 — closes a real gap between stated discipline and actual behavior, but lower urgency than 0002/0003.
- **Status:** adopted (2026-07-07)

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

## Outcome (2026-07-07)

All 5 steps implemented as written:

1. Heuristic confirmed: `word_count × 1.3`, computed via `wc -w` and `awk`, no tokenizer dependency.
2. `check_token_guardrail()` added to `sync.sh`: reads `$WORKSPACE/$FROM/CONTEXT.md`, extracts the first `Max N tokens` match via `grep -oE`, and checks every file in `$FROM_OUT` except `BLOCKED_REASON.md` against it.
3. Warn-only confirmed — the function never exits non-zero; it only prints to stderr. The sync proceeds regardless.
4. Tested in a sandbox: a small in-bounds file produced no warning; a deliberately oversized file (~2600 estimated tokens against a 1500 ceiling) produced the warning and the sync still completed and copied the file forward.
5. Documented in `CLAUDE.md`'s "Automated skill routing" section.

**One simplification worth recording**, found while reading the actual stage `CONTEXT.md` wording during implementation: the guardrail phrasing isn't uniform across stages — stage 03 says "Max 2500 tokens *total output for this stage*" (a per-stage budget) and stage 06 says "Max 1500 tokens *for `Validation_Report.md`*" (scoped to one named file), while 01/02/04 say "Max N tokens *per output file*" (a per-file ceiling). The mechanical check doesn't distinguish these — it applies whatever number it finds to every file in that stage's `outputs/` individually, which is stricter than stage 03's wording (a per-stage total) and looser than stage 06's (only one file is actually meant to be checked, but the check applies the number to every file in that stage). This is an acceptable heuristic tradeoff per the entry's own framing ("close enough for a guardrail, not a precise budget"), but worth knowing if the warnings ever look surprising. Also confirmed: stage 05 has no numeric ceiling at all in its `CONTEXT.md` (a `repomix`-bundling threshold instead) — the check correctly finds nothing to compare against and stays silent, even against a deliberately huge test file.

Per the versioning workflow from entry `0015`: no `.mwp-templates/` file touched (the ceiling wording itself wasn't changed), so no `template-version` bump applies — root `VERSION` bumped from `7` to `8` since `scripts/sync.sh` and `CLAUDE.md` both ship to products.
