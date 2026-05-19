# Build Sequence

This chapter specifies the order in which to construct suppr. Each phase produces working software. Phases are sequential — each builds on the previous — but within a phase, tasks can be parallelized.

	An AI reading this book should implement the phases in order. Each phase has a clear "Done When" checklist. Do not proceed to the next phase until the current phase passes all checks.

---

## Phase 1: The Foundation (Server + Import)

	**Goal**: A running API server on DO with 276 restaurants queryable via curl.

### Tasks

	1. Write `suppr-schema.sql` — canonical DDL for all tables (see Data Model chapter)
	2. Initialize Go module — `go.mod`, wire up `pkg/models/` with all Go structs matching the schema
	3. Build `internal/db/` — Open, Close, migrate, CRUD for Restaurants + Awards + AwardSources + AwardSourceUrls + Episodes
	4. Build `cmd/suppr-import/` — reads archived checkplease.db, runs schema, migrates all tables per the schema mapping
	5. Build `cmd/suppr-server/` — chi router, API key auth middleware, CORS middleware, Restaurant endpoints only (list, get, create, update, delete, filters, search, stats), Health endpoint
	6. Deploy to DO — Caddy config, systemd service, SCP binary + database
	7. Wire up `package.json` and `Makefile` — build targets matching the platform pattern

### Done When

- `curl https://suppr.trueblocks.io/api/health` returns status
- `curl https://suppr.trueblocks.io/api/restaurants` returns 276 restaurants as JSON
- `curl https://suppr.trueblocks.io/api/restaurants?q=zahav` returns search results
- `curl https://suppr.trueblocks.io/api/restaurants/1` returns a single restaurant with all fields
- Requests without a valid API key are rejected with `UNAUTHORIZED` error

---

## Phase 2: The Desktop App (Wails Shell)

	**Goal**: A running Wails app that displays the restaurant list and detail, pulling data from the DO API.

### Tasks

	1. Scaffold Wails app — `wails init`, configure frontend with React + Mantine + TypeScript + Vite
	2. Build `pkg/client/` — Go HTTP client with all Restaurant methods and internal helpers (get, post, patch, delete)
	3. Build `app/app.go` — App struct with startup (load config, create client), shutdown
	4. Build `app/restaurants.go` — Wails bindings that delegate to `pkg/client/`
	5. Build `app/state.go` — UI state persistence via appkit.Store
	6. Frontend shell — sidebar navigation (8 items), header, status bar, routing
	7. Frontend: Restaurant List — DataTable with all columns, sorting, filtering, search, persistence
	8. Frontend: Restaurant Detail — DetailHeader with prev/next, Overview sub-tab with EditableField components, other sub-tabs as placeholders
	9. Hotkeys — Cmd+1–8, Cmd+R (reload), basic table navigation

### Done When

- `wails dev` launches the app with sidebar and restaurant list loaded from DO API
- Click a restaurant → detail view with all fields displayed
- Edit a field → PATCH sent to API → field updates immediately
- Sidebar resizes and width persists across restarts
- Route persists across restarts (re-opens where you left off)
- Table state (sort, search, filters) persists

---

## Phase 3: Visits + Recommendations

	**Goal**: Log visits, see history, get recommendations. The app becomes genuinely useful.

### Tasks

	1. Server: Visit endpoints — CRUD (list, get, create, update, delete, filters, recent)
	2. Server: Recommendation endpoints — all four modes (tonight, bucket-list, revisit, explore) with full scoring logic
	3. `pkg/client/`: Visit + Recommend methods
	4. `app/visits.go` + `app/recommend.go` — Wails bindings
	5. Frontend: Visit List + Detail — DataTable, editable fields
	6. Frontend: Recommend Page — wizard UI with filters, four sub-tabs, recommendation cards with one-line reasons
	7. Frontend: Dashboard — stat cards, recent visits, bucket list preview, patterns
	8. Frontend: Restaurant Detail sub-tabs — Visits (with "Log Visit" button), Awards, Episodes
	9. Cross-navigation — Restaurant ↔ Visit, Dashboard → Restaurant, Recommend → Restaurant, all with return context

### Done When

- Log a visit from the app → appears in visit list and restaurant's Visits sub-tab
- Dashboard shows stats and recent visits
- "Tonight" returns scored recommendations with reasons
- "Bucket List" shows unvisited award-winners
- "Revisit" shows loved-but-overdue restaurants
- Navigation between entities works with return buttons

---

## Phase 4: The PWA

	**Goal**: Browse restaurants and log visits from an iPhone.

### Tasks

	1. Server: Photo endpoints — upload (multipart), metadata, download (file streaming), delete
	2. PWA shell — bottom tab bar (Home, Browse, Tonight, Log, Profile), manifest, service worker, offline fallback
	3. PWA: Browse — restaurant card list with search and filters, tap → stacked detail cards
	4. PWA: Log Visit — restaurant autocomplete, date, rating stars, occasion, notes, camera button
	5. PWA: Tonight — simplified recommendation UI with filter dropdowns and action buttons (Directions, View)
	6. PWA: Home — dashboard lite (recent visits, intel alerts, stats)
	7. PWA: Profile — visits, lists, settings
	8. `useApi()` hook — abstracts Wails bindings vs `fetch()`, shared TypeScript types
	9. Deploy via siteman — `make deploy-pwa` builds and deploys to DO
	10. Desktop: Photo upload — `app/photos.go` reads local files, multipart POST to API

### Done When

- PWA loads on iPhone via `suppr.trueblocks.io`
- "Add to Home Screen" works with app icon
- Browse restaurants, tap to see detail
- Log a visit with star rating and photo from camera
- Photo appears on restaurant's Photos sub-tab on desktop
- "Tonight" shows recommendations on phone

---

## Phase 5: Enrichment + Polish

	**Goal**: Fill data gaps, add remaining features, polish the experience.

### Tasks

	1. `cmd/suppr-geocode/` — Google Places API enrichment (addresses, lat/lng, phone, price)
	2. Cuisine tagger — AI-assisted or manual review for restaurants with NULL cuisine
	3. Server: Intel, Tags, Lists endpoints — full CRUD
	4. `pkg/client/` + Wails bindings for Intel, Tags, Lists
	5. Frontend: Intel List + Detail — DataTable, dismiss button, dashboard alerts
	6. Frontend: Tags — tag management on Restaurant Overview tab, autocomplete
	7. Frontend: Lists — list creation, add/remove restaurants, Restaurant Detail Lists sub-tab
	8. Frontend: Global Search (Cmd+K) — search across restaurants, visits, intel
	9. Frontend: Command Palette (Cmd+Shift+P) — fuzzy action search with shortcut display
	10. Preview system — curl + cache + local file server for restaurant website previews (desktop only)
	11. FTS5 — full-text search wired to the search endpoint
	12. Tit-for-tat — configurable alternation feature (off by default, mutual consent to enable)
	13. Recommendation config UI — Settings → Recommendation tab with all configurable parameters

### Done When

- Most restaurants have addresses, lat/lng, cuisine, phone
- Intel items can be created, viewed, dismissed
- Tags work on restaurants with autocomplete
- Custom lists can be created and populated
- Cmd+K and Cmd+Shift+P both work
- Preview tab shows cached restaurant websites
- FTS5 search returns relevant results
- Settings page includes recommendation configuration

---

## Phase 6: Federation (Future)

	**Goal**: A second couple runs their own suppr instance and shares recommendations.

### Tasks

	1. Peers table + Outbox + Inbox — schema additions (see Data Model chapter)
	2. Peer management endpoints — invite, accept, list, unlink
	3. Share action — "Share with friends" button on Restaurant Detail, composes a recommendation message
	4. Federation inbox handler — `POST /api/federation/inbox` receives messages, validates signature, deduplicates, stores as Intel
	5. Outbox sender — background goroutine pushes queued messages with exponential backoff
	6. Recommendation engine: friend bonus — peer recommendations add to Tonight scoring
	7. Second deployment — help a friend set up their own instance

### Done When

- Two suppr instances can pair via shared token
- Sharing a recommendation from instance A appears as Intel on instance B
- The recommendation engine factors in peer recommendations
- Unlinking removes the connection but preserves received data

---

## Dependency Order

	```
	Phase 1: Server + DB + Import
	    ↓
	Phase 2: Wails app (needs working server)
	    ↓
	Phase 3: Visits + Recommend (needs Wails shell)
	    ↓
	Phase 4: PWA (needs photo endpoints, needs useApi() pattern)
	    ↓
	Phase 5: Polish (needs all core features working)
	    ↓
	Phase 6: Federation (needs stable single-instance app)
	```

	Within each phase, the numbered tasks can often be parallelized. For example, in Phase 2, the Go backend work (tasks 2–5) can proceed independently of the frontend shell (tasks 6–9) once the Wails scaffold is in place.

---

## The Single-Book Constraint

	This build sequence assumes the reader's AI is constructing the entire app from the book alone. There is no existing codebase to reference, no GitHub repo to clone, no package to install. The spec must be complete enough that an AI, reading the narrative + these specification chapters in order, can produce working software.

	Every detail that a builder needs but cannot infer must be specified explicitly in one of the preceding chapters. If a phase references a pattern or structure, that pattern is defined in Prerequisites, Architecture, Project Structure, API, Recommendation Engine, Data Model, UI, or Client-Server Pattern.
