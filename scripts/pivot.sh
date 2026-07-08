#!/bin/bash
# Lean Pivot/Persevere control for a Micro-PDLC feature.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$*" "$LOG_EXIT_CODE"' EXIT

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $0 <FEATURE_NAME> --pivot|--persevere"
  echo "Lean Pivot/Persevere control for a Micro-PDLC feature."
  exit 0
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <FEATURE_NAME> --pivot|--persevere"
  exit 1
fi

FEATURE_NAME=$1
ACTION=$2
FEATURE_DIR="$ROOT_DIR/features/$FEATURE_NAME"

if [ ! -d "$FEATURE_DIR" ]; then
  echo "Error: $FEATURE_DIR not found." >&2
  exit 1
fi

# --- Lessons-learned summary extraction (entry 0008) ---
# First non-empty, non-heading line of $1, single-line-safe for a markdown
# table cell (pipes escaped, truncated). Prints $2 if the file is missing
# or has nothing usable -- never fails the pivot over a missing source file.
extract_summary() {
  local file="$1" placeholder="$2"
  if [ ! -f "$file" ]; then
    echo "$placeholder"
    return
  fi
  local line
  line="$(grep -v -E '^[[:space:]]*#' "$file" 2>/dev/null | grep -v -E '^[[:space:]]*$' | head -1)"
  [ -z "$line" ] && line="$placeholder"
  line="${line//|/\\|}"
  if [ "${#line}" -gt 150 ]; then
    line="${line:0:147}..."
  fi
  echo "$line"
}

# --- Learnings capture for stage 06 (entry 0012) ---
# sync.sh folds Learnings_Note.md into LEARNINGS.md at every 01->06
# transition, but stage 06 is terminal -- nothing ever syncs it forward.
# pivot.sh is the script actually invoked at the end of stage 06 either way
# (--persevere or --pivot), so it's the right place to close that gap.
# Same logic as sync.sh's block; duplicated rather than factored into a
# shared lib for a block this small (see docs/DEVELOPMENT.md's script
# conventions on scratch-testing, not premature abstraction).
fold_learnings_note() {
  local note="$FEATURE_DIR/06_validation_gtm/outputs/Learnings_Note.md"
  [ -f "$note" ] || return 0
  local learnings_file="$ROOT_DIR/LEARNINGS.md"
  if [ ! -f "$learnings_file" ]; then
    if [ -f "$ROOT_DIR/.mwp-templates/LEARNINGS.template.md" ]; then
      cp "$ROOT_DIR/.mwp-templates/LEARNINGS.template.md" "$learnings_file"
    else
      cat > "$learnings_file" <<'EOF'
# Learnings

Append-only register of incidental discoveries. Populated automatically by
scripts/sync.sh (and scripts/pivot.sh for stage 06) from each stage's
Learnings_Note.md; never hand-edit a past row.

| Date | Feature | Discovery |
|---|---|---|
EOF
    fi
  fi
  local added=0 line
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*#.*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    line="${line//|/\\|}"
    if [ "${#line}" -gt 150 ]; then
      line="${line:0:147}..."
    fi
    echo "| $(date '+%Y-%m-%d') | $FEATURE_NAME | $line |" >> "$learnings_file"
    added=$((added + 1))
  done < "$note"
  [ "$added" -gt 0 ] && echo "Folded $added discovery line(s) from $note into $learnings_file."
}

case "$ACTION" in
  --pivot)
    echo "Hypothesis invalidated for $FEATURE_NAME. Archiving learnings, purging workspace..."
    ARCHIVE_DIR="$ROOT_DIR/.archive/failed_hypotheses/$FEATURE_NAME"
    mkdir -p "$ARCHIVE_DIR"
    [ -d "$FEATURE_DIR/01_discovery_ideation" ] && mv "$FEATURE_DIR/01_discovery_ideation" "$ARCHIVE_DIR/"
    [ -d "$FEATURE_DIR/02_definition_metrics" ] && mv "$FEATURE_DIR/02_definition_metrics" "$ARCHIVE_DIR/"

    # Read Validation_Report.md (stage 06, if it exists) BEFORE the rm -rf
    # below purges it along with the rest of 03-06 -- this is the only
    # chance to distill it before it's gone for good.
    ASSUMPTION="$(extract_summary "$ARCHIVE_DIR/01_discovery_ideation/outputs/Riskiest_Assumption.md" "no Riskiest_Assumption.md found -- summary incomplete")"
    WHY_FAILED="$(extract_summary "$FEATURE_DIR/06_validation_gtm/outputs/Validation_Report.md" "no Validation_Report.md -- pivoted before stage 06")"

    # Same reasoning as the Validation_Report.md read above: fold in stage
    # 06's Learnings_Note.md (if any) before the rm -rf below purges it.
    fold_learnings_note

    LESSONS_FILE="$ROOT_DIR/LESSONS_LEARNED.md"
    if [ ! -f "$LESSONS_FILE" ]; then
      if [ -f "$ROOT_DIR/.mwp-templates/LESSONS_LEARNED.template.md" ]; then
        cp "$ROOT_DIR/.mwp-templates/LESSONS_LEARNED.template.md" "$LESSONS_FILE"
      else
        cat > "$LESSONS_FILE" <<'EOF'
# Lessons Learned

Append-only register of pivoted (disproven) hypotheses. Read this before
forming a new feature's riskiest assumption -- a similar idea may have
already failed. Populated automatically by scripts/pivot.sh; never hand-edit
a past row.

| Feature | Assumption Tested | Why It Failed | Date | Archive Path |
|---|---|---|---|---|
EOF
      fi
    fi
    echo "| $FEATURE_NAME | $ASSUMPTION | $WHY_FAILED | $(date '+%Y-%m-%d') | \`.archive/failed_hypotheses/$FEATURE_NAME\` |" >> "$LESSONS_FILE"

    rm -rf "$FEATURE_DIR"
    echo "Archived discovery/metrics learnings to $ARCHIVE_DIR."
    echo "Logged a summary row to $LESSONS_FILE."
    echo "Purged specs/architecture/code for $FEATURE_NAME so it never pollutes future context."
    echo "Remember to update its Status to PIVOTED in .mwp/FEATURE_PRIORITY_REGISTRY.md."
    ;;
  --persevere)
    fold_learnings_note
    echo "$FEATURE_NAME persevered. No files changed; proceed to the next stage or ship."
    ;;
  *)
    echo "Unknown action: $ACTION" >&2
    exit 1
    ;;
esac
