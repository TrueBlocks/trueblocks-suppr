# Article Planner

This document organizes the article series, defines the publication arc, and tracks the status of each piece. Articles are drafted during implementation phases and polished between phases.

---

## The Series: "Small Batch Apps"

A 5-part series telling the story of building suppr — from philosophy to working software to peer-to-peer federation. Each article stands alone but they build on each other.

### Audience

Software developers and technically curious people who are tired of platforms. People who've thought "I could build something better for just me" but haven't. People who build side projects. People who care about software craft.

### Publication

TBD — personal blog, dev.to, or both. The articles should work as standalone blog posts (1500–2500 words each) and as a collected series.

### Voice

First person, conversational, opinionated. Technical details included but explained — a senior developer should nod along, a curious non-developer should follow the argument. No jargon without context. Show the code, but only when it makes the point better than prose.

---

## Article 1: "The Problem with Yelp (and Every Restaurant App)"

**Status**: Draft complete

### Core Argument

Every restaurant recommendation platform is broken because the platform's incentives are misaligned with yours. Yelp sells ads to restaurants and data about you. Google wants you to stay in Google Maps. The Infatuation wants traffic. None of them are trying to answer the question you're actually asking: "Where should *we* eat tonight?"

### Structure

1. **The Saturday Night Problem** — You and your partner, 5pm, hungry, staring at phones. Open Yelp. Sort by rating. Every result has 4.2 stars. The reviews are either fake ("Amazing!! 5 stars!!"), vindictive ("Waited 10 minutes, 1 star"), or irrelevant (a tourist rating a cheesesteak place). You give up and go to the same place you always go.

2. **Why Platforms Fail at Recommendations** — The aggregation problem: averaging thousands of strangers' opinions produces mush. The incentive problem: platforms sell access to you, not recommendations for you. The cold start problem: a new restaurant with 3 reviews competes against an institution with 3,000. The gaming problem: businesses that optimize for Yelp aren't optimizing for food.

3. **What You Actually Want** — A recommendation from someone who knows your taste, knows the city, and has no financial incentive. Your friend who says "trust me, get the lamb shoulder." That's worth more than 10,000 anonymous reviews — and you already know it, because that's how you actually pick restaurants when the stakes are high.

4. **The Missing Category** — Software built for two people. Not a platform. Not "social." Not "community-powered." Just you and the person you eat dinner with, keeping track of where you've been, what you loved, and where you should go next. Software that knows your taste because it IS your taste — your data, your history, your preferences, nobody else's.

5. **A Clue** — Introduce the series concept. In the next articles, we'll build this thing. A restaurant app for a couple. And then we'll ask: what if software always started this small?

### Key Lines to Hit

- "The best restaurant recommendation you've ever received came from a person, not a platform."
- "Yelp has 4 billion reviews and can't tell me where to eat tonight."
- "The problem isn't the algorithm. The problem is the audience."
- "What if software started at two and grew sideways?"

### Research / Examples

- Specific Yelp gaming examples (well-documented)
- The "3.5 star restaurant" problem — why mid-rated places are often the best
- Philadelphia-specific: Philly Mag 50 Best as a curated alternative (the data we already have)
- Personal anecdote: a specific restaurant discovery that came from a friend, not an app

---

## Article 2: "Small Batch Apps: Software for Two"

**Status**: Not started
**Target length**: 2000–2500 words
**Phase**: Can write now, but benefits from Phase 1 being done (concrete examples)

### Core Argument

Software should start at the smallest viable size. For suppr, that's two people — a couple who eats dinner together. The "small batch" metaphor (craft beer, artisan bread, small-run prints) applies to software: made with care, valued for quality over quantity, personal, and not trying to dominate the market.

### Structure

1. **The Metaphor** — What "small batch" means in manufacturing and why it maps to software. The craft beer revolution didn't try to replace Budweiser — it created a different category. Small batch apps don't try to replace Yelp.

2. **The Growth Model** — The 5-stage progression: Solo → Couple → Mini-Node → Federated Pairs → Community. Each stage is a complete, useful product — not a stepping stone to the "real" thing.

3. **The Unit is the Relationship** — Why "two" is the right starting size, not "one." Software for one person is a notebook. Software for two people requires shared state, shared decisions, different perspectives on the same data. That's where the interesting design problems live.

4. **What This Means Technically** — Brief overview of suppr's architecture. A Go API server on a $6 VPS, a desktop app, a PWA for phones. SQLite. No infrastructure drama. The whole thing could run on a Raspberry Pi.

5. **Data Stays Home** — Each couple owns their data. No export needed because there's nothing to export from — the database IS yours. Contrast with platform lock-in.

6. **The Five Principles** — Enumerate them with examples from suppr.

### Key Lines to Hit

- "Small batch apps are software built for the smallest viable audience."
- "The smallest possible network is two nodes and one edge."
- "Growth is lateral, not vertical. Couples connect to couples. No one becomes 'the server.'"
- "The software is the product, not the data."

---

## Article 3: "Building suppr: A Restaurant App in Go and React"

**Status**: Not started — write during/after Phase 1-2
**Target length**: 2000–2500 words
**Phase**: Write after Phase 2 (working desktop app)

### Core Argument

Building a personal app from scratch in 2026 is easier than you think — and more rewarding than any platform. This article walks through the key technical decisions and shows what the code actually looks like.

### Structure

1. **The Stack** — Go + Wails + React + Mantine + SQLite. Why each choice, what the alternatives were, why we didn't pick them.

2. **The Database** — Schema design. Importing 276 restaurants from 9 years of Philly Mag 50 Best lists. The migration tool. Data quality gaps and enrichment strategy.

3. **The Novel Part** — The Wails app as HTTP client. Why the Go backend delegates to a remote API instead of a local database. The `pkg/client/` pattern. Code samples.

4. **The PWA** — Why we skipped the App Store. The camera trick. Deploying via siteman.

5. **What We Learned** — Surprises, mistakes, things that were easier or harder than expected. (Fill from build log.)

### Key Lines to Hit

- "The best architecture for two users is the simplest one that works."
- "Every line of Go on the backend is a line of JavaScript you don't have to write."

---

## Article 4: "A Recommendation Engine for Two"

**Status**: Not started — write during/after Phase 3
**Target length**: 1500–2000 words
**Phase**: Write after Phase 3 (recommendations working)

### Core Argument

You don't need machine learning to build a good recommendation engine. When your dataset is small and your users are known, simple scoring beats neural networks. And the recommendations are better because they're personal — the algorithm IS your taste.

### Structure

1. **The Question** — "Where should we eat tonight?" broken down into subproblems: quality signal, personal history, mood, recency, exploration.

2. **The Formula** — Walk through the scoring components with real examples from the data. "Zahav gets +15 for quality (5-year 50 Best), +20 for visit affinity (you rated it 5 stars), -15 for recency (you went last week), net +20."

3. **Cold Start** — What happens before you've logged any visits. The engine falls back to award data — which is actually a great cold start because it's curated expert opinion.

4. **The Four Modes** — Tonight, Bucket List, Revisit, Explore. Each solves a different version of the question.

5. **Why This Beats Yelp** — The recommendation knows YOUR history, YOUR preferences, YOUR partner's opinions. It's not averaging strangers. It's not selling you anything.

### Key Lines to Hit

- "100 lines of Go and five scoring factors. That's the whole engine."
- "The best recommendation algorithm is one that knows you had the lamb shoulder at Zahav last month and loved it."

---

## Article 5: "Peer-to-Peer Dining"

**Status**: Not started — write during/after Phase 6
**Target length**: 2000–2500 words
**Phase**: Write after Phase 6 (federation working) — or as a vision piece before

### Core Argument

What if restaurant recommendations flowed between friends, not through platforms? A federation protocol for sharing discoveries without centralizing data. Push-based, trust-explicit, and designed for small networks.

### Structure

1. **The Vision** — Two couples, two databases, two servers. They don't merge — they share discoveries. "We loved this place, you should try it."

2. **The Protocol** — What a recommendation message looks like. JSON, signed, pushed. What flows (ratings, discoveries) and what stays home (spend, schedule, private notes).

3. **Trust** — Why explicit, small-network trust beats crowd-sourced reputation. The QR code pairing flow. No central directory.

4. **The Desktop Becomes the Server** — The long game: each couple's laptop IS their server. No VPS needed. The app peers directly.

5. **What This Means Beyond Dining** — The pattern generalizes. Book recommendations. Hiking trails. Travel itineraries. Any domain where personal, trusted recommendations beat the crowd.

### Key Lines to Hit

- "Federation is just a fancy word for 'my friends and I can share things without asking a corporation's permission.'"
- "The network doesn't need a hub. Couples connect to couples. No one accumulates power."

---

## Standalone Articles (Unscheduled)

These can be written anytime when the mood strikes or when relevant work is done:

| Title | When | Notes |
|-------|------|-------|
| "Scraping the Wayback Machine for a Restaurant Database" | After Phase 1 | The data import story, data archaeology |
| "Wails Apps as a Platform" | After Phase 2 | How the mono-repo pattern evolved across 5 apps |
| "A Recommendation Engine in 100 Lines of Go" | After Phase 3 | Technical deep-dive, show the actual code |
| "SQLite as a Personal Data Platform" | Anytime | Why SQLite is the right DB for personal software |
| "The Curl + Cache Preview Pattern" | After Phase 5 | General-purpose embedded preview system |

---

## Writing Process

1. **Capture during implementation** — Use `note <topic>` to add build-log entries as decisions happen. These are raw material.

2. **Draft during the phase** — While the decisions are fresh, write a rough draft. Don't polish. Get the argument and structure down.

3. **Polish between phases** — During natural pauses (waiting for review, between phases), shape drafts into finished articles.

4. **The build log is the bridge** — `articles/build-log.md` accumulates timestamped notes. Each article draws from these notes. The log is private; the articles are public.

---

## Publication Schedule (Aspirational)

| # | Article | Write When | Publish When |
|---|---------|------------|-------------|
| 1 | The Problem with Yelp | Now | Before implementation starts |
| 2 | Small Batch Apps: Software for Two | Now / Phase 1 | After Phase 1 |
| 3 | Building suppr | Phase 1–2 | After Phase 2 |
| 4 | A Recommendation Engine for Two | Phase 3 | After Phase 3 |
| 5 | Peer-to-Peer Dining | Phase 6 or as vision piece | After Phase 6 |

Article 1 can be written right now — it needs no code, no implementation, just the argument. It sets up the series and gives you something to publish while building.

---

*This document is updated as articles progress. Status field on each article tracks: Not started → Drafting → Draft complete → Polished → Published.*
