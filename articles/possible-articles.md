# Possible Articles

A running list of article ideas emerging from the suppr build and the "small batch apps" thesis.

---

## Article Series: Small Batch Apps

### 1. "Small Batch Apps: Software for Two"
The core thesis. Why software should start at the smallest viable size and grow laterally through peer-to-peer federation, not centralization. Use suppr as the concrete example — a restaurant app built for a couple, not a platform.

### 2. "The Problem with Yelp (and Every Restaurant App)"
Why every restaurant recommendation platform sucks: review gaming, algorithmic manipulation, data harvesting, one-size-fits-all recommendations from strangers. The fundamental misalignment between platform incentives and user needs.

### 3. "Building suppr: Technical Decisions for a Two-Person App"
The architecture piece. Why we chose Wails + Go API server + PWA. How the same patterns we use for desktop publishing tools apply to a restaurant app. The decision to put the database on Digital Ocean, not in the app.

### 4. "Your Friend's Wife's Opinion > 10,000 Yelp Reviews"
Trust in small networks. Why a recommendation from someone you know who shares your taste is fundamentally different from crowd-sourced reviews. The math of trust decay as network size increases.

### 5. "Peer-to-Peer Dining: A Federation Protocol for Restaurants"
Technical deep-dive on how two couples' suppr instances could share recommendations without a central server. What a "recommendation message" looks like. How conflicting ratings work. The trust model.

### 6. "The App on the Table"
The wild vision piece. Stage 5 of small batch apps — voluntary presence broadcasting at restaurants. Strangers who share your taste graph, sitting ten feet away. What happens when software creates serendipity instead of surveillance.

### 7. "Against Scale: A Manifesto in Code"
The philosophical piece. Why "doesn't scale" is a feature, not a bug. The relationship between software scale and human connection. How the obsession with growth has ruined the tools we use.

---

## Standalone Articles

### "Scraping the Wayback Machine for a Restaurant Database"
The data import story. How we built a database of 276 Philly restaurants from 9 years of Philly Mag 50 Best lists, using Wayback Machine captures and Python scrapers. Data provenance and the archaeology of web content.

### "Wails Apps as a Platform: Building Desktop Apps That Share a Pattern"
How the trueblocks-art mono-repo has evolved a reusable pattern for Wails desktop apps (works, acrylic, poetry, siteman, suppr). What's shared, what's per-app, and how each new app improves the pattern for the next.

### "A Recommendation Engine in 100 Lines of Go"
The scoring formula for suppr's "Where should we eat tonight?" feature. Quality signals, visit affinity, recency penalty, exploration bonus. How simple math beats machine learning when your dataset is small and your taste is specific.

### "SQLite as a Personal Data Platform"
Why SQLite is the right database for personal software. No daemon, no admin, copy-one-file backups, WAL mode for concurrent access, WASM for the browser. How suppr, works, and the rest of the trueblocks-art apps all run on SQLite.

### "The Curl + Cache Preview Pattern"
How suppr previews restaurant websites by fetching, cleaning, and caching them locally — the same pattern works uses for document previews. A general-purpose approach to embedding third-party web content without iframe restrictions.

---

*This is a living document. New article ideas added as they emerge during development.*
