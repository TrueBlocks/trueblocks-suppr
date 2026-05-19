# Recommendation Engine

This chapter specifies the recommendation engine — the scoring logic that answers "where should we eat tonight?" All computation happens server-side. The frontend renders results; it does not compute scores.

---

## The Four Modes

	Each mode is a distinct query/scoring strategy, not four variations of one algorithm.

| Mode | Question It Answers | Returns |
|------|--------------------|---------| 
| **Tonight** | "Where should we eat?" | Ranked list, top result emphasized as THE answer |
| **Bucket List** | "What haven't we tried that's supposedly great?" | Unvisited award-winners |
| **Revisit** | "What did we love but haven't been to in a while?" | Highly-rated, overdue |
| **Explore** | "What cuisines/neighborhoods are we missing?" | Underexplored areas with strong signals |

---

## Mode A: "Tonight" (The Main Event)

	User optionally provides: occasion, cuisine, price, byob, mood. The engine scores every eligible restaurant and returns a ranked list (configurable `result_count`, default 5). The UI emphasizes the #1 result as "the answer" — prominently displayed above the others. The ideal is one-tap-one-answer: open the app, tap Tonight, get a restaurant. The remaining results are visible but secondary ("or if not that...").

### Eligibility Filter (eliminates before scoring)

- Status must be `open`
- If cuisine specified, must match
- If price specified, must be ≤ specified
- If byob specified, must match
- Not soft-deleted

### Scoring Formula

	```
	score = quality_signal
	      + visit_affinity
	      - recency_penalty
	      + exploration_bonus
	      + occasion_match
	      + turn_bonus
	      + friend_signal
	      + jitter
	```

### Scoring Components

| Component | Range | Calculation |
|-----------|-------|-------------|
| **quality_signal** | 0–40 | Each 50 Best appearance = 5 pts, decayed by age: `5 × (1 / (current_year - award_year + 1))`. A 2026 award = 5 pts, a 2020 award = 0.83 pts. Check Please appearance = 3 pts flat. Max capped at 40. |
| **visit_affinity** | -10 to +20 | If visited: `avg_rating × 4` (5-star = 20, 2-star = 8). Rated 1-2 stars becomes negative: `(rating - 3) × 5`. Never visited = 0 (neutral). |
| **recency_penalty** | 0 to -15 | Visited in last 2 weeks = -15. Last month = -10. Last 3 months = -5. Over 3 months ago = 0. Never visited = 0. Prevents recommending where you just went. Decay is rating-aware: 5-star restaurants decay at half rate (a 5-star visited 2 weeks ago = -7 instead of -15). The logic: places you loved should resurface sooner. |
| **exploration_bonus** | 0 to +15 | Never visited + has quality signals = +15. Never visited + no quality signals = +5. Already visited = 0. Encourages trying new places. |
| **occasion_match** | 0 to +10 | Tags include requested occasion/mood = +10. Partial match (e.g., "romantic" tag when "date-night" occasion) = +5. No match = 0. |
| **turn_bonus** | 0 to +20 | If tit-for-tat is enabled and it's this user's turn to pick: their personal ratings count double in `visit_affinity` (effectively: `avg_rating × 8` instead of `× 4` for restaurants they've rated). Additionally, restaurants they've tagged or favorited get +10. The effect: the list reorders itself around the picker's preferences. See Preferences section. |
| **friend_signal** | 0 to +10 | If a federated peer recommended this restaurant, +10. Configurable. See Preferences section. |
| **distance_penalty** | 0 to -10 | If home_lat/home_lng are configured: penalizes restaurants far from home. Within 2 miles = 0. 2–5 miles = -3. 5–10 miles = -7. Over 10 miles = -10. Configurable radius threshold. Disabled (0) if no home location set. |
| **jitter** | -3 to +3 | Random per-request. Prevents identical results on repeated queries. |

	**Total range**: roughly -38 to +118. Returned sorted descending, count set by `result_count` (default 5).

### One-Line Reason Generation

	Each result includes a human-readable reason. The engine picks the dominant scoring factor:

- "Award-winning, you haven't tried it yet" (high quality_signal + exploration_bonus)
- "You loved it 4 months ago" (high visit_affinity + low recency_penalty)
- "Perfect for date night, highly rated" (occasion_match + quality_signal)
- "BYOB gem you haven't been to" (exploration_bonus + tag match)
- "Jay & Meriam's friends recommended it" (friend_signal dominated)
- "Your turn to pick — you tagged this one" (turn_bonus dominated)

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

## Preferences & Configuration

	The recommendation engine is configurable. Both users must agree on configuration changes — no unilateral algorithm tweaks. Preferences are stored in a `RecommendConfig` table (or as a JSON document in the existing config), shared between both users.

### Configurable Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `tit_for_tat_enabled` | true | Alternate whose turn it is to pick |
| `turn_bonus_weight` | 10 | Points added when it's your turn (0 = disabled) |
| `friend_signal_enabled` | true | Include federated peer recommendations in scoring |
| `friend_signal_weight` | 10 | Points added for friend-recommended restaurants |
| `recency_window_days` | 14 / 30 / 90 | The three recency thresholds |
| `exploration_weight` | 15 | Max points for never-visited places |
| `quality_decay_rate` | 1.0 | Multiplier for award age decay (higher = more decay) |
| `jitter_range` | 3 | Random ±N points per request |
| `result_count` | 5 | How many recommendations to return (UI emphasizes #1) |
| `distance_enabled` | true | Include distance penalty in scoring |
| `distance_radius_miles` | 10 | Max radius before full penalty applies |

### Tit-for-Tat Logic

	When enabled, the system tracks whose turn it is to pick:
- After a visit is logged, the *other* user gets "next pick" status
- The user whose turn it is gets their ratings doubled in visit_affinity AND +10 to their tagged/favorited restaurants
- The effect: "the list reorders itself around her preferences, not mine" — the picker's taste dominates the ranking
- The UI displays whose turn it is: a subtle text line ("Meriam's pick" or "Your pick")
- Either user can waive their turn ("you pick tonight") — tap the turn indicator
- Turn state is stored in a simple counter: `last_picker` in the config

### Mutual Consent

	Configuration changes require both users to confirm. The mechanism:
	1. One user proposes a change via the settings UI
	2. The other user sees a pending change notification
	3. Change takes effect only when both acknowledge

	For a 2-user app, this is simple: a `pending_config` field that becomes `active_config` when both users have seen it.

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

---

## Implementation Notes

- All four modes are **server-side** — the Go API server computes scores and returns results. No scoring in the Wails app or PWA.
- Scoring coefficients are **named constants** in Go, initialized from the config table — tunable as usage reveals what feels right.
- The "reason" string is generated by a function that examines which scoring component dominated.
- Results include full restaurant data (name, cuisine, neighborhood, price, etc.) plus the score and reason. The frontend just renders cards.
