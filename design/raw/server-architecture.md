# suppr Server Architecture

## Overview

suppr runs as a Go API server on Digital Ocean, serving two clients: a Wails desktop app (macOS) and a PWA (iPhones). The server is the single source of truth — it owns the SQLite database, handles all CRUD operations, stores photos, and runs the recommendation engine.

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────────┐
│  Wails App   │     │  PWA (phone) │     │  DO API Server      │
│  laptop.local│────▶│  Safari      │────▶│  Go + chi + SQLite  │
│  laptop2     │     │  2 iPhones   │     │  suppr.trueblocks.io│
└──────────────┘     └──────────────┘     └─────────────────────┘
```

## Technology Choices

| Component | Choice | Why |
|-----------|--------|-----|
| **Language** | Go | Consistent with all other trueblocks-art apps. Single binary deployment. |
| **Router** | chi | Lightweight, idiomatic, middleware-friendly. |
| **Database** | SQLite (modernc.org/sqlite) | Pure Go, no CGO. 2 users, ~1000 rows. WAL mode for concurrent reads. |
| **Auth** | API key per user | Two known users, no registration flow. `X-API-Key` header on every request. |
| **Frontend** | React 18 + Mantine 8 + TypeScript 5 | Same stack as all other apps in the platform. |
| **Mobile** | PWA | No App Store. Camera via HTML input. Installable to home screen. |
| **Reverse proxy** | Caddy | Auto-TLS, simple config. Already running on DO for other sites. |
| **Deployment** | Siteman (PWA) + SCP (server binary) | PWA is static files. Server is a single Go binary with systemd. |

### Why Not PostgreSQL?

Two users, 276 restaurants, ~1000 total rows across all tables. SQLite handles millions. WAL mode gives concurrent reads with single-writer. No daemon, no admin, backups are `cp suppr.db suppr.db.bak`.

### Why Not a Native Phone App?

A PWA gives us:
- Install to home screen (looks native)
- Camera access (for food photos at the restaurant)
- No App Store review, no $99/year Apple dev account
- Shared codebase with the desktop frontend

### Why Digital Ocean Instead of Local?

The previous design ran on `desktop.local` with Tailscale for remote access. Problems:
- Desktop must be running 24/7
- Tailscale adds complexity for two non-technical users (Meriam's phone)
- No access if desktop is sleeping, updating, or off

DO solves all of this. A $6/month droplet is always on, publicly accessible via `suppr.trueblocks.io`, and Caddy handles TLS automatically.

## Server Binary

The API server binary lives at `cmd/suppr-server/main.go`. It:

1. Opens (or creates) the SQLite database at `/data/suppr/suppr.db`
2. Runs schema migrations
3. Sets up the chi router with middleware (auth, logging, CORS)
4. Listens on `localhost:8420`
5. Caddy reverse-proxies `suppr.trueblocks.io/api/*` to it

```go
func main() {
    db := db.Open("/data/suppr/suppr.db")
    defer db.Close()

    r := api.NewRouter(db)
    log.Println("suppr-server listening on :8420")
    http.ListenAndServe(":8420", r)
}
```

## Authentication

API key per user. Two keys, stored in the Users table. Every request must include `X-API-Key`.

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

No login flow, no sessions, no JWT. The API key is stored in:
- Desktop: `~/.local/share/trueblocks/suppr/config.json`
- PWA: `localStorage`

## Database

SQLite with WAL mode, stored at `/data/suppr/suppr.db` on DO.

### Tables

| Table | Description |
|-------|-------------|
| Restaurants | Core records: name, address, city, state, zip, neighborhood, cuisine, founder, chef, website, phone, status, source, price_range, byob, outdoor, reservations, lat/lng, notes |
| AwardSources | Award-granting organizations (4 rows: Philly Mag, Michelin, James Beard, Check Please) |
| AwardSourceUrls | Provenance URLs for each year's award list (9 rows of Wayback Machine captures) |
| Awards | Restaurant ↔ award source ↔ year with rank |
| Episodes | Check, Please! appearances: restaurant, season, episode, video_url |
| Users | 2 rows with name, email, API key |
| Visits | Visit log: restaurant, user, date, rating, occasion, spend, notes |
| Photos | Photo metadata (files stored on DO filesystem at `/data/suppr/photos/`) |
| Tags | Flexible tagging: restaurant ↔ tag |
| Intel | Restaurant news, tips, closings, openings |
| Lists | Named custom lists (Date Night, BYOB favorites, etc.) |
| ListItems | List membership: list ↔ restaurant |

### Schema Conventions

- PascalCase table names
- camelCase for ID columns (restaurantID, awardID)
- snake_case for all other columns
- `created_at` and `modified_at` timestamps on all tables
- FTS5 virtual table for full-text search across restaurants and intel

### Backups

Daily cron on DO: `cp /data/suppr/suppr.db /data/suppr/backups/suppr-$(date +%Y%m%d).db`. Keep 30 days. The database is small enough that a full copy takes milliseconds.

## API Surface

~60 REST endpoints. Full details in `api-surface.md`. Summary:

```
Restaurants:
  GET    /api/restaurants              → list (filterable)
  GET    /api/restaurants/:id          → detail
  POST   /api/restaurants              → create
  PATCH  /api/restaurants/:id          → partial update
  DELETE /api/restaurants/:id          → soft delete
  + sub-resource endpoints for awards, episodes, visits, photos, intel, tags

Visits:
  GET    /api/visits                   → all visits (filterable)
  POST   /api/visits                   → log a visit
  PATCH  /api/visits/:id              → update
  DELETE /api/visits/:id              → delete

Awards, Episodes, Intel, Photos, Tags, Lists:
  Standard CRUD patterns per api-surface.md

Recommendations:
  GET    /api/recommend/tonight        → scoring-based suggestion
  GET    /api/recommend/bucket-list    → unvisited award-winners
  GET    /api/recommend/revisit        → loved but overdue
  GET    /api/recommend/explore        → underexplored cuisines

Users:
  GET    /api/users/me                 → current user
  PATCH  /api/users/me                → update preferences

Health:
  GET    /api/health                   → server status
```

### PATCH Semantics

All updates use PATCH with partial payloads. The handler receives `map[string]any`, validates each field, and updates only what's provided. This maps directly to the EditableField pattern in the frontend.

### Photo Storage

Photos are stored as files on DO at `/data/suppr/photos/{restaurantID}/{filename}`. The API handles upload (multipart POST), metadata storage (Photos table), and download (file streaming).

## Deployment

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

**PWA**: `yarn build` → siteman deploys to `/var/www/suppr/` on DO.

**API server**: Cross-compile → SCP → restart systemd.

**Both**: `make deploy`.

## File Layout on DO

```
/data/suppr/
├── suppr.db                    # SQLite database
├── photos/                     # Uploaded photos
│   └── {restaurantID}/         # By restaurant
└── backups/                    # Daily DB snapshots

/var/www/suppr/                 # PWA static files (siteman)
├── index.html
├── assets/
├── manifest.json
└── sw.js

/usr/local/bin/suppr-server     # API server binary
```

---

## Toward Peer-to-Peer: The Federation Architecture

The DO server is Stage 1 infrastructure — a pragmatic choice for a couple who wants the app to work today. But suppr is designed with an eye toward a future where each couple runs their own node and nodes talk to each other directly. This section describes how we get there.

### The Path

```
Today (Stage 1):     One server, one couple, centralized
                     ┌─────────┐
                     │  DO     │
                     │  suppr  │
                     └─────────┘

Near future (Stage 2): Two servers, two couples, independent
                     ┌─────────┐     ┌─────────┐
                     │  Our    │     │  Their  │
                     │  suppr  │     │  suppr  │
                     └─────────┘     └─────────┘

Federation (Stage 3): Two servers, linked
                     ┌─────────┐────▶┌─────────┐
                     │  Our    │◀────│  Their  │
                     │  suppr  │     │  suppr  │
                     └─────────┘     └─────────┘

Groups (Stage 4):    Mesh of servers
                     ┌─────────┐────▶┌─────────┐
                     │  A      │◀────│  B      │
                     └────┬────┘     └────┬────┘
                          │               │
                     ┌────┴────┐     ┌────┴────┐
                     │  C      │◀────│  D      │
                     └─────────┘     └─────────┘
```

### What Makes This Possible

Several architectural decisions we've already made set up the P2P path:

1. **SQLite, not Postgres.** Each node is a single file. Easy to back up, easy to move, easy to run on a Raspberry Pi or a phone. No database server to configure.

2. **Go binary, not a Python/Node stack.** Cross-compile for any platform. A single binary that runs anywhere — laptop, VPS, Pi, even a phone via Termux.

3. **API-first design.** The Wails app already talks to the server via HTTP. Federation is just another HTTP client — one server talking to another server's API.

4. **API key auth, not session-based.** Easy to extend to inter-node auth. A peer node authenticates with an API key just like a user does.

5. **PATCH semantics.** Partial updates transfer cleanly between nodes — you don't need to sync entire records, just changes.

### The Federation Protocol

Federation means: sharing recommendations between nodes without merging databases. Each couple keeps their own data. What flows between nodes is a curated feed of what you want to share.

#### Data That Flows

| Shareable | Format | Direction |
|-----------|--------|-----------|
| Restaurant discovery | "We found a great place" — name, cuisine, neighborhood, why we liked it | Push to peers |
| Rating signal | "We went to X, rated it 4/5" — no details unless you choose to share | Push to peers |
| Photo | A photo of a dish, with restaurant context | Push to peers (optional) |
| Intel | "X closed" or "X opened a second location" | Push to peers |

#### Data That Stays Home

| Private | Why |
|---------|-----|
| Visit dates and frequency | Your schedule is nobody's business |
| Spend amounts | Financial privacy |
| Personal notes | "Meriam didn't like the server" stays between us |
| Lists | Your "Date Night" list is curated for you |
| Full recommendation history | The algorithm is personal |

#### The Message Format

A recommendation share is a simple JSON message, signed with the sender's key:

```json
{
  "type": "recommendation",
  "from": {
    "node": "suppr.trueblocks.io",
    "couple": "Jay & Meriam"
  },
  "restaurant": {
    "name": "Zahav",
    "cuisine": "Israeli",
    "neighborhood": "Society Hill",
    "city": "Philadelphia",
    "state": "PA",
    "website": "https://zahavrestaurant.com"
  },
  "signal": {
    "rating": 5,
    "visitCount": 3,
    "lastVisit": "2026-04",
    "tags": ["date-night", "special-occasion"],
    "note": "The lamb shoulder is life-changing. Get the whole thing."
  },
  "ts": "2026-05-17T14:30:00Z",
  "sig": "..."
}
```

This is enough for the receiving node to:
- Match against their own restaurant database (by name + city, fuzzy)
- Create a new restaurant record if they don't have it
- Store the recommendation as a special type of Intel ("Jay & Meriam recommend this")
- Factor it into their own recommendation engine ("friends loved this" bonus)

#### Peer Management

```
GET    /api/peers                → list linked peers
POST   /api/peers                → invite a peer (generates a pairing token)
POST   /api/peers/accept         → accept an invitation
DELETE /api/peers/:id            → unlink a peer
GET    /api/peers/:id/feed       → what they've shared with us
POST   /api/peers/:id/share      → share something with them
```

Pairing works like Bluetooth: one side generates a token (or QR code), the other side enters it. Both sides now have each other's API endpoint and a shared key. No central directory.

#### Sync Mechanics

Federation is **push-based, not pull-based**. When you share a recommendation, your server POSTs it to the peer's `/api/federation/inbox` endpoint. The peer processes it asynchronously. There's no polling, no subscription, no WebSocket.

```
Our server                              Their server
    │                                        │
    │  POST /api/federation/inbox            │
    │  { recommendation about Zahav }         │
    │───────────────────────────────────────▶│
    │                                        │
    │  201 Created                           │
    │◀───────────────────────────────────────│
    │                                        │
```

If the peer is offline, the message is queued locally and retried with exponential backoff. Messages are idempotent (keyed by hash), so duplicates are harmless.

### What Changes in the Codebase

The federation layer is additive — it doesn't change existing code, it extends it.

| New Package | Purpose |
|-------------|---------|
| `internal/api/federation.go` | Inbox handler, outbox sender, peer management endpoints |
| `internal/db/peers.go` | Peers table, outbox queue, inbox log |
| `pkg/models/federation.go` | Recommendation, Intel, and Peer types for federation messages |

New tables:

```sql
CREATE TABLE Peers (
    peerID       INTEGER PRIMARY KEY,
    name         TEXT NOT NULL,
    endpoint     TEXT NOT NULL,
    shared_key   TEXT NOT NULL,
    status       TEXT DEFAULT 'active',
    created_at   TEXT DEFAULT (datetime('now'))
);

CREATE TABLE Outbox (
    outboxID     INTEGER PRIMARY KEY,
    peerID       INTEGER NOT NULL REFERENCES Peers(peerID),
    message      TEXT NOT NULL,
    status       TEXT DEFAULT 'pending',
    attempts     INTEGER DEFAULT 0,
    last_attempt TEXT,
    created_at   TEXT DEFAULT (datetime('now'))
);

CREATE TABLE Inbox (
    inboxID      INTEGER PRIMARY KEY,
    peerID       INTEGER NOT NULL REFERENCES Peers(peerID),
    message_hash TEXT NOT NULL UNIQUE,
    message      TEXT NOT NULL,
    processed    INTEGER DEFAULT 0,
    created_at   TEXT DEFAULT (datetime('now'))
);
```

### The Desktop App Becomes the Server

In the fully realized version, the Wails desktop app doesn't need DO at all. The desktop app IS the server:

1. The Go backend runs a chi server on a local port
2. The PWA connects to the desktop directly (on the home LAN, or via a tunnel)
3. Federation messages go directly between desktop apps

This inverts the current architecture:

```
Today:   Wails app → pkg/client/ → HTTP → DO server → SQLite
Future:  Wails app → internal/db/ → SQLite (local)
         + federation layer ↔ other Wails apps
```

The `pkg/client/` layer becomes optional — used only when you want to hit a remote server. The app can work in either mode:
- **Hosted mode**: API on DO, clients connect remotely (current design)
- **Local mode**: Database on the laptop, PWA connects on LAN
- **Hybrid**: Database on laptop, DO acts as a relay for federation messages when laptops are sleeping

### Why Not Start with P2P?

Because it's harder to debug, harder to deploy for non-technical users, and harder to make reliable. The DO server gives us:
- Always-on access (no "is the laptop awake?")
- A stable URL for the PWA
- Simple deployment
- A working app today while we think about federation tomorrow

The key insight: **the API is the same either way.** Whether the server runs on DO or on your laptop, the endpoints, the auth, the database schema — all identical. The migration from hosted to local to federated is a deployment change, not a rewrite.

### Timeline Intuition

| Stage | When | What Changes |
|-------|------|-------------|
| 1 (Current) | Now | DO server, 2 users, done |
| 2 (Second couple) | When a friend says "I want this" | They deploy their own instance. We help them set it up. No code changes needed. |
| 3 (Federation) | When both couples want to share | Add federation layer (~500 lines of Go). Peer pairing. Push-based sharing. |
| 4 (Groups) | When 3+ couples are linked | Multi-peer fan-out. Group recommendation weighting. Group dining coordination. |
| 5 (Local mode) | When the architecture is proven | Wails app becomes the server. DO becomes optional relay. Full sovereignty. |

Stage 2 is free — it's just deploying the same binary twice. Stage 3 is the real work, but it's bounded: an inbox, an outbox, a peer table, and a share button. The existing API surface doesn't change.

---

## Future Possibilities (Not Planned for Stage 1)

- **Cron workers**: Auto-crawl restaurant websites for closures, news, menu changes. Populate Intel table automatically.
- **Email digests**: Weekly summary of intel, recommendations, and upcoming visits.
- **Reservation tracking**: Confirmation numbers, reminders. Currently use Resy/OpenTable directly.
- **Calendar integration**: iCal feed for reservations.
- **Polls**: "Where should we eat this week?" voting between the two users.
