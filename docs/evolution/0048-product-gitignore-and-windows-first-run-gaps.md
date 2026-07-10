# 0048 — Product `.gitignore` Template, and Three Windows First-Run Gotchas Found During the First Real Pilot

- **Date:** 2026-07-10
- **Status:** adopted (2026-07-10)
- **Priority:** surfaced directly while bootstrapping and committing the first pilot's product repo — concrete findings, not a speculative survey.

## Problem

`README.md`'s "Using this framework for a new product" steps never create a product-level `.gitignore` — confirmed by re-reading the steps directly, nothing was missed in a skim. Copying the framework repo's own `.gitignore` would have been actively wrong for a product repo, not just incomplete: it ignores `features/`, `sprints/`, and `.mwp/GLOBAL_CONTEXT.md`, correct only because the framework repo itself must never accumulate live product data (`PROJECT_PLAN.md`'s repo-split decision). A product repo needs exactly those tracked.

Separately, three unrelated but real first-run gotchas surfaced in the same session, all specific to running this on an actual Windows machine rather than the sandbox these scripts were originally verified in (entry `0002`):

1. A relative path passed to bash with Windows-style backslashes (`..\..\some folder\script.sh`) fails with a confusing "No such file or directory" — bash only treats `/` as a path separator, so the whole backslash-containing string gets treated as one literal, nonexistent filename.
2. More than one program can answer to `bash` on a Windows PATH — Git Bash's own `bash.exe` and WSL's are both real possibilities, resolving the same drive differently (`/d/Projects/...` vs. `/mnt/d/Projects/...`).
3. A fresh machine's first `git commit` anywhere fails with `Author identity unknown` until `git config --global user.name`/`user.email` are set once.

## Decision

- **`.gitignore` gap: adopted, ships a template.** New `.mwp-templates/GITIGNORE.template`, covering only framework-level ignores (operational log, generated Repomix/Graphify output, OS/editor noise, an optional Obsidian vault) and explicitly leaving stack-specific entries to the product team — this framework stays tech-stack-agnostic per `docs/CONSTRAINTS.md`'s anti-lock-in rule, so nothing Python/Node/etc.-specific is pre-filled. `README.md`'s setup steps gained a new step (renumbering the rest) copying it in early, before a first commit would typically happen.
- **Windows first-run gotchas: adopted, documentation only.** Added to `README.md`'s Prerequisites section and `docs/FAQ.md`, so the next person gets an explanation instead of a confusing raw error. None of these three are specific to this framework's own script logic — they're general bash/git behavior — but they sit naturally alongside the Windows-specific claims `README.md`'s Prerequisites section already makes (entry `0002`'s Git Bash verification, entry `0023`'s preflight check, `TOOLING_MATRIX.md`'s `winget` PATH gotcha).

## What happened

- `.mwp-templates/GITIGNORE.template` (new file, `template-version: 1`).
- `README.md`: new setup step 3 (renumbers steps 3–7 to 4–8), file-map row for `.mwp-templates/` updated to mention it, Prerequisites section gained the three-gotcha paragraph.
- `docs/FAQ.md`: two new entries.
- `VERSION` bumped MINOR (new `.mwp-templates/` file — backward-compatible addition, doesn't change how any existing template is parsed).

## Outcome (2026-07-10)

Documentation and one new template file only — no script logic changed. Confirmed no test-suite impact: `tests/test_template_contracts.sh`'s template-version check only globs `*.md` files (`find "$TEMPLATES_DIR" -type f -name "*.md"`), so the new `GITIGNORE.template` (no `.md` extension, matching what it's meant to be copied to) sits correctly outside that check's scope — the same kind of deliberate exemption already established for `05_development_test/CONTEXT.md`'s missing token ceiling, not an oversight. Full suite re-run: 225/225.

Not yet validated against a second pilot. Worth confirming the `.gitignore` template's contents are actually sufficient once a pilot's product starts producing real build artifacts (a Python virtualenv, a local vector store, etc.) rather than assuming the comment-only "add your own stack-specific ignores" guidance is enough in practice.
