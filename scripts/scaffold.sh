#!/bin/bash
# Micro-PDLC / Agile-PDLC dual-mode scaffolder.
# Run from inside a product repo that has copied this framework's
# scripts/ and .mwp-templates/ directories into its root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$ROOT_DIR/.mwp-templates"

# Captured before any function is defined/called (entry 0044 dry-run finding):
# "$*" inside the EXIT trap below would otherwise reflect whichever function's
# own (possibly empty) positional parameters happen to be in scope at exit
# time -- e.g. usage() below is called with no arguments, so exiting from
# inside it silently blanks framework.log's args field on exactly the
# bad-usage failure path where the args would matter most.
SCRIPT_ARGS="$*"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$SCRIPT_ARGS" "$LOG_EXIT_CODE"' EXIT

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $0 --feature <FEAT-xxx_name> | --sprint <SPRINT-xx_name>"
  echo "Scaffold a new Micro-PDLC feature or Agile-PDLC sprint workspace from .mwp-templates/."
  echo "Features get a FEATURE_META.md for C-V-R scoring; sprints don't (see docs/evolution/0027)."
  exit 0
fi

# shellcheck source=lib/stages.sh
source "$SCRIPT_DIR/lib/stages.sh"

usage() {
  echo "Usage: $0 --feature <FEAT-xxx_name> | --sprint <SPRINT-xx_name>"
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

MODE=$1
NAME=$2

case "$MODE" in
  --feature) TARGET_DIR="$ROOT_DIR/features/$NAME" ;;
  --sprint)  TARGET_DIR="$ROOT_DIR/sprints/$NAME" ;;
  *) usage ;;
esac

if [ -d "$TARGET_DIR" ]; then
  echo "Error: $TARGET_DIR already exists." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/.mwp/GLOBAL_CONTEXT.md" ]; then
  echo "Warning: $ROOT_DIR/.mwp/GLOBAL_CONTEXT.md not found." >&2
  echo "  Copy .mwp-templates/GLOBAL_CONTEXT.template.md there and fill it in before pointing Claude at this workspace." >&2
fi

echo "Creating workspace for $NAME at $TARGET_DIR ..."
for stage in "${STAGES[@]}"; do
  mkdir -p "$TARGET_DIR/$stage/inputs" "$TARGET_DIR/$stage/outputs"
  if [ -f "$TEMPLATES_DIR/$stage/CONTEXT.md" ]; then
    sed "s/{{FEATURE_NAME}}/$NAME/g" "$TEMPLATES_DIR/$stage/CONTEXT.md" > "$TARGET_DIR/$stage/CONTEXT.md"
  else
    echo "Warning: no template found for $stage at $TEMPLATES_DIR/$stage/CONTEXT.md" >&2
  fi
done

mkdir -p "$TARGET_DIR/05_development_test/src" "$TARGET_DIR/05_development_test/tests"
mkdir -p "$TARGET_DIR/06_validation_gtm/validation_data" "$TARGET_DIR/06_validation_gtm/design_artifacts"

# Resolved BLOCKED_REASON.md files are always archived here, never deleted — see docs/evolution/0010-archive-not-delete-escalations.md
mkdir -p "$TARGET_DIR/.escalations_archive"

# FEATURE_META.md (C-V-R scoring) only applies to --feature mode. A sprint
# is a shared, time-boxed Agile-PDLC batch, not a single scored hypothesis
# the way a Micro-PDLC feature is -- registry.sh only ever scans features/,
# so a sprint's FEATURE_META.md would be silently unread dead weight.
# See docs/evolution/0027-sprint-mode-feature-meta-dead-weight.md.
if [ "$MODE" = "--feature" ]; then
  if [ -f "$TEMPLATES_DIR/FEATURE_META.template.md" ]; then
    sed "s/{{FEATURE_NAME}}/$NAME/g" "$TEMPLATES_DIR/FEATURE_META.template.md" > "$TARGET_DIR/FEATURE_META.md"
  else
    echo "Warning: no FEATURE_META.template.md found at $TEMPLATES_DIR — skipping." >&2
  fi
fi

echo "Done."
echo "Next steps:"
echo "  1. Drop raw discovery material into $TARGET_DIR/${STAGES[0]}/inputs/"
if [ "$MODE" = "--feature" ]; then
  echo "  2. Fill in $TARGET_DIR/FEATURE_META.md — set is_core_anchor: true for Phase 0 foundational work,"
  echo "     otherwise score it (C-V-R) per docs/PRIORITIZATION_GUIDE.md. Never hand-edit the registry directly."
  echo "  3. Run ./scripts/registry.sh to regenerate .mwp/FEATURE_PRIORITY_REGISTRY.md from all features' metadata."
  echo "  4. Open Claude Chat/Desktop and start stage 01."
else
  echo "  2. Open Claude Chat/Desktop and start stage 01. Sprints aren't C-V-R scored or tracked in"
  echo "     the priority registry — that applies to features only."
fi
