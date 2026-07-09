#!/bin/bash
# tests/test_audit_manifest.sh
# Covers entry 0044 (Tier 2 of docs/PILOT_MEASUREMENT_PLAN.md):
# scripts/audit_manifest.sh compares a stage's self-reported
# outputs/Context_Manifest.md against its CONTEXT.md's declared READ ONLY
# scope. Confirms: declared/always-allowed reads are not flagged, an
# undeclared read is flagged, a missing manifest is skipped without error,
# and -h/--help works like every other script.
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
STAGE_DIR="$FEATURE/04_architecture_design"

# --- -h/--help works like every other script ---
OUT_HELP="$(bash scripts/audit_manifest.sh -h 2>&1)"
assert_contains "$OUT_HELP" "Usage:" "-h prints usage"

# --- No Context_Manifest.md yet: skipped silently, exit 0, nothing flagged ---
set +e
OUT_EMPTY="$(bash scripts/audit_manifest.sh "$FEATURE" 04_architecture_design)"
EC_EMPTY=$?
set -e
assert_equal "0" "$EC_EMPTY" "no Context_Manifest.md yet -- exits 0, not an error"
assert_not_contains "$OUT_EMPTY" "Flagged" "nothing to flag when there's no manifest at all"

# --- Manifest with only declared/always-allowed reads: clean, exit 0 ---
{
  echo "- \`../03_requirements_specs/outputs/BDD_Gherkin_Specs.md\`"
  echo "- \`./inputs/some_file.md\`"
  echo "- \`../../../.mwp/GLOBAL_CONTEXT.md\`"
} > "$STAGE_DIR/outputs/Context_Manifest.md"
set +e
OUT_CLEAN="$(bash scripts/audit_manifest.sh "$FEATURE" 04_architecture_design)"
EC_CLEAN=$?
set -e
assert_equal "0" "$EC_CLEAN" "all-declared/always-allowed manifest exits 0"
assert_contains "$OUT_CLEAN" "Clean" "all-declared/always-allowed manifest reports clean"
assert_not_contains "$OUT_CLEAN" "Flagged" "nothing flagged when everything is in declared scope"

# --- Manifest with one undeclared read: flagged, non-zero exit ---
{
  echo "- \`../03_requirements_specs/outputs/BDD_Gherkin_Specs.md\`"
  echo "- \`../02_definition_metrics/outputs/Core_Metrics_KPIs.md\`"
} > "$STAGE_DIR/outputs/Context_Manifest.md"
set +e
OUT_FLAG="$(bash scripts/audit_manifest.sh "$FEATURE" 04_architecture_design)"
EC_FLAG=$?
set -e
assert_equal "1" "$EC_FLAG" "an undeclared read yields a non-zero (informational, not blocking) exit code"
assert_contains "$OUT_FLAG" "Flagged" "undeclared read is flagged"
assert_contains "$OUT_FLAG" "Core_Metrics_KPIs.md" "the specific undeclared file is named"
assert_not_contains "$OUT_FLAG" "  - ../03_requirements_specs/outputs/BDD_Gherkin_Specs.md" "the declared read is not itself flagged"

# --- Omitting [stage] audits every stage that has a manifest, and only those ---
set +e
OUT_ALL="$(bash scripts/audit_manifest.sh "$FEATURE")"
set -e
assert_contains "$OUT_ALL" "## 04_architecture_design" "no-stage-arg mode includes the stage that has a manifest"
assert_not_contains "$OUT_ALL" "## 01_discovery_ideation" "no-stage-arg mode skips a stage with no manifest yet"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
