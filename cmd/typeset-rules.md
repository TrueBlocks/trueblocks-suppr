# Typeset Formatting and Naming Spec

This is the specification that `typeset.fish` (and `~/source/md2docx`) implements when generating .docx files from suppr's markdown sources into `./works/imports/files/`. The script is the executable form of these rules; change the rules here and in the script together.

## Source of Truth

- Markdown files in `suppr/specs/` and `suppr/articles/final-drafts/` are the canonical source.
- The .docx files in `./works/imports/files/` are generated output — overwrite without confirmation.
- After generating all .docx files, touch all source markdowns so they are newer than the .docx.

## Guard: User-Edited .docx

Before overwriting any .docx, compare file dates:

- If the .docx is NEWER than its source .md → STOP. Ask the user: "overwrite" or "sync".
- **overwrite**: proceed as normal (user's docx edits are discarded).
- **sync**: extract text from the .docx, incorporate changes back into the markdown source, THEN regenerate and touch as normal.

The script enforces the date guard; `--force` skips it. The sync path is manual.

## Tool

Use `~/source/md2docx` with template `~/.local/share/trueblocks/works/works/templates/book-template.dotm`.

## .docx Formatting Rules

1. **No markdown headers in output** — use a blank line between sections (no Heading 1/2/3 styles, just white space separating logical blocks).
2. **All Normal paragraphs start with a tab** (first-line indent). Carry over indent from previous paragraphs in the same block.
3. **No "Part of a series" banners** or any meta-commentary at the start of the document.
4. **Every document (except section headers) has a Title and Subtitle** — use Title style for the title, Subtitle style for a meaningful subtitle reflecting the chapter contents. These are the first two elements in every document. md2docx splits `# Title: Subtitle` on the first colon.
5. **Notes/endnotes appear in the document** — include them as-is from the markdown source.
6. **Section documents** (section-1.md through section-5.md, section-specs.md) contain ONLY: the section name in Title style, then a brief one-paragraph explanation in Normal style. Nothing else.

## Output Naming

Files go to `./works/imports/files/` following the pattern:

- Spec chapters: `cEssay - 2026 - AI - <Title>.docx`
- Narrative essays: `cEssay - 2026 - AI - <Title>.docx`
- Section dividers: `cSection - 2026 - AI - Section <N>.docx`

The ` - AI - ` segment between the year and title marks AI-generated content. The import system detects this and sets `is_ai=true` on the work record. All typeset files use it.
