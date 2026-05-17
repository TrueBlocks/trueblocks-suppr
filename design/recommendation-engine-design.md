# suppr Recommendation Engine Design

This document captures the complete recommendation engine logic for suppr. All scoring happens server-side on the Digital Ocean Go API server.

---

## The Four Modes

Each mode is a distinct query/scoring strategy, not four variations of one algorithm.

---

## Mode A: "Tonight" (The Main Event)

User optionally provides: occasion, cuisine, price, byob, mood. The engine scores every eligible restaurant and returns the top 5.

### Eligibility Filter (eliminates before scoring)

- Status must be `open`
- If cuisine specified, must match
- If price specified, must match
- If byob specified, must match
- Not soft-deleted

### Scoring Formula

```
score = quality_signal
      + visit_affinity
      - recency_penalty
      + exploration_bonus
      + occasion_match
```

### Scoring Components

| Component | Range | Calculation |
|-----------|-------|-------------|
| **quality_signal** | 0–40 | Each 50 Best appearance = 5 pts, decayed by age: `5 × (1 / (current_year - award_year + 1))`. A 2026 award = 5 pts, a 2020 award = 0.83 pts. Check Please appearance = 3 pts flat. Max capped at 40. |
| **visit_affinity** | -10 to +20 | If visited: `avg_rating × 4` (5-star = 20, 2-star = 8). Rated 1-2 stars becomes negative: `(rating - 3) × 5`. Never visited = 0 (neutral). |
| **recency_penalty** | 0 to -15 | Visited in last 2 weeks = -15. Last month = -10. Last 3 months = -5. Over 3 months ago = 0. Never visited = 0. Prevents recommending where you just went. |
| **exploration_bonus** | 0 to +15 | Never visited + has quality signals = +15. Never visited + no quality signals = +5. Already visited = 0. Encourages trying new places. |
| **occasion_match** | 0 to +10 | Tags include requested occasion/mood = +10. Partial match (e.g., "romantic" tag when "date-night" occasion) = +5. No match = 0. |

**Total range**: roughly -25 to +85. Top 5 returned, sorted descending.

### One-Line Reason Generation

Each result includes a human-readable reason. The engine picks the dominant scoring factor:

- "Award-winning, you haven't tried it yet" (high quality_signal + exploration_bonus)
- "You loved it 4 months ago" (high visit_affinity + low recency_penalty)
- "Perfect for date night, highly rated" (occasion_match + quality_signal)
- "BYOB gem you haven't been to" (exploration_bonus + tag match)

### Randomization

To avoid returning the exact same 5 every time, add a small random jitter (±3 pts) to the final score. This means the top recommendations shuffle slightly each request.

---

## Mode B: "Bucket List"

No scoring formula needed. Pure SQL query:

```sql
SELECT r.*, COUNT(a.awardID) as award_count
FROM Restaurants r
JOIN Awards a ON a.restaurantID = r.restaurantID
LEFT JOIN Visits v ON v.restaurantID = r.restaurantID
WHERE v.visitID IS NULL
  AND r.status = 'open'
  AND (r.attributes IS NULL OR r.attributes NOT LIKE '%deleted%')
GROUP BY r.restaurantID
ORDER BY award_count DESC, r.name ASC
```

Returns all unvisited restaurants with at least one award, sorted by award count. Multi-year 50 Best appearances rank highest.

---

## Mode C: "Revisit"

```sql
SELECT r.*,
       MAX(v.date) as last_visit,
       AVG(v.rating) as avg_rating,
       COUNT(v.visitID) as visit_count
FROM Restaurants r
JOIN Visits v ON v.restaurantID = r.restaurantID
WHERE v.userID = ?
  AND r.status = 'open'
  AND (r.attributes IS NULL OR r.attributes NOT LIKE '%deleted%')
GROUP BY r.restaurantID
HAVING avg_rating >= 4
   AND MAX(v.date) < date('now', '-3 months')
ORDER BY avg_rating DESC, last_visit ASC
```

Restaurants rated 4+ stars on average but not visited in 3+ months. Sorted by rating (highest first), then by staleness (longest since last visit first).

---

## Mode D: "Explore"

The most interesting mode algorithmically. Finds cuisines or neighborhoods you rarely visit but that have strong quality signals.

### Algorithm

**Step 1** — Count your visits by cuisine:
```sql
SELECT r.cuisine, COUNT(*) as visit_count
FROM Visits v JOIN Restaurants r ON v.restaurantID = r.restaurantID
WHERE v.userID = ?
GROUP BY r.cuisine
```

**Step 2** — Count award-winning restaurants by cuisine:
```sql
SELECT r.cuisine, COUNT(DISTINCT r.restaurantID) as awarded_count
FROM Awards a JOIN Restaurants r ON a.restaurantID = r.restaurantID
WHERE r.status = 'open'
GROUP BY r.cuisine
```

**Step 3** — Find cuisines where `awarded_count` is high but `visit_count` is low (or zero). Score: `awarded_count / (visit_count + 1)`. High score = "lots of great places you haven't explored."

**Step 4** — From those underexplored cuisines, return the top award-winning restaurants you haven't visited.

Same logic applies to neighborhoods as a secondary dimension.

---

## Implementation Notes

- All four modes are **server-side** — the Go API server computes scores and returns results. No scoring in the Wails app or PWA.
- Scoring coefficients (5 pts per award, decay rate, recency thresholds) are **named constants** in Go, not hardcoded inline — tunable as usage reveals what feels right.
- The "reason" string is generated by a function that examines which scoring component dominated.
- Results include full restaurant data (name, cuisine, neighborhood, price, etc.) plus the score and reason. The frontend just renders cards.

---

## Cold Start Behavior

With no visits logged yet, the engine degrades gracefully:

| Mode | Cold Start Behavior |
|------|-------------------|
| **Tonight** | Returns top award-winners (quality_signal dominates, everything else is 0) |
| **Bucket List** | Works perfectly (no visits = everything is on the bucket list) |
| **Revisit** | Returns empty (no visits to revisit) |
| **Explore** | Returns the most-awarded cuisines overall |

As visits are logged, recommendations become more personalized.
