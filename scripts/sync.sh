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

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $0 <workspace_path> <from_stage> <to_stage> [approver]"
  echo "Advance approved outputs from one stage into the next stage's inputs."
  echo "Example: $0 features/FEAT-101_stripe 01_discovery_ideation 02_definition_metrics \"J. Rivera\""
  exit 0
fi

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

# --- Secrets/credential guardrail (entry 0034) ---
# Mechanical, regex-based scan of this stage's outputs/ before it syncs
# forward -- not a real secret scanner (no entropy analysis, no
# provider-specific API), just the same class of pattern-matching guardrail
# as entry 0005's shared-path check: catches literal, common shapes of a
# leaked credential (a private-key block, an AWS-shaped access key ID, a
# hardcoded api_key/secret/password/token assignment with a non-trivial
# value) and blocks the sync outright, auto-writing BLOCKED_REASON.md, the
# same way entry 0005's collision check does. A leaked secret is a different
# order of severity than an over-length file (entry 0004's guardrail, which
# only warns): once it syncs forward -- and especially once it's committed
# -- it can't be un-leaked, so this blocks rather than warns. Runs on every
# sync, not just specific stage transitions, since a secret can show up in
# any stage's raw notes or output, not just architecture/code stages.
check_secrets_guardrail() {
  local hits=()
  local f base line

  for f in "$FROM_OUT"/*; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    [ "$base" = "BLOCKED_REASON.md" ] && continue

    case "$base" in
      *.pem|*.key|id_rsa|id_ed25519|*.pfx|*.p12)
        hits+=("$f — filename looks like a private key/credential file")
        ;;
    esac

    if grep -qE -- '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----' "$f" 2>/dev/null; then
      hits+=("$f — contains a PRIVATE KEY block")
    fi

    if grep -qE -- 'AKIA[0-9A-Z]{16}' "$f" 2>/dev/null; then
      hits+=("$f — contains what looks like an AWS access key ID")
    fi

    while IFS= read -r line; do
      [ -z "$line" ] && continue
      hits+=("$f — line looks like a hardcoded credential: \"${line:0:70}\"")
    done < <(grep -inE '(api[_-]?key|secret|password|passwd|token|access[_-]?key)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_=-]{16,}' "$f" 2>/dev/null | grep -viE '\{\{[A-Z_]+\}\}')
  done

  if [ "${#hits[@]}" -gt 0 ]; then
    FEATURE_NAME="$(basename "$WORKSPACE")"
    cat > "$FROM_OUT/BLOCKED_REASON.md" <<EOF
# BLOCKED: $FEATURE_NAME / $FROM

## What was attempted
Ran scripts/sync.sh to advance $FROM outputs into $TO inputs.

## Why it failed
Automated secrets/credential guardrail found content in this stage's outputs that looks like a hardcoded credential:
$(printf '%s\n' "${hits[@]}" | sed 's/^/- /')

This is a mechanical, pattern-based check (entry 0034) -- not a full secret scanner. It catches literal private-key blocks, AWS-shaped access key IDs, and generic key/secret/password/token assignments with a non-trivial value. It does not catch every possible credential shape, and can false-positive on a genuinely-random-looking non-secret string.

## Attempts made
1. scripts/sync.sh $WORKSPACE $FROM $TO — blocked automatically before any files were copied.

## What a human needs to decide
Whether the flagged content is a real credential (rotate/revoke it immediately if so -- it may already be exposed in this stage's outputs, and should never be allowed to sync forward or get committed) or a false positive (a placeholder, example, or non-secret string that happens to match the pattern -- reword it to stop matching, or note it as reviewed).

## Suggested next step
Review the flagged file(s) above. If real, rotate the credential and remove it from the output file before retrying. If a false positive, edit the file so it no longer matches (e.g. use an obvious placeholder like {{API_KEY}} instead of a real-looking string), then re-run sync.sh.
EOF
    echo "Error: possible hardcoded credential detected — see $FROM_OUT/BLOCKED_REASON.md" >&2
    exit 1
  fi
}
check_secrets_guardrail

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
