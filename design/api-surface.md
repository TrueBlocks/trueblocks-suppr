# suppr API Surface Design

This document captures the complete API design for the suppr Go API server running on Digital Ocean. Both the Wails desktop app and the phone PWA call these endpoints.

---

## Authentication

Every request includes an `X-API-Key` header. The server validates it against the Users table and identifies which user is making the request.

```
X-API-Key: {user's api key}
```

- Unauthenticated requests → `401 Unauthorized`
- Invalid keys → `403 Forbidden`
- User identity derived from the key (no separate user ID param needed)

---

## Conventions

- **JSON** request and response bodies
- **RESTful** routes: nouns are plural, IDs in path
- **PATCH** for updates (partial — send only changed fields, not full resource)
- Consistent error responses: `{"error": "message"}`
- **Pagination** via `?limit=N&offset=N` on list endpoints (optional for small tables)
- **Filtering** via query params: `?cuisine=Italian&neighborhood=Rittenhouse&price=3`
- **Sorting** via `?sort=name&dir=asc`
- **Search** via `?q=zahav` (uses FTS5 on the server)

### Why PATCH (not PUT)

PATCH sends only changed fields. This maps perfectly to the Wails app's `EditableField` pattern — one field changes, one field gets sent. For a 2-user app with simple field assignments, the theoretical downsides of PATCH (distinguishing "omitted" from "set to empty", no idempotency guarantee) don't apply. The Go handler uses `map[string]any` to build dynamic UPDATE statements from the fields present in the request body.

---

## Endpoints

### Restaurants

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/restaurants` | List all (filters: cuisine, neighborhood, price, status, byob, q) |
| GET | `/api/restaurants/:id` | Get one (includes computed: avg rating, visit count, award count) |
| POST | `/api/restaurants` | Create |
| PATCH | `/api/restaurants/:id` | Update (partial — only changed fields) |
| DELETE | `/api/restaurants/:id` | Soft delete (sets attributes marker) |
| GET | `/api/restaurants/:id/visits` | Visits for this restaurant |
| GET | `/api/restaurants/:id/awards` | Awards for this restaurant |
| GET | `/api/restaurants/:id/episodes` | Episodes for this restaurant |
| GET | `/api/restaurants/:id/photos` | Photos for this restaurant |
| GET | `/api/restaurants/:id/intel` | Intel for this restaurant |
| GET | `/api/restaurants/:id/lists` | Lists containing this restaurant |
| GET | `/api/restaurants/filters` | Distinct values for filter dropdowns (cuisines, neighborhoods, prices, statuses) |
| GET | `/api/restaurants/search?q=` | FTS5 search |
| GET | `/api/restaurants/stats` | Dashboard stats (total, visited count, cuisine count, avg rating) |

### Visits

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/visits` | List all (filters: user, restaurant, occasion, date range, rating range) |
| GET | `/api/visits/:id` | Get one |
| POST | `/api/visits` | Create (user identified from API key) |
| PATCH | `/api/visits/:id` | Update |
| DELETE | `/api/visits/:id` | Delete |
| GET | `/api/visits/filters` | Distinct values for filter dropdowns |
| GET | `/api/visits/recent` | Last N visits (for dashboard) |

### Awards

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/awards` | List all (filters: source, year, category) |
| GET | `/api/awards/:id` | Get one |
| POST | `/api/awards` | Create |
| PATCH | `/api/awards/:id` | Update |
| DELETE | `/api/awards/:id` | Delete |
| GET | `/api/awards/filters` | Distinct values |

### Episodes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/episodes` | List all (filters: season, air date range) |
| GET | `/api/episodes/:id` | Get one |
| POST | `/api/episodes` | Create |
| PATCH | `/api/episodes/:id` | Update |
| DELETE | `/api/episodes/:id` | Delete |
| GET | `/api/episodes/filters` | Distinct values |

### Intel

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/intel` | List all (filters: type, dismissed, restaurant, date range) |
| GET | `/api/intel/:id` | Get one |
| POST | `/api/intel` | Create |
| PATCH | `/api/intel/:id` | Update (including dismiss/undismiss) |
| DELETE | `/api/intel/:id` | Delete |
| GET | `/api/intel/filters` | Distinct values |
| GET | `/api/intel/undismissed` | Active alerts (for dashboard) |

### Photos

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/photos` | List all (filters: restaurant, visit, user) |
| GET | `/api/photos/:id` | Get metadata |
| GET | `/api/photos/:id/file` | Download the actual image file |
| POST | `/api/photos` | Upload (multipart/form-data: image file + restaurantID + visitID? + caption?) |
| PATCH | `/api/photos/:id` | Update metadata (caption) |
| DELETE | `/api/photos/:id` | Delete (removes file from disk too) |
| POST | `/api/photos/sync` | Bulk download — returns manifest of photos since a given timestamp (for desktop sync) |

### Tags

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/tags` | All distinct tags (for autocomplete) |
| POST | `/api/restaurants/:id/tags` | Add tag to restaurant |
| DELETE | `/api/restaurants/:id/tags/:tag` | Remove tag from restaurant |

### Lists

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/lists` | All lists for the current user |
| GET | `/api/lists/:id` | Get list with items |
| POST | `/api/lists` | Create list |
| PATCH | `/api/lists/:id` | Rename list |
| DELETE | `/api/lists/:id` | Delete list (cascades items) |
| POST | `/api/lists/:id/items` | Add restaurant to list |
| DELETE | `/api/lists/:id/items/:restaurantID` | Remove restaurant from list |
| PATCH | `/api/lists/:id/items/:restaurantID` | Update position/notes |

### Recommendations

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/recommend/tonight` | Scored recommendations (params: occasion, cuisine, price, mood, byob) |
| GET | `/api/recommend/bucket-list` | Unvisited award-winners sorted by quality signal |
| GET | `/api/recommend/revisit` | Rated 4+ but not visited in 3+ months |
| GET | `/api/recommend/explore` | Underexplored cuisines/neighborhoods with strong signals |

### Users / Auth

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/me` | Current user profile (from API key) |
| PATCH | `/api/me` | Update prefs (home location, dietary, radius) |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Server status + DB stats (for siteman health checks) |

---

## State Persistence (Not in API)

The Wails app's UI state (sidebar width, last route, table states, tab states) is **per-machine, not shared**. It uses the same `internal/state/` + `appkit.Store` pattern as all other Wails apps — stored locally in `state.json`, not on the DO server. No API endpoints needed for state.

---

## Client Architecture

### Wails App (Go backend → API)

The Wails app's Go backend has a `pkg/client/` package wrapping all HTTP calls:

```go
// pkg/client/client.go
type Client struct {
    baseURL string
    apiKey  string
    http    *http.Client
}

func New(baseURL, apiKey string) *Client { ... }
```

Then `app/restaurants.go` delegates:

```go
func (a *App) GetRestaurants(filters RestaurantFilters) ([]Restaurant, error) {
    return a.client.GetRestaurants(filters)
}
```

The React frontend calls Wails bindings as usual — it has no idea the data comes from a remote API.

### PWA (JavaScript → API)

The PWA calls the same endpoints directly via `fetch()`:

```ts
const res = await fetch('https://suppr.trueblocks.io/api/restaurants?cuisine=Italian', {
  headers: { 'X-API-Key': apiKey }
});
const restaurants = await res.json();
```

---

## API Server Structure (on DO)

```
suppr/
├── cmd/
│   └── suppr-server/
│       └── main.go          ← API server entry point
├── internal/
│   ├── api/
│   │   ├── router.go        ← chi router setup, middleware
│   │   ├── auth.go           ← API key validation middleware
│   │   ├── restaurants.go    ← handler functions
│   │   ├── visits.go
│   │   ├── awards.go
│   │   ├── episodes.go
│   │   ├── intel.go
│   │   ├── photos.go
│   │   ├── tags.go
│   │   ├── lists.go
│   │   ├── recommend.go
│   │   └── health.go
│   └── db/
│       ├── db.go             ← same DB layer pattern as works
│       ├── schema.sql
│       ├── restaurants.go
│       ├── visits.go
│       └── ...
└── pkg/
    └── client/
        ├── client.go         ← HTTP client (used by Wails app)
        ├── restaurants.go
        ├── visits.go
        └── ...
```

`internal/db/` is the same database layer pattern used in works. The API handlers in `internal/api/` are thin — they parse the request, call `db.DB` methods, and marshal the response. No business logic in the handler layer.

`pkg/client/` is the HTTP client that both the Wails app and any future CLI tools use. It mirrors the `internal/db/` interface but over HTTP.
