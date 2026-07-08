#!/bin/bash
# Advance approved outputs from one stage into the next stage's inputs.
# Keeps stage folders strictly local-scoped (no leaky ../../ relative reads
# from inside CONTEXT.md prompts).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$*" "$LOG_EXIT_CODE"' EXIT

if [ $# -lt 3 ]; then
  echo "Usage: $0 <workspace_path> <from_stage> <to_stage> [approver]"
  echo "Example: $0 features/FEAT-101_stripe 01_discovery_ideation 02_definition_metrics \"J. Rivera\""
  exit 1
fi

WORKSPACE=$1
FROM=$2
TO=$3
APPROVER="${4:-unspecified}"

FROM_OUT="$WORKSPACE/$FROM/outputs"
TO_IN="$WORKSPACE/$TO/inputs"

if [ ! -d "$FROM_OUT" ]; then
  echo "Error: $FROM_OUT does not exist." >&2
  exit 1
fi

if [ -f "$FROM_OUT/BLOCKED_REASON.md" ]; then
  echo "Error: $FROM/outputs contains an unresolved BLOCKED_REASON.md. Resolve it before syncing forward." >&2
  exit 1
fi

# --- Token guardrail check (entry 0004) ---
# Heuristic estimate (word_count * 1.3), not a real tokenizer -- close enough
# for a guardrail, not a precise budget. Warns only, never blocks the sync.
# See docs/evolution/0004-enforce-token-guardrails.md.
check_token_guardrail() {
  local context_file="$WORKSPACE/$FROM/CONTEXT.md"
  [ -f "$context_file" ] || return 0

  local ceiling
  ceiling="$(grep -oE 'Max [0-9]+ tokens' "$context_file" | head -1 | grep -oE '[0-9]+' || true)"
  [ -z "$ceiling" ] && return 0

  local f words est
  for f in "$FROM_OUT"/*; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "BLOCKED_REASON.md" ] && continue
    words="$(wc -w < "$f" 2>/dev/null | tr -d ' ')"
    [ -z "$words" ] && continue
    est=$(awk -v w="$words" 'BEGIN { printf "%d", w * 1.3 }')
    if [ "$est" -gt "$ceiling" ]; then
      echo "Warning: $(basename "$f") is ~$est estimated tokens (word-count heuristic), over $FROM's declared ceiling of $ceiling. Sync continues — see docs/evolution/0004-enforce-token-guardrails.md." >&2
    fi
  done
}
check_token_guardrail

# --- Shared-path collision check (entry 0005) ---
# Only meaningful at the 04->05 and 05->06 transitions, where a feature's
# architecture/code output could touch something declared shared in
# .mwp/GLOBAL_CONTEXT.md. Mechanical, not airtight: greps file paths and
# contents for a literal match against each declared shared_path.
CHECK_DIR=""
case "$FROM" in
  04_architecture_design) CHECK_DIR="$FROM_OUT" ;;
  05_development_test)    CHECK_DIR="$WORKSPACE/$FROM/src" ;;
esac

if [ -n "$CHECK_DIR" ] && [ -d "$CHECK_DIR" ]; then
  GLOBAL_CONTEXT="$ROOT_DIR/.mwp/GLOBAL_CONTEXT.md"
  if [ -f "$GLOBAL_CONTEXT" ]; then
    mapfile -t SHARED_PATHS < <(grep -E '^- shared_path:' "$GLOBAL_CONTEXT" | sed -E 's/^- shared_path:[[:space:]]*//')
    FLAGGED=()
    for sp in "${SHARED_PATHS[@]:-}"; do
      [ -z "$sp" ] && continue
      while IFS= read -r f; do
        [ -n "$f" ] && FLAGGED+=("$f (content references \"$sp\")")
      done < <(grep -rl -- "$sp" "$CHECK_DIR" 2>/dev/null || true)
      while IFS= read -r f; do
        [ -n "$f" ] && FLAGGED+=("$f (path matches \"$sp\")")
      done < <(find "$CHECK_DIR" -path "*$sp*" 2>/dev/null || true)
    done

    if [ "${#FLAGGED[@]}" -gt 0 ]; then
      FEATURE_NAME="$(basename "$WORKSPACE")"
      cat > "$FROM_OUT/BLOCKED_REASON.md" <<EOF
# BLOCKED: $FEATURE_NAME / $FROM

## What was attempted
Ran scripts/sync.sh to advance $FROM outputs into $TO inputs.

## Why it failed
Automated shared-path collision check found this feature's output touching one or more paths declared shared in .mwp/GLOBAL_CONTEXT.md:
$(printf '%s\n' "${FLAGGED[@]}" | sed 's/^/- /')

Per "Shared Architecture Sync" in docs/CLAUDE_WORKFLOW_PLAYBOOK.md, a feature must never edit a shared definition directly from its isolated context.

## Attempts made
1. scripts/sync.sh $WORKSPACE $FROM $TO — blocked automatically before any files were copied.

## What a human needs to decide
Whether this is a legitimate shared-schema change (route it through a human-reviewed Core Data Anchor update to .mwp/GLOBAL_CONTEXT.md instead of this feature) or a false positive (the flagged file just mentions the path name without needing to modify it).

## Suggested next step
Review the flagged file(s) above. If it's a real shared-schema change, escalate it as its own Core Data Anchor update. If it's a false positive, reword the content to stop referencing the shared path literally, or narrow the shared_path entry in .mwp/GLOBAL_CONTEXT.md.
EOF
      echo "Error: shared-path collision detected — see $FROM_OUT/BLOCKED_REASON.md" >&2
      exit 1
    fi
  fi
fi

mkdir -p "$TO_IN"
cp -r "$FROM_OUT"/. "$TO_IN"/
echo "Synced $FROM_OUT -> $TO_IN"

# --- Learnings capture (entry 0012) ---
# A stage never writes LEARNINGS.md directly (it's outside that stage's
# outputs/, and no stage's write scope has an exception for this the way
# READ ONLY scope does) -- instead it leaves a plain-text
# outputs/Learnings_Note.md, one discovery per line, and this script folds
# each non-empty, non-comment line into <product-root>/LEARNINGS.md as a
# table row. Same division of responsibility pivot.sh already has for
# LESSONS_LEARNED.md: the agent stays inside its stage; the script performs
# the actual cross-boundary write. See docs/evolution/0012-shared-learnings-file.md.
LEARNINGS_NOTE="$FROM_OUT/Learnings_Note.md"
if [ -f "$LEARNINGS_NOTE" ]; then
  LEARNINGS_FILE="$ROOT_DIR/LEARNINGS.md"
  if [ ! -f "$LEARNINGS_FILE" ]; then
    if [ -f "$ROOT_DIR/.mwp-templates/LEARNINGS.template.md" ]; then
      cp "$ROOT_DIR/.mwp-templates/LEARNINGS.template.md" "$LEARNINGS_FILE"
    else
      cat > "$LEARNINGS_FILE" <<'EOF'
# Learnings

Append-only register of incidental discoveries. Populated automatically by
scripts/sync.sh (and scripts/pivot.sh for stage 06) from each stage's
Learnings_Note.md; never hand-edit a past row.

| Date | Feature | Discovery |
|---|---|---|
EOF
    fi
  fi
  FEATURE_NAME="$(basename "$WORKSPACE")"
  ADDED=0
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*#.*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    line="${line//|/\\|}"
    if [ "${#line}" -gt 150 ]; then
      line="${line:0:147}..."
    fi
    echo "| $(date '+%Y-%m-%d') | $FEATURE_NAME | $line |" >> "$LEARNINGS_FILE"
    ADDED=$((ADDED + 1))
  done < "$LEARNINGS_NOTE"
  [ "$ADDED" -gt 0 ] && echo "Folded $ADDED discovery line(s) from $LEARNINGS_NOTE into $LEARNINGS_FILE."
fi

# --- Sync audit trail (entry 0009) ---
# Lightweight paper trail, not an auth system: one line per successful sync.
SYNC_LOG="$WORKSPACE/SYNC_LOG.md"
if [ ! -f "$SYNC_LOG" ]; then
  echo "# Sync Log — $(basename "$WORKSPACE")" > "$SYNC_LOG"
  echo "" >> "$SYNC_LOG"
fi
echo "$(date '+%Y-%m-%d %H:%M') — $FROM -> $TO (approved by: $APPROVER)" >> "$SYNC_LOG"
