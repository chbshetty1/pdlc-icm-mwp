# scripts/lib/scan_features.sh
# Shared feature/sprint-directory scanning helper for scripts/registry.sh
# (entry 0003) and scripts/status.sh (entry 0016) — avoids duplicating the
# features/*/ (and sprints/*/) folder-walk logic in more than one place.
# Meant to be sourced, not executed directly.

# Prints one workspace directory (no trailing slash) per line under $1,
# or nothing if $1 doesn't exist / has no matching subdirectories.
list_workspace_dirs() {
  local base_dir="$1"
  [ -d "$base_dir" ] || return 0
  local d
  for d in "$base_dir"/*/; do
    [ -d "$d" ] || continue
    printf '%s\n' "${d%/}"
  done
}
