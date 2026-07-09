#!/bin/bash
# tests/run_tests.sh
# Dependency-free test runner for scripts/*.sh -- see
# docs/evolution/0030-script-test-harness.md. No bats-core, no third-party
# tool: only bash, already this framework's hard prerequisite.
#
# Each tests/test_*.sh file runs as its own subprocess (never sourced) so a
# `cd` or an unexpected `exit` inside one test can't corrupt the next --
# every test builds its own scratch copy of scripts/ + .mwp-templates/ per
# docs/DEVELOPMENT.md's script conventions ("test in a scratch copy, never
# against the committed repo directly") and cleans up after itself.
#
# Usage:
#   ./tests/run_tests.sh          # run every tests/test_*.sh
#   ./tests/run_tests.sh <file>   # run just one test file
set -uo pipefail  # not -e: a failing suite must not abort the rest of the run

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
export ROOT_DIR TESTS_DIR

TOTAL_RUN=0
TOTAL_FAILED=0
SUITES=0
SUITES_FAILED=0

run_suite() {
  local file="$1"
  SUITES=$((SUITES + 1))
  echo "=== $(basename "$file") ==="
  local output ec
  output="$(bash "$file" 2>&1)"
  ec=$?
  echo "$output"
  local summary run failed
  summary="$(printf '%s\n' "$output" | grep -E '^SUMMARY:' | tail -1)"
  run="$(printf '%s' "$summary" | grep -oE '[0-9]+ run' | grep -oE '[0-9]+')"
  failed="$(printf '%s' "$summary" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+')"
  run="${run:-0}"
  failed="${failed:-0}"
  TOTAL_RUN=$((TOTAL_RUN + run))
  TOTAL_FAILED=$((TOTAL_FAILED + failed))
  if [ "$failed" -gt 0 ] || [ "$ec" -ne 0 ]; then
    SUITES_FAILED=$((SUITES_FAILED + 1))
    echo "  (suite exited $ec)"
  fi
  echo ""
}

if [ $# -ge 1 ]; then
  run_suite "$1"
else
  for f in "$TESTS_DIR"/test_*.sh; do
    [ -f "$f" ] || continue
    run_suite "$f"
  done
fi

echo "----------------------------------------"
echo "$TOTAL_RUN assertion(s) across $SUITES suite(s), $TOTAL_FAILED failed ($SUITES_FAILED suite(s) with failures)."
# Scope note (entry 0042): this certifies scripts/*.sh behave as coded against
# synthetic scratch data -- it is NOT evidence the framework's actual thesis
# (folder-scoped context beats the alternatives for AI-agent output quality)
# holds. That claim has no test here and stays open until a real pilot runs.
# See docs/evolution/0042-critical-theory-audit.md.
[ "$TOTAL_FAILED" -eq 0 ] && [ "$SUITES_FAILED" -eq 0 ]
