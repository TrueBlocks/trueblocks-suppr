# suppr Repo Structure

This document describes the folder layout, build targets, deployment strategy, and development workflow for the suppr submodule.

---

## Folder Layout

```
suppr/
├── main.go                    # Wails app entry point
├── go.mod                     # Single Go module for all Go code
├── wails.json
├── package.json               # Yarn scripts (lint, test, type-check, build)
├── Makefile
│
├── app/                       # Wails bindings (Go → frontend)
│   ├── app.go                 # App struct, startup/shutdown, config
│   ├── restaurants.go         # Restaurant CRUD → delegates to pkg/client
│   ├── visits.go
│   ├── awards.go
│   ├── episodes.go
│   ├── photos.go
│   ├── intel.go
│   ├── lists.go
│   ├── recommend.go
│   └── state.go               # UI state persistence (local only)
│
├── cmd/
│   ├── suppr-server/          # API server binary (deployed to DO)
│   │   └── main.go
│   ├── suppr-import/          # One-time migration from checkplease.db
│   │   └── main.go
│   └── suppr-geocode/         # Address/lat-lng enrichment tool
│       └── main.go
│
├── pkg/
│   ├── client/                # Go HTTP client to the API
│   │   └── client.go          # RestaurantList(), VisitCreate(), etc.
│   └── models/                # Shared Go types (Restaurant, Visit, etc.)
│       └── models.go
│
├── internal/
│   ├── api/                   # HTTP handlers (server-side only)
│   │   ├── router.go          # chi router setup + middleware
│   │   ├── restaurants.go
│   │   ├── visits.go
│   │   ├── awards.go
│   │   ├── episodes.go
│   │   ├── photos.go
│   │   ├── intel.go
│   │   ├── lists.go
│   │   ├── recommend.go
│   │   └── auth.go            # API key middleware
│   └── db/                    # SQLite operations (server-side only)
│       ├── db.go              # Open, migrate, close
│       ├── restaurants.go
│       ├── visits.go
│       ├── awards.go
│       ├── episodes.go
│       ├── photos.go
│       ├── intel.go
│       ├── lists.go
│       └── recommend.go
│
├── frontend/                  # React + Mantine (shared by Wails + PWA)
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── utils/
│   │   └── pwa/               # PWA manifest, service worker, offline page
│   ├── index.html
│   ├── package.json
│   └── eslint.config.js
│
├── build/                     # Wails build artifacts
├── design/                    # Architecture docs
├── articles/                  # Small batch apps article series
├── original/                  # Archived CheckPlease database
└── ai/                        # AI agent instructions + ToDoList
```

---

## Dependency Graph

```
app/              → pkg/client/  → pkg/models/
cmd/suppr-server/ → internal/api/ → internal/db/ → pkg/models/
cmd/suppr-import/ → internal/db/  → pkg/models/
cmd/suppr-geocode/→ internal/db/
```

- `pkg/models/` and `pkg/client/` are shared across the Wails app, the server, and CLI tools.
- `internal/api/` and `internal/db/` are server-only — the Wails app never touches the database directly.
- Single `go.mod` covers everything. No workspace complexity.

---

## Frontend: Wails + PWA from One Codebase

The same React components serve both the Wails desktop app and the PWA. The difference is how API calls are made:

- **Wails desktop**: Calls Go functions via `wailsjs/` bindings, which delegate to `pkg/client/` (HTTP to API server).
- **PWA mobile**: Calls the API directly via `fetch()` with API key header.

A `useApi()` hook abstracts this:

```typescript
function useApi() {
  const isWails = !!window.runtime;
  return {
    listRestaurants: isWails
      ? () => ListRestaurants()           // wailsjs binding
      : () => fetchApi('/api/restaurants') // direct fetch
  };
}
```

PWA-specific files (manifest.json, service worker, offline fallback) live in `frontend/src/pwa/`.

---

## Deployment

### PWA (frontend)

Deployed as a static site via siteman to Digital Ocean.

1. `yarn build` → produces `frontend/dist/`
2. Siteman deploys `frontend/dist/` to `/var/www/suppr/` on DO
3. Caddy serves static files at `suppr.trueblocks.io/*`

### API Server (backend)

Deployed as a Go binary with a systemd service on Digital Ocean.

1. `GOOS=linux GOARCH=amd64 go build -o suppr-server cmd/suppr-server/main.go`
2. SCP binary to DO
3. Restart systemd service
4. Caddy proxies `suppr.trueblocks.io/api/*` to `localhost:8420`

### Caddy Config

```
suppr.trueblocks.io {
    handle /api/* {
        reverse_proxy localhost:8420
    }
    handle {
        root * /var/www/suppr
        try_files {path} /index.html
        file_server
    }
}
```

The `try_files` fallback enables SPA client-side routing — any path that doesn't match a real file returns `index.html`, and React Router handles it.

### Wails Desktop App

Built locally via `wails build`. Produces `build/bin/suppr.app`. Not deployed — runs on laptop.local and laptop2.local.

---

## Development Workflow

### Frontend + Backend Together (Full Stack)

```fish
# Terminal 1: Vite dev server (hot reload on frontend changes)
yarn dev

# Terminal 2: Local API server
go run cmd/suppr-server/main.go --dev --port 8420
```

Vite's dev server proxies `/api/*` to `localhost:8420` (configured in `vite.config.ts`). Frontend changes hot-reload instantly. Backend changes require restarting `go run`.

### Wails Desktop App

```fish
wails dev
```

Runs the Wails app with live reload. The Go backend (`app/`) makes HTTP calls to the API server (local or DO, configurable).

### Frontend Only

```fish
yarn dev
```

Points at the DO API server. No local Go process needed.

---

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make build` | Build Wails app (`wails build`) |
| `make server` | Build API server to `~/source/suppr-server` |
| `make import` | Build import tool to `~/source/suppr-import` |
| `make geocode` | Build geocode tool to `~/source/suppr-geocode` |
| `make cmds` | Build all CLI tools (server + import + geocode) |
| `make deploy-pwa` | Build frontend, deploy via siteman |
| `make deploy-server` | Cross-compile server, SCP to DO, restart service |
| `make deploy` | Deploy both PWA and server |
| `make lint` | `yarn lint --fix; and yarn type-check` |
| `make test` | Run tests |
| `make clean` | Remove build artifacts |

---

## Data Storage

| What | Where | Managed By |
|------|-------|------------|
| SQLite database | DO: `/data/suppr/suppr.db` | API server |
| Photos | DO: `/data/suppr/photos/` | API server |
| PWA static files | DO: `/var/www/suppr/` | Siteman |
| Server binary | DO: `/usr/local/bin/suppr-server` | Manual SCP |
| Desktop UI state | Local: `~/.local/share/trueblocks/suppr/` | Wails app (appkit.Store) |
| Wails app bundle | Local: `build/bin/suppr.app` | `wails build` |
