#!/bin/bash
# tests/test_pivot.sh
# Covers scripts/pivot.sh: entry 0008's LESSONS_LEARNED.md summary row,
# entry 0012's stage-06 Learnings_Note.md fold on both --pivot and
# --persevere, and that --pivot actually archives 01/02 and purges the rest.
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

# --- --pivot path ---
bash scripts/scaffold.sh --feature FEAT-002_pivot_me >/dev/null 2>&1
FEATURE="features/FEAT-002_pivot_me"
echo "Assuming users want faster checkout." > "$FEATURE/01_discovery_ideation/outputs/Riskiest_Assumption.md"
mkdir -p "$FEATURE/06_validation_gtm/outputs"
echo "Checkout speed did not move conversion." > "$FEATURE/06_validation_gtm/outputs/Validation_Report.md"
echo "Learned that users abandon at shipping cost, not checkout speed." > "$FEATURE/06_validation_gtm/outputs/Learnings_Note.md"

bash scripts/pivot.sh FEAT-002_pivot_me --pivot >/dev/null 2>&1

assert_dir_not_exists "$SCRATCH/$FEATURE" "pivot purges the feature directory entirely"
assert_dir_exists "$SCRATCH/.archive/failed_hypotheses/FEAT-002_pivot_me/01_discovery_ideation" "pivot archives stage 01 before purging"
assert_file_exists "$SCRATCH/LESSONS_LEARNED.md" "pivot creates LESSONS_LEARNED.md (entry 0008)"
assert_file_contains "$SCRATCH/LESSONS_LEARNED.md" "faster checkout" "LESSONS_LEARNED.md row captures the riskiest assumption"
assert_file_contains "$SCRATCH/LESSONS_LEARNED.md" "did not move conversion" "LESSONS_LEARNED.md row captures why it failed"
assert_file_exists "$SCRATCH/LEARNINGS.md" "pivot also folds stage 06's Learnings_Note.md (entry 0012)"
assert_file_contains "$SCRATCH/LEARNINGS.md" "abandon at shipping cost" "the stage-06 discovery line was folded in before the purge"

# --- --persevere path: nothing purged, learnings still folded ---
bash scripts/scaffold.sh --feature FEAT-003_persevere >/dev/null 2>&1
FEATURE2="features/FEAT-003_persevere"
mkdir -p "$FEATURE2/06_validation_gtm/outputs"
echo "Onboarding flow needs a progress indicator." > "$FEATURE2/06_validation_gtm/outputs/Learnings_Note.md"
bash scripts/pivot.sh FEAT-003_persevere --persevere >/dev/null 2>&1
assert_dir_exists "$SCRATCH/$FEATURE2" "persevere leaves the feature directory intact"
assert_file_contains "$SCRATCH/LEARNINGS.md" "progress indicator" "persevere also folds stage-06 Learnings_Note.md"

# --- Unknown feature name fails cleanly ---
set +e
bash scripts/pivot.sh FEAT-999_does_not_exist --pivot >/tmp/pivot_missing_out 2>&1
MISSING_EC=$?
set -e
assert_equal "1" "$MISSING_EC" "pivot fails cleanly against a nonexistent feature"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
