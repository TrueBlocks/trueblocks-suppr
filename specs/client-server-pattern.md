# Client-Server Pattern

This chapter specifies how the Wails desktop app communicates with the remote API server. This is a new pattern for the platform — all existing Wails apps (works, poetry, siteman, acrylic) use direct local database access. suppr's Go backend is an HTTP client, not a database owner.

---

## Architecture Comparison

### Existing Pattern (works, poetry, etc.)

```
Frontend → wailsjs binding → app/*.go → internal/db/ → local SQLite
```

The Go backend owns the database. Everything is local. No network involved.

### suppr Pattern

```
Frontend → wailsjs binding → app/*.go → pkg/client/ → HTTP → API server → SQLite on DO
```

The Go backend is an HTTP client. The database lives on a remote server. Every data operation is a network round-trip.

---

## Why This Pattern

suppr has multiple clients:
- Wails desktop app on one MacBook
- Wails desktop app on a second MacBook
- PWA on two iPhones

All need to see the same data. A shared remote database is the simplest solution. The Wails app becomes a client of the API, just like the PWA — it just happens to go through Go instead of JavaScript.

---

## Component Responsibilities

### `app/*.go` — Wails Bindings (Thin Proxy)

Each file exposes functions callable from the frontend. They do three things:
1. Call `pkg/client/` to make the API request
2. Translate errors into structured responses the frontend can route (see Error Handling below)
3. Return the result

*Illustrative (not definitive):*

```go
// app/restaurants.go
func (a *App) RestaurantList(query string) ([]models.Restaurant, error) {
    return a.client.RestaurantList(query)
}

func (a *App) RestaurantGet(id int64) (*models.Restaurant, error) {
    return a.client.RestaurantGet(id)
}

func (a *App) RestaurantUpdate(id int64, fields map[string]any) (*models.Restaurant, error) {
    return a.client.RestaurantUpdate(id, fields)
}
```

No business logic here. No database imports. Just delegation.

### `pkg/client/` — Go HTTP Client

A typed Go client for the suppr API. Used by both the Wails app and CLI tools.

*Illustrative (not definitive):*

```go
// pkg/client/client.go
type Client struct {
    baseURL    string
    apiKey     string
    httpClient *http.Client
}

func New(baseURL, apiKey string) *Client {
    return &Client{
        baseURL:    strings.TrimRight(baseURL, "/"),
        apiKey:     apiKey,
        httpClient: &http.Client{Timeout: 30 * time.Second},
    }
}

func (c *Client) RestaurantList(query string) ([]models.Restaurant, error) {
    var restaurants []models.Restaurant
    err := c.get("/api/restaurants", url.Values{"q": {query}}, &restaurants)
    return restaurants, err
}

func (c *Client) RestaurantUpdate(id int64, fields map[string]any) (*models.Restaurant, error) {
    var restaurant models.Restaurant
    err := c.patch(fmt.Sprintf("/api/restaurants/%d", id), fields, &restaurant)
    return &restaurant, err
}
```

Internal helpers handle the repetitive HTTP mechanics:

```go
func (c *Client) get(path string, params url.Values, result any) error {
    u := c.baseURL + path
    if len(params) > 0 {
        u += "?" + params.Encode()
    }
    req, err := http.NewRequest("GET", u, nil)
    if err != nil {
        return err
    }
    return c.do(req, result)
}

func (c *Client) do(req *http.Request, result any) error {
    req.Header.Set("X-API-Key", c.apiKey)
    req.Header.Set("Accept", "application/json")

    resp, err := c.httpClient.Do(req)
    if err != nil {
        return fmt.Errorf("API unreachable: %w", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode >= 400 {
        body, _ := io.ReadAll(resp.Body)
        return fmt.Errorf("API error %d: %s", resp.StatusCode, string(body))
    }

    if result != nil {
        return json.NewDecoder(resp.Body).Decode(result)
    }
    return nil
}
```

### `pkg/models/` — Shared Types

Go structs used by the client, the server, and the Wails app. Defined once, used everywhere.

*Illustrative (not definitive):*

```go
type Restaurant struct {
    RestaurantID int64   `json:"restaurantID"`
    Name         string  `json:"name"`
    Address      string  `json:"address"`
    City         string  `json:"city"`
    State        string  `json:"state"`
    Zip          string  `json:"zip"`
    Neighborhood string  `json:"neighborhood"`
    Cuisine      string  `json:"cuisine"`
    Website      string  `json:"website"`
    Phone        string  `json:"phone"`
    Status       string  `json:"status"`
    PriceRange   int     `json:"price_range"`
    BYOB         bool    `json:"byob"`
    Outdoor      bool    `json:"outdoor"`
    Reservations *bool   `json:"reservations"`
    Latitude     float64 `json:"latitude"`
    Longitude    float64 `json:"longitude"`
    Attributes   string  `json:"attributes"`
    Notes        string  `json:"notes"`
    CreatedAt    string  `json:"created_at"`
    ModifiedAt   string  `json:"modified_at"`
}
```

### `internal/api/` and `internal/db/` — Server-Side Only

The Wails app never imports these packages. They exist only in the API server binary.

---

## The `useApi()` Hook — Frontend Abstraction

The React frontend doesn't know whether it's running inside Wails or as a PWA. A single hook abstracts the difference:

*Illustrative (not definitive):*

```typescript
function useApi() {
  const isWails = !!window.runtime;
  return {
    listRestaurants: isWails
      ? (q: string) => ListRestaurants(q)           // wailsjs binding
      : (q: string) => fetchApi('/api/restaurants', { q }),  // direct fetch
    getRestaurant: isWails
      ? (id: number) => GetRestaurant(id)
      : (id: number) => fetchApi(`/api/restaurants/${id}`),
    updateRestaurant: isWails
      ? (id: number, fields: Record<string, unknown>) => UpdateRestaurant(id, fields)
      : (id: number, fields: Record<string, unknown>) => patchApi(`/api/restaurants/${id}`, fields),
  };
}
```

Components call `useApi()` and get typed functions. They never import wailsjs directly or construct fetch URLs. Adding a new API call means:
1. Add it to `pkg/client/` (Go)
2. Add it to `app/*.go` (Wails binding)
3. Add it to `useApi()` (frontend abstraction)
4. Use it in components

---

## Configuration

The Wails app reads its API server URL and API key from local config on startup:

```
~/.local/share/trueblocks/suppr/config.json
```

```json
{
    "apiURL": "https://suppr.trueblocks.io",
    "apiKey": "your-api-key-here"
}
```

During development, `apiURL` can point to `http://localhost:8420` for a local server.

### Startup

```go
func (a *App) Startup(ctx context.Context) {
    a.ctx = ctx
    cfg := loadConfig()
    a.client = client.New(cfg.APIURL, cfg.APIKey)
}
```

---

## Photo Uploads

The one case where the Wails app does more than proxy: file access. The desktop app can read local files that the PWA cannot.

*Illustrative (not definitive):*

```go
// app/photos.go
func (a *App) PhotoUpload(restaurantID int64, filePath string) (*models.Photo, error) {
    data, err := os.ReadFile(filePath)
    if err != nil {
        return nil, fmt.Errorf("cannot read file: %w", err)
    }
    return a.client.PhotoUpload(restaurantID, filepath.Base(filePath), data)
}
```

The client sends a multipart POST to the API server.

---

## Error Handling

The API returns structured error responses with severity (see API chapter). The client-server pattern preserves this structure through the chain:

1. **API server** returns `{ "error": { "code": "...", "message": "...", "severity": "..." } }`
2. **`pkg/client/`** parses the error body and returns a typed Go error containing the structured fields
3. **`app/*.go`** returns the error to the frontend via the Wails binding
4. **Frontend** reads the severity and routes:
   - `user` → toast notification (visible, dismissible)
   - `warning` → status bar update (persistent, non-intrusive)
   - `system` → log to file + brief toast ("Something went wrong")

| HTTP Status | Meaning | Severity | User Sees |
|-------------|---------|----------|-----------|
| Network failure | Server unreachable | system | "Cannot reach server. Check your connection." |
| 401 | Invalid API key | user | "Authentication failed. Check Settings." |
| 404 | Resource not found | user | "Restaurant not found." |
| 400 | Validation failure | user | The specific validation message |
| 409 | Conflict | warning | "This restaurant is already on that list." |
| 500 | Server failure | system | "Server error. Try again later." |

The user should **never** see a silent failure. Every error reaches a surface.

---

## Offline Behavior

If the API server is unreachable, the app cannot display or modify data. This is a deliberate simplification:

- No local cache or replica database
- No offline queue or sync
- The app shows an error state and retries on the next action

For a 2-user app on residential internet with a $6/month DO server, this is acceptable. If offline support becomes necessary later, the path is: add a local SQLite cache → sync on reconnect → last-write-wins conflict resolution. But this is not planned.

---

## UI State vs. Data

A critical distinction: **UI state stays local, data goes through the API.**

| What | Where | Why |
|------|-------|-----|
| Sidebar width, window position | Local (appkit.Store) | Personal preference, per-machine |
| Last route, active tab | Local (appkit.Store) | Per-machine navigation state |
| Table sort/filter state | Local (appkit.Store) | Personal preference |
| Restaurant records | API server | Shared between both users |
| Visit history | API server | Shared data |
| Photos | API server (filesystem) | Shared data |
| Recommendation config | API server | Shared, mutual consent |

---

## Development Workflow

### Local API Server

```fish
go run cmd/suppr-server/main.go --dev --port 8420
```

Set `apiURL` in config.json to `http://localhost:8420`.

### Pointing at Production

Set `apiURL` to `https://suppr.trueblocks.io`. The desktop app hits the real API. Useful for testing with real data.

### Vite Proxy

The Vite dev server proxies `/api/*` to the Go server:

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': 'http://localhost:8420'
    }
  }
});
```

---

## PWA Comparison

| | Wails Desktop | PWA Mobile |
|---|---|---|
| API calls via | `pkg/client/` (Go HTTP) | `fetch()` (JavaScript) |
| Auth | API key from config.json | API key from localStorage |
| File access | Full filesystem | Camera only (HTML input) |
| UI state | appkit.Store (file-based) | localStorage |
| Offline | Error state | Error state |
| Photo upload | Read from disk → multipart POST | Camera capture → multipart POST |

The frontend abstraction (`useApi()` hook) means components are identical regardless of which runtime they execute in.
