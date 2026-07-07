# Model Workspace Protocol (MWP) — Automation Guide

This file is read by Claude Code at the root of any product workspace built from this framework.

## Structural constraints

This workspace operates under the Interpretable Context Methodology (ICM). Respect stage boundaries strictly:

- Never read files outside the active stage folder except the explicit `READ ONLY` references listed in that stage's `CONTEXT.md`.
- Never write outside the active stage's `outputs/` (or `src/` / `tests/` in `05_development_test/`).
- If launched at the workspace root rather than inside a specific stage folder, ask which stage you are operating in before doing anything — do not assume you may read the whole tree.

## Automated skill routing

Before invoking any tool below, check it's actually installed (`command -v <tool>`). If missing, don't attempt the run — write `BLOCKED_REASON.md` in the active stage's `outputs/` per `.mwp-templates/CRITICAL_ESCALATION.md`, putting the install command from `docs/TOOLING_MATRIX.md` under "What a human needs to decide." Fail this way, not with a bare "command not found" mid-task. A human can also run `scripts/doctor.sh` anytime to scan the whole tool stack at once, or `scripts/doctor.sh --install-missing` to install what it safely can — never automatic, always opt-in. See `docs/evolution/0013-verify-tooling-matrix.md`.

- **01_discovery_ideation / 02_definition_metrics:** pipe unstructured input (transcripts, notes) through `fabric` patterns before writing output markdown. Keep outputs to a single riskiest-assumption framing, not a full research report.
- **04_architecture_design:** before proposing structural changes, run `graphify .` and read `graphify-out/GRAPH_REPORT.md`. Use Mermaid syntax for any diagram committed to markdown.
- **05_development_test:** run `repomix` to bundle source before large contextual queries. Use `duckdb` for local data aggregation rather than ingesting raw CSV/SQL dumps.
- **06_validation_gtm:** summarize telemetry with `duckdb` before writing `Validation_Report.md`. Never paste raw logs into context.

Every stage's declared token ceiling ("Max N tokens per output file" in that stage's `CONTEXT.md`) is checked mechanically, not just stated: `sync.sh` estimates each output file's token count (`word_count × 1.3` — a guardrail heuristic, not a real tokenizer) and prints a warning if it's over. This never blocks the sync — treat the warning as a signal to trim the output before the next stage builds on it, not a hard failure. See `docs/evolution/0004-enforce-token-guardrails.md`.

## Failure handling

If a stage's validation or test step fails twice consecutively, stop. Write `BLOCKED_REASON.md` in the active stage's `outputs/` describing the failure per `.mwp-templates/CRITICAL_ESCALATION.md`, and end the session. Do not retry a third time unattended.

## FAQ capture

If a conversation in this repo produces a reusable question-and-answer about how the framework works — not specific to a single feature, commit, or one-off bug — append it to `docs/FAQ.md` using the existing Q&A format (one `##` heading per question, a direct prose answer). Do this proactively, without being asked, at the point the exchange resolves; don't wait to be told to document it. Mention what you added at the end of your response so it doesn't go unnoticed. Skip anything already covered there, or anything genuinely specific to one feature's implementation.

This applies whether you're running as Claude Code CLI or the VS Code extension — both read this file as project instructions the same way, as long as you're working inside this repo (or a product repo copied from it, which carries its own `docs/FAQ.md`).

## Direct commands

- Re-index knowledge graph: `graphify .`
- Compress code context: `repomix`
- Advance approved outputs to next stage: `./scripts/sync.sh <feature_path> <from_stage> <to_stage> [approver]`
- Compact a growing feature: `./scripts/compact.sh <feature_path>`
- Kill a failed hypothesis: `./scripts/pivot.sh <feature_name> --pivot`
- Check the tool stack: `./scripts/doctor.sh` (add `--install-missing` to install what it can)
- Check what's blocked or in-progress across all active features: `./scripts/status.sh` (on-demand only, no alerting)
- Regenerate the priority registry: `./scripts/registry.sh`
