# scripts/lib/log.sh
# Shared operational-log helper (entry 0014). Sourced, not executed directly.
#
# Single, always-on log -- no levels, no per-stage config, deliberately (see
# docs/evolution/0014-minimal-operational-log.md for why configurable
# logging was explicitly rejected). Appends one line per script invocation
# to <product-root>/.mwp/framework.log: timestamp, script name, args, exit
# code.
#
# Wired via `trap ... EXIT` in each script rather than a manual call before
# every exit point -- several scripts (sync.sh, pivot.sh) have multiple
# scattered `exit 1`s on failure paths, and a trap fires exactly once
# whichever path is taken (success, an early usage-error exit, or set -e
# catching an unhandled error) without needing to track down every one by
# hand.
#
# Never fails the calling script over a logging problem: mkdir/write
# failures are swallowed, not propagated.
log_invocation() {
  local root_dir="$1" script_name="$2" args="$3" exit_code="$4"
  mkdir -p "$root_dir/.mwp" 2>/dev/null || return 0
  printf '%s | %s | %s | exit=%s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$script_name" "$args" "$exit_code" \
    >> "$root_dir/.mwp/framework.log" 2>/dev/null || true
}
