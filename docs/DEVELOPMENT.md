# Developing This Framework

This file is about *developing this framework template itself* — not about using it to build a product. If you're building a product with this framework, you don't need this file; see `README.md` instead. Framework-repo-only: like `docs/evolution/` and `PROJECT_PLAN.md`, this does not travel to new products.

## Change process

Every substantive change to this framework goes through `docs/evolution/` first — write an entry, then implement it in the same commit as marking it `adopted`. The full convention, status values, and the "Proposed → Adopted workflow" (pick an entry, run its plan, record the outcome, update statuses, bump versions) already live in `docs/evolution/EVOLUTION_LOG.md`'s "How to use this when evolving the framework" and "Proposed → Adopted workflow" sections — this file doesn't repeat that, it just points to it.

## Script conventions

Established through practice across every script in `scripts/`, stated explicitly here so they don't have to be reverse-engineered from example:

- **`set -euo pipefail`** at the top of every script — fail fast and loud rather than continuing past an error or an unset variable.
- **A `usage()` function plus argument validation** before doing anything destructive (creating directories, deleting files, writing output). If required arguments are missing or malformed, print usage and exit non-zero before touching the filesystem.
- **Test in a scratch copy, never against the committed repo directly.** The pattern used throughout this framework's own development: copy the relevant scripts/templates into a temporary directory (or the agent sandbox's own scratch space — see the FAQ's note on sandbox-mount staleness if testing from an agent environment), run the change there, confirm the output, only then consider it verified. Never `rm -rf` or mutate this repo's own tree as a test.
- **Fail via the escalation contract, not silently.** A script hitting a genuinely blocking condition (missing dependency, ambiguous state) should point at `CRITICAL_ESCALATION.md`'s pattern rather than a bare stack trace or "command not found."
- **Log every invocation via `trap ... EXIT`, not manual calls before each exit point.** `scripts/lib/log.sh`'s `log_invocation` is wired into every script this way (entry `0014`) so it fires exactly once regardless of which exit path a script takes — success, an early usage-error `exit 1`, or `set -e` catching an unhandled error — without needing to track down every scattered `exit` statement by hand. **Known gotcha, worth remembering:** capture `$?` into a variable as its own statement first — `trap 'EC=$?; log_invocation ... "$EC"' EXIT` — never reference `"$?"` directly inside a trap command string that also contains a command substitution like `$(basename "$0")` earlier in the same argument list. Word expansions happen left to right, and the command substitution's own exit status silently overwrites `$?` before it gets read, always logging `exit=0` regardless of what actually happened. Caught this exact bug while testing entry `0014` — a bad-usage call was logging as a success until the capture-first fix went in.

## Testing this framework

`tests/run_tests.sh` runs every `tests/test_*.sh` suite and reports pass/fail counts. Deliberately dependency-free — no `bats-core` or any other third-party test framework, just bash, since that's already this framework's one hard prerequisite. (`bats-core` was the original plan per entry `0030`; it couldn't be installed in the sandbox this framework was developed in — no root, no network egress to any package registry — so the fallback the entry's own plan allowed for became the actual design. In hindsight it's arguably the better fit anyway: adding `bats-core` would mean another `docs/TOOLING_MATRIX.md` entry and another Windows install question for a framework that otherwise needs nothing beyond bash.)

Each `test_*.sh` builds its own scratch copy of `scripts/` + `.mwp-templates/` in a `mktemp -d` directory and runs as its own subprocess — same "test in a scratch copy, never against the committed repo directly" rule from the script conventions above, just mechanically enforced instead of manually remembered per entry.

```bash
./tests/run_tests.sh          # run every suite
./tests/run_tests.sh tests/test_sync.sh   # run just one
```

If your change touches a behavior one of these suites already covers, run the relevant suite (or the full run) before writing that entry's Outcome section — treat a newly-broken test the same as any other test failure caught during manual verification. If your change adds a new behavior worth protecting against regression (especially anything that took real debugging to find, the way entry `0014`'s `$?`-trap bug did), add a test for it in the same entry rather than deferring it. `tests/` is framework-repo-only — it doesn't travel to new products (see `docs/evolution/0030-script-test-harness.md`), since a product repo uses this framework's scripts rather than developing them.

**Scope of what a passing suite actually certifies (entry `0042`):** every assertion here checks that `scripts/*.sh` behave as coded against synthetic scratch data — it certifies script correctness, not that the framework's underlying methodology (folder-scoped context producing better AI-agent output than the alternatives) actually holds. Don't cite "N/N passing" in an evolution entry's Outcome as evidence the *methodology* works; it's evidence the *scripts* work. The methodology claim stays untested until a real product pilot runs one comparable task through this framework and, ideally, against some counterfactual. See `docs/evolution/0042-critical-theory-audit.md`.

## Documentation map

| File | Audience | What belongs here |
|---|---|---|
| `README.md` | Anyone new to the framework | What it is, prerequisites, file map, how to start a new product from it. |
| `docs/CLAUDE_WORKFLOW_PLAYBOOK.md` | Teams using Claude specifically | Which Claude surface to use per stage — optional reference, not required by the scripts. |
| `docs/PRIORITIZATION_GUIDE.md` | Anyone scoring features | The C-V-R formula, worked examples. |
| `docs/TOOLING_MATRIX.md` | Anyone setting up the optional tool stack | Per-stage tool list, verified install commands. |
| `docs/CONSTRAINTS.md` | Anyone extending or auditing the framework | Every hard non-negotiable rule, why it exists, where it's enforced. |
| `docs/FAQ.md` | Anyone with a "why does it work this way" question | Recurring meta-questions and operational lessons that don't fit neatly elsewhere. |
| `docs/MIGRATIONS.md` | Anyone upgrading a product repo's copy of the framework | One row per MAJOR `VERSION` bump — what broke, what to do about it. See entry `0029`. |
| `docs/evolution/` (this file's sibling, `EVOLUTION_LOG.md` + numbered entries) | Framework contributors | The append-only record of every design decision — what changed, why, and what it superseded. |
| `docs/PILOT_MEASUREMENT_PLAN.md` | Whoever runs the first real end-to-end pilot | Tiered pilot metrics (free / small-addition / deferred), the counterfactual decision entry `0042`'s NA4 requires, and a pre-pilot TODO checklist. See entry `0043`. Framework-repo-only, does not travel — it's about validating this framework, not building a product. |
| `docs/DEVELOPMENT.md` (this file) | Framework contributors | How to actually make a change — script conventions, doc map, adoption checklist, testing. |
| `tests/` | Framework contributors | Dependency-free regression suite for `scripts/*.sh`. See entry `0030` and "Testing this framework" above. **Framework-repo only, does not travel.** |
| `PROJECT_PLAN.md` | Framework contributors, historical reference | How this framework's original design decisions were made, pre-`docs/evolution/`. |

## General adoption checklist

Applies to *every* adopted entry, not just entries specifically about documentation or versioning:

1. Update the entry file itself: append an "Outcome" section, change `Status` to `adopted`.
2. Update `docs/evolution/EVOLUTION_LOG.md`'s table row to match.
3. If a new script or doc file was created, add it to `README.md`'s file table.
4. If user-facing behavior changed (a script's output, a template's contract), check whether `docs/FAQ.md` needs a new or updated entry.
5. If a new non-negotiable rule was established (or an existing one changed), update `docs/CONSTRAINTS.md`.
6. Bump versions per entry `0015`'s system (tiered per entry `0029`): `template-version` on any touched `.mwp-templates/` file, and root `VERSION` — `MAJOR.MINOR.PATCH` — on any change shipped to `.mwp-templates/`, `scripts/`, `CLAUDE.md`, or a doc marked "Travels with new products." Pick the tier honestly, don't default to the smallest:
   - **PATCH** — doc-only wording/typo/comment fixes, zero behavioral or structural effect on an already-scaffolded product.
   - **MINOR** — backward-compatible additions (new optional script flag, new template file, new FAQ entry, new optional `CONTEXT.md` reference). Nothing already scaffolded breaks by staying on an older minor version.
   - **MAJOR** — could break or silently miscopy something already scaffolded (renamed/removed template file, changed script argument behavior, changed `CONTEXT.md` contract shape, a load-bearing path/logic fix — entry `0025` would have qualified had this scheme existed then).
   This is mandatory for every adoption now, not just versioning-related ones.
7. If the bump was MAJOR, add a row to `docs/MIGRATIONS.md` describing what changed and what a product repo on an older version must do about it. PATCH/MINOR bumps don't get a row — they're backward-compatible by definition.
8. If the change touches `scripts/` behavior, run `tests/run_tests.sh` (the relevant suite at minimum, the full run if unsure) before writing the Outcome section. If the entry fixes or adds a behavior worth protecting against regression, add or extend a `tests/test_*.sh` suite for it in the same entry — see "Testing this framework" above.
9. Revisit the "Known cross-entry collisions" list below — remove anything just resolved, add anything a newly-logged entry surfaces.

## Known cross-entry collisions

A living list of backlog entries that touch the same files, so they get planned around rather than each independently colliding. Revisited on every adoption per checklist step 7 above — entries move off this list once adopted and their collision is resolved.

*As of 2026-07-09 (all 21 ranked backlog entries, 0001–0028, are resolved — adopted or superseded; entries 0029–0043 are additional, logged from external research, a stage-01/02 discovery pass, or a requested critical-lens review rather than the original ranked backlog; nothing is currently open):*

- Nothing outstanding. The next entry to touch `scripts/` should run `tests/run_tests.sh` first (entry 0030) to establish a known-good baseline before editing, in addition to reading each script's current state directly as every entry in this list already advises. Remember `0042`'s scope note when doing so: a clean run confirms the baseline's *scripts* behave correctly, not that the methodology itself is validated.

*Resolved and removed from this list since the entry was first logged:* 0018 and 0012 both editing all six stage `CONTEXT.md` templates (both landed) · 0003/0016 sharing `features/*/` scan logic (both landed, factored into `scripts/lib/scan_features.sh`) · 0016's last-sync column depending on 0009's `SYNC_LOG.md` (0009 landed first) · 0007/0012 both touching the same `README.md` copy-steps block (both landed sequentially without conflict) · 0012's stepwise plan pre-dating entry 0025's path-depth fix (resolved differently than originally expected — see `docs/evolution/0012-shared-learnings-file.md`'s Outcome) · 0014 touching every script in `scripts/` (landed; `sync.sh`/`pivot.sh`'s post-0012 shape was read directly rather than assumed, as this list itself had flagged) · 0027 (`scaffold.sh --sprint` dead-weight `FEATURE_META.md`, resolved by skipping creation for sprint mode) · 0029/0030 both touching `docs/DEVELOPMENT.md` and `README.md`'s file tables (landed sequentially, in the same session, without conflict — 0030 read 0029's just-written state directly before editing) · 0035/0036 both touching `scaffold.sh` and `status.sh` (0035's `lib/stages.sh` extraction landed first, 0036's `-h`/`--help` block was added on top of that already-refactored shape, read directly rather than assumed) · 0033/0037 both adding new `tests/test_*.sh` suites in the same session as 0034's `sync.sh` change, run against `tests/run_tests.sh`'s full suite after each addition rather than assuming independence · 0038 touching both `sync.sh` and `pivot.sh`'s near-identical (deliberately duplicated) `Learnings_Note.md`-folding blocks in the same entry, so the fix landed in both places at once rather than one drifting from the other · 0039's `registry.sh` change interacting with entry 0037's pre-existing synthetic `R=0` test fixtures (0037 landed first; 0039 broke two of its assertions in a way that was correct given the new validation, not a regression — see 0039's Outcome for the actual open-ended-`awk`-range bug this surfaced in 0037's own test).

<!-- Not versioned via template-version — this file is framework-repo-only and doesn't travel to new products, but IS covered by an evolution-entry outcome each time it's updated. -->
