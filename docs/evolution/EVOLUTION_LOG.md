# Evolution Log

This is the running record of how this framework's design has been challenged, revised, or deliberately left alone. It exists so future readers (including future us) can see *why* the framework looks the way it does, not just what it currently looks like.

## Convention

- Every substantive design analysis, critique, or change gets its own file in `docs/evolution/`, named `NNNN-slug.md` (zero-padded, sequential, never reused or renumbered).
- Each entry is added to the table below. Never edit or delete a past entry's content — if a conclusion later turns out wrong, add a new entry that supersedes it and note that in the "Status" column. The log is append-only, same as the framework's own philosophy of preserving intermediate state.
- Status values: `proposed` (analysis exists, no action taken yet), `adopted` (changed the shipped framework), `rejected` (considered, explicitly not doing it, with reasons), `superseded` (an entry that later analysis overrode).

## Log

| # | Date | Title | Status | Summary |
|---|---|---|---|---|
| 0001 | 2026-07-07 | [First-Principles Analysis](0001-first-principles-analysis.md) | proposed | Strips the v1 framework to fundamental truths (context-as-tokens economics, decisions-not-stages, irreversibility over effort, single-writer concurrency). Concludes v1's fixed 6-stage pipeline, Micro/Agile/Lean labels, and C-V-R bypass rule are practical approximations of a more general "Decision Node DAG" model — flags concrete trigger conditions for when to migrate. No changes made to the shipped framework yet. |

## How to use this when evolving the framework

1. Before changing a core mechanic (stage count, scoring formula, isolation model), write an entry here first — dogma / fundamentals / rebuild — even if the answer is "keep it as is, and here's why."
2. If an entry leads to an actual change, update the relevant file (`docs/PRIORITIZATION_GUIDE.md`, stage `CONTEXT.md` templates, etc.) in the same commit, and mark the entry `adopted`.
3. If you later reverse a decision, don't rewrite history — add a new numbered entry and mark the old one `superseded`, with a one-line pointer to the new entry.
