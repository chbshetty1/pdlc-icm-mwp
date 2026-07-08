# 0027 — `scaffold.sh --sprint` Creates a Dead-Weight `FEATURE_META.md`

- **Date:** 2026-07-08
- **Status:** proposed
- **Priority:** unranked — surfaced as a side-finding while testing entry 0006's `--sprint` mode verification, not yet slotted into the backlog ordering.

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
