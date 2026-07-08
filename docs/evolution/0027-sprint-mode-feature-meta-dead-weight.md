# 0027 — `scaffold.sh --sprint` Creates a Dead-Weight `FEATURE_META.md`

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** ranked 21 of 21 by entry `0028`'s unified backlog re-prioritization.

## Problem

`scaffold.sh` creates a `FEATURE_META.md` (C-V-R scoring fields, `is_core_anchor`, `status`) unconditionally for both `--feature` and `--sprint` modes — confirmed by reading the script and by running `scaffold.sh --sprint SPRINT-01_test` in a sandbox, which produced a `FEATURE_META.md` titled "Feature Metadata — SPRINT-01_test" with a `feature_id: SPRINT-01_test` field.

`registry.sh`, however, is hardcoded to only scan `$ROOT_DIR/features` (`FEATURES_DIR="$ROOT_DIR/features"`, confirmed by reading the script) — it never looks inside `sprints/`. Confirmed empirically: after scaffolding a sprint and running `registry.sh`, the sprint's `FEATURE_META.md` produced zero mentions in the regenerated `.mwp/FEATURE_PRIORITY_REGISTRY.md`.

Worse, `scaffold.sh`'s own printed "Next steps" actively mislead a sprint user: step 2 says "Fill in `$TARGET_DIR/FEATURE_META.md` — set `is_core_anchor`... otherwise score it (C-V-R)... Never hand-edit the registry directly," and step 3 says "Run `./scripts/registry.sh` to regenerate the registry from all features' metadata" — both implying the sprint's metadata file matters to a process that will never actually read it.

## Proposed change

Either (a) skip creating `FEATURE_META.md` for `--sprint` mode entirely and adjust the printed next-steps message to not reference it, or (b) extend `registry.sh` to also scan `sprints/*/` if C-V-R scoring is meant to apply to sprints too (unclear — sprints are shared, time-boxed batches under Agile-PDLC, not single scored hypotheses the way features are, so this may not be conceptually meaningful either). Leaning toward (a) unless a concrete case for scoring sprints surfaces.

## Stepwise implementation plan (not yet executed)

1. Confirm with a human which resolution is correct: skip `FEATURE_META.md` for sprints (a), or make `registry.sh` sprint-aware (b) — this determines whether the fix is a `scaffold.sh` trim or a `registry.sh` extension, not something to guess.
2. If (a): guard the `FEATURE_META.md` creation block in `scaffold.sh` behind `[ "$MODE" = "--feature" ]`, and rewrite the "Next steps" message so it only mentions `FEATURE_META.md`/`registry.sh` for feature mode — sprint mode's next-steps should say something conceptually appropriate instead (e.g. just "start stage 01").
3. If (b): add a `sprints/*/` scan to `registry.sh` (reusing `scan_features.sh`'s `list_workspace_dirs`, already generic) and decide whether sprint rows belong in the existing three sections or a new one, since "Deep Context Backlog" and "Active execution queue" framing is feature-hypothesis language.
4. Test in a sandbox: scaffold both a feature and a sprint, confirm the chosen behavior end to end.

## What happens if adopted

Removes a real (if low-stakes) point of confusion for anyone using `--sprint` mode — currently the tool's own instructions send them to fill in and score a file that quietly does nothing.

## Outcome (2026-07-08)

**Resolution decided without a human round-trip this time, on explicit instruction to decide and document rather than ask.** Went with **(a) — skip `FEATURE_META.md` for sprints** — the entry's own already-stated leaning, for the same reasons written into the Proposed change section: a sprint is a shared, time-boxed Agile-PDLC batch, not a single scored hypothesis the way a Micro-PDLC feature is, so C-V-R scoring doesn't have a clean meaning applied to one. Option (b) (`registry.sh` scanning `sprints/*/`) would have required inventing new registry sections or awkwardly forcing sprints into "Core Data Anchor / Active Queue / Deep Backlog" framing that's written entirely in feature-hypothesis language — a bigger, more speculative change for a problem option (a) already has a small, clean fix for.

All 4 steps executed:

1. Decision made and documented above, rather than guessed silently.
2. `scaffold.sh`'s `FEATURE_META.md` creation block guarded behind `[ "$MODE" = "--feature" ]`. The printed "Next steps" message now branches by mode: feature mode keeps its original 4 steps (including the `FEATURE_META.md`/`registry.sh` instructions); sprint mode gets a trimmed 2-step message that explicitly states sprints aren't C-V-R scored or tracked in the priority registry, rather than silently dropping the reference and leaving a gap.
3. (b) not applicable — not implemented.
4. Tested in a sandbox: `--feature` mode still produces `FEATURE_META.md` and the full 4-step message; `--sprint` mode produces neither the file nor the misleading steps, confirmed by direct file-existence checks on both.

No `.mwp-templates/` file touched, so no `template-version` bump. Root `VERSION` bumped 18→19 — `scaffold.sh` ships to every new product.
