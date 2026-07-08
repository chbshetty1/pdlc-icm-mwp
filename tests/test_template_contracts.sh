#!/bin/bash
# tests/test_template_contracts.sh
# Covers entry 0033: nothing previously checked that .mwp-templates/ content
# actually matches the exact patterns scripts/*.sh mechanically parse out of
# it. Several of those checks fail *silently* in production if a template's
# wording drifts -- sync.sh's token-guardrail check and shared-path collision
# check both `return 0` (skip, no warning) when their grep pattern finds no
# match, rather than erroring. This suite exists to catch that drift at
# template-edit time instead of at some future silent no-op in the field.
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

TEMPLATES_DIR="$ROOT_DIR/.mwp-templates"
STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)

# --- Every stage CONTEXT.md: {{FEATURE_NAME}} placeholder (scaffold.sh's sed target) ---
for s in "${STAGES[@]}"; do
  f="$TEMPLATES_DIR/$s/CONTEXT.md"
  assert_file_contains "$f" "{{FEATURE_NAME}}" "$s/CONTEXT.md has {{FEATURE_NAME}} placeholder"
done

# --- Every stage CONTEXT.md except 05_development_test: a token-ceiling
# line matching sync.sh's exact grep pattern (Max [0-9]+ tokens). Most
# important check in this file -- sync.sh's check_token_guardrail silently
# no-ops if this pattern isn't found, so a drifted template disables the
# guardrail with zero signal anywhere else.
#
# 05_development_test is deliberately excluded: its deliverables are code/
# tests, not prose bounded by the word-count heuristic the other 5 stages
# use, so it has no numeric ceiling by design (see CLAUDE.md's automation
# routing: stage 05 bundles via `repomix` instead). The second loop below
# asserts that exemption explicitly, rather than silently skipping 05 and
# risking this suite masking a real future gap. ---
for s in "${STAGES[@]}"; do
  [ "$s" = "05_development_test" ] && continue
  f="$TEMPLATES_DIR/$s/CONTEXT.md"
  if grep -qE 'Max [0-9]+ tokens' "$f" 2>/dev/null; then R=0; else R=1; fi
  assert_equal "0" "$R" "$s/CONTEXT.md has a 'Max N tokens' line sync.sh's guardrail check can parse"
done

F5="$TEMPLATES_DIR/05_development_test/CONTEXT.md"
if grep -qE 'Max [0-9]+ tokens' "$F5" 2>/dev/null; then R=0; else R=1; fi
assert_equal "1" "$R" "05_development_test/CONTEXT.md has NO numeric token ceiling (deliberate -- code/tests, not prose)"
assert_file_contains "$F5" "repomix" "05_development_test/CONTEXT.md documents its alternate guardrail (repomix bundling) explicitly"

# --- Every stage CONTEXT.md: the 6 numbered section headers, so every
# stage's contract has the same shape a human (or Claude) can rely on. ---
for s in "${STAGES[@]}"; do
  f="$TEMPLATES_DIR/$s/CONTEXT.md"
  for n in 1 2 3 4 5 6; do
    assert_file_contains "$f" "## $n." "$s/CONTEXT.md has section ## $n."
  done
done

# --- Every travelling template file: a template-version marker (entry
# 0015's contract) ---
while IFS= read -r f; do
  rel="${f#"$TEMPLATES_DIR"/}"
  if grep -qE '<!-- template-version: [0-9]+ -->' "$f" 2>/dev/null; then R=0; else R=1; fi
  assert_equal "0" "$R" ".mwp-templates/$rel has a template-version marker"
done < <(find "$TEMPLATES_DIR" -type f -name "*.md" | sort)

# --- GLOBAL_CONTEXT.template.md: its example shared_path line matches the
# exact prefix sync.sh's collision check greps for (^- shared_path:) ---
GC="$TEMPLATES_DIR/GLOBAL_CONTEXT.template.md"
if grep -qE '^- shared_path:' "$GC" 2>/dev/null; then R=0; else R=1; fi
assert_equal "0" "$R" "GLOBAL_CONTEXT.template.md's shared_path example matches sync.sh's grep pattern"

# --- FEATURE_META.template.md: every field registry.sh's get_field() parses
# via `grep -E "^${field}:"` is present as its own line ---
FM="$TEMPLATES_DIR/FEATURE_META.template.md"
for field in feature_id name c v r status is_core_anchor; do
  if grep -qE "^${field}:" "$FM" 2>/dev/null; then R=0; else R=1; fi
  assert_equal "0" "$R" "FEATURE_META.template.md has a '$field:' line registry.sh's get_field() can parse"
done

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
