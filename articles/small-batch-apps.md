# Small Batch Apps

A design philosophy and exploration document. This file tracks ideas, principles, and observations as we build `suppr` — with an eye toward a broader thesis about how software should work.

---

## The Core Idea

**Small batch apps** are software built for the smallest viable audience — starting with two people — that can organically grow through peer-to-peer federation, never through centralization.

The antithesis of the "server-based takes over the world" model of modern computing. No Yelp. No Google Reviews. No algorithmic feed deciding what you see. No data harvesting. No platform lock-in.

Instead: software that starts as intimate as a conversation between two people at a dinner table.

---

## The Growth Model

```
Stage 0: Solo
  You alone. A personal database of restaurants, ratings, notes.
  Just a better notebook.

Stage 1: Couple (suppr starts here)
  You + Meriam. Shared database. Shared ratings. Shared photos.
  "Where should WE eat tonight?" — not "where should I eat."
  The smallest possible network: two nodes, one edge.

Stage 2: Mini-Node
  A friend starts their own suppr instance with their partner.
  Two couples, two databases, two servers.
  They don't share a database — they share discoveries.
  "We loved this place, you should try it."

Stage 3: Mini-Couple (Federated Pairs)
  Your couple joins up with another couple.
  Not by merging databases — by establishing a peer link.
  You can see their ratings alongside yours.
  Recommendations can factor in "our friends loved this."
  Trust is explicit: you chose to connect with them.

Stage 4: Dining Group
  Multiple couples form a group. 6-8 people.
  Group recommendations. Group voting on where to go.
  Coordinated reservations.
  Still no central server — each couple runs their own node.

Stage 5: Community
  Groups discover each other. A neighborhood dining network.
  You show up at a restaurant and your phone shows other
  "players" at nearby tables — not by surveillance, but by
  voluntary presence broadcasting.
  Strangers who share your taste graph, sitting ten feet away.
  The app on your table is a signal: "I'm one of us."
```

---

## Principles

### 1. The Unit is the Relationship, Not the Individual

Yelp is built for individuals reviewing restaurants for strangers. suppr is built for couples deciding together. The fundamental data model is shared — not "my ratings" but "our ratings."

### 2. Data Stays Home

Each node owns its data. Federation means sharing recommendations, not replicating databases. When you disconnect from a group, your data stays yours. No export needed. No "download your data" request to a corporation.

### 3. Trust is Explicit and Small

You don't trust "the crowd." You trust specific people you know. A recommendation from your best friend's wife who shares your taste in food is worth more than 10,000 anonymous Yelp reviews.

### 4. Growth is Lateral, Not Vertical

The network doesn't need a hub. Couples connect to couples. Groups connect to groups. No one becomes "the server." No one accumulates power. The topology is a graph, not a tree.

### 5. The Software is the Product, Not the Data

In the platform model, the software is free because the data is the product (sold to advertisers, mined for insights). In the small batch model, the software IS the product. It's self-hosted. There's nothing to mine because there's no central place to mine it from.

---

## Why "Small Batch"

The metaphor is deliberate. Small batch manufacturing (craft beer, artisan bread, small-run prints) is:
- Made with care, not at scale
- Valued for quality over quantity
- Personal — the maker and consumer are close
- Not trying to dominate the market
- Often better than the mass-produced version

Small batch apps follow the same pattern:
- Built for a specific, small audience
- Optimized for depth of experience, not breadth of reach
- The builder is often one of the users
- Not trying to "scale" — the small size IS the feature
- Often better for the people who use them than any platform alternative

---

## Technical Implications for suppr

### Stage 1 (Current Build)

- Central API server on DO is a pragmatic choice, not an ideological one
- The server serves two users — it's not a "platform," it's shared infrastructure for a couple
- All data belongs to the couple, stored in a single SQLite file they can download anytime

### Stage 2-3 (Future: Federation)

When another couple sets up their own suppr instance, federation would mean:
- **Discovery sharing**: "We went to X and loved it" becomes a message between nodes
- **Protocol, not platform**: A simple JSON-over-HTTPS API for sharing recommendations between nodes
- **Selective sharing**: You choose what to share (ratings, photos, visit history) and with whom
- **No central directory**: Nodes find each other through explicit introduction (QR code, shared link), not a registry

### Stage 4-5 (Future: Groups & Community)

- **Group formation**: A lightweight protocol for couples to form dining groups
- **Group recommendations**: "3 of 4 couples in our group loved this place"
- **Coordinated events**: "Let's all go to X on Saturday" — poll, vote, reserve
- **Presence**: Voluntary, opt-in, proximity-based — "I'm at this restaurant right now, app visible on table"

### The Server Question

The DO server is Stage 1 infrastructure. In a fully realized small batch architecture:
- Each couple runs their own server (could be a Raspberry Pi, a $5 VPS, or a phone acting as a server)
- Federation happens peer-to-peer between servers
- No server is more important than any other
- The Wails desktop app could eventually BE the server (Option B from our early architecture discussion comes back, but at the federation layer)

---

## Notes for the Article Series

### Working Title Ideas
- "Small Batch Apps: Software for Two"
- "The Smallest Network: Building Apps That Don't Scale"
- "Peer-to-Peer Dining: Why I Built a Restaurant App for My Wife and Me"
- "Against Platforms: A Manifesto in Code"

### Article Arc
1. **The Problem**: Why every restaurant app sucks (Yelp gaming, Google monopoly, algorithmic manipulation)
2. **The Thesis**: Software should start at the smallest viable size and grow laterally
3. **The Build**: How we built suppr — technical decisions, architecture, what worked
4. **The Federation**: How two couples can share recommendations without a platform
5. **The Vision**: What happens when small batch apps become a pattern, not just a project

### Key Tensions to Explore
- Convenience vs. sovereignty (platforms are easier; small batch requires effort)
- Scale vs. intimacy (Yelp has every restaurant; your friend has taste)
- Open vs. trusted (anonymous reviews vs. recommendations from people you know)
- Building vs. buying (the joy and cost of making your own tools)

---

*This document is a living notebook. Updated as ideas crystallize during the suppr build.*
