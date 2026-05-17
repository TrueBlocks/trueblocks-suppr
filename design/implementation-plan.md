# suppr Implementation Plan

This document defines the phased build plan for suppr. Each phase produces working software and article material. Phases are sequential — each builds on the previous — but within a phase, tasks can be parallelized.

---

## Phase 1: The Foundation (Server + Import)

**Goal**: A running API server on DO with 276 restaurants queryable via curl.

### Tasks

1. **Write `suppr-schema.sql`** — canonical DDL for all tables (Restaurants, AwardSources, AwardSourceUrls, Awards, Episodes, Users, Visits, Photos, Tags, Intel, Lists, ListItems, FTS5 virtual tables). This is the single source of truth for the database schema.

2. **Initialize Go module** — `go.mod`, add to `go.work`, wire up `pkg/models/` with all Go structs matching the schema.

3. **Build `internal/db/`** — database layer: Open, Close, migrate (run schema.sql), and CRUD for Restaurants + Awards + AwardSources + AwardSourceUrls + Episodes. Same patterns as works.

4. **Build `cmd/suppr-import/`** — reads checkplease.db, runs schema, migrates all tables per data-import-pipeline.md. Run once locally, SCP the resulting suppr.db to DO.

5. **Build `cmd/suppr-server/`** — chi router, API key auth middleware, CORS middleware (for dev), restaurant endpoints only (list, get, create, update, delete, filters, search, stats). Health endpoint.

6. **Deploy to DO** — Caddy config, systemd service, SCP binary + database. Verify: `curl https://suppr.trueblocks.io/api/health` and `curl https://suppr.trueblocks.io/api/restaurants`.

7. **Wire up `package.json` and `Makefile`** — build targets matching other submodules. `make server`, `make import`, `make deploy-server`.

### Done When

- `curl https://suppr.trueblocks.io/api/restaurants` returns 276 restaurants as JSON
- `curl https://suppr.trueblocks.io/api/restaurants?q=zahav` returns search results
- `curl https://suppr.trueblocks.io/api/restaurants/1` returns a single restaurant
- Auth rejects requests without valid API key

### Article Material

"Building a Restaurant App for Two" — the thesis, the schema, the import pipeline. Why Go + SQLite. Why a personal API server on a $6 VPS instead of Yelp.

---

## Phase 2: The Desktop App (Wails Shell)

**Goal**: A running Wails app that displays the restaurant list and detail, pulling data from the DO API.

### Tasks

1. **Scaffold Wails app** — follow CREATING_NEW_APPS.md blueprint. `wails init`, configure `wails.json`, set up frontend with React + Mantine + TypeScript.

2. **Build `pkg/client/`** — Go HTTP client: `New(baseURL, apiKey)`, `RestaurantList()`, `RestaurantGet()`, `RestaurantUpdate()`, `RestaurantFilters()`, `RestaurantSearch()`, `RestaurantStats()`. Internal helpers for get/post/patch/delete with auth header.

3. **Build `app/app.go`** — App struct with startup (load config, create client), shutdown. Config from `~/.local/share/trueblocks/suppr/config.json`.

4. **Build `app/restaurants.go`** — Wails bindings that delegate to `pkg/client/`. Thin proxy layer.

5. **Build `app/state.go`** — UI state persistence via appkit.Store (sidebar width, last route, table states, tab states).

6. **Frontend: Shell** — sidebar navigation (8 items), header, status bar, routing. Copy works' shell patterns.

7. **Frontend: Restaurant List** — DataTable with all columns, sorting, filtering, search, persistence. `createDataTable` wrapper.

8. **Frontend: Restaurant Detail** — DetailHeader with prev/next. Overview sub-tab only (all EditableField components). Other sub-tabs as placeholders.

9. **Hotkeys** — Cmd+1–8, Cmd+K (search modal placeholder), Cmd+R (reload).

### Done When

- `wails dev` shows the app with sidebar, restaurant list loads from DO API
- Click a restaurant → detail view with editable fields
- Edit a field → PATCH sent to API → field updates
- Sidebar resizes, route persists across restarts
- Table state (sort, search, filters) persists

### Article Material

"The Wails HTTP Client Pattern" — how the desktop app delegates to a remote API. The thin proxy. Why this is different from every Wails tutorial. Code examples from pkg/client/.

---

## Phase 3: Visits + Recommendations

**Goal**: Log visits, see your history, get recommendations. The app becomes genuinely useful.

### Tasks

1. **Server: Visit endpoints** — CRUD for visits (list, get, create, update, delete, filters, recent). Add to `internal/db/` and `internal/api/`.

2. **Server: Recommendation endpoints** — all four modes (tonight, bucket-list, revisit, explore). Scoring logic in `internal/db/recommend.go`. Named constants for scoring coefficients.

3. **`pkg/client/`: Visit + Recommend methods** — mirror the new endpoints.

4. **`app/visits.go` + `app/recommend.go`** — Wails bindings.

5. **Frontend: Visit List + Detail** — DataTable with columns from ui-design.md. Visit Detail with editable fields.

6. **Frontend: Recommend Page** — wizard UI with filters, four sub-tabs (Tonight, Bucket List, Revisit, Explore). Recommendation cards with one-line reasons.

7. **Frontend: Dashboard** — stat cards, recent visits, bucket list preview, patterns. Wire to `/api/restaurants/stats` and `/api/visits/recent`.

8. **Frontend: Restaurant Detail sub-tabs** — Visits sub-tab (shows visits for this restaurant, "Log Visit" button). Awards and Episodes sub-tabs (read-only DataTables).

9. **Cross-navigation** — Restaurant → Visit, Visit → Restaurant, Dashboard → Restaurant, Recommend → Restaurant. All with return context.

### Done When

- Log a visit from the app → appears in visit list and on restaurant's Visits sub-tab
- Dashboard shows stats and recent visits
- "Tonight" recommendation returns scored results with reasons
- "Bucket List" shows unvisited award-winners
- "Revisit" shows loved-but-overdue restaurants (once you have visit data)
- Navigation between entities works with return context

### Article Material

"A Recommendation Engine for Two" — the scoring formula, cold start behavior, why "your friend's wife who shares your taste" beats anonymous reviews. Real examples from the data.

---

## Phase 4: The PWA

**Goal**: Meriam can browse restaurants and log visits from her iPhone.

### Tasks

1. **Server: Photo endpoints** — upload (multipart), metadata, download, delete. Photo storage at `/data/suppr/photos/{restaurantID}/`.

2. **PWA shell** — bottom tab bar (Home, Browse, Tonight, Log, Profile). Manifest, service worker, offline fallback page. Build to `frontend/dist/` via Vite.

3. **PWA: Browse** — restaurant list as cards with search and filters. Tap → restaurant detail as stacked cards.

4. **PWA: Log Visit** — the most important mobile screen. Restaurant autocomplete, date, rating stars, occasion, notes, camera button. `<input type="file" accept="image/*" capture="environment">`.

5. **PWA: Tonight** — simplified recommendation UI with filter dropdowns. Recommendation cards with Directions (Apple Maps) and View buttons.

6. **PWA: Home** — dashboard lite (recent visits, intel alerts, stats).

7. **PWA: Profile** — your visits, your lists, settings (API key, server URL).

8. **`useApi()` hook** — abstracts Wails bindings vs `fetch()`. Detects runtime, routes calls appropriately. Shared TypeScript types.

9. **Deploy via siteman** — `make deploy-pwa` builds and deploys to `/var/www/suppr/` on DO.

10. **Desktop: Photo upload** — `app/photos.go` reads local files, calls `pkg/client/UploadPhoto()` with multipart POST.

### Done When

- PWA loads on iPhone via `suppr.trueblocks.io`
- "Add to Home Screen" works, app icon appears
- Browse restaurants, tap to see detail
- Log a visit with star rating and photo from camera
- Photo appears on restaurant's Photos sub-tab on desktop
- "Tonight" shows recommendations on phone

### Article Material

"PWA for Two: Why We Skipped the App Store" — the camera trick, deployment via siteman, mobile UX choices. Why PWA is perfect for 2-user apps.

---

## Phase 5: Enrichment + Polish

**Goal**: Fill data gaps, add remaining features, polish the experience.

### Tasks

1. **`cmd/suppr-geocode/`** — Google Places API enrichment tool. Fills addresses, lat/lng, phone numbers, price levels for all 276 restaurants.

2. **Cuisine tagger** — AI-assisted pass through restaurants with NULL cuisine. Website keyword matching or manual review in the app.

3. **Server: Intel, Tags, Lists endpoints** — full CRUD for all three.

4. **`pkg/client/` + Wails bindings** — for Intel, Tags, Lists.

5. **Frontend: Intel List + Detail** — DataTable with type, headline, date, source, dismiss. Dashboard intel alerts wired up.

6. **Frontend: Tags** — tag management on Restaurant Detail Overview tab. Autocomplete from existing tags.

7. **Frontend: Lists** — Lists sidebar or page. Add/remove restaurants. Restaurant Detail Lists sub-tab.

8. **Frontend: Global Search (Cmd+K)** — search across restaurants, visits, intel. Results grouped by type with icons.

9. **Frontend: Command Palette (Cmd+Shift+P)** — fuzzy-searchable action list. Navigation commands, toggles, shortcuts displayed.

10. **Preview system** — curl + cache + local file server for restaurant website previews. Desktop only. Preview sub-tab on Restaurant Detail.

11. **FTS5** — full-text search on restaurant names, notes, intel headlines. Server-side query via `/api/restaurants/search?q=`.

### Done When

- Most restaurants have addresses, lat/lng, cuisine, phone
- Intel items can be created, viewed, dismissed
- Tags work on restaurants
- Custom lists can be created and populated
- Cmd+K searches across all entities
- Cmd+Shift+P opens command palette
- Preview tab shows cached restaurant websites
- FTS5 search returns relevant results

### Article Material

"Small Batch Apps: Software That Doesn't Scale (and Why That's the Point)" — the manifesto. The five principles. The growth model. Why building for two is more interesting than building for two million.

---

## Phase 6: Federation (Future)

**Goal**: A second couple runs their own suppr instance and shares recommendations with you.

### Tasks

1. **Peers table + Outbox + Inbox** — schema additions per server-architecture.md federation section.

2. **Peer management endpoints** — invite, accept, list, unlink.

3. **Share action** — "Share with friends" button on Restaurant Detail. Composes a recommendation message.

4. **Federation inbox handler** — `POST /api/federation/inbox` receives recommendation messages from peers. Validates signature, deduplicates, stores as Intel.

5. **Outbox sender** — background goroutine that pushes queued messages to peers with exponential backoff.

6. **Recommendation engine: friend bonus** — peer recommendations add a "friends loved this" bonus to the Tonight scoring formula.

7. **Second deployment** — help a friend set up their own instance. Document the process.

### Done When

- Two suppr instances can pair via shared token
- Sharing a recommendation from instance A appears as Intel on instance B
- The recommendation engine factors in peer recommendations
- Unlinking a peer removes the connection but preserves received data

### Article Material

"Peer-to-Peer Dining: Sharing Restaurant Recommendations Without a Platform" — the federation protocol, the pairing flow, the trust model. Why push-based beats pull-based. What it means when software grows laterally instead of vertically.

---

## Build Log

Throughout all phases, maintain `articles/build-log.md` — raw notes captured during implementation. Each entry is timestamped with a brief observation, decision, surprise, or insight. This is the raw material that articles are shaped from.

Use `note <topic>` to add a fleshed-out entry (interactive — agent asks clarifying questions before writing). Use `note-quick <text>` to add a quick one-liner.

---

## Parallel Tracks: Code + Articles

| Phase | Code Output | Article Draft |
|-------|-------------|---------------|
| 1 | Running API server on DO | "Building a Restaurant App for Two" |
| 2 | Working Wails desktop app | "The Wails HTTP Client Pattern" |
| 3 | Visits + recommendations | "A Recommendation Engine for Two" |
| 4 | Working PWA on iPhones | "PWA for Two: Why We Skipped the App Store" |
| 5 | Polished app with all features | "Small Batch Apps" (the manifesto) |
| 6 | Federation between two instances | "Peer-to-Peer Dining" |

Articles are drafted during each phase while decisions are fresh, then polished between phases or during natural pauses. The build log is the bridge — capture insights in real time, shape them into prose later.
