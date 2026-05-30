#!/usr/bin/env fish
#
# typeset.fish — Generate .docx files from suppr markdown sources.
# Run from anywhere. Finds paths relative to the repo root.
#
# Usage:
#   fish suppr/cmds/typeset.fish [--force]
#
# --force: Skip the date guard (overwrite even if .docx is newer than .md)

set script_dir (status dirname)
set suppr_root (realpath "$script_dir/..")
set repo_root (realpath "$script_dir/../..")

set template ~/.local/share/trueblocks/works/works/templates/book-template.dotm
set outdir "$repo_root/works/imports/files"
set essaydir "$suppr_root/articles/final-drafts"
set specdir "$suppr_root/specs"
set force 0

for arg in $argv
    if test "$arg" = "--force"
        set force 1
    end
end

# --- Date guard ---
# If any .docx is newer than its source .md, stop and warn (unless --force).
function check_date_guard
    set src $argv[1]
    set dst $argv[2]
    if test -f "$dst"
        if test "$dst" -nt "$src"
            echo "BLOCKED: $dst is newer than $src"
            echo "  The .docx was edited after generation. Use --force to overwrite,"
            echo "  or manually resolve the conflict."
            return 1
        end
    end
    return 0
end

# --- Generation function ---
function gen_chapter
    set src $argv[1]
    set dst $argv[2]

    if test $force -eq 0
        check_date_guard "$src" "$dst"
        or return 1
        # Skip if .docx is already fresh (newer than or same age as .md)
        if test -f "$dst"
            if not test "$src" -nt "$dst"
                return 0
            end
        end
    end

    ~/source/md2docx "$template" "$src" "$dst"
end

# --- Preflight ---
if not test -f "$template"
    echo "ERROR: Template not found: $template"
    exit 1
end

if not command -q ~/source/md2docx
    echo "ERROR: md2docx not found at ~/source/md2docx"
    exit 1
end

mkdir -p "$outdir"

set blocked 0

# --- Introduction (no section header) ---
gen_chapter "$essaydir/00-introduction.md" "$outdir/cChapter - 2026 - AI - 00.00 - Introduction.docx"; or set blocked 1

# --- Chapters ---
gen_chapter "$essaydir/01-where-should-we-eat-tonight.md" "$outdir/cChapter - 2026 - AI - 01.01 - Where Should We Eat Tonight.docx"; or set blocked 1
gen_chapter "$essaydir/02-small-batch-apps.md" "$outdir/cChapter - 2026 - AI - 01.02 - Small Batch Apps.docx"; or set blocked 1
gen_chapter "$essaydir/03-the-architect-who-lives-in-the-house.md" "$outdir/cChapter - 2026 - AI - 01.03 - The Architect Who Lives in the House.docx"; or set blocked 1
gen_chapter "$essaydir/04-276-restaurants-and-a-database.md" "$outdir/cChapter - 2026 - AI - 02.01 - 276 Restaurants and a Database.docx"; or set blocked 1
gen_chapter "$essaydir/05-the-stack.md" "$outdir/cChapter - 2026 - AI - 02.02 - The Stack.docx"; or set blocked 1
gen_chapter "$essaydir/06-what-the-ai-gets-right-and-wrong.md" "$outdir/cChapter - 2026 - AI - 02.03 - What the AI Gets Right and Wrong.docx"; or set blocked 1
gen_chapter "$essaydir/07-a-recommendation-engine-for-two.md" "$outdir/cChapter - 2026 - AI - 03.01 - A Recommendation Engine for Two.docx"; or set blocked 1
gen_chapter "$essaydir/08-your-friends-wifes-opinion.md" "$outdir/cChapter - 2026 - AI - 03.02 - Your Friends Wifes Opinion.docx"; or set blocked 1
gen_chapter "$essaydir/09-the-saturday-night-test.md" "$outdir/cChapter - 2026 - AI - 03.03 - The Saturday Night Test.docx"; or set blocked 1
gen_chapter "$essaydir/10-peer-to-peer-dining.md" "$outdir/cChapter - 2026 - AI - 04.01 - Peer-to-Peer Dining.docx"; or set blocked 1
gen_chapter "$essaydir/11-the-desktop-becomes-the-server.md" "$outdir/cChapter - 2026 - AI - 04.02 - The Desktop Becomes the Server.docx"; or set blocked 1
gen_chapter "$essaydir/12-against-scale-a-manifesto-in-code.md" "$outdir/cChapter - 2026 - AI - 04.03 - Against Scale.docx"; or set blocked 1
gen_chapter "$essaydir/13-the-app-on-the-table.md" "$outdir/cChapter - 2026 - AI - 05.01 - The App on the Table.docx"; or set blocked 1
gen_chapter "$essaydir/14-vibe-designing.md" "$outdir/cChapter - 2026 - AI - 05.02 - Vibe Designing.docx"; or set blocked 1
gen_chapter "$essaydir/15-small-batch-everything.md" "$outdir/cChapter - 2026 - AI - 05.03 - Small Batch Everything.docx"; or set blocked 1

# --- Specs ---
gen_chapter "$specdir/prerequisites.md" "$outdir/cChapter - 2026 - AI - 06.01 - Prerequisites and Dependencies.docx"; or set blocked 1
gen_chapter "$specdir/architecture.md" "$outdir/cChapter - 2026 - AI - 06.02 - Architecture.docx"; or set blocked 1
gen_chapter "$specdir/project-structure.md" "$outdir/cChapter - 2026 - AI - 06.03 - Project Structure.docx"; or set blocked 1
gen_chapter "$specdir/api.md" "$outdir/cChapter - 2026 - AI - 06.04 - API.docx"; or set blocked 1
gen_chapter "$specdir/recommendation-engine.md" "$outdir/cChapter - 2026 - AI - 06.05 - Recommendation Engine.docx"; or set blocked 1
gen_chapter "$specdir/data-model.md" "$outdir/cChapter - 2026 - AI - 06.06 - Data Model.docx"; or set blocked 1
gen_chapter "$specdir/ui.md" "$outdir/cChapter - 2026 - AI - 06.07 - User Interface.docx"; or set blocked 1
gen_chapter "$specdir/client-server-pattern.md" "$outdir/cChapter - 2026 - AI - 06.08 - Client-Server Pattern.docx"; or set blocked 1
gen_chapter "$specdir/build-sequence.md" "$outdir/cChapter - 2026 - AI - 06.09 - Build Sequence.docx"; or set blocked 1
gen_chapter "$specdir/federation.md" "$outdir/cChapter - 2026 - AI - 06.10 - Federation.docx"; or set blocked 1

# --- Section headers (no subtitle) ---
gen_chapter "$specdir/section-1.md" "$outdir/cSection - 2026 - AI - 01.00 - Software for Saturday Night.docx"; or set blocked 1
gen_chapter "$specdir/section-2.md" "$outdir/cSection - 2026 - AI - 02.00 - Building the Machine.docx"; or set blocked 1
gen_chapter "$specdir/section-3.md" "$outdir/cSection - 2026 - AI - 03.00 - Taste Is Personal.docx"; or set blocked 1
gen_chapter "$specdir/section-4.md" "$outdir/cSection - 2026 - AI - 04.00 - The Network of Two.docx"; or set blocked 1
gen_chapter "$specdir/section-5.md" "$outdir/cSection - 2026 - AI - 05.00 - After the Code.docx"; or set blocked 1
gen_chapter "$specdir/section-specs.md" "$outdir/cSection - 2026 - AI - 06.00 - Specifications.docx"; or set blocked 1

# --- Glossary ---
gen_chapter "$specdir/glossary.md" "$outdir/cChapter - 2026 - AI - 07.00 - Glossary.docx"; or set blocked 1

# --- Check for blocked files ---
if test $blocked -eq 1
    echo ""
    echo "Some files were BLOCKED (docx newer than source). Use --force to overwrite all."
    exit 1
end

echo "Done. Typeset complete. Output: $outdir"
