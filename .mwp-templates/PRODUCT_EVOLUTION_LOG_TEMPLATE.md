# Evolution Log

<!-- Copy to <product-repo>/docs/evolution/EVOLUTION_LOG.md at product init
     (see README.md's "Using this framework for a new product" step 3).
     This is the product's own running record of architecture and product
     decisions -- why FEAT-005 rejected the obvious approach, why Postgres
     over Mongo, why a stage's contract got hand-edited after a real feature
     hit a gap in it. It is the same append-only convention this framework
     used on itself (see the framework repo's own docs/evolution/), reworded
     for a product instead of the framework template. The specific framework
     entries do not carry over -- only the convention does. Starts empty;
     the first real entry is this product's own. -->

This is the running record of how this product's design has been challenged, revised, or deliberately left alone. It exists so future readers (including future agents) can see *why* the product looks the way it does, not just what it currently looks like.

## Convention

- Every substantive design analysis, critique, or change gets its own file in `docs/evolution/`, named `NNNN-slug.md` (zero-padded, sequential, never reused or renumbered).
- Each entry is added to the table below. Never edit or delete a past entry's content — if a conclusion later turns out wrong, add a new entry that supersedes it and note that in the "Status" column. The log is append-only.
- Status values: `proposed` (analysis exists, no action taken yet), `adopted` (changed the shipped product), `rejected` (considered, explicitly not doing it, with reasons), `superseded` (an entry that later analysis overrode).

## Log

| # | Date | Title | Status | Summary |
|---|---|---|---|---|

<!-- No entries yet. Add the first row here once this product's first
     evolution entry exists at docs/evolution/0001-<slug>.md. -->

## How to use this when evolving the product

1. Before changing a core mechanic (a shared schema, an auth pattern, a decision that other features will build on), write an entry here first — problem / proposed change / stepwise plan, even if the answer is "keep it as is, and here's why."
2. If an entry leads to an actual change, update the relevant file (code, a stage's `CONTEXT.md`, `GLOBAL_CONTEXT.md`) in the same commit, and mark the entry `adopted`.
3. If you later reverse a decision, don't rewrite history — add a new numbered entry and mark the old one `superseded`, with a one-line pointer to the new entry.

## Proposed → Adopted workflow

1. **Write the entry**: problem, proposed change, a stepwise plan.
2. **Run the plan** as written.
3. **Record the outcome** in the same entry file: append what actually happened, especially if reality diverged from the plan.
4. **Update the entry's Status** to `adopted`, `rejected` (say why), or leave as `proposed` if paused mid-way.
5. **Update this file's log table row** to match the new status.
6. **If adopted**, the actual product files get edited in the same commit as the status change — the evolution entry and the shipped change land together, never separately.

<!-- template-version: 1 -->
