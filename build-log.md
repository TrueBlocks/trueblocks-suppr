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
