#!/bin/bash
# On-demand audit: for one stage (or every stage of a feature/sprint),
# compares its self-reported outputs/Context_Manifest.md against that
# stage's CONTEXT.md declared READ ONLY scope, and flags any claimed read
# not covered by the declared scope.
#
# Tier 2 of docs/PILOT_MEASUREMENT_PLAN.md (entry 0044): mechanizes the
# existing manual cross-check entry 0018 already asks a human to do at the
# Obsidian review gate -- this does NOT replace that human judgment call.
# Per docs/CONSTRAINTS.md's "Scope & containment" section, Context_Manifest.md
# is self-reported, not OS-level traced, and this script's own path-matching
# is a simple prefix/exact match, not a real parser -- both a false positive
# (flagged but actually fine) and a false negative (an under-reported read
# this script can't see because it was never written to the manifest at all)
# are possible. Always exits 0 -- advisory only, a flag never a block, same
# posture as entry 0018 itself. See docs/evolution/0044-tier2-instrumentation.md.
set -uo pipefail  # not -e: grep/find returning no matches is expected, not fatal

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$*" "$LOG_EXIT_CODE"' EXIT

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $0 <workspace_path> [stage]"
  echo "On-demand audit: compares each stage's outputs/Context_Manifest.md against"
  echo "its CONTEXT.md's declared READ ONLY scope. Flags extras for human review --"
  echo "never blocks, never auto-enforces. Omit [stage] to audit every stage that"
  echo "has a Context_Manifest.md so far."
  exit 0
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 <workspace_path> [stage]"
  exit 1
fi

WORKSPACE="$1"
ONLY_STAGE="${2:-}"

if [ ! -d "$WORKSPACE" ]; then
  echo "Error: $WORKSPACE does not exist." >&2
  exit 1
fi

# shellcheck source=lib/stages.sh
source "$SCRIPT_DIR/lib/stages.sh"

# Claimed reads that are always in-scope regardless of what's declared --
# a stage's own inputs/outputs and its own contract are implicitly readable.
is_always_allowed() {
  local p="$1"
  case "$p" in
    ./inputs/*|inputs/*|./outputs/*|outputs/*|./CONTEXT.md|CONTEXT.md) return 0 ;;
    *) return 1 ;;
  esac
}

audit_stage() {
  local stage="$1"
  local context_file="$WORKSPACE/$stage/CONTEXT.md"
  local manifest_file="$WORKSPACE/$stage/outputs/Context_Manifest.md"

  [ -f "$manifest_file" ] || return 0

  echo "## $stage"
  echo ""

  if [ ! -f "$context_file" ]; then
    echo "(no CONTEXT.md found at $context_file — cannot check declared scope)"
    echo ""
    return 0
  fi

  # Declared scope: "- READ ONLY: `<path>` (optional comment)" lines --
  # extract just the first backtick-quoted span per line.
  local declared=()
  while IFS= read -r line; do
    local p
    p="$(printf '%s' "$line" | grep -oE '`[^`]+`' | head -1 | tr -d '\`')"
    [ -n "$p" ] && declared+=("$p")
  done < <(grep -E '^- READ ONLY:' "$context_file" 2>/dev/null || true)

  # Claimed reads: Context_Manifest.md has no fixed format (entry 0018 --
  # self-reported, freeform) beyond "one file per line, paths only" in
  # practice. Treat each non-empty, non-header line as a candidate; strip
  # a leading markdown bullet and surrounding backticks; only keep it if it
  # looks path-like (contains a "/" or a dotted extension) to filter out
  # stray prose without a real parser.
  local claimed=()
  while IFS= read -r raw; do
    local p
    p="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]*[-*][[:space:]]*//; s/^`//; s/`$//; s/[[:space:]]+$//')"
    [ -z "$p" ] && continue
    [[ "$p" =~ ^#.*$ ]] && continue
    if [[ "$p" == */* ]] || [[ "$p" =~ \.[A-Za-z0-9]+$ ]]; then
      claimed+=("$p")
    fi
  done < <(grep -v '^[[:space:]]*$' "$manifest_file" 2>/dev/null || true)

  if [ "${#claimed[@]}" -eq 0 ]; then
    echo "(Context_Manifest.md present but nothing that looks like a file path was found in it)"
    echo ""
    return 0
  fi

  local flagged=()
  local c d matched
  for c in "${claimed[@]}"; do
    if is_always_allowed "$c"; then
      continue
    fi
    matched=0
    for d in "${declared[@]:-}"; do
      [ -z "$d" ] && continue
      if [ "$c" = "$d" ]; then
        matched=1
        break
      fi
      # A declared entry ending in "/" covers anything under it.
      if [[ "$d" == */ ]] && [[ "$c" == "$d"* ]]; then
        matched=1
        break
      fi
    done
    [ "$matched" -eq 0 ] && flagged+=("$c")
  done

  echo "Declared scope: ${#declared[@]} entr$([ "${#declared[@]}" = 1 ] && echo y || echo ies). Claimed reads found in manifest: ${#claimed[@]}."
  if [ "${#flagged[@]}" -eq 0 ]; then
    echo "Clean — every claimed read matches (or falls under) a declared READ ONLY entry."
  else
    echo "Flagged (in manifest, not covered by declared scope — review, don't assume violation):"
    printf '  - %s\n' "${flagged[@]}"
    FLAGGED_TOTAL=$((FLAGGED_TOTAL + ${#flagged[@]}))
  fi
  echo ""
}

FLAGGED_TOTAL=0
if [ -n "$ONLY_STAGE" ]; then
  audit_stage "$ONLY_STAGE"
else
  for s in "${STAGES[@]}"; do
    audit_stage "$s"
  done
fi

echo "----------------------------------------"
echo "$FLAGGED_TOTAL flagged read(s) total across audited stage(s). Advisory only — review, don't treat as a verdict."
# Informational exit code only: nothing in this framework calls this script
# automatically, so a non-zero exit here never blocks anything -- it just
# makes "did this find anything" scriptable for a dry run without grepping
# the printed report.
[ "$FLAGGED_TOTAL" -eq 0 ]
