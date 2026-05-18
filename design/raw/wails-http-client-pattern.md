# Wails Backend as HTTP Client

This document describes the pattern where the Wails app's Go backend delegates all data operations to a remote API server via HTTP, instead of accessing a local SQLite database directly.

This is a new pattern for the trueblocks-art platform. All existing Wails apps (works, poetry, siteman, acrylic) use direct local database access.

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
- Wails desktop app on laptop.local
- Wails desktop app on laptop2.local
- PWA on two iPhones

All need to see the same data. A shared remote database is the simplest solution. The Wails app becomes a client of the API, just like the PWA — it just happens to go through Go instead of JavaScript.

---

## Component Responsibilities

### `app/*.go` — Wails Bindings (Thin Proxy)

Each file exposes functions callable from the frontend. They do three things:
1. Call `pkg/client/` to make the API request
2. Translate HTTP errors into user-facing error messages
3. Return the result

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

A typed Go client for the suppr API. Used by both the Wails app and CLI tools (suppr-import, suppr-geocode).

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

Internal helpers handle the repetitive parts:

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

```go
// pkg/models/models.go
type Restaurant struct {
    RestaurantID int64  `json:"restaurantID"`
    Name         string `json:"name"`
    Address      string `json:"address"`
    City         string `json:"city"`
    State        string `json:"state"`
    Zip          string `json:"zip"`
    Neighborhood string `json:"neighborhood"`
    Cuisine      string `json:"cuisine"`
    Founder      string `json:"founder"`
    Chef         string `json:"chef"`
    Website      string `json:"website"`
    Phone        string `json:"phone"`
    Status       string `json:"status"`
    Source       string `json:"source"`
    PriceRange   string `json:"priceRange"`
    BYOB         bool   `json:"byob"`
    Outdoor      bool   `json:"outdoor"`
    Reservations string `json:"reservations"`
    Latitude     float64 `json:"latitude"`
    Longitude    float64 `json:"longitude"`
    Notes        string `json:"notes"`
    CreatedAt    string `json:"createdAt"`
    ModifiedAt   string `json:"modifiedAt"`
}
```

### `internal/api/` — HTTP Handlers (Server-Side Only)

Chi router handlers that receive HTTP requests, call `internal/db/`, and return JSON. The Wails app never imports this package.

### `internal/db/` — SQLite Operations (Server-Side Only)

Direct database access. The Wails app never imports this package.

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

During development, `apiURL` can point to `http://localhost:8420` to hit a local server.

### Startup

```go
// app/app.go
func (a *App) Startup(ctx context.Context) {
    a.ctx = ctx
    cfg := loadConfig()
    a.client = client.New(cfg.APIURL, cfg.APIKey)
}
```

---

## Photo Uploads

The one case where the Wails app does more than proxy: file access. The desktop app can read local files that the PWA cannot.

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

The client sends a multipart POST:

```go
// pkg/client/client.go
func (c *Client) PhotoUpload(restaurantID int64, filename string, data []byte) (*models.Photo, error) {
    var buf bytes.Buffer
    w := multipart.NewWriter(&buf)
    part, err := w.CreateFormFile("photo", filename)
    if err != nil {
        return nil, err
    }
    part.Write(data)
    w.Close()

    path := fmt.Sprintf("/api/restaurants/%d/photos", restaurantID)
    req, err := http.NewRequest("POST", c.baseURL+path, &buf)
    if err != nil {
        return nil, err
    }
    req.Header.Set("Content-Type", w.FormDataContentType())

    var photo models.Photo
    err = c.do(req, &photo)
    return &photo, err
}
```

---

## Error Handling

The client translates HTTP failures into Go errors. The Wails binding returns these to the frontend, which displays them via Mantine notifications.

| HTTP Status | Client Error | User Sees |
|-------------|-------------|-----------|
| Network failure | `API unreachable: ...` | "Cannot reach server. Check your connection." |
| 401 | `API error 401: invalid API key` | "Authentication failed. Check Settings." |
| 404 | `API error 404: restaurant not found` | "Restaurant not found." |
| 422 | `API error 422: name is required` | "Name is required." |
| 500 | `API error 500: internal error` | "Server error. Try again later." |

---

## Offline Behavior

If the API server is unreachable, the app cannot display or modify data. This is a deliberate simplification:

- No local cache or replica database
- No offline queue or sync
- The app shows an error state and retries on the next action

For a 2-user app on residential internet with a DO server, this is acceptable. If offline support becomes necessary in the future, the path is:
1. Add a local SQLite cache
2. Sync on reconnect
3. Conflict resolution (last-write-wins is fine for 2 users)

But this is not planned.

---

## UI State vs Data

A critical distinction: **UI state stays local, data goes through the API.**

| What | Where | Why |
|------|-------|-----|
| Sidebar width | Local (appkit.Store) | Personal preference |
| Last selected restaurant | Local (appkit.Store) | Per-machine state |
| Table column widths | Local (appkit.Store) | Personal preference |
| Active tab | Local (appkit.Store) | Per-machine state |
| Restaurant records | API server | Shared data |
| Visit history | API server | Shared data |
| Photos | API server | Shared data |

The Wails app uses appkit.Store (same as works) for UI state. It uses `pkg/client/` for everything else.

---

## Development

### Local API Server

```fish
go run cmd/suppr-server/main.go --dev --port 8420
```

Set `apiURL` in config.json to `http://localhost:8420` during development.

### Pointing at Production

Set `apiURL` to `https://suppr.trueblocks.io`. The desktop app hits the real API. Useful for testing with real data without running a local server.

### Frontend Development

The Vite dev server proxies `/api/*` to the Go server (local or remote). Configure in `vite.config.ts`:

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': 'http://localhost:8420'
    }
  }
});
```

---

## Comparison with PWA

The PWA does the same thing as the Wails app, but without the Go layer:

| | Wails Desktop | PWA Mobile |
|---|---|---|
| API calls via | `pkg/client/` (Go HTTP) | `fetch()` (JavaScript) |
| Auth | API key from config.json | API key from localStorage |
| File access | Full filesystem (os.ReadFile) | Camera only (HTML input) |
| UI state | appkit.Store (file-based) | localStorage |
| Offline | Error state | Error state |

The frontend components are shared. The `useApi()` hook detects the runtime and routes calls appropriately.
