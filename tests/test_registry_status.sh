#!/bin/bash
# tests/test_registry_status.sh
# Covers scripts/registry.sh (entry 0003: Core Anchor / Active Queue / Deep
# Backlog / Not-yet-scored sorting) and scripts/status.sh (entry 0016:
# per-workspace + stage rollup), plus confirms registry.sh genuinely never
# reads a sprint's files even if one happens to exist (entry 0027's
# resolution assumes this, so it's worth pinning down directly).
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

# Core anchor feature
bash scripts/scaffold.sh --feature FEAT-001_anchor >/dev/null 2>&1
sed -i 's/^is_core_anchor: false/is_core_anchor: true/' features/FEAT-001_anchor/FEATURE_META.md
sed -i 's/^name:/name: Core schema/' features/FEAT-001_anchor/FEATURE_META.md

# Scored, low-risk feature (R < 4 -> Active Queue)
bash scripts/scaffold.sh --feature FEAT-002_scored >/dev/null 2>&1
sed -i 's/^name:/name: Scored feature/' features/FEAT-002_scored/FEATURE_META.md
sed -i 's/^c:/c: 4/' features/FEAT-002_scored/FEATURE_META.md
sed -i 's/^v:/v: 3/' features/FEAT-002_scored/FEATURE_META.md
sed -i 's/^r:/r: 2/' features/FEAT-002_scored/FEATURE_META.md

# Scored, high-risk feature (R >= 4 -> Deep Backlog)
bash scripts/scaffold.sh --feature FEAT-003_deep >/dev/null 2>&1
sed -i 's/^name:/name: Deep backlog feature/' features/FEAT-003_deep/FEATURE_META.md
sed -i 's/^c:/c: 2/' features/FEAT-003_deep/FEATURE_META.md
sed -i 's/^v:/v: 2/' features/FEAT-003_deep/FEATURE_META.md
sed -i 's/^r:/r: 5/' features/FEAT-003_deep/FEATURE_META.md

# Unscored feature
bash scripts/scaffold.sh --feature FEAT-004_unscored >/dev/null 2>&1

# A sprint whose FEATURE_META.md would exist only on a pre-0027 framework --
# simulate that stale state to confirm registry.sh really never reads it.
bash scripts/scaffold.sh --sprint SPRINT-01_test >/dev/null 2>&1
mkdir -p sprints/SPRINT-01_test
cat > sprints/SPRINT-01_test/FEATURE_META.md <<'EOF'
feature_id: SPRINT-01_test
name: Should never appear in the registry
c: 5
v: 5
r: 1
status: not started
is_core_anchor: false
EOF

OUT="$(bash scripts/registry.sh 2>&1)"
assert_file_exists ".mwp/FEATURE_PRIORITY_REGISTRY.md" "registry.sh generates FEATURE_PRIORITY_REGISTRY.md"
REG="$(cat .mwp/FEATURE_PRIORITY_REGISTRY.md)"
assert_contains "$REG" "Core schema" "core anchor feature listed under Phase 0"
assert_contains "$REG" "Scored feature" "scored low-risk feature listed"
assert_contains "$REG" "Deep backlog feature" "high-risk (R>=4) feature routed to Deep Backlog"
assert_contains "$REG" "FEAT-004_unscored" "unscored feature listed under Not yet scored"
assert_not_contains "$REG" "Should never appear in the registry" "sprint's FEATURE_META.md is never read (entry 0027's assumption holds)"
assert_contains "$OUT" "4 feature(s)" "registry.sh reports scanning exactly the 4 features, not the sprint"

# --- status.sh: per-workspace + stage rollup ---
OUT_STATUS="$(bash scripts/status.sh 2>&1)"
assert_contains "$OUT_STATUS" "FEAT-001_anchor" "status.sh lists FEAT-001_anchor"
assert_contains "$OUT_STATUS" "SPRINT-01_test" "status.sh lists the sprint too (unlike registry.sh, it scans sprints/)"
assert_contains "$OUT_STATUS" "not started" "status.sh reports 'not started' for features with no stage outputs yet"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
