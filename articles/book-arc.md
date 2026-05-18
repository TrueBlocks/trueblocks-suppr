# Small Batch Apps — Book Arc

A narrative architecture for the book. Two tracks interleaved throughout: **the philosophy** (what small-batch computing is) and **the process** (what it's like to build software with an AI co-author). The suppr app is the concrete spine — every idea is grounded in the act of building one restaurant app for two people.

Published under the **Jacquard** imprint. Byline: **Claude Jay Rush.**

---

## The Shape

The book follows the shape of a spiral. It starts small — two people in a kitchen — and widens outward through philosophy, construction, connection, and vision. Each turn of the spiral revisits the same question (*where should we eat tonight?*) at a larger scale. By the end, it's not about restaurants anymore. It's about how software should work and who gets to build it.

Five movements. Each is a collection of essays that stand alone but build on each other — the same structure as *Revolution*, where you can read any essay independently, but reading them in order reveals a decade-long arc.

---

## Movement I — Where Should We Eat Tonight?

**What's broken, and what if we just built our own?**

The opening movement establishes the problem (platforms are terrible), the solution (software for two), and the method (the AI builds everything, I design). The reader should finish this movement thinking: *Wait, he's not writing any code? And it works?*

| Essay | Core Beat |
|-------|-----------|
| The Problem with Yelp | Saturday at 5pm. Yelp is broken. Every platform is broken. The question nobody can answer. |
| Small Batch Apps: Software for Two | The philosophy. The growth model. The smallest network is two nodes and one edge. "Doesn't scale" is a feature. |
| The Architect Who Lives in the House | First extended AI diary piece. What vibe designing actually feels like. Forty years of code, now I write none. The difference between 2024 AI and 2026 AI. The joy. |

**Emotional register:** Frustration → curiosity → delight. The reader arrives annoyed at Yelp and leaves excited about building things.

---

## Movement II — 276 Restaurants and a Database

**Laying the first stones. Data, decisions, and the AI as contractor.**

The building begins. This movement is technical but personal — every architecture choice becomes a story, and the AI's behavior is reported honestly: where it shines, where it stumbles, where it surprises.

| Essay | Core Beat |
|-------|-----------|
| Archaeology of a Restaurant Database | Importing 9 years of Philly Mag 50 Best, Check Please episodes, award sources. The data is messy and interesting. |
| The Stack | Go + Wails + React + Mantine + SQLite. Why each choice. Why the Wails app talks to an API server instead of a local database. The simplest architecture that works. |
| What the AI Gets Right (and Wrong) | Process diary. The AI as tireless contractor. Where it over-engineers. Where it reads my mind. The design conversation as the actual product. |

**Emotional register:** The pleasure of making. Hands in the material. Discoveries in the data.

---

## Movement III — Your Friend's Wife's Opinion

**The recommendation algorithm, and the deeper question of whose opinion matters.**

The app starts working. The recommendation engine is the centerpiece — simple math that beats machine learning because it knows *you*. This movement is where the philosophy gets tested against reality.

| Essay | Core Beat |
|-------|-----------|
| A Recommendation Engine for Two | 100 lines of Go. Five scoring factors. Why simple math beats neural networks when your audience is two. |
| Your Friend's Wife's Opinion > 10,000 Yelp Reviews | Trust in small networks. Why a recommendation from someone you know is fundamentally different from crowd-sourced anything. The math of trust decay. |
| The Saturday Night Test | First real use. Meriam and I use the app to pick a restaurant. What works. What doesn't. Whether we still go to the same place. (Honest.) |

**Emotional register:** Satisfaction → testing → honesty. The thing either works or it doesn't. No faking it when there are only two users and one of them is your wife.

---

## Movement IV — What If Jen and Dave Had One Too?

**Federation: what happens when the spiral widens.**

Two couples. Two databases. Two servers. They don't merge — they share. This movement introduces federation as the natural next step, not as a grand vision but as the answer to a simple question: *What if Jen and Dave had one of these too?*

| Essay | Core Beat |
|-------|-----------|
| Peer-to-Peer Dining | The federation protocol. What a recommendation message looks like. What flows between nodes and what stays home. |
| The Desktop Becomes the Server | The long game: no VPS needed. Your laptop IS the server. The Wails app peers directly. Software that grows the way trust grows. |
| Against Scale: A Manifesto in Code | The philosophical capstone. Why "doesn't scale" is the whole point. The relationship between software scale and human connection. Platforms as herds. Small batch apps as households. |

**Emotional register:** Expansion → conviction. The idea scales without scaling. The spiral widens.

---

## Movement V — What Would You Build If Code Were Free?

**What happens when anyone can build software this way?**

The final movement steps back from suppr entirely. If an AI can co-build a restaurant app from a conversation, what else can it build? If software can start at two people, what changes about who gets to be a software maker? This is where the book earns its title.

| Essay | Core Beat |
|-------|-----------|
| The App on the Table | The wild vision piece. Stage 5 — voluntary presence broadcasting. Strangers who share your taste graph, sitting ten feet away. Serendipity, not surveillance. |
| Vibe Designing | The definitive AI essay. Not about whether AI will replace programmers — about what happens when design becomes the bottleneck and code becomes free. What "vibe coding" actually means to someone who's been coding since 1981. |
| Small Batch Everything | The closing essay. The pattern generalizes. Book clubs, hiking trails, travel, recipes. Any domain where personal beats the crowd. Software growing from the inside out. Like a spiral. |

**Emotional register:** Wonder → possibility. Ending not with a conclusion but with a question: *What would you build if code were free?*

---

## Interleaving the Tracks

The two tracks — **philosophy** and **process** — don't alternate in neat chapters. They bleed into each other the way the technical and personal bleed together in *Revolution*. Every philosophy essay contains moments of "and then the AI did this." Every process essay contains moments of "and this is why small-batch matters."

Some essays are primarily one track or the other (the architecture piece is mostly build; the manifesto is mostly philosophy). But the AI observations should appear everywhere, casually, the way the dad appears in *Revolution* — not announced, just there.

**The build log feeds the process track.** Timestamped notes captured during implementation become raw material. The build log is private; the essays refine its material into story.

---

## Research and Sources

Every time we reach out to the web, consult a paper, reference a dataset, or look something up — document it. Two places:

1. **Per-essay `## Notes` section** at the bottom of each essay file. Dated entries: what we were looking for, what we found (or didn't), and what it means for the essay. Academic-style research notes, not polished prose.

2. **Central `sources.md`** — a running bibliography across all essays. Books, web sources, datasets, and open questions that still need answers.

The notes sections stay in the essay files even after publication. They're part of the book's honest accounting — showing the work, not hiding it.

---

## Voice Calibration

After every draft, the author reads it and delivers hard critique — not "could you adjust the tone" but "this is shit because ___". Every correction gets recorded in the voice guide as a specific, permanent rule. The guide accumulates scar tissue.

The protocol:

1. **Draft delivered.** AI writes a complete essay draft.
2. **Red pen.** Author reads it, marks what's dead, what's generic, what's wrong. No softening. If a heading sounds like a TED talk, say so. If a paragraph could appear in any Medium post, kill it.
3. **Diagnosis.** For each critique, identify the *pattern* — not just this instance but the underlying habit. "You reach for metaphors before earning them." "You summarize what you just said." "You default to triads."
4. **Voice guide update.** The pattern gets added to the voice guide's "What to Avoid" section as a named, permanent rule. Future drafts are checked against every accumulated rule.
5. **Redraft.** AI rewrites the flagged sections (or the whole piece) against the updated guide.
6. **Repeat.** Until it passes the read-aloud test.

This isn't editing. It's training. Each essay should be harder for the AI to get wrong than the last, because the guide gets sharper with every pass. By essay 15, the guide should be a document worth publishing on its own — a record of what it takes to teach a machine to sound like a specific human being.

That training process is also book material. The corrections themselves — the moments where the AI defaults to slop and gets caught — belong in the process track.

---

## The Title

Working title: **Small Batch Apps**

Subtitle candidates:
- *Building Software That Doesn't Scale*
- *Software for Two, Built by One (and an AI)*
- *A Manifesto in Code*
- *On Building Software That Starts Small and Grows Sideways*

---

## Word Count Estimate

~15 essays × ~2,000 words = ~30,000 words. Short book. More like *Spiral* in length than *Revolution*. Dense, each essay earning its place. Not a singleone word more.
