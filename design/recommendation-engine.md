# Check, Please! Recommendation Engine

## What We Have

| Asset | Count | Notes |
|-------|-------|-------|
| Restaurants | 276 | All with websites, cuisine, neighborhood |
| Cuisines | 76 | Top: Mexican (7), American (7), Italian (5), French (4) |
| Neighborhoods | 18 | Across Philly metro area |
| Awards (Philly Mag 50 Best) | 455 | 9 years: 2015–2024, 2026 |
| Check Please appearances | 120 | Across 41 episodes, 6 seasons |
| Overlap (award + CP) | 40 | Restaurants featured in both sources |

## What We're Missing

To go from a directory to a recommendation engine, we need three things:

### 1. Richer Restaurant Attributes

Right now each restaurant has cuisine and neighborhood. That's not enough to match mood, occasion, or preference. We need:

| Attribute | Why It Matters | How to Get It |
|-----------|---------------|---------------|
| **Price range** (1-4 $signs) | "Somewhere nice but not crazy" | Manual entry or scrape from Yelp/Google |
| **Vibe tags** (romantic, lively, chill, trendy) | Date night vs casual Tuesday | Manual tagging, ~5 min total |
| **Occasion fit** (date night, group, solo, brunch, celebration) | The core question: "what's the occasion?" | Manual tagging |
| **BYOB** | Huge in Philly — saves $50+, changes the calculus | Manual or scrape |
| **Outdoor seating** | Seasonal preference | Manual or scrape |
| **Reservation required** | Spontaneous vs planned | Manual or scrape |
| **Lat/lng** | Distance from home, "what's near X?" | Geocode from address |
| **Operating status** | Don't recommend closed restaurants | Periodic check |

**Recommendation:** Start with **price range**, **vibe tags**, and **BYOB** — those three cover 80% of the "where should we go?" decision. Add the rest incrementally.

### 2. Your Visit History & Opinions

The engine needs to know where you've been and what you thought:

```
visits table:
  id, restaurant_id, date, rating (1-5), liked (bool), notes, occasion
```

Key questions a visit log answers:
- **What did you love?** → Recommend similar places
- **What was meh?** → Avoid recommending similar places
- **Where haven't you been?** → Surface unexplored award-winners
- **What's overdue for a revisit?** → "You loved Zahav 8 months ago"
- **What patterns emerge?** → "You rate Italian higher than average"

**Cold start:** You could seed this quickly. Even a simple pass through the 276 restaurants marking "been there" / "want to try" / "not interested" gives the engine a foundation.

### 3. Preference Profile

Rather than asking you to fill out a questionnaire, the engine should **learn** from your visit log. But some explicit preferences help:

- Home location (for distance calculations)
- Default radius ("how far are we willing to drive?")
- Dietary constraints
- Hard no's (specific cuisines or neighborhoods you'd skip)

## Recommendation Strategies

### Strategy A: "Where Should We Eat Tonight?"

The main use case. User provides optional filters, engine returns a ranked shortlist.

**Inputs:** occasion (optional), cuisine (optional), neighborhood (optional), price (optional), mood (optional)

**Scoring formula:**
```
score = award_rank_score          # proven quality (decayed by year, already built)
      + visit_affinity            # you liked similar places
      - familiarity_penalty       # you just went there recently
      + exploration_bonus         # highly rated, never visited
      + occasion_match            # fits tonight's vibe
      + proximity_bonus           # closer to home
```

The engine returns 3-5 suggestions with a one-line reason: *"Award-winning BYOB you haven't tried, 10 min away"*

### Strategy B: "The Bucket List"

Surface the best restaurants you haven't visited yet, sorted by quality signal:
- Multi-year 50 Best appearances you've never been to
- CP-featured restaurants you haven't tried
- New (2024/2026) award winners

### Strategy C: "Return To"

Restaurants you rated 4+ stars but haven't visited in 3+ months. Simple query, high value.

### Strategy D: "Explore Something New"

When you're in a rut. Engine picks a cuisine or neighborhood you rarely visit but that has strong quality signals.

## Architecture Options

### Option 1: CLI-Only (Simplest)
Extend the existing `checkplease` CLI tool:
```
checkplease tonight                    # recommend for tonight
checkplease tonight --byob --italian   # with filters
checkplease log 42 --rating 4          # log a visit to restaurant #42
checkplease bucket                     # show bucket list
checkplease revisit                    # overdue revisits
```
Pros: Fast to build, no infrastructure, fits your workflow.

### Option 2: Enhanced Static Site
Add visit logging and recommendations to the web UI. Use localStorage for visit data (no backend needed).
Pros: Visual, shareable with wife. Cons: Data stuck in browser, no sync.

### Option 3: Static Site + Small JSON Backend
Site stays static but reads/writes a `visits.json` file. A tiny Python HTTP server handles the API locally.
Pros: Best of both. Cons: Must run server.

### Option 4: Static Site + SQLite via WASM
Use sql.js (SQLite compiled to WebAssembly) to run the full database in the browser. Export/import DB file for persistence.
Pros: Full SQL power in browser, no server. Cons: More complex build.

## Suggested Phasing

### Phase 1: Foundation (Data Enrichment)
- Add `price_range` (1-4) column to restaurants
- Add `tags` table (restaurant_id, tag) for vibe/feature tags (BYOB, outdoor, romantic, etc.)
- Add `visits` table (restaurant_id, date, rating, notes, occasion)
- Geocode addresses → add lat/lng
- Do a quick pass tagging price range and top tags for all 276 restaurants

### Phase 2: Basic Recommendations (CLI)
- `checkplease tonight` — weighted random from unvisited award-winners
- `checkplease log` — log visits from terminal
- `checkplease bucket` — unvisited, sorted by award score
- `checkplease revisit` — loved but haven't been recently

### Phase 3: Smart Recommendations
- Implement the full scoring formula
- Learn cuisine/neighborhood preferences from visit history
- Occasion-based filtering
- "Explain why" for each recommendation

### Phase 4: Web UI
- Add recommendation panel to the static site
- Visit logging in the browser
- Map view with markers
- "Tonight" button with swipe-style cards

## Open Questions

1. **How many of these 276 have you actually been to?** (Determines cold-start strategy)
2. **How far are you willing to drive?** (Philly proper only, or suburbs too?)
3. **Are there cuisines or neighborhoods you'd always skip?**
4. **Is your wife going to use this too, or just you picking?**
5. **Do you care about price, or is it not a factor?**
6. **CLI first, or jump straight to web UI?**
