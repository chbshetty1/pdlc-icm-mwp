#!/bin/bash
# tests/test_scaffold.sh
# Covers scripts/scaffold.sh: basic --feature structure, and entry 0027's
# fix (--sprint must NOT create FEATURE_META.md, and its next-steps message
# must not mention it).
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

# --- --feature mode: full structure + FEATURE_META.md present ---
OUT="$(bash scripts/scaffold.sh --feature FEAT-001_test 2>&1)"
assert_dir_exists "$SCRATCH/features/FEAT-001_test/01_discovery_ideation/inputs" "feature: stage 01 inputs/ created"
assert_dir_exists "$SCRATCH/features/FEAT-001_test/05_development_test/src" "feature: stage 05 src/ created"
assert_dir_exists "$SCRATCH/features/FEAT-001_test/06_validation_gtm/validation_data" "feature: stage 06 validation_data/ created"
assert_dir_exists "$SCRATCH/features/FEAT-001_test/.escalations_archive" "feature: .escalations_archive/ created (entry 0010)"
assert_file_exists "$SCRATCH/features/FEAT-001_test/01_discovery_ideation/CONTEXT.md" "feature: stage 01 CONTEXT.md copied"
assert_file_contains "$SCRATCH/features/FEAT-001_test/01_discovery_ideation/CONTEXT.md" "FEAT-001_test" "feature: {{FEATURE_NAME}} substituted into CONTEXT.md"
assert_file_exists "$SCRATCH/features/FEAT-001_test/FEATURE_META.md" "feature mode: FEATURE_META.md IS created"
assert_contains "$OUT" "registry.sh" "feature mode: next-steps message mentions registry.sh"

# --- --sprint mode: same structure, but NO FEATURE_META.md (entry 0027) ---
OUT2="$(bash scripts/scaffold.sh --sprint SPRINT-01_test 2>&1)"
assert_dir_exists "$SCRATCH/sprints/SPRINT-01_test/01_discovery_ideation/inputs" "sprint: stage 01 inputs/ created"
assert_file_not_exists "$SCRATCH/sprints/SPRINT-01_test/FEATURE_META.md" "sprint mode: FEATURE_META.md NOT created (entry 0027 fix)"
assert_not_contains "$OUT2" "registry.sh" "sprint mode: next-steps message does not mention registry.sh"
assert_contains "$OUT2" "aren't C-V-R scored" "sprint mode: next-steps message explains why, not silent"

# --- refuses to clobber an existing workspace ---
set +e
bash scripts/scaffold.sh --feature FEAT-001_test >/tmp/scaffold_dupe_out 2>&1
DUPE_EC=$?
set -e
assert_equal "1" "$DUPE_EC" "scaffold refuses to overwrite an existing feature dir (exit 1)"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
