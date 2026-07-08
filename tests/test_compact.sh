#!/bin/bash
# tests/test_compact.sh
# Covers scripts/compact.sh: requires SUMMARY_SNAPSHOT.md before archiving,
# archives everything else, keeps the snapshot in place.
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
STAGE="features/FEAT-001_test/05_development_test"

# --- Refuses without a SUMMARY_SNAPSHOT.md ---
echo "some notes" > "$STAGE/outputs/Notes.md"
set +e
bash scripts/compact.sh "features/FEAT-001_test" 05_development_test >/tmp/compact_missing_out 2>&1
MISSING_EC=$?
set -e
assert_equal "1" "$MISSING_EC" "compact refuses without a SUMMARY_SNAPSHOT.md"
assert_file_exists "$STAGE/outputs/Notes.md" "Notes.md untouched when compact refused"

# --- Archives everything except the snapshot, once one exists ---
echo "current state summary" > "$STAGE/outputs/SUMMARY_SNAPSHOT.md"
bash scripts/compact.sh "features/FEAT-001_test" 05_development_test >/dev/null 2>&1
assert_file_exists "$STAGE/outputs/SUMMARY_SNAPSHOT.md" "SUMMARY_SNAPSHOT.md stays in outputs/ after compacting"
assert_file_not_exists "$STAGE/outputs/Notes.md" "Notes.md was moved out of outputs/"
ARCHIVE_COUNT="$(find "$STAGE/.archive" -name "Notes.md" 2>/dev/null | wc -l | tr -d ' ')"
assert_equal "1" "$ARCHIVE_COUNT" "Notes.md was moved into .archive/<timestamp>/, not deleted"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
