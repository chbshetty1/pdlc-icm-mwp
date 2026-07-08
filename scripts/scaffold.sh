#!/bin/bash
# Micro-PDLC / Agile-PDLC dual-mode scaffolder.
# Run from inside a product repo that has copied this framework's
# scripts/ and .mwp-templates/ directories into its root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$ROOT_DIR/.mwp-templates"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$*" "$LOG_EXIT_CODE"' EXIT

STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)

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

if [ -f "$TEMPLATES_DIR/FEATURE_META.template.md" ]; then
  sed "s/{{FEATURE_NAME}}/$NAME/g" "$TEMPLATES_DIR/FEATURE_META.template.md" > "$TARGET_DIR/FEATURE_META.md"
else
  echo "Warning: no FEATURE_META.template.md found at $TEMPLATES_DIR — skipping." >&2
fi

echo "Done."
echo "Next steps:"
echo "  1. Drop raw discovery material into $TARGET_DIR/${STAGES[0]}/inputs/"
echo "  2. Fill in $TARGET_DIR/FEATURE_META.md — set is_core_anchor: true for Phase 0 foundational work,"
echo "     otherwise score it (C-V-R) per docs/PRIORITIZATION_GUIDE.md. Never hand-edit the registry directly."
echo "  3. Run ./scripts/registry.sh to regenerate .mwp/FEATURE_PRIORITY_REGISTRY.md from all features' metadata."
echo "  4. Open Claude Chat/Desktop and start stage 01."
