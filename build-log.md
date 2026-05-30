# Build Log

## May 17, 2026 — The AI Found My Voice (and I Didn't Expect It To)

During the design phase of suppr, I asked the AI to read two of my books — *You Say You Want a Revolution* (technical essays, 2016–2026) and *Spiral* (poetry, 2013/2026) — and produce a voice guide for the article series. The two books could not be more different: one is obsessive blockchain data analysis laced with dad stories and profanity, the other is compressed grief poetry about my brother's death and spirals and lawnmower engines. I expected the AI to produce something split down the middle, "of two parts." It didn't.

What came back was a coherent ten-trait guide that put its finger on telling details — the guidance counselor, the peanut butter sandwiches, the egg coming away from its shell. Not just the details themselves, but *why* they matter to the voice: the concrete object that carries the abstract weight. That's the thread between both books, and the AI found it without being told.

This is the first time I've asked an AI to co-author a book alongside co-building the software the book is about. I tried something similar two years ago and the results were flat — competent but bloodless. The difference now is partly the models (they're better) but mostly the workflow: extended design conversations give the AI enough context to stop writing like a generalist and start writing like it knows what it's talking about.

The book will be published under the Jacquard imprint (my AI-written line) with the byline "Claude Jay Rush" — my nom-de-plume for AI co-authored work. The signaling matters. Thomas Jay Rush writes his own shit. Claude Jay Rush means the AI is in the room, and the reader should know that. The voice guide exists partly for this reason: to keep the AI writing in *my* voice even when it's doing most of the drafting, so the co-authorship produces something coherent rather than something that reads like two different people wrote alternating paragraphs.

The first article draft — before the voice guide — was boring. Structured, competent, dead. After feeding it both books and telling it to stop writing like a fucking consultant, the rewrite was alive. Not perfect, but alive. That's the whole game right now: teaching the AI to stop defaulting to its familiar patterns and start defaulting to mine.

## May 17, 2026 — Writing the Narrative Expands the Software

I expected writing to come after coding — build the thing, then write about it. That's how it's always worked. You ship, then you tell the story. But drafting Article 2 ("Small Batch Apps: Software for Two") while the app is still being designed turned out to be something different entirely. The writing doesn't just document the software. It improves it.

The tit-for-tat feature — alternating who picks the restaurant, "we went to your place last week, it's my turn" — came directly from writing the essay. I was drafting the section about why two-person software has interesting design problems, reaching for concrete examples, and the idea just appeared. It wasn't in the design docs. It wasn't on any feature list. The act of explaining *why* software for two is different from software for one forced me to think harder about what "shared decisions" actually means, and a new feature fell out of that thinking.

Same thing happened with the dinner-as-review-session concept — eating together with another couple, discussing the meal at the table, then each couple rating independently on their own app. Like a book club for restaurants. That emerged from trying to explain federation in human terms rather than protocol terms.

And the pattern generalizes beyond restaurants. Writing about "small batch apps" as a philosophy — not just a restaurant app — made it obvious that the same model works for music recommendations, hiking trails, Christmas gifts for kids, wine, books, travel. Any domain where personal taste beats the crowd. The narrative forced the abstraction that the code hadn't demanded yet.

This is surprising. I've been building software for forty years and writing about it for ten, and I've never experienced the two processes feeding each other in real time like this. Writing and coding in tandem, with the narrative actually driving feature discovery — that's new. And it might be the most useful thing about the AI co-authorship model: the AI can hold both the codebase and the manuscript in the same conversation, so insights flow in both directions.

## May 18, 2026 — The Book IS the Product (A Complete Inversion)

The entire model flipped while writing essays 10–15. At the start of this project, I was 100% certain that we'd write the code first, then go back forensically and deconstruct it — building the narrative around what we'd already built. Now I'm 100% certain that was 100% wrong.

Here's what actually happened: we wrote the narrative first. All fifteen essays. The spec is fleshed out (and I intend to attach the full spec to the book as an appendix). Not one line of code is written. Zero. The software doesn't exist yet — only the complete description of what it should be, why it should exist, and how it should work.

This inverts the business model completely. I was thinking GitHub repo, open source, download-and-build-it-yourself. Now I'm thinking: sell a book. The book contains (a) the narrative (these fifteen essays), (b) the full technical spec, and (c) how the business model works. People buy the book. Their AI reads it. The AI builds perfect open source software that runs locally on their machine. All the buyer needs is an AI and a book.

I sell books. That's the business. Not software. Not a platform. Not a service. Books. The code is a byproduct of reading the book — generated fresh by whatever AI the reader has access to, tailored to their machine, their preferences, their city. No two instances will be identical, because no two AIs reading the same spec will produce identical code. But they'll all work, because the spec is precise enough to constrain the output.

This is genuinely new. A book that, when read by a machine, produces working software. The human reads the narrative. The AI reads the spec. Both get what they need from the same artifact. The book is simultaneously a story, a manual, and a seed.

The incentives are finally clean. No hosting costs — it runs on the reader's machine. No support tickets — their AI handles that. No versioning hell — the only version is the edition of the book, and a new edition is just a new book. No fucked up platform incentives where you have to grow to survive. The book is a public good in the purest sense: it exists, it works, it asks nothing of you after purchase. Buy it once. Feed it to your AI. Run your own software forever. The author gets paid for writing. The reader gets sovereignty over their tools. Nobody extracts rent from anyone. That's what a gift to the world looks like when it still lets the maker eat.

## May 18, 2026 — Shifting to .docx as Single Source of Truth

The markdown drafts served their purpose — fast first drafts during the initial writing sprint. But now the essays live in the Works app under the Jacquard/claude imprint as .docx files. From here forward, the .docx files are the single source of truth. All edits happen there.

This matters for collaboration: the AI edits .docx files directly using the md2docx tool (for creation) and docx manipulation (for in-place edits). The workflow is: author reads in the Works app, identifies changes, describes them to the AI, and the AI applies them to the .docx. No intermediate markdown step. No sync problem between two formats. One file, one truth, one workflow.

## May 18, 2026 — Deliberate Under-Specification as a Collaboration Strategy

I'm constantly surprised by how productive it feels to work with the AI. Not only does it do what I ask, but it very frequently clarifies what I'm asking, extends it, organizes and improves what I'm trying to articulate. I've taken to deliberately under-specifying my requests — partly out of laziness, partly because it gives the AI more room to breathe.

When I say "fix the ordering" without spelling out exactly what the correct order is, the AI figures it out from context and presents it back to me for confirmation. When I say "file an issue about the section dividers," it asks the right clarifying questions and drafts something better-structured than what I would have written from scratch. The under-specification isn't sloppiness — it's trust. I trust the AI to fill in the obvious parts, and I focus my energy on the non-obvious decisions.

This is the working relationship that makes the "book as product" model viable. The spec doesn't have to specify every implementation detail. It specifies the *what* and the *why* precisely. The AI that reads it fills in the *how* — just like it does for me, every day, in this conversation.

## May 18, 2026 — Process Reflection Paragraphs (Idea)

In the final version: consider adding a few paragraphs at the end of each chapter discussing my mental state during the process. What did the AI suggest? What ideas did I add? What was inspired by something the AI said? A kind of meta-commentary on the collaboration itself — making the co-authorship visible rather than hiding it behind the prose.

## May 18, 2026 — What This Book Actually Is (Back Cover / Introduction Note)

We need to describe exactly what we're doing — on the back cover, in the introduction, or both. This is a new kind of book and a new kind of software paradigm. It's 100% local-first and written for both the human and the AI in equal measure.

The human reads the narrative section and understands exactly what we're trying to build and why. The AI also reads this section and understands the exact same thing. The AI then goes on to read the specification. From there, it builds that piece of software on the end user's machine.

A human buys an enjoyable, informative, entertaining, and enlightening book. The AI builds software. The human gets to use the software without any of the downsides of the current End Stage Capitalism Surveillance nightmare we all live in — while still being able to enjoy all the intense joy brought by social media.

This needs to be crystal clear to the buyer before purchase: you are buying a book that is simultaneously a story and a seed. Read it for pleasure. Feed it to your AI for sovereignty.

## May 18, 2026 — The Narrative-Spec Ping-Pong

The relationship between narrative and spec is not linear (write story → extract spec). It's a ping-pong game. The narrative reveals features the spec didn't anticipate. The spec constrains ideas the narrative invented on a whim. They correct each other continuously.

Example: The image of sitting in a restaurant with the phone face-up on the table, showing the suppr logo so other couples notice it — that's a visual from the narrative (Essay 13, "The App on the Table") that implies features: voluntary presence broadcasting, a visually distinctive logo/screen, a social-object mode distinct from the utility mode. None of that was in the original spec. It came from imagining a scene and asking "what would the app need to do for this moment to happen?"

Rule: where narrative and spec disagree, we correct the narrative. There should be no disagreements. The spec is authoritative for the builder, but the narrative is the source of vision. Both must converge.

## May 18, 2026 — Easter Egg: Tits and Tats

Somewhere in the narrative section — probably in the essay about tit-for-tat alternation — bury a line that makes "the tits and the tats" read as a natural reference to the two sides of the alternation. Don't flag it. Don't wink. Let it sit there for the author's private amusement. If nobody catches it, that's fine. Hidden jokes are a gift to yourself.

## May 18, 2026 — Hacking Is Back (Because the AI Can Pick Up Threads)

I deliberately leave things underspecified, under-implemented, half-assed. I know I'm only going to use something the way I want it NOW. Either I'll never touch it again, or I'll come back later and the AI will pick up where I left off — fully grasping the context from the code, the comments, the conversation history.

In the old days this would have been called hacking. Bad practice. Technical debt. Unprofessional. You don't ship code that's "good enough for today" because future-you has to maintain it, and future-you will hate past-you for every shortcut.

That calculation changed completely. Future-me doesn't maintain code. Future-me describes what he wants and the AI refactors the hack into whatever it needs to be. The cost of a hack dropped to near zero because the cost of fixing a hack dropped to near zero. So I hack the shit out of everything. I literally do not care what the code looks like. How shitty it is. How bad it is. I never have to look at it. Does the command-line tool do what I want? Does the app do what I want? That's all that matters. And it's not even "does it do what I want forever" — it's "does it do what I want RIGHT NOW." Don't worry about the future. The AI will handle the future.

This is hugely liberating. It changes what "quality" means. Quality used to mean: clean code, good abstractions, maintainable architecture, test coverage. Now quality means: does the thing work for the person using it today? Everything else is premature optimization against a future that might never arrive — and if it does arrive, it arrives with an AI that can rewrite anything in minutes.

## May 18, 2026 — The Typeset Workflow (Bidirectional md↔docx)

Invented a new alias: `typeset`. The AI generates .docx files from the markdown sources (specs + narrative essays) into `./works/imports/files/`. The works app picks them up, generates PDF previews, and they appear in the galley. The markdown is the source of truth. The .docx is a rendered view.

But — and this is the key innovation — I can ALSO edit the .docx files directly (red-pen edits in Word, reading in the works app and marking things up). The system handles this: before overwriting a .docx, the AI checks file dates. If the .docx is newer than the .md, it means I edited the docx. The AI stops and asks: overwrite (discard my edits) or sync (extract my changes back into the markdown, then regenerate).

This gives us true bidirectional editing without a sync protocol. The AI writes in markdown. I read and edit in Word. Changes flow in both directions through a simple date-comparison guard. No merge conflicts. No version numbers. Just file timestamps and a human deciding which direction to push.

The insight: the book pipeline doesn't need a single format. It needs a single source of truth with a clean generation step in one direction and a clean sync step in the other. The `typeset` alias is that generation step. The `sync` response is the reverse step. Both are simple, both are reversible, both preserve the markdown as canonical.

## May 18, 2026 — Markdown Is Not How AI Should Think

The typeset workflow works, but it exposed something deeper: markdown is a terrible format for AI memory and collaboration. Getting the AI to produce .docx files from markdown — stripping banners, injecting subtitles, handling the colon convention for Title/Subtitle splitting — required multiple rounds of correction. The AI kept including "Part 5 of the Small Batch Apps series" banners because the markdown contained them. It couldn't distinguish structural metadata from content because markdown makes no such distinction. Everything is flat text with decoration characters.

The real problem isn't this particular workflow. It's that markdown is the only viable way to get an AI to do structured work, and it's obviously inadequate. Markdown loses context. It loses relationships between documents. It loses the difference between "this is metadata about the document" and "this is content of the document." It loses formatting intent — is this italic for emphasis or italic because it's a series name? You can't tell. The AI can't tell either, so it guesses, and half the time it guesses wrong.

What AI memory actually needs is a native format — something that preserves all context, all connections, all the subtlety that gets stripped when you flatten thought into `# headings` and `*emphasis*`. The human side needs WYSIWYG — text that looks exactly as it will appear on the physical page, whether that page is paper or screen. These are two completely different requirements served by two completely different formats, and the translation layer between them should be trivial and lossless.

Right now we're forcing both sides through markdown, which serves neither side well. The human can't see final formatting. The AI can't see semantic relationships. We're in an awkward middle ground that will look as primitive as punch cards once someone builds the right native format. Markdown is JSON for prose: technically sufficient, existentially hostile, and inexplicably dominant despite being obviously wrong.

## May 25, 2026 — The App Should Start Its Own Server

The first end-to-end run of the suppr Wails app surfaced a workflow bug worth recording. The architecture the spec describes is clean — Wails desktop app talks HTTP to a separate `suppr-server` binary, same server the PWA hits — but it has a usability cost: nothing happens until the user starts the server in a second terminal. Open the app, get a hung window with no feedback. Worse: the webview cannot surface a useful error because the API call just times out silently.

Two lessons. First: the *book* needs to say the app launches the server itself. The architectural diagram in the specs (`client-server-pattern.md`, `project-structure.md`) shows `Wails app → HTTP → suppr-server → SQLite` with the implication that they are separate processes. That is true on a deployed VPS, but on the user laptop they have to feel like one program. The desktop app should spawn (or embed) the API server during `Startup` and shut it down during `Shutdown`. The PWA continues to point at the deployed server. Same client, two host environments, but the desktop experience is *one app, one click*.

Second: silent failures are unforgivable in a two-person app. Thomas is not going to read a README to find out he needs to `make run` first. Meriam definitely is not. The first thing every page renders has to be either real data or a real error message — not a perpetual loading spinner.

The fix going in now: `app/app.go` starts the API server in a goroutine during `Startup`, on a free port if `:8420` is taken, and writes the chosen URL into the client. The user-visible model is "double-click suppr, see restaurants." The book chapter on the client/server pattern needs an edit to reflect this.

## May 25, 2026 — Wails Only, No Browser Mode

Decision: suppr is a Wails desktop app, full stop. No browser-mode development. The frontend will never be served by a separate vite dev server in a tab, and the API will never be reached at `http://localhost:8420` from a browser. The desktop bundle has the API embedded in-process via Wails AssetServer Handler; that is the only supported runtime.

Why this matters: every "two host environments" feature (CORS handling, absolute API URLs, port-detection heuristics, vite proxy config, a separate `cmd/suppr-server` build target wired into the dev workflow) is dead weight. It complicates the code, it complicates the docs, and worst of all it gives the user two ways to launch the app — one that works and one that silently fails. Two-person software has one front door.

The PWA (Phase 4) is the only legitimate browser surface. That is a separate deployment talking to a separate deployed `suppr-server` on a VPS, with its own URL, its own auth, and its own UX (mobile-first, bottom tabs, photo upload). It is not "the suppr Wails frontend opened in a browser." When the book gets to Phase 4 it needs to be explicit that the PWA is a sibling client, not a development mode of the desktop app.

What gets pulled from the codebase as a result: the vite `proxy` config, the `wails-dev` and `make run` workflow conveniences that assumed browser-mode dev, and any frontend logic that tried to handle "not in Wails" gracefully. `wails dev` remains for hot-reload during development — but that still runs inside the Wails webview, never a browser tab.

## May 26, 2026 — `wails dev` Has Its Own Networking Reality (Spec + Narrative Note)

Lost half a day to a problem that should have been a five-minute footnote. In production the chi router is mounted in-process via `assetserver.Options.Handler` — the webview talks to it directly, no TCP, no ports, no CORS. Clean. Beautiful. The single front door I just wrote a build-log entry celebrating.

Then I ran `wails dev` and there was no data. None. Vite serves the frontend from `:5173` and intercepts every `/api/*` request as an SPA route, falling back to `index.html`. The frontend `fetch("/api/restaurants")` returned HTML. Adding a Vite proxy to Wails internal `:34115` produced a flood of `socket hang up` — that port is the webview loader, not an HTTP server for external clients. Before that, `431 Request Header Fields Too Large` from Node’s default header cap. None of this is anywhere in the Wails docs as a single coherent paragraph.

The fix that finally worked: `main.go` starts chi on a dedicated `127.0.0.1:34116` listener in a goroutine, alongside the in-process `AssetServer.Handler`. Vite proxies `/api` to `:34116`. Production is unchanged — webview still uses the in-process path, the extra port just sits there idle.

**What needs to change in the spec.** The "one handler, one front door" language was correct for the deployed shape but elided a real implementation requirement. The spec must explicitly say: the API handler MUST be reachable two ways simultaneously — (1) as `assetserver.Options.Handler` for the production webview, and (2) on a fixed loopback TCP port (`127.0.0.1:34116`) for the Vite dev proxy. Both bindings use the exact same `http.Handler`. The Vite config must proxy `/api` to that port. This is not a "dev mode" toggle — it is the same code path in both builds, which is the whole point. A reader’s AI implementing from the spec must not be allowed to interpret "in-process handler" as "no TCP listener at all," because then `wails dev` silently breaks and the next person loses half a day.

**What needs to change in the narrative.** The previous build-log entry ("PWA is a separate sibling client, not a dev mode of the desktop app") is still right and stays. But the chapter that introduces the single-handler architecture needs one honest paragraph: even though there is logically one API, there are two transports — webview→handler in production, and loopback TCP→handler in `wails dev`. The narrative should not pretend this is a clean abstraction it isn’t. Tooling has seams. The seam is at `wails dev`. Name it, show why it exists (Vite owns the frontend during dev and cannot reach an in-process Go handler), and move on. Hiding the seam is what got me here today.

It finally works. That sucked.

## May 26, 2026 — Wails URL opening rule

In Wails apps, do not rely on plain browser links (`href`, `target="_blank"`) inside the webview for external URLs. Use the Wails runtime opener (`BrowserOpenURL`) or backend wrapper (`appkit.OpenURL`) so links open reliably in the host OS browser.

## May 26, 2026 — Inventory Note: Spec Coverage vs Implementation Gaps

Quick inventory against current suppr-build implementation and the written spec:

1) Cmd+K global search (including full-text path): **In spec, not implemented yet.**
- Spec explicitly calls for global search modal + hotkey (`Cmd+K`) and cross-entity search (restaurants/visits/intel) with FTS5 integration.
- Current implementation does not yet wire global hotkeys, search modal, or FTS endpoint usage.

2) Full list/detail navigation pattern + repeated menu hotkey cycling: **In spec, not implemented yet.**
- Spec defines list/detail architecture with `NavigationProvider`, `useDetailPageNavigation`, and repeated Cmd+N cycling behavior (list↔detail).
- Current app uses simple route switching and selected-row detail pane; no scaffold list/detail stack or hotkey cycling yet.

3) Multi-part sorting (3+ levels) in DataTable: **In spec, partially implemented / missed full scope.**
- Spec says DataTable should support multi-column sort up to 4 levels.
- Current DataTable persists a single sort key+direction only.

4) Direct navigation to Detail view: **In spec, partially implemented.**
- Spec expects direct/open-detail navigation patterns with return context and dedicated detail flows.
- Current app supports direct opening to restaurant detail from dashboard/visits/recommend/awards/photos/lists via route+selected ID, but does not yet implement full platform detail stack behavior from scaffold pattern.

Conclusion: all four items are either explicitly in spec or strongly implied by spec architecture. The gaps are implementation debt, not missing spec language.

## May 26, 2026 — Process Preference: Step Progress Reporting

After each completed implementation step, include a short progress report with explicit counts (for example: "Done with 14 of 23 steps in this phase"), plus what remains next. Keep it concise and consistent.

## May 26, 2026 — Cmd+K Search Scaffold

Added a global search endpoint and wired a command palette in the app shell. Search now returns cross-entity hits (restaurants, episodes, lists, photos, awards) and routes users to the relevant page or directly to a restaurant detail context when available.

## May 26, 2026 — List/Detail Hotkey Cycling Scaffold

Implemented route hotkey scaffold for list/detail cycling behavior. Cmd+2 now navigates to Restaurants and, when already on Restaurants, toggles List/Detail mode; re-clicking the active Restaurants nav item also toggles the mode. Restaurants now supports explicit List and Detail panels with Enter/double-click opening detail from the list.

## May 26, 2026 — Response Format Preference

Before the closing line, include 2-3 short headline features describing what was added in this step. Then end with: "We are done. Would you like to continue" on one line. If the user says yes, proceed immediately to the next step.

## May 26, 2026 — Multi-Column Sort Behavior Aligned to Spec

Aligned DataTable sorting to works-style semantics: normal clicks build sort levels up to three; adding a fourth new sort rotates out sort level 1; Shift+click resets to a single primary sort and clears the others.

## May 26, 2026 — HARD RULE: No Local Duplication of Library Behavior

Never duplicate shared library behavior in local app code when a library implementation already exists. Use or adapt the shared package implementation. Treat local duplication as a blocking architecture error.

## May 26, 2026 — Direct Detail Return Context

When a restaurant is opened from another page (Dashboard, Visits, Recommend, Awards, Photos, Lists, or search), the Restaurants detail view now shows a Return button back to that source page. Manual nav/hotkey route changes clear that return context.

## May 26, 2026 — Command Palette (Cmd+Shift+P)

Added a command palette modal with action search, shortcut labels, arrow-key navigation, and Enter-to-execute. Includes navigation commands (Cmd+1..8 equivalents), Open Search (Cmd+K), and Reload Current View (Cmd+R).

## May 26, 2026 — Read the Library First

We spent a full session building a custom `NavRow`, a hand-rolled `AppShell` navbar, and a local `DataTable` copy — then turned around and migrated all of it to `AppLayout` and `DataTable` from `packages/ui`, which were already there and ready to use. The wasted work was entirely avoidable.

The rule going forward: before writing a single line of component or layout code in any trueblocks app, read `packages/ui/src/components/` first. Map what the app needs against what already exists. Build against the library. Only write local code when the library genuinely doesn't cover it.

---

## May 26, 2026 — Works-Style Keyboard Parity for List/Detail

Implemented works-style list behavior: list tables are keyboard-active immediately (Arrow Up/Down, Home/End, Enter). Enter opens detail for the selected row. Added detail navigation shortcuts in Restaurants: Cmd+Left returns to source/preview context when available, and Cmd+Shift+Left / Cmd+Shift+Up return to current Restaurants list view.

Spec note: Cmd+Shift+Left / Cmd+Shift+Up are explicitly speced. Cmd+Left as a return-to-source/preview action is implemented for works parity but is not currently explicit in suppr/specs/ui.md.

## May 26, 2026 — Window geometry persistence

Window size and position are now saved and restored across launches via `~/.local/share/suppr/prefs.json` (same file as the rest of the UI prefs).

**Pattern matches `works`:**
- Frontend: `useWindowGeometry(SaveWindowGeometry, WindowGetPosition, WindowGetSize)` from `@trueblocks/ui` polls every 2 seconds and debounce-writes on change.
- Go bound method: `App.SaveWindowGeometry(x, y, w, h int)` writes into `prefsData`.
- Restore on launch: `main.go` calls the package-level `app.WindowGeometryFromPrefs(path)` before `wails.Run` to get the saved size (used for initial `Width`/`Height`), then restores the position in `OnDomReady` via `runtime.WindowSetPosition`. `StartHidden: true` prevents the window from flashing at the default position before it moves.

**Why `WindowGeometryFromPrefs` is not a method on `App`:** Wails binds all exported methods on the bound struct. Multiple-return-value methods generate incorrect TypeScript (`Promise<number>` instead of a tuple). The package-level function is called from `main.go` only and is never bound to the frontend.
