# suppr

Writing and data repo for the suppr project — a restaurant recommendation and
management app for two — and the **Small Batch Apps** book and article series
about building it.

The suppr application code (Wails desktop app, PWA, and API server) no longer
lives in this submodule. What remains here is the writing, the specs, and the
source data.

## Contents

- `specs/` — book-ready spec chapters: architecture, API, data model,
  recommendation engine, UI, federation, glossary, and the section chapters
- `articles/` — the Small Batch Apps article series; `articles/final-drafts/`
  is the canonical markdown source for typeset output
- `cmd/` — `typeset.fish` and `typeset-rules.md`: generates `.docx` files from
  the specs and final drafts into `works/imports/files/` (run via the
  repo-root `typeset` alias)
- `data/` — restaurant source data (Philly Mag 50 Best, Check Please! Philly,
  Eater 38)
- `original/` — the archived CheckPlease database and schema
- `design/` — raw design material
- `build-log.md` — dated build-log entries

## Typeset

Markdown in `specs/` and `articles/final-drafts/` is the canonical source; the
`.docx` files under `works/imports/files/` are generated output. From the repo
root:

```fish
fish suppr/cmd/typeset.fish
```

See `cmd/typeset-rules.md` for the formatting and naming spec.
