# Data Model

This chapter specifies every table, column, relationship, and constraint in the suppr database. The database is SQLite in WAL mode, stored as a single file. An AI implementing suppr should generate the schema exactly as described here.

---

## Schema Conventions

- **PascalCase** table names: `Restaurants`, `AwardSources`, `ListItems`
- **camelCase** for ID columns: `restaurantID`, `awardID`, `sourceID`
- **snake_case** for all other columns: `price_range`, `created_at`, `video_url`
- Every table has `created_at TEXT DEFAULT (datetime('now'))` and `modified_at TEXT DEFAULT (datetime('now'))`
- Foreign keys enforced: `PRAGMA foreign_keys = ON`
- IDs are `INTEGER PRIMARY KEY` (SQLite rowid alias)

---

## Attributes Pattern

Restaurants use a hybrid approach for boolean/flag-like properties:

- **Explicit columns** for fields that are filtered on, sorted by, or used in the recommendation engine: `status`, `price_range`, `byob`, `outdoor`, `reservations`
- **`attributes` TEXT column** (JSON array) for extensible flags that don't need structured queries: `["cash-only", "dog-friendly", "good-for-groups", "live-music"]`

This gives type-safe filtering on core fields while allowing indefinite extensibility without schema migrations.

---

## Tables

### Restaurants

The core table. One row per restaurant.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| restaurantID | INTEGER | PRIMARY KEY | Auto-increment |
| name | TEXT | NOT NULL | Restaurant name |
| address | TEXT | | Street address |
| city | TEXT | DEFAULT 'Philadelphia' | City |
| state | TEXT | DEFAULT 'PA' | State |
| zip | TEXT | | ZIP code |
| neighborhood | TEXT | | Philly neighborhood |
| cuisine | TEXT | | Primary cuisine type |
| website | TEXT | | Restaurant website URL |
| phone | TEXT | | Phone number |
| founder | TEXT | | Owner/founder name |
| chef | TEXT | | Head chef name |
| source | TEXT | | How we first learned about it |
| status | TEXT | DEFAULT 'open' | open, closed, moved, deleted |
| price_range | INTEGER | | 1–4 ($–$$$$) |
| byob | INTEGER | DEFAULT 0 | 1 = BYOB, 0 = full bar or N/A |
| outdoor | INTEGER | DEFAULT 0 | 1 = outdoor seating available |
| reservations | INTEGER | | 1 = takes reservations, 0 = walk-in only, NULL = unknown |
| latitude | REAL | | Latitude (from geocoding) |
| longitude | REAL | | Longitude (from geocoding) |
| attributes | TEXT | DEFAULT '[]' | JSON array of extensible flags |
| notes | TEXT | | Free-text notes |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### AwardSources

Award-granting organizations. 4 rows.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| sourceID | INTEGER | PRIMARY KEY | |
| name | TEXT | NOT NULL | e.g., "Philly Mag 50 Best" |
| description | TEXT | | What this source is |
| url | TEXT | | Source website |

Rows: Philly Mag, Michelin, James Beard, Check Please.

### AwardSourceUrls

Provenance: where each year's list was captured from. 9 rows.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| urlID | INTEGER | PRIMARY KEY | |
| sourceID | INTEGER | NOT NULL REFERENCES AwardSources(sourceID) | |
| year | INTEGER | NOT NULL | Which year's list |
| url | TEXT | NOT NULL | Wayback Machine capture URL |
| notes | TEXT | | |

### Awards

Restaurant ↔ award source ↔ year. ~455 rows.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| awardID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| sourceID | INTEGER | NOT NULL REFERENCES AwardSources(sourceID) | |
| year | INTEGER | NOT NULL | Year of the award |
| rank | INTEGER | | Position in the list (NULL if unranked) |
| category | TEXT | | Award category if applicable |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### Episodes

Check, Please! Philly appearances. One row per restaurant-per-episode. ~120 rows.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| episodeID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| season | INTEGER | NOT NULL | Season number (1–6) |
| episode | INTEGER | NOT NULL | Episode number within season |
| video_url | TEXT | | WHYY video URL |
| embed_url | TEXT | | YouTube embed URL if available |
| air_date | TEXT | | Original air date |
| segment_notes | TEXT | | Notes about the segment |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### Users

Exactly 2 rows. No registration flow. The unit of the app is the couple — but each person has their own row so the system can track whose preferences are whose (essential for tit-for-tat, for "her 4 means great" calibration awareness, and for independent ratings of the same restaurant).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| userID | INTEGER | PRIMARY KEY | |
| name | TEXT | NOT NULL | Display name |
| email | TEXT | NOT NULL UNIQUE | |
| api_key | TEXT | NOT NULL UNIQUE | For authentication |
| home_lat | REAL | | Home location (for distance calc) |
| home_lng | REAL | | |
| preferences | TEXT | DEFAULT '{}' | JSON: dietary restrictions, default radius, etc. |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### Visits

Visit log. Grows over time through app usage.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| visitID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| userID | INTEGER | NOT NULL REFERENCES Users(userID) | Who logged this visit |
| date | TEXT | NOT NULL | Visit date (YYYY-MM-DD) |
| rating | INTEGER | | 1–5 stars |
| would_go_back | INTEGER | | Boolean (1/0): "Would we go back?" — captures intent distinct from rating |
| occasion | TEXT | | date-night, casual, celebration, business, etc. |
| spend | REAL | | Total spend in dollars |
| notes | TEXT | | Free-text notes about the visit |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### Photos

Photo metadata. Files stored on filesystem.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| photoID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| visitID | INTEGER | REFERENCES Visits(visitID) | Optional link to a specific visit |
| userID | INTEGER | NOT NULL REFERENCES Users(userID) | Who uploaded |
| filename | TEXT | NOT NULL | Filename on disk |
| caption | TEXT | | Photo caption |
| taken_at | TEXT | | When the photo was taken |
| created_at | TEXT | DEFAULT (datetime('now')) | |

### Tags

Flexible tagging for restaurants.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| tagID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| tag | TEXT | NOT NULL | Tag value (e.g., "date-night", "byob-gem") |
| created_at | TEXT | DEFAULT (datetime('now')) | |

UNIQUE constraint on (restaurantID, tag) — no duplicate tags.

### Intel

News, tips, closings, openings. A living feed.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| intelID | INTEGER | PRIMARY KEY | |
| restaurantID | INTEGER | REFERENCES Restaurants(restaurantID) | NULL if not restaurant-specific |
| type | TEXT | NOT NULL | closing, opening, news, tip, menu-change, award |
| title | TEXT | NOT NULL | Short headline |
| body | TEXT | | Full details |
| source_url | TEXT | | Where we learned this |
| dismissed | INTEGER | DEFAULT 0 | 1 = user has acknowledged |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### Lists

Named custom lists (Date Night, BYOB Favorites, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| listID | INTEGER | PRIMARY KEY | |
| userID | INTEGER | NOT NULL REFERENCES Users(userID) | Owner |
| name | TEXT | NOT NULL | List name |
| description | TEXT | | What this list is for |
| created_at | TEXT | DEFAULT (datetime('now')) | |
| modified_at | TEXT | DEFAULT (datetime('now')) | |

### ListItems

List membership: list ↔ restaurant.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| listItemID | INTEGER | PRIMARY KEY | |
| listID | INTEGER | NOT NULL REFERENCES Lists(listID) ON DELETE CASCADE | |
| restaurantID | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | |
| position | INTEGER | | Sort order within the list |
| notes | TEXT | | Why it's on this list |
| created_at | TEXT | DEFAULT (datetime('now')) | |

UNIQUE constraint on (listID, restaurantID) — no duplicates.

### RecommendConfig

Shared configuration for the recommendation engine. One row.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| configID | INTEGER | PRIMARY KEY | Always 1 |
| config | TEXT | NOT NULL DEFAULT '{}' | JSON object with all configurable parameters |
| pending_config | TEXT | | Proposed changes awaiting mutual consent |
| last_picker | INTEGER | REFERENCES Users(userID) | Who picked last (for tit-for-tat) |
| modified_at | TEXT | DEFAULT (datetime('now')) | |
| confirmed_by | TEXT | DEFAULT '[]' | JSON array of userIDs who confirmed pending |

### RecommendOverrides

Tracks when users ignore a recommendation and what they chose instead. Over time, these overrides teach the engine about preferences that the scoring formula doesn't capture.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| overrideID | INTEGER | PRIMARY KEY | |
| userID | INTEGER | NOT NULL REFERENCES Users(userID) | Who overrode |
| recommended_id | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | What the engine suggested (#1) |
| chosen_id | INTEGER | NOT NULL REFERENCES Restaurants(restaurantID) | What they actually chose |
| reason | TEXT | | Why they overrode (optional free text) |
| mode | TEXT | NOT NULL | Which mode was active (tonight, bucket-list, revisit, explore) |
| filters | TEXT | DEFAULT '{}' | JSON: what filters were applied |
| created_at | TEXT | DEFAULT (datetime('now')) | |

The recommendation engine can query overrides to detect persistent biases: "they always pick BYOB over non-BYOB" or "they always pick Rittenhouse over other neighborhoods" — and adjust future scoring accordingly. This is Phase 5+ functionality: the table exists from the start but the learning logic is added later.

---

## Full-Text Search

An FTS5 virtual table for fast text search across restaurants and intel:

```sql
CREATE VIRTUAL TABLE RestaurantSearch USING fts5(
    name,
    cuisine,
    neighborhood,
    notes,
    content='Restaurants',
    content_rowid='restaurantID'
);
```

Kept in sync via triggers on INSERT/UPDATE/DELETE of the Restaurants table. The `/api/restaurants/search?q=` endpoint queries this table.

---

## Relationships

```
Restaurants ─┬─< Awards (via restaurantID)
             ├─< Episodes (via restaurantID)
             ├─< Visits (via restaurantID)
             ├─< Photos (via restaurantID)
             ├─< Tags (via restaurantID)
             ├─< Intel (via restaurantID)
             └─< ListItems (via restaurantID)

Users ─┬─< Visits (via userID)
       ├─< Photos (via userID)
       └─< Lists (via userID)

Lists ─< ListItems (via listID, CASCADE)

AwardSources ─┬─< Awards (via sourceID)
              └─< AwardSourceUrls (via sourceID)
```

---

## Initial Data

On first run, the import tool seeds the database from the archived CheckPlease database:

- 276 restaurants (many fields NULL, filled during enrichment)
- 4 award sources
- 9 award source URLs (Wayback Machine provenance)
- 455 awards (9 years of Philly Mag 50 Best)
- 120 episode appearances (Check Please! Philly, 6 seasons)
- 2 user records with API keys

All other tables start empty and are populated through app usage.

---

## Enrichment (Post-Import)

Data gaps are filled after initial import:

| Gap | Approach | Priority |
|-----|----------|----------|
| Cuisine (156 missing) | AI-assisted + manual review in app | High |
| Neighborhood (232 missing) | Geocode → point-in-polygon against Philly boundaries | High |
| Address + lat/lng (276 missing) | Google Places API by name + city | High |
| Price range (276 missing) | Manual tagging in app | Medium |
| BYOB (276 missing) | Manual tagging (Philly-specific knowledge) | Medium |
| Phone numbers | From Google Places results | Low |
| Episode air dates | Research | Low |

Enrichment tools live in `cmd/suppr-geocode/` and are run once per batch.

---

## Backup Strategy

- Daily cron: `cp /data/suppr/suppr.db /data/suppr/backups/suppr-$(date +%Y%m%d).db`
- Keep 30 days
- Database is small enough (~1MB) that full copy takes milliseconds
- The archived `original/checkplease.db` is never modified — it's provenance
