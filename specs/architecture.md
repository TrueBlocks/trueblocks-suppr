# Architecture

This chapter specifies the system shape of suppr: what components exist, how they connect, why each choice was made, and how the architecture evolves over time.

---

## System Overview

suppr consists of three runtime components:

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────────┐
│  Wails App   │     │  PWA (phone) │     │  DO API Server      │
│  macOS       │────▶│  Safari      │────▶│  Go + chi + SQLite  │
│              │     │  2 iPhones   │     │  suppr.trueblocks.io│
└──────────────┘     └──────────────┘     └─────────────────────┘
```

- **Wails desktop app** — the primary interface. Runs on a MacBook. Go backend + React/Mantine frontend in a native WebView.
- **PWA** — the mobile interface. Runs in Safari on two iPhones. Same React components, communicates directly with the API server.
- **API server** — the single source of truth. A Go binary running on Digital Ocean. Owns the SQLite database, handles all CRUD, stores photos, runs the recommendation engine.

The desktop app does not touch the database directly. It calls the API server via HTTP, same as the PWA. This is the key architectural decision — it makes the future migration from hosted to local seamless (see Evolution Path below).

---

## Why This Shape

### Why not local-only?

Meriam's phone needs access when the laptop is sleeping, off, or away. A $6/month droplet is always on. No "is the laptop awake?" problem.

### Why not a web app?

Sovereignty. The browser is someone else's house. A desktop app runs on your hardware, stores data on your terms, doesn't need an internet connection for the UI to load. Wails gives native app packaging with a web-standard frontend.

### Why a PWA instead of a native phone app?

- No App Store review, no $99/year Apple developer account
- Camera access for food photos via HTML input
- Installable to home screen (looks native)
- Shared codebase with the desktop frontend — same React components

### Why Digital Ocean?

The previous design ran on `desktop.local` with Tailscale for remote access. Problems: desktop must be running 24/7, Tailscale adds complexity for non-technical users, no access if desktop is sleeping. DO solves all of this. Caddy handles TLS automatically.

---

## Technology Choices

| Component | Choice | Why |
|-----------|--------|-----|
| Language | Go | Single binary deployment. Consistent with the platform. |
| Router | chi | Lightweight, idiomatic, middleware-friendly. |
| Database | SQLite (modernc.org/sqlite) | Pure Go, no CGO. 2 users, ~1000 rows. WAL mode for concurrent reads. |
| Auth | API key per user | Two known users, no registration flow. |
| Frontend | React 18 + Mantine 8 + TypeScript 5 | Same stack as all apps in the platform. |
| Mobile | PWA | No App Store. Camera via HTML input. |
| Reverse proxy | Caddy | Auto-TLS, simple config. |
| Deployment | Siteman (PWA) + SCP (server binary) | Static files + single binary. |

### Why SQLite, Not PostgreSQL?

Two users, 276 restaurants, ~1000 total rows across all tables. SQLite handles millions. WAL mode gives concurrent reads with single-writer. No daemon, no admin. Backups are `cp suppr.db suppr.db.bak`.

---

## The Server Binary

The API server binary lives at `cmd/suppr-server/main.go`. On startup it:

1. Opens (or creates) the SQLite database at `/data/suppr/suppr.db`
2. Runs schema migrations
3. Sets up the chi router with middleware (auth, logging, CORS)
4. Listens on `localhost:8420`
5. Caddy reverse-proxies `suppr.trueblocks.io/api/*` to it

*Illustrative (not definitive):*

```go
func main() {
    db := db.Open("/data/suppr/suppr.db")
    defer db.Close()

    r := api.NewRouter(db)
    log.Println("suppr-server listening on :8420")
    http.ListenAndServe(":8420", r)
}
```

---

## Authentication

API key per user. Two keys, stored in the Users table. Every request must include the `X-API-Key` header.

No login flow, no sessions, no JWT. The API key is stored in:
- Desktop: `~/.local/share/trueblocks/suppr/config.json`
- PWA: `localStorage`

*Illustrative (not definitive):*

```go
func AuthMiddleware(db *db.DB) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            key := r.Header.Get("X-API-Key")
            user, err := db.UserByAPIKey(key)
            if err != nil {
                http.Error(w, "unauthorized", http.StatusUnauthorized)
                return
            }
            ctx := context.WithValue(r.Context(), userKey, user)
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}
```

---

## Deployment Topology

### File Layout on Digital Ocean

```
/data/suppr/
├── suppr.db                    # SQLite database
├── photos/                     # Uploaded photos
│   └── {restaurantID}/         # By restaurant
└── backups/                    # Daily DB snapshots

/var/www/suppr/                 # PWA static files (deployed by siteman)
├── index.html
├── assets/
├── manifest.json
└── sw.js

/usr/local/bin/suppr-server     # API server binary
```

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

### Systemd Service

```ini
[Unit]
Description=suppr API server
After=network.target

[Service]
ExecStart=/usr/local/bin/suppr-server
WorkingDirectory=/data/suppr
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Deploy Steps

- **PWA**: `yarn build` → siteman deploys to `/var/www/suppr/` on DO.
- **API server**: Cross-compile → SCP → restart systemd.
- **Both**: `make deploy`.

### Backups

Daily cron on DO: `cp /data/suppr/suppr.db /data/suppr/backups/suppr-$(date +%Y%m%d).db`. Keep 30 days. The database is small enough that a full copy takes milliseconds.

---

## Evolution Path

The architecture is designed to evolve through five stages without requiring a rewrite:

| Stage | When | What Changes |
|-------|------|--------------|
| 1 (Current) | Now | DO server, 2 users, done |
| 2 (Second couple) | When a friend says "I want this" | They deploy their own instance. No code changes needed. |
| 3 (Federation) | When both couples want to share | Add federation layer. Peer pairing. Push-based sharing. |
| 4 (Groups) | When 3+ couples are linked | Multi-peer fan-out. Group recommendation weighting. |
| 5 (Local mode) | When the architecture is proven | Wails app becomes the server. DO becomes optional relay. Full sovereignty. |

Stage 2 is free — it's just deploying the same binary twice. Stage 3 is the real work, but it's bounded. The existing API surface doesn't change.

### Why the API-First Design Enables This

The Wails app already talks to the server via HTTP. This means:
- Federation is just another HTTP client (one server talking to another server's API)
- The migration from "server on DO" to "server on your laptop" is a config change, not a rewrite
- API key auth extends naturally to inter-node authentication
- PATCH semantics transfer cleanly between nodes

The full federation protocol is specified in a separate chapter.

---

## Future Possibilities (Not in Scope for Stage 1)

- **Cron workers**: Auto-crawl restaurant websites for closures, news, menu changes. Populate Intel table automatically.
- **Email digests**: Weekly summary of intel, recommendations, and upcoming visits.
- **Reservation tracking**: Confirmation numbers, reminders.
- **Calendar integration**: iCal feed for reservations.
- **Polls**: "Where should we eat this week?" voting between the two users.
