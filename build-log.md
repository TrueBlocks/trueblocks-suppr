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
