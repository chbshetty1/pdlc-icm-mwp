#!/bin/bash
# tests/test_help.sh
# Covers entry 0036: every script must respond to an explicit -h/--help
# request with exit 0 and a "Usage:" line, without disturbing any existing
# bad-usage (missing/malformed args) exit-1 path.
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

for s in scaffold sync pivot compact doctor registry status; do
  OUT="$(bash "scripts/$s.sh" -h 2>&1)"
  EC=$?
  assert_equal "0" "$EC" "$s.sh -h exits 0"
  assert_contains "$OUT" "Usage:" "$s.sh -h prints a Usage: line"

  OUT2="$(bash "scripts/$s.sh" --help 2>&1)"
  EC2=$?
  assert_equal "0" "$EC2" "$s.sh --help exits 0"
done

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
