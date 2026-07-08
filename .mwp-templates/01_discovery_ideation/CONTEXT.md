# STAGE CONTRACT: 01_discovery_ideation ({{FEATURE_NAME}})

## 1. Objective

Synthesize raw, unstructured input (interviews, notes, market data) into a single riskiest-assumption framing. This is a Lean gate, not a research report.

## 2. Input scope

- READ ONLY: local files in `./inputs/`
- READ ONLY: `../../../.mwp/GLOBAL_CONTEXT.md`
- READ ONLY (if present): `../../../LESSONS_LEARNED.md` — the product's running register of already-disproven hypotheses from pivoted features.
- READ ONLY (optional, if present): `../../../LEARNINGS.md` — incidental discoveries from other features (rate limits, library quirks) worth knowing before starting discovery.

## 3. Execution rules

- Before forming the riskiest assumption, check `../../../LESSONS_LEARNED.md` if it exists — don't propose (or re-propose) an assumption that register shows was already tested and invalidated.
- Identify the **one** fundamental assumption that must be true for this feature to succeed. Discard anything that doesn't validate or invalidate it.
- If `inputs/` contains raw transcripts or long text, pipe through `fabric` first; do not paste raw text into the model.
- No conversational filler. No multi-page persona documents.

## 4. Expected deliverables

- `./outputs/Riskiest_Assumption.md` — the assumption, why it's risky, and what evidence would confirm/deny it.
- `./outputs/Problem_Statement.md` — 3-5 sentences max.
- `./outputs/Context_Manifest.md` — every file this stage actually read (paths only), self-reported, for human cross-check against this contract's declared READ ONLY scope (see `CRITICAL_ESCALATION.md`).
- If you discover something outside this feature's own scope that a future feature would benefit from knowing, add a one-line note to `./outputs/Learnings_Note.md` (plain text, one discovery per line) — `sync.sh` folds it into the product's `LEARNINGS.md` automatically when this stage's outputs sync forward. Never write to `LEARNINGS.md` directly from this stage.

## 5. Token guardrails

- Max 1500 tokens per output file.
- If input exceeds ~10k tokens, chunk and summarize via `fabric` before this stage runs.

## 6. On failure

If two consecutive attempts fail to produce a falsifiable assumption, write `./outputs/BLOCKED_REASON.md` per `../../../.mwp-templates/CRITICAL_ESCALATION.md` and stop.

<!-- template-version: 5 -->
