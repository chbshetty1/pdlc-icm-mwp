#!/bin/bash
# tests/test_guardrail_log.sh
# Covers entry 0044 (Tier 2 of docs/PILOT_MEASUREMENT_PLAN.md): sync.sh's
# token and secrets guardrails now append one line per real event to
# <workspace>/GUARDRAIL_LOG.md, same shape as SYNC_LOG.md (entry 0009).
# Confirms: no log file on a clean sync, a line appended on a token-ceiling
# warning, a line appended on a secrets block, and the log is append-only
# across multiple events.
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

cp -r "$ROOT_DIR/scripts" "$SCRATCH/scripts"
cp -r "$ROOT_DIR/.mwp-templates" "$SCRATCH/.mwp-templates"
cd "$SCRATCH" || exit 1
bash scripts/scaffold.sh --feature FEAT-001_test >/dev/null 2>&1
FEATURE="features/FEAT-001_test"
FROM_OUT="$FEATURE/01_discovery_ideation/outputs"
GUARDRAIL_LOG="$FEATURE/GUARDRAIL_LOG.md"

run_sync() {
  bash scripts/sync.sh "$FEATURE" 01_discovery_ideation 02_definition_metrics 2>&1
}

# --- Clean sync: no GUARDRAIL_LOG.md at all ---
echo "just some ordinary discovery notes" > "$FROM_OUT/Notes.md"
set +e
run_sync >/dev/null
set -e
assert_file_not_exists "$GUARDRAIL_LOG" "clean sync creates no GUARDRAIL_LOG.md (no event, nothing to log)"
rm -f "$FROM_OUT"/*
rm -rf "features/FEAT-001_test/02_definition_metrics/inputs"/*

# --- Token-ceiling warning: appends a token-warn line ---
# 01_discovery_ideation's declared ceiling is 1500 tokens (word_count*1.3);
# 1300 words comfortably clears that (1300*1.3 = 1690 > 1500).
python3 -c "print('word ' * 1300)" > "$FROM_OUT/Oversized.md" 2>/dev/null || \
  { for i in $(seq 1 1300); do printf 'word '; done > "$FROM_OUT/Oversized.md"; }
set +e
run_sync >/dev/null
set -e
assert_file_exists "$GUARDRAIL_LOG" "GUARDRAIL_LOG.md created after a token-ceiling warning"
assert_file_contains "$GUARDRAIL_LOG" "token-warn" "logged event is tagged token-warn"
assert_file_contains "$GUARDRAIL_LOG" "01_discovery_ideation" "logged event names the stage it occurred at"
rm -f "$FROM_OUT/Oversized.md"
rm -rf "features/FEAT-001_test/02_definition_metrics/inputs"/*

# --- Secrets block: appends a secrets-block line, on top of the earlier one ---
printf 'access_key = %s\n' "not-a-real-secret-1234567890" > "$FROM_OUT/Config.md"
set +e
run_sync >/dev/null
set -e
assert_file_contains "$GUARDRAIL_LOG" "secrets-block" "logged event is tagged secrets-block"
BLOCK_COUNT="$(grep -c "secrets-block" "$GUARDRAIL_LOG")"
assert_equal "1" "$BLOCK_COUNT" "exactly one secrets-block line logged for this single event"
WARN_COUNT="$(grep -c "token-warn" "$GUARDRAIL_LOG")"
assert_equal "1" "$WARN_COUNT" "earlier token-warn line still present -- log is append-only, not overwritten"
rm -f "$FROM_OUT/Config.md" "$FROM_OUT/BLOCKED_REASON.md"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
