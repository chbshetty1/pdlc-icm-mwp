#!/bin/bash
# tests/test_doctor.sh
# Smoke test for scripts/doctor.sh -- can't assert on which tools are
# actually installed (that's this machine's state, not the script's
# behavior), so this only pins down the reporting contract: it must always
# run to completion, log its own invocation, and exit non-zero exactly when
# something is missing and zero when nothing is.
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

cp -r "$ROOT_DIR/scripts" "$SCRATCH/scripts"
cd "$SCRATCH" || exit 1

set +e
OUT="$(bash scripts/doctor.sh 2>&1)"
EC=$?
set -e

assert_contains "$OUT" "Tooling check" "doctor.sh prints its header regardless of tool state"
assert_file_exists ".mwp/framework.log" "doctor.sh logs its own invocation even in report-only mode"
if [[ "$OUT" == *"All CLI tools installed"* ]]; then
  assert_equal "0" "$EC" "exit 0 when doctor.sh reports everything installed"
else
  assert_contains "$OUT" "tool(s) missing" "reports a missing-tool count when something isn't found"
  assert_equal "1" "$EC" "exit 1 when something is missing, matching the printed count"
fi

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
