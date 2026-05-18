# suppr Data Import Pipeline

This document describes how to migrate the existing CheckPlease database into suppr's schema, and how to fill the data gaps.

---

## Source Data

The original database lives at `~/Desktop/CheckPlease/checkplease.db` (archived copy at `original/checkplease.db`).

### Existing Tables

| Table | Rows | Description |
|-------|------|-------------|
| `restaurants` | 276 | Core restaurant records. All have name, website, status. |
| `awards` | 455 | Philly Mag 50 Best appearances, 9 years (2015–2024, 2026). |
| `award_sources` | 4 | Philly Mag, Michelin, James Beard, Check Please. Only Philly Mag populated. |
| `award_source_urls` | 9 | Wayback Machine URLs documenting where each year's list was scraped from. |
| `cp_episodes` | 41 | Check Please! Philly episodes across 6 seasons, all with WHYY video URLs. |
| `cp_appearances` | 120 | Junction table linking restaurants to episodes. |

### Data Quality Assessment

| Field | Present | Missing | Coverage |
|-------|---------|---------|----------|
| name | 276 | 0 | 100% |
| website | 276 | 0 | 100% |
| status | 276 | 0 | 100% |
| cuisine | 120 | 156 | 43% |
| neighborhood | 44 | 232 | 16% |
| address | 0 | 276 | 0% |
| phone | 0 | 276 | 0% |
| price_range | 0 | 276 | 0% (not in schema) |
| byob | 0 | 276 | 0% (not in schema) |
| lat/lng | 0 | 276 | 0% (not in schema) |

### Cross-Reference Coverage

- 196 restaurants have at least one award
- 120 restaurants appeared on Check Please!
- 40 restaurants appear in both sources
- Top cuisines (of the 120 tagged): Mexican (7), American (7), American/Bar (6), Italian (5), French (4)

### Awards Distribution by Year

| Year | Count |
|------|-------|
| 2015 | 50 |
| 2016 | 50 |
| 2017 | 50 |
| 2019 | 50 |
| 2021 | 60 |
| 2022 | 45 |
| 2023 | 50 |
| 2024 | 50 |
| 2026 | 50 |

Note: No 2018 or 2020 lists. 2021 had 60 entries (18 unranked additions + ranked #3–#50). 2022 had only 45 (all unranked).

### Episodes by Season

| Season | Episodes |
|--------|----------|
| 1 | 12 |
| 2 | 6 |
| 3 | 5 |
| 4 | 7 |
| 5 | 5 |
| 6 | 6 |

Each episode features 3 restaurants. All 41 episodes have WHYY video URLs.

---

## Schema Mapping

### restaurants → Restaurants

| Source Column | Target Column | Transformation |
|--------------|---------------|----------------|
| `id` | `restaurantID` | Direct copy |
| `name` | `name` | Direct copy |
| `address` | `address` | Direct copy (all NULL currently) |
| `neighborhood` | `neighborhood` | Direct copy (84% NULL) |
| `cuisine` | `cuisine` | Direct copy (57% NULL) |
| `website` | `website` | Direct copy |
| `phone` | `phone` | Direct copy (all NULL) |
| `status` | `status` | Direct copy |
| `notes` | `notes` | Direct copy |
| `created_at` | `created_at` | Direct copy |
| `city` | `city` | Direct copy (default 'Philadelphia') |
| `state` | `state` | Direct copy (default 'PA') |
| `zip` | `zip` | Direct copy (all NULL currently) |
| `founder` | `founder` | Direct copy |
| `chef` | `chef` | Direct copy |
| `source` | `source` | Direct copy (where we first learned about it) |
| `updated_at` | `modified_at` | Rename |
| *(not in source)* | `price_range` | NULL — fill in enrichment phase |
| *(not in source)* | `byob` | 0 — fill in enrichment phase |
| *(not in source)* | `outdoor` | 0 — fill in enrichment phase |
| *(not in source)* | `reservations` | NULL — fill in enrichment phase |
| *(not in source)* | `latitude` | NULL — fill via geocoding |
| *(not in source)* | `longitude` | NULL — fill via geocoding |
| *(not in source)* | `attributes` | empty string (soft-delete marker) |

Dropped columns: `founding_date` (sparsely populated, not needed in suppr).

### awards → Awards

| Source Column | Target Column | Transformation |
|--------------|---------------|----------------|
| `id` | `awardID` | Direct copy |
| `restaurant_id` | `restaurantID` | Direct copy |
| `award_source_id` | `sourceID` | Direct copy (FK to AwardSources) |
| `year` | `year` | Direct copy |
| `position` | `rank` | Direct copy (NULL when unranked) |
| `notes` | `category` | Map if contains category info, else NULL |

### award_sources → AwardSources

| Source Column | Target Column | Transformation |
|--------------|---------------|----------------|
| `id` | `sourceID` | Direct copy |
| `name` | `name` | Direct copy |
| `description` | `description` | Direct copy |
| `url` | `url` | Direct copy |

This produces 4 rows (Philly Mag, Michelin, James Beard, Check Please).

### award_source_urls → AwardSourceUrls

| Source Column | Target Column | Transformation |
|--------------|---------------|----------------|
| `id` | `urlID` | Direct copy |
| `award_source_id` | `sourceID` | Direct copy |
| `year` | `year` | Direct copy |
| `url` | `url` | Direct copy |
| `notes` | `notes` | Direct copy |

This produces 9 rows — Wayback Machine captures documenting exactly where each year's Philly Mag list was scraped from. Invaluable provenance data.

### cp_episodes + cp_appearances → Episodes

The existing schema has a M:M junction (one episode → 3 restaurants). Our schema denormalizes: one row per restaurant-per-episode.

| Source | Target Column | Transformation |
|--------|---------------|----------------|
| `cp_appearances.restaurant_id` | `restaurantID` | Direct copy |
| `cp_episodes.season` | `season` | Direct copy |
| `cp_episodes.episode_num` | `episode` | Direct copy |
| `cp_episodes.title` | *(not stored)* | Title is the 3 restaurant names — redundant |
| `cp_episodes.url` | `video_url` | Direct copy (WHYY URL) |
| *(derived)* | `embed_url` | NULL initially — fill if YouTube versions found |
| `cp_episodes.description` | `segment_notes` | Direct copy |
| *(not in source)* | `air_date` | NULL — could research later |

This produces 120 rows (one per appearance).

### New Tables (No Source Data)

| Table | Initial State |
|-------|---------------|
| `Users` | 2 rows: you + Meriam, each with name, email, API key |
| `Visits` | Empty — populated through app usage |
| `Photos` | Empty |
| `Tags` | Empty — populated during enrichment or through app |
| `Intel` | Empty |
| `Lists` | Empty |
| `ListItems` | Empty |

---

## Import Strategy

### Phase 1: Direct Migration (Day 1 — Launch Blocker)

No data loss. Migrate everything from checkplease.db into suppr.db with column remapping. The app is immediately usable with 276 restaurants, 455 awards, and 120 episode appearances.

The import tool lives at `cmd/suppr-import/main.go`:
1. Opens `checkplease.db` read-only
2. Opens or creates `suppr.db` on the DO server
3. Runs the suppr schema (CREATE TABLE statements)
4. Migrates restaurants with column mapping (including city, state, zip)
5. Migrates award_sources and award_source_urls (direct copy)
6. Migrates awards with sourceID FK preserved
7. Migrates episodes + appearances, denormalizing into one-row-per-appearance
8. Creates 2 User records with API keys
9. Reports totals

Run once to seed. The original database is archived.

### Phase 2: Enrichment (First Week)

Fill data gaps. Priority order:

**High priority** (app is less useful without these):
1. **Cuisine tagging** (156 missing) — AI-assisted pass using restaurant names + websites. Review in the app.
2. **Neighborhood tagging** (232 missing) — Geocode first, then derive from coordinates using Philly neighborhood boundary polygons.
3. **Addresses** (276 missing) — Google Places API lookup by restaurant name + "Philadelphia PA". ~$5 for 276 lookups.
4. **Lat/Lng** (276 missing) — Comes free with the Google Places lookup.

**Medium priority** (app works fine without, but recommendations improve):
5. **Price range** (276 missing) — Manual tagging in the app. Could also scrape from Google Places results.
6. **BYOB** (276 missing) — Manual tagging. Philly-specific knowledge required.

**Low priority** (nice to have):
7. **Phone numbers** — From Google Places results.
8. **YouTube embed URLs** for episodes — Search YouTube for each WHYY episode title.
9. **Outdoor seating, reservations** — Manual or scrape.

### Phase 3: Ongoing (Post-Launch)

- Annual: Import new Philly Mag 50 Best list (scrape + import tool)
- Seasonal: Import new Check Please episodes
- Continuous: Intel items via cron job or manual entry
- Continuous: Visit logging, photo uploads, tag refinement through normal app usage

---

## Enrichment Tools

### Google Places Geocoding

A small Go CLI tool (`cmd/suppr-geocode/`) that:
1. Reads restaurants with NULL address from suppr.db
2. Calls Google Places API: `findplacefromtext?input={name}+Philadelphia+PA`
3. Gets back: formatted_address, lat, lng, phone, price_level
4. Updates the restaurant record
5. Rate-limited to respect API quotas

### Cuisine Tagger

A Go CLI tool or a one-time script that:
1. Reads restaurants with NULL cuisine
2. For each, fetches the restaurant website (already has URL)
3. Uses keyword matching or a simple heuristic to suggest a cuisine
4. Outputs suggestions for manual review
5. Updates after approval

### Neighborhood Derivation

Given lat/lng coordinates, map to Philadelphia neighborhoods using a GeoJSON boundary file (freely available from OpenDataPhilly). A Go function that does point-in-polygon testing.

---

## Data Provenance

The `award_sources` and `award_source_urls` tables are fully migrated into suppr. The source URLs document exactly where each year's Philly Mag list was scraped from (Wayback Machine captures with dates). The original database is also archived at `XYZ/original/checkplease.db` and `XYZ/original/schema.sql`.
