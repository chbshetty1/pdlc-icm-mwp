# 0044 — Tier 2 Pilot Instrumentation, Dry Run, and a Real Logging Bug Found Along the Way

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-09)
- **Trigger:** direct follow-up to `docs/PILOT_MEASUREMENT_PLAN.md`'s TODO list (entry 0043) — user asked whether the framework needed to run a feature manually first before the real pilot, and chose "estimate first" for the counterfactual and "build + dry-run first" for the pre-pilot instrumentation work.
- **Scope:** build the two Tier 2 measurement pieces the plan left as not-yet-built, then actually exercise the full Tier 1 + Tier 2 measurement setup against a synthetic feature before trusting any of it on the real pilot.

## What was built

1. **Persistent guardrail event logging (`scripts/sync.sh`).** The token-ceiling warning (entry 0004) and the secrets/credential block (entry 0034) always printed to stdout/stderr, but nothing persisted how often they actually fire on real content. A new `log_guardrail_event()` appends one line per event to `<workspace>/GUARDRAIL_LOG.md`, same shape as `SYNC_LOG.md` (entry 0009) — plain, append-only, non-configurable. Wired into both guardrail checks.
2. **`scripts/audit_manifest.sh` (new, 8th top-level script).** On-demand: compares a stage's self-reported `outputs/Context_Manifest.md` against its `CONTEXT.md`'s declared `READ ONLY` scope, flags anything claimed but not covered. Mechanizes the manual cross-check entry 0018 already asks a human to do — does not replace that judgment call, always exits based on whether anything was flagged (informational, nothing in this framework calls it automatically, so a non-zero exit never blocks anything real). Supports `-h`/`--help` like every other script, logs via `lib/log.sh` like every other script.
3. **Tests:** `tests/test_guardrail_log.sh` (7 assertions) and `tests/test_audit_manifest.sh` (12 assertions), following the existing scratch-copy convention.

## The dry run

Per the user's choice, before trusting any of this on the real pilot: scaffolded a synthetic feature (`FEAT-901_pilot_smoke_test`) and walked it through several real stage transitions — a normal sync with an approver, a deliberately oversized file (triggering the token-warn guardrail), a `Context_Manifest.md` with one legitimate declared read, one always-allowed read, and one deliberately undeclared read, and a deliberate secrets-block (an AWS-shaped key) that was then fixed and retried. Afterward, read back `SYNC_LOG.md`, `GUARDRAIL_LOG.md`, `.mwp/framework.log`, `scripts/audit_manifest.sh`'s report, and `scripts/status.sh`'s rollup together, as a human doing this for the real pilot would.

Findings:

- **Everything worked as designed** on the parts that were supposed to work: `GUARDRAIL_LOG.md` got exactly one `token-warn` and one `secrets-block` line, correctly attributed to the right stage; `audit_manifest.sh` correctly flagged only the one genuinely undeclared read (`../05_development_test/src/db_schema.sql`) and correctly left the declared and always-allowed reads unflagged; `status.sh` and `SYNC_LOG.md` both reflected the feature's true state after the dry run.
- **A real, previously undiscovered bug**, found only by actually reading `framework.log` next to `GUARDRAIL_LOG.md` for the same event rather than trusting either file in isolation: the secrets-block sync's `framework.log` line showed blank args (`sync.sh |  | exit=1`) instead of the actual workspace/stage/approver. Root cause: `check_secrets_guardrail()` (and, checked afterward, `scaffold.sh`'s `usage()`) are bash functions called with no arguments of their own; `$*` inside a function refers to that function's own (here, empty) positional parameters, and this shadowing persists into the `trap ... EXIT` handler that reads `$*` when the function's own `exit 1` fires. Every prior test exercised these failure paths for their exit *code*, never cross-checked the logged *args* against what was actually invoked, so this had never been caught. This is exactly the class of finding the "dry-run before trusting the real pilot's data" step existed to catch — not a plumbing bug in what this entry was building, but a real gap in something four prior entries (`0009`, `0014`, `0034`) had already shipped and tested.

## The fix

Both affected scripts now capture `SCRIPT_ARGS="$*"` at the very top, before any function is defined or the trap is set, and the trap references `$SCRIPT_ARGS` instead of `$*`. `tests/test_logging.sh` (entry 0014's home for exactly this class of trap bug) gained two new assertions reproducing the bug directly — a real invocation arg surviving an exit from inside `usage()`, and real workspace/stage args surviving an exit from inside `check_secrets_guardrail()` — so this can't silently regress.

`compact.sh`, `doctor.sh`, `pivot.sh`, `registry.sh`, and `status.sh` were checked for the same pattern (an `exit` called from inside a function invoked with no arguments) and don't have it — `pivot.sh`'s only bare `exit 1` is at top-level case-statement flow, not inside a function; the others either have no such function or their functions never call `exit`.

## Counterfactual, decided

Per the user's choice: **estimate first**. Before the real pilot's `scaffold.sh` runs, whoever runs it writes down a predicted lead time and rough context/token cost for the feature *without* the framework, in that pilot's own product repo — not attempted here, since no product data belongs in this repo. `docs/PILOT_MEASUREMENT_PLAN.md` updated to record this as decided rather than open.

## Outcome (2026-07-09)

Implemented as written. Full suite: 225 assertions across 14 suites, 0 failures (up from 203 at entry `0041` — 19 new assertions from this entry's two new suites plus `test_logging.sh`'s two additions). `docs/PILOT_MEASUREMENT_PLAN.md`'s TODO list updated: the two Tier 2 build items and the timestamp-granularity spot-check are checked off (`SYNC_LOG.md`/`GUARDRAIL_LOG.md` are minute-granularity, `framework.log` is second-granularity — sufficient for realistic pilot timescales; line order still preserves sequence for same-minute ties). `docs/CONSTRAINTS.md`'s "Generated files are never hand-edited" bullet gained `GUARDRAIL_LOG.md`. `README.md`'s scripts entry and file table updated for `audit_manifest.sh`. `docs/FAQ.md` gained an entry. `VERSION` bumped MINOR (new script is a backward-compatible addition per `docs/DEVELOPMENT.md`'s tiering; the logging fix itself is arguably PATCH alone, but the entry as a whole ships a new script to `scripts/`, which travels).
