# Migrations

This file lists every **MAJOR** version bump this framework has shipped, and what a product repo on an older version needs to do about it. It exists so "are we on the latest framework" has a cheap answer beyond re-reading every `docs/evolution/` entry since you copied — see `docs/evolution/0029-tiered-version-scheme.md` for why the scheme is tiered this way, and `docs/evolution/0015-framework-and-template-versioning.md` for why versioning exists at all.

**Travels with new products** — copy this alongside `FAQ.md`/`CONSTRAINTS.md`/etc. when scaffolding a new product from this framework.

## Convention

Root `VERSION` is `MAJOR.MINOR.PATCH`:

- **PATCH** — doc-only wording/typo/comment fixes, zero behavioral or structural effect. No row here.
- **MINOR** — backward-compatible additions (new optional flag, new template file, new FAQ entry). Nothing already scaffolded breaks by staying on an older minor version. No row here.
- **MAJOR** — could break or silently miscopy something already scaffolded (renamed/removed template file, changed script argument behavior, changed `CONTEXT.md` contract shape, a load-bearing path/logic fix). **Always gets a row below.**

If your product's `VERSION` file's major number is behind the framework's current major number, read every row between the two before copying anything new in. If only the minor/patch numbers differ, it's safe to skip straight to the latest — nothing in between was breaking.

## Log

| Version | What changed | What a product repo on an older version must do |
|---|---|---|
| `20.0.0` | The `VERSION` file's own format changed from a plain incrementing integer (e.g. `19`) to `MAJOR.MINOR.PATCH` (e.g. `20.0.0`). Nothing else in `.mwp-templates/`, `scripts/`, or `CLAUDE.md` changed as part of this entry. | No action needed. If any local tooling of your own parses your product's `VERSION` file expecting a bare integer, update it to expect a three-part string instead — the framework's own scripts never parsed it programmatically, so this is a documentation-only migration for the framework itself. |
