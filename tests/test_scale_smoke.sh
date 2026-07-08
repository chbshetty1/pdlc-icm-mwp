#!/bin/bash
# tests/test_scale_smoke.sh
# Covers entry 0037: registry.sh and status.sh have only ever been exercised
# against 2-4 synthetic features in the other suites -- nothing has checked
# either script against something closer to a real product's scale, where
# bash-array bugs, sort-stability issues, or an R=0 divide-by-zero edge case
# would actually show up. Generates 60 synthetic features (with a deliberate
# mix of anchor/scored/unscored/R=0 cases) and 8 sprints, then asserts both
# scripts still produce correct, correctly-bucketed, correctly-sorted output
# -- and finish in reasonable time, as a smoke test rather than a strict
# timed benchmark (this sandbox's performance isn't a stable baseline to
# assert a tight threshold against).
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

cp -r "$ROOT_DIR/scripts" "$SCRATCH/scripts"
mkdir -p "$SCRATCH/features" "$SCRATCH/sprints" "$SCRATCH/.mwp"
cd "$SCRATCH" || exit 1

STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)
N=60
EXPECTED_ANCHOR=0
EXPECTED_UNSCORED=0
EXPECTED_ACTIVE=0
EXPECTED_DEEP=0
MAX_ACTIVE_SCORE="-1"
MAX_ACTIVE_ID=""
MAX_DEEP_SCORE="-1"
MAX_DEEP_ID=""

for i in $(seq 1 "$N"); do
  FID="FEAT-$(printf '%03d' "$i")"
  FNAME="${FID}_synthetic"
  FDIR="features/$FNAME"
  mkdir -p "$FDIR"

  stage_idx=$(( i % 6 ))
  stage="${STAGES[$stage_idx]}"
  mkdir -p "$FDIR/$stage/outputs"
  echo "dummy" > "$FDIR/$stage/outputs/Placeholder.md"
  if [ $(( i % 11 )) -eq 0 ]; then
    echo "blocked" > "$FDIR/$stage/outputs/BLOCKED_REASON.md"
  fi

  if [ "$i" -eq 1 ]; then
    EXPECTED_ANCHOR=$((EXPECTED_ANCHOR + 1))
    cat > "$FDIR/FEATURE_META.md" <<EOF
feature_id: $FID
name: synthetic-$i
c:
v:
r:
status: not started
is_core_anchor: true
EOF
  elif [ $(( i % 7 )) -eq 0 ]; then
    EXPECTED_UNSCORED=$((EXPECTED_UNSCORED + 1))
    cat > "$FDIR/FEATURE_META.md" <<EOF
feature_id: $FID
name: synthetic-$i
c:
v:
r:
status: not started
is_core_anchor: false
EOF
  else
    C=$(( (i * 3) % 5 + 1 ))
    V=$(( (i * 2) % 4 + 1 ))
    R=$(( i % 6 ))
    SCORE=$(awk -v c="$C" -v v="$V" -v r="$R" 'BEGIN { if (r+0 == 0) print "0"; else printf "%.1f", (c*v)/r }')
    cat > "$FDIR/FEATURE_META.md" <<EOF
feature_id: $FID
name: synthetic-$i
c: $C
v: $V
r: $R
status: not started
is_core_anchor: false
EOF
    if [ "$R" -ge 4 ]; then
      EXPECTED_DEEP=$((EXPECTED_DEEP + 1))
      if awk -v a="$SCORE" -v b="$MAX_DEEP_SCORE" 'BEGIN{exit !(a>b)}'; then
        MAX_DEEP_SCORE="$SCORE"; MAX_DEEP_ID="$FID"
      fi
    else
      EXPECTED_ACTIVE=$((EXPECTED_ACTIVE + 1))
      if awk -v a="$SCORE" -v b="$MAX_ACTIVE_SCORE" 'BEGIN{exit !(a>b)}'; then
        MAX_ACTIVE_SCORE="$SCORE"; MAX_ACTIVE_ID="$FID"
      fi
    fi
  fi
done

for j in $(seq 1 8); do
  SID="SPRINT-$(printf '%02d' "$j")"
  SDIR="sprints/${SID}_synthetic"
  mkdir -p "$SDIR"
  stage_idx=$(( j % 6 ))
  stage="${STAGES[$stage_idx]}"
  mkdir -p "$SDIR/$stage/outputs"
  echo "dummy" > "$SDIR/$stage/outputs/Placeholder.md"
done

# --- Run registry.sh, time it, check correctness ---
START=$(date +%s)
REG_OUT="$(bash scripts/registry.sh 2>&1)"
REG_EC=$?
END=$(date +%s)
REG_ELAPSED=$((END - START))

assert_equal "0" "$REG_EC" "registry.sh exits 0 against $N features"
assert_contains "$REG_OUT" "from $N feature(s)" "registry.sh reports scanning exactly $N features"

REG_FILE=".mwp/FEATURE_PRIORITY_REGISTRY.md"
assert_file_exists "$REG_FILE" "FEATURE_PRIORITY_REGISTRY.md was generated"

TOTAL_ROWS="$(grep -cE '^\| FEAT-' "$REG_FILE")"
assert_equal "$N" "$TOTAL_ROWS" "registry has exactly $N feature rows total across all sections"

if [ "$REG_ELAPSED" -lt 30 ]; then R=0; else R=1; fi
assert_equal "0" "$R" "registry.sh finished in under 30s against $N features (took ${REG_ELAPSED}s) -- smoke check, not a strict benchmark"

# --- Sort-order spot check: the highest-scored active feature must be the
# first data row under the Active execution queue heading, and likewise for
# Deep backlog. ---
# Ties are possible in synthetic data (and in real C-V-R scoring -- nothing
# in the framework defines a tiebreak rule), so this checks the *score* at
# row 1 matches the computed maximum rather than assuming a specific ID wins
# a tie -- a meaningful sort-correctness check either way.
ACTIVE_FIRST_SCORE="$(awk '/^## Active execution queue/,/^## Deep context backlog/' "$REG_FILE" | grep -E '^\| FEAT-' | head -1 | awk -F'|' '{print $7}' | tr -d ' ')"
assert_equal "$MAX_ACTIVE_SCORE" "$ACTIVE_FIRST_SCORE" "Active queue's first row has the max computed score ($MAX_ACTIVE_SCORE)"

DEEP_FIRST_SCORE="$(awk '/^## Deep context backlog/,0' "$REG_FILE" | grep -E '^\| FEAT-' | head -1 | awk -F'|' '{print $7}' | tr -d ' ')"
assert_equal "$MAX_DEEP_SCORE" "$DEEP_FIRST_SCORE" "Deep backlog's first row has the max computed score ($MAX_DEEP_SCORE)"

# --- Bucket counts: cross-check the generation-time expectation against
# what actually landed in each section. ---
ANCHOR_ROWS_ACTUAL="$(awk '/^## Phase 0/,/^## Active execution queue/' "$REG_FILE" | grep -cE '^\| FEAT-')"
assert_equal "$EXPECTED_ANCHOR" "$ANCHOR_ROWS_ACTUAL" "Phase 0 anchor row count matches ($EXPECTED_ANCHOR)"

ACTIVE_ROWS_ACTUAL="$(awk '/^## Active execution queue/,/^## Deep context backlog/' "$REG_FILE" | grep -cE '^\| FEAT-')"
assert_equal "$EXPECTED_ACTIVE" "$ACTIVE_ROWS_ACTUAL" "Active queue row count matches ($EXPECTED_ACTIVE)"

DEEP_ROWS_ACTUAL="$(awk '/^## Deep context backlog/,/^## Not yet scored|^## Rules/' "$REG_FILE" | grep -cE '^\| FEAT-')"
assert_equal "$EXPECTED_DEEP" "$DEEP_ROWS_ACTUAL" "Deep backlog row count matches ($EXPECTED_DEEP)"

UNSCORED_ROWS_ACTUAL="$(awk '/^## Not yet scored/,0' "$REG_FILE" | grep -cE '^\| FEAT-')"
assert_equal "$EXPECTED_UNSCORED" "$UNSCORED_ROWS_ACTUAL" "Not-yet-scored row count matches ($EXPECTED_UNSCORED)"

# --- Run status.sh, time it, check correctness ---
START=$(date +%s)
STATUS_OUT="$(bash scripts/status.sh 2>&1)"
STATUS_EC=$?
END=$(date +%s)
STATUS_ELAPSED=$((END - START))

assert_equal "0" "$STATUS_EC" "status.sh exits 0 against $N features + 8 sprints"

if [ "$STATUS_ELAPSED" -lt 30 ]; then R=0; else R=1; fi
assert_equal "0" "$R" "status.sh finished in under 30s (took ${STATUS_ELAPSED}s) -- smoke check, not a strict benchmark"

FEATURE_ROWS_IN_STATUS="$(printf '%s\n' "$STATUS_OUT" | grep -cE '^FEAT-')"
assert_equal "$N" "$FEATURE_ROWS_IN_STATUS" "status.sh lists all $N features individually"

SPRINT_ROWS_IN_STATUS="$(printf '%s\n' "$STATUS_OUT" | grep -cE '^SPRINT-')"
assert_equal "8" "$SPRINT_ROWS_IN_STATUS" "status.sh lists all 8 sprints too (unlike registry.sh)"

# Rollup cross-check: for each stage, the count status.sh's "Active" column
# reports must equal how many of our 60 features we placed at that stage.
for idx in "${!STAGES[@]}"; do
  stage="${STAGES[$idx]}"
  EXPECTED_AT_STAGE=0
  for i in $(seq 1 "$N"); do
    [ $(( i % 6 )) -eq "$idx" ] && EXPECTED_AT_STAGE=$((EXPECTED_AT_STAGE + 1))
  done
  ACTUAL_LINE="$(printf '%s\n' "$STATUS_OUT" | grep -E "^${stage}[[:space:]]")"
  ACTUAL_AT_STAGE="$(printf '%s' "$ACTUAL_LINE" | awk '{print $2}' | head -1)"
  assert_equal "$EXPECTED_AT_STAGE" "$ACTUAL_AT_STAGE" "status.sh rollup: $stage shows $EXPECTED_AT_STAGE active feature(s)"
done

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
