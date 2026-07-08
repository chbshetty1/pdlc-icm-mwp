#!/bin/bash
# tests/test_sync.sh
# Covers scripts/sync.sh: basic advance, entry 0009's audit log, entry
# 0004's non-blocking token-guardrail warning, entry 0012's Learnings_Note.md
# folding, and entry 0005's shared-path collision block.
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

# --- Basic advance + entry 0009 audit trail ---
echo "some discovery output" > "$FEATURE/01_discovery_ideation/outputs/Notes.md"
OUT="$(bash scripts/sync.sh "$FEATURE" 01_discovery_ideation 02_definition_metrics "J. Tester" 2>&1)"
assert_file_exists "$FEATURE/02_definition_metrics/inputs/Notes.md" "sync copies outputs/ into next stage's inputs/"
assert_file_exists "$FEATURE/SYNC_LOG.md" "sync writes SYNC_LOG.md (entry 0009)"
assert_file_contains "$FEATURE/SYNC_LOG.md" "J. Tester" "SYNC_LOG.md records the approver"

# --- Refuses to sync when a BLOCKED_REASON.md is present ---
mkdir -p "$FEATURE/02_definition_metrics/outputs"
echo "# blocked" > "$FEATURE/02_definition_metrics/outputs/BLOCKED_REASON.md"
set +e
bash scripts/sync.sh "$FEATURE" 02_definition_metrics 03_requirements_specs >/tmp/sync_blocked_out 2>&1
BLOCKED_EC=$?
set -e
assert_equal "1" "$BLOCKED_EC" "sync refuses to advance past an unresolved BLOCKED_REASON.md"
rm -f "$FEATURE/02_definition_metrics/outputs/BLOCKED_REASON.md"

# --- Entry 0004: token guardrail warns but does not block ---
# 02_definition_metrics/CONTEXT.md declares "Max 1000 tokens per output file."
python3 -c "print('word ' * 900)" > "$FEATURE/02_definition_metrics/outputs/Oversized.md" 2>/dev/null \
  || { for i in $(seq 1 900); do printf 'word '; done > "$FEATURE/02_definition_metrics/outputs/Oversized.md"; }
OUT_GUARD="$(bash scripts/sync.sh "$FEATURE" 02_definition_metrics 03_requirements_specs 2>&1)"
GUARD_EC=$?
assert_equal "0" "$GUARD_EC" "sync still succeeds despite an over-ceiling file (warns, never blocks -- entry 0004)"
assert_contains "$OUT_GUARD" "over" "sync prints a token-guardrail warning for the oversized file"
assert_file_exists "$FEATURE/03_requirements_specs/inputs/Oversized.md" "the oversized file is still copied through"

# --- Entry 0012: Learnings_Note.md folds into LEARNINGS.md ---
{
  echo "# comment lines are skipped"
  echo ""
  echo "Discovered that widget X needs a fallback for empty state."
} > "$FEATURE/03_requirements_specs/outputs/Learnings_Note.md"
bash scripts/sync.sh "$FEATURE" 03_requirements_specs 04_architecture_design >/dev/null 2>&1
assert_file_exists "$SCRATCH/LEARNINGS.md" "LEARNINGS.md auto-created on first Learnings_Note.md fold"
assert_file_contains "$SCRATCH/LEARNINGS.md" "widget X needs a fallback" "the real discovery line was folded in"
assert_file_not_contains "$SCRATCH/LEARNINGS.md" "comment lines are skipped" "comment lines were NOT folded in"

# --- Entry 0005: shared-path collision blocks 04->05 and writes BLOCKED_REASON.md ---
mkdir -p "$SCRATCH/.mwp"
cp "$SCRATCH/.mwp-templates/GLOBAL_CONTEXT.template.md" "$SCRATCH/.mwp/GLOBAL_CONTEXT.md"
mkdir -p "$FEATURE/04_architecture_design/outputs"
echo "touches shared_schemas/ directly" > "$FEATURE/04_architecture_design/outputs/Design.md"
set +e
bash scripts/sync.sh "$FEATURE" 04_architecture_design 05_development_test >/tmp/sync_collision_out 2>&1
COLLISION_EC=$?
set -e
assert_equal "1" "$COLLISION_EC" "sync blocks on a declared shared_path collision (entry 0005)"
assert_file_exists "$FEATURE/04_architecture_design/outputs/BLOCKED_REASON.md" "BLOCKED_REASON.md auto-written on collision"
assert_file_contains "$FEATURE/04_architecture_design/outputs/BLOCKED_REASON.md" "shared_schemas/" "BLOCKED_REASON.md names the colliding shared path"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
