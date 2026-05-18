# API

This chapter specifies every HTTP endpoint the suppr server exposes. An AI implementing suppr should generate handlers for each endpoint listed below, with the error handling semantics described in the Error Response section.

Both the Wails desktop app and the phone PWA call these endpoints identically — the only difference is the transport layer (see Client-Server Pattern chapter).

---

## Conventions

- **JSON** request and response bodies
- **RESTful** routes: nouns are plural, IDs in path
- **PATCH** for updates (partial — send only changed fields, not full resource)
- **Pagination** via `?limit=N&offset=N` on list endpoints
- **Filtering** via query params: `?cuisine=Italian&neighborhood=Rittenhouse&price=3`
- **Sorting** via `?sort=name&dir=asc`
- **Search** via `?q=zahav` (uses FTS5 on the server)

### Why PATCH (not PUT)

PATCH sends only changed fields. This maps perfectly to the Wails app's `EditableField` pattern — one field changes, one field gets sent. For a 2-user app with simple field assignments, the theoretical downsides of PATCH (distinguishing "omitted" from "set to empty", no idempotency guarantee) don't apply. The Go handler uses `map[string]any` to build dynamic UPDATE statements from the fields present in the request body.

---

## Error Handling (First-Class Citizen)

Error handling is not tacked on after the happy path works. Every endpoint returns structured errors with enough context for the client to decide how to surface them to the user.

### Error Response Shape

All errors return this structure:

```json
{
  "error": {
    "code": "RESTAURANT_NOT_FOUND",
    "message": "Restaurant with ID 42 does not exist",
    "severity": "user",
    "field": "restaurantID"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | Machine-readable error code (for client-side routing) |
| `message` | string | Human-readable description (safe to display) |
| `severity` | string | One of: `user`, `warning`, `system` |
| `field` | string? | Optional — which input field caused the error (for form validation) |

### Error Severities

Severity determines how the client surfaces the error:

| Severity | Meaning | Client Routing |
|----------|---------|----------------|
| `user` | The user did something wrong or needs to know something | Toast notification — immediate, visible, dismissible |
| `warning` | Something degraded but the operation partially succeeded | Status bar update — persistent but non-intrusive |
| `system` | Server-side failure the user can't fix | Log to file + brief toast ("Something went wrong, check logs") |

### Error Codes by Category

**Validation errors** (severity: `user`, HTTP 400):
- `MISSING_REQUIRED_FIELD` — a required field was not provided
- `INVALID_FIELD_VALUE` — field value is wrong type or out of range
- `DUPLICATE_ENTRY` — attempting to create something that already exists

**Not found errors** (severity: `user`, HTTP 404):
- `RESTAURANT_NOT_FOUND`
- `VISIT_NOT_FOUND`
- `LIST_NOT_FOUND`
- `PHOTO_NOT_FOUND`
- `{RESOURCE}_NOT_FOUND` — pattern for all resources

**Auth errors** (severity: `user`, HTTP 401/403):
- `UNAUTHORIZED` — no API key or invalid key
- `FORBIDDEN` — valid key but not allowed for this operation

**Conflict errors** (severity: `warning`, HTTP 409):
- `CONCURRENT_MODIFICATION` — resource changed since you last read it
- `RESTAURANT_ALREADY_IN_LIST` — duplicate list membership

**Server errors** (severity: `system`, HTTP 500):
- `DATABASE_ERROR` — SQLite failure
- `FILESYSTEM_ERROR` — photo storage failure
- `INTERNAL_ERROR` — unexpected panic or logic error

### Client Responsibility

The client MUST:
1. Check HTTP status code first (2xx = success, anything else = parse error body)
2. Read `severity` to decide routing (toast / status bar / log)
3. Read `code` for programmatic handling (retry logic, field highlighting)
4. Display `message` to the user when severity is `user`
5. Log the full error response to the log file regardless of severity

The user should **never** see a silent failure. Every error reaches a surface — the question is which surface.

---

## Endpoints

### Restaurants

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/restaurants` | List all (filters: cuisine, neighborhood, price, status, byob, q) |
| GET | `/api/restaurants/:id` | Get one (includes computed: avg rating, visit count, award count) |
| POST | `/api/restaurants` | Create |
| PATCH | `/api/restaurants/:id` | Update (partial — only changed fields) |
| DELETE | `/api/restaurants/:id` | Soft delete (sets status to "deleted") |
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

### Users

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/users/me` | Current user profile (from API key) |
| PATCH | `/api/users/me` | Update prefs (home location, dietary, radius) |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Server status + DB stats (for siteman health checks) |

---

## Response Shape Examples

These are illustrative — the definitive field list comes from the Data Model chapter. But they show the shape an AI should produce.

### GET /api/restaurants/:id

```json
{
  "restaurantID": 42,
  "name": "Zahav",
  "cuisine": "Israeli",
  "neighborhood": "Society Hill",
  "city": "Philadelphia",
  "state": "PA",
  "address": "237 St James Pl",
  "zip": "19106",
  "phone": "215-625-8800",
  "website": "https://zahavrestaurant.com",
  "price_range": 4,
  "byob": false,
  "outdoor": true,
  "reservations": true,
  "status": "active",
  "lat": 39.9469,
  "lng": -75.1467,
  "notes": "Lamb shoulder needs 2-person minimum",
  "created_at": "2026-01-15T10:30:00Z",
  "modified_at": "2026-05-10T14:22:00Z",
  "computed": {
    "avg_rating": 4.8,
    "visit_count": 3,
    "award_count": 2,
    "last_visited": "2026-04-20"
  }
}
```

### GET /api/recommend/tonight

```json
{
  "recommendations": [
    {
      "restaurant": { "restaurantID": 42, "name": "Zahav", "cuisine": "Israeli", "neighborhood": "Society Hill", "price_range": 4 },
      "score": 87.5,
      "factors": {
        "recency_bonus": 0,
        "rating_signal": 24.0,
        "award_signal": 20.0,
        "variety_bonus": 15.0,
        "occasion_match": 18.5,
        "distance_penalty": -5.0,
        "freshness_decay": -5.0
      },
      "reason": "Highly rated, award-winning, haven't been in 3 months"
    }
  ],
  "params_used": {
    "occasion": "date-night",
    "cuisine": null,
    "price_max": null,
    "byob_only": false
  }
}
```

### GET /api/visits/recent

```json
{
  "visits": [
    {
      "visitID": 88,
      "restaurantID": 42,
      "restaurant_name": "Zahav",
      "user": "Jay",
      "date": "2026-04-20",
      "rating": 5,
      "occasion": "date-night",
      "spend": 185,
      "notes": "Lamb shoulder was perfect. New wine list is excellent.",
      "created_at": "2026-04-20T22:15:00Z"
    }
  ]
}
```

---

## Photo Storage

Photos are stored as files on DO at `/data/suppr/photos/{restaurantID}/{filename}`. The API handles:
- **Upload**: multipart POST → resize to max 2048px → store file → create Photos table row
- **Download**: stream file from disk with appropriate Content-Type
- **Delete**: remove file from disk + delete Photos table row
- **Sync**: return a manifest of photo metadata since a timestamp (for desktop to download new photos)

---

## State Persistence (Not in the API)

The Wails app's UI state (sidebar width, last route, table states, tab states) is **per-machine, not shared**. It uses the `appkit.Store` pattern — stored locally in `state.json`, not on the DO server. No API endpoints needed for state.

---

## PATCH Semantics Detail

All updates use PATCH with partial payloads:

```json
PATCH /api/restaurants/42
{ "cuisine": "Israeli/Middle Eastern", "price_range": 4 }
```

The handler:
1. Parses the body into `map[string]any`
2. Validates each key against allowed fields
3. Validates each value's type and constraints
4. Builds a dynamic `UPDATE ... SET field1=?, field2=? WHERE id=?`
5. Updates `modified_at` automatically
6. Returns the full updated resource

Unknown fields → `INVALID_FIELD_VALUE` error. Missing required fields on CREATE → `MISSING_REQUIRED_FIELD` error.
