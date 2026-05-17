# Check, Please! Server Architecture

## Vision

A self-hosted restaurant recommendation and management platform running on `desktop.local`, serving two users (you and your wife) across laptops and phones. The system maintains itself by crawling the web for fresh restaurant intelligence, and actively helps you decide where to eat.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    desktop.local (Mac)                       │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Web App  │  │ API      │  │ Cron     │  │ Email      │  │
│  │ (PWA)    │  │ Server   │  │ Workers  │  │ Sender     │  │
│  │ :8080    │  │ :8080    │  │ (launchd)│  │ (weekly)   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘  │
│       │              │             │              │         │
│       └──────────────┴──────┬──────┴──────────────┘         │
│                             │                               │
│                    ┌────────┴────────┐                       │
│                    │   SQLite DB     │                       │
│                    │ checkplease.db  │                       │
│                    └─────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
         │
         │  HTTPS (Tailscale or local network)
         │
    ┌────┴────┐
    │ Clients │
    ├─────────┤
    │ Laptop  │  → Full web UI (browser)
    │ Laptop  │  → Full web UI (browser)
    │ Phone   │  → PWA (installed to home screen)
    │ Phone   │  → PWA (installed to home screen)
    └─────────┘
```

## Technology Choices

| Component | Choice | Why |
|-----------|--------|-----|
| **Backend** | Python + FastAPI | Already using Python; FastAPI is fast, async, auto-generates API docs |
| **Database** | SQLite | 2 users, read-heavy, zero admin, already built, perfectly adequate |
| **Frontend** | Vanilla JS + PWA | No build step, instant load, installable on phones |
| **Styling** | Embedded CSS (current approach) | No dependencies, dark theme already built |
| **Mobile** | PWA (Progressive Web App) | No app store, works offline, push notifications, camera for photos |
| **Email** | Python + SMTP | Use Gmail SMTP or local postfix; simple for weekly digests |
| **Scheduler** | macOS launchd | Native, reliable, survives reboots |
| **Networking** | Tailscale (recommended) | Secure access from anywhere, no port forwarding, free for personal use |
| **Process manager** | launchd or supervisord | Keep the server running after reboots |

### Why Not PostgreSQL?

Two users, 276 restaurants, ~1000 rows of awards. SQLite handles millions of rows. WAL mode gives us concurrent reads with single-writer, which is fine. No admin, no daemon, easy backups (copy one file).

### Why Not a Native Phone App?

A PWA gives us:
- Install to home screen (looks like a native app)
- Works offline (service worker caches the shell)
- Camera access (for food photos)
- Push notifications (for reminders)
- No App Store review, no $99/year Apple dev account
- One codebase for everything

### Why Tailscale?

`desktop.local` is only visible on your home LAN. When you're at a restaurant, you need access. Options:
1. **Tailscale** (recommended): Free VPN mesh. Install on desktop + phones + laptops. Access via `https://desktop:8080` from anywhere. Encrypted, no port forwarding.
2. **Cloudflare Tunnel**: Free, exposes the server to the internet behind Cloudflare. More complex setup.
3. **Port forwarding + Dynamic DNS**: Old school, less secure.

## Database Schema Evolution

Starting from the current schema, we add:

```sql
-- User accounts (just you two, but proper auth)
CREATE TABLE users (
    id        INTEGER PRIMARY KEY,
    name      TEXT NOT NULL,
    email     TEXT NOT NULL UNIQUE,
    password  TEXT NOT NULL,  -- bcrypt hash
    prefs     TEXT            -- JSON: home_lat, home_lng, default_radius, dietary, etc.
);

-- Visit log
CREATE TABLE visits (
    id            INTEGER PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    user_id       INTEGER NOT NULL REFERENCES users(id),
    date          TEXT NOT NULL,       -- ISO date
    rating        INTEGER,            -- 1-5 stars
    occasion      TEXT,               -- date-night, casual, celebration, etc.
    notes         TEXT,
    created_at    TEXT DEFAULT (datetime('now'))
);

-- Restaurant tags (vibe, features)
CREATE TABLE tags (
    id            INTEGER PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    tag           TEXT NOT NULL,       -- byob, outdoor, romantic, lively, etc.
    UNIQUE(restaurant_id, tag)
);

-- Price range added to restaurants
ALTER TABLE restaurants ADD COLUMN price_range INTEGER; -- 1-4

-- Geocoding
ALTER TABLE restaurants ADD COLUMN latitude  REAL;
ALTER TABLE restaurants ADD COLUMN longitude REAL;

-- Reservation tracking
CREATE TABLE reservations (
    id            INTEGER PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    date          TEXT NOT NULL,
    time          TEXT NOT NULL,
    party_size    INTEGER DEFAULT 2,
    platform      TEXT,               -- opentable, resy, phone, walk-in
    confirmation  TEXT,               -- confirmation number
    notes         TEXT,
    status        TEXT DEFAULT 'confirmed', -- confirmed, cancelled, completed
    created_by    INTEGER REFERENCES users(id),
    created_at    TEXT DEFAULT (datetime('now'))
);

-- Calendar events (linked to reservations or standalone)
CREATE TABLE calendar_events (
    id              INTEGER PRIMARY KEY,
    reservation_id  INTEGER REFERENCES reservations(id),
    title           TEXT NOT NULL,
    date            TEXT NOT NULL,
    time            TEXT,
    notes           TEXT,
    created_at      TEXT DEFAULT (datetime('now'))
);

-- Web intelligence (cron job findings)
CREATE TABLE intel (
    id            INTEGER PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    type          TEXT NOT NULL,       -- closure, menu-change, award, discount, event, news
    headline      TEXT NOT NULL,
    detail        TEXT,
    source_url    TEXT,
    discovered_at TEXT DEFAULT (datetime('now')),
    dismissed     INTEGER DEFAULT 0    -- user can dismiss stale intel
);

-- Weekly poll (which restaurant this week?)
CREATE TABLE polls (
    id         INTEGER PRIMARY KEY,
    week_start TEXT NOT NULL,          -- ISO date of Monday
    status     TEXT DEFAULT 'open',    -- open, decided, skipped
    winner_id  INTEGER REFERENCES restaurants(id),
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE poll_votes (
    id            INTEGER PRIMARY KEY,
    poll_id       INTEGER NOT NULL REFERENCES polls(id),
    user_id       INTEGER NOT NULL REFERENCES users(id),
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    notes         TEXT,
    created_at    TEXT DEFAULT (datetime('now'))
);
```

## API Design

```
Authentication:
  POST   /api/login                    → session token

Restaurants:
  GET    /api/restaurants              → list (with filters: cuisine, neighborhood, price, tags)
  GET    /api/restaurants/:id          → detail (includes awards, appearances, visits, intel)
  PATCH  /api/restaurants/:id          → update (price_range, tags, status, etc.)

Visits:
  GET    /api/visits                   → visit history (filterable by user, date range)
  POST   /api/visits                   → log a visit (restaurant_id, rating, notes, occasion)
  PATCH  /api/visits/:id               → update a visit

Recommendations:
  GET    /api/recommend                → "where tonight?" (params: occasion, cuisine, price, mood)
  GET    /api/recommend/bucket-list    → unvisited award-winners
  GET    /api/recommend/revisit        → loved but overdue

Reservations:
  GET    /api/reservations             → upcoming reservations
  POST   /api/reservations             → create reservation
  PATCH  /api/reservations/:id         → update/cancel
  DELETE /api/reservations/:id         → delete

Calendar:
  GET    /api/calendar                 → events for date range
  GET    /api/calendar/ical            → iCal feed (subscribe from Apple Calendar)

Polls:
  GET    /api/polls/current            → this week's poll
  POST   /api/polls/current/vote       → cast vote
  GET    /api/polls/history            → past polls

Intel:
  GET    /api/intel                    → recent discoveries
  POST   /api/intel/:id/dismiss        → dismiss stale intel
```

## Cron Jobs (launchd)

| Job | Schedule | What It Does |
|-----|----------|-------------|
| **Freshness check** | Daily, 6am | For each restaurant, check if website is still up (HEAD request). Flag closures. |
| **News crawler** | Daily, 7am | Search Google News for each restaurant name + Philadelphia. Store new articles in `intel`. |
| **Award scanner** | Monthly, 1st | Check Philly Mag, Eater, Infatuation for new lists. |
| **Weekly poll** | Monday 9am | Create new poll, email both users with top suggestions + voting link. |
| **Reservation reminder** | Daily, 10am | Email reminder for reservations in next 48 hours. |
| **Weekly digest** | Friday 5pm | Email summary: intel highlights, upcoming reservation, poll results, "try this weekend" suggestion. |

### News Crawler Strategy

For 276 restaurants, we can't hit Google 276 times daily. Instead:
1. Batch by priority: check award-winners (196) weekly, others monthly
2. Use Google News RSS: `https://news.google.com/rss/search?q="restaurant+name"+Philadelphia` — no API key needed, no rate limiting on RSS
3. Deduplicate by URL
4. Only store genuinely new intel (new URLs not seen before)

## Frontend Pages

### Desktop/Laptop Views
1. **Dashboard** — Intel feed, upcoming reservations, this week's poll, quick "tonight" button
2. **Restaurant Directory** — Current grid view, enhanced with price/tags/visit status
3. **Restaurant Detail** — Awards, visits, intel, reservation history, "book it" button
4. **50 Best by Year** — Current view
5. **Episodes** — Current view
6. **Visit History** — Timeline of where you've been, ratings, notes
7. **Calendar** — Month view with reservations and events
8. **Settings** — User prefs, home location, dietary restrictions

### Phone Views (PWA)
Same pages, responsive layout. Key phone-specific features:
1. **Quick Review** — While at restaurant: star rating + quick notes + photo. Minimal UI, fast.
2. **"Where are we going?"** — Tonight's recommendation, one tap to navigate (opens Maps)
3. **Reservation card** — Confirmation number, time, address, one tap to call

## Deployment on desktop.local

```bash
# Project structure on desktop.local
~/checkplease/
├── checkplease.db          # the database
├── server.py               # FastAPI app
├── cmd/                    # maintenance scripts
├── docs/                   # static site (fallback)
├── design/                 # design docs
├── static/                 # CSS, JS, icons, manifest
│   ├── app.js
│   ├── style.css
│   ├── manifest.json       # PWA manifest
│   └── sw.js               # service worker
├── templates/              # HTML templates (Jinja2)
├── cron/                   # launchd plist files
│   ├── com.checkplease.freshness.plist
│   ├── com.checkplease.news.plist
│   ├── com.checkplease.poll.plist
│   └── com.checkplease.digest.plist
└── backups/                # daily DB snapshots
```

### Server startup
```bash
# Install (one time)
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn aiofiles python-multipart bcrypt

# Run
uvicorn server:app --host 0.0.0.0 --port 8080

# Or via launchd for auto-start on boot
```

## Development Workflow

You develop on your laptop, the real app runs on `desktop.local`. Two options:

### Option A: Live Deploy (preferred)

Your laptop is the development machine. Every push to the server restarts the live app. You're always using the real database and the real server — no stale copies.

```
laptop (develop)                    desktop.local (run)
┌─────────────┐    git push /       ┌──────────────────┐
│ Edit code   │───rsync──────────→  │ Server restarts  │
│ Test locally│    (Makefile)        │ Real DB, real app│
│ (optional)  │                     │ Serves everyone  │
└─────────────┘                     └──────────────────┘
```

**How it works:**
- A `Makefile` target: `make deploy`
  - `rsync` copies code (not the DB) to `desktop.local:~/checkplease/`
  - `ssh desktop.local 'launchctl kickstart -k gui/$(id -u)/com.checkplease.server'` restarts the server
- Takes ~2 seconds. You see changes live immediately.
- The database lives ONLY on `desktop.local` — never copied to laptop
- To query the DB during development, use `ssh desktop.local sqlite3 ~/checkplease/checkplease.db "..."`
- The `checkplease` CLI tool can work in two modes:
  - `--local` (optional): uses a local dev copy of the DB
  - Default: hits the server API at `http://desktop.local:8080/api/...`

**Why this is safe:**
- Code is versioned in git — easy to roll back
- Database is never overwritten by deploy (rsync excludes `checkplease.db`, `backups/`, `.venv/`)
- Server restart is graceful (in-flight requests complete)

### Option B: Local Dev Server (fallback)

Run the server locally on your laptop with a stale DB snapshot. Publish to desktop.local only when ready.

```
laptop                              desktop.local
┌──────────────┐                    ┌──────────────────┐
│ Local server │                    │ Production server│
│ Stale DB copy│   make publish →   │ Real DB          │
│ Port 8080    │                    │ Port 8080        │
└──────────────┘                    └──────────────────┘
```

- `make snapshot` — pulls a DB copy from desktop.local for local testing
- `make publish` — same as `make deploy` above
- Downside: you test against stale data, visit logs diverge

**Recommendation:** Option A. You're the only developer, and the deploy is a 2-second rsync. Developing against the real app and real data catches problems faster. Option B is there if desktop.local is down or unreachable.

### Makefile

```makefile
SERVER = desktop.local
REMOTE_DIR = ~/checkplease
EXCLUDE = --exclude=checkplease.db --exclude=backups/ --exclude=.venv/ \
          --exclude=.git/ --exclude=__pycache__/ --exclude='*.pyc' \
          --exclude=checkplease.xlsx

deploy:
	rsync -avz $(EXCLUDE) ./ $(SERVER):$(REMOTE_DIR)/
	ssh $(SERVER) 'launchctl kickstart -k gui/$$(id -u)/com.checkplease.server'
	@echo "Deployed and restarted."

snapshot:
	scp $(SERVER):$(REMOTE_DIR)/checkplease.db ./checkplease-dev.db
	@echo "Snapshot saved to checkplease-dev.db"

logs:
	ssh $(SERVER) 'tail -f $(REMOTE_DIR)/logs/server.log'

status:
	ssh $(SERVER) 'launchctl print gui/$$(id -u)/com.checkplease.server'
```

## Backup Strategy

SQLite is a single file — backups are trivial. Three layers of protection:

### Layer 1: Daily Snapshots (on desktop.local)

A launchd job runs daily at 3am:
```bash
#!/bin/bash
DB=~/checkplease/checkplease.db
BACKUP_DIR=~/checkplease/backups
DATE=$(date +%Y-%m-%d)
cp "$DB" "$BACKUP_DIR/checkplease-$DATE.db"
# Keep 90 days
find "$BACKUP_DIR" -name "checkplease-*.db" -mtime +90 -delete
```

### Layer 2: Weekly Off-Site (to your laptop)

A launchd job on your laptop (or a cron entry) pulls the latest backup weekly:
```bash
#!/bin/bash
scp desktop.local:~/checkplease/backups/checkplease-$(date +%Y-%m-%d).db \
    ~/Desktop/CheckPlease/backups/
```

Or add it to the Makefile:
```makefile
backup:
	mkdir -p backups
	scp $(SERVER):$(REMOTE_DIR)/checkplease.db backups/checkplease-$$(date +%Y-%m-%d).db
	@echo "Backup saved."
```

### Layer 3: Git for Code (not data)

The code (server, templates, static files, cron scripts) lives in a git repo. Push to GitHub for off-site code backup. The database is `.gitignore`d — it's data, not code.

### Recovery

| Scenario | Recovery |
|----------|----------|
| Accidental bad data | Restore from yesterday's snapshot: `cp backups/checkplease-YYYY-MM-DD.db checkplease.db` |
| Server disk failure | Restore from laptop's weekly backup + rebuild venv |
| Both machines die | Restore code from GitHub + most recent backup from wherever survives |

## Phasing

### Phase 1: Server Foundation (get it running on desktop.local)
- [ ] Set up project on desktop.local (clone/copy files, venv)
- [ ] FastAPI server serving the current static site
- [ ] API endpoints: restaurants (list, detail), basic auth (2 hardcoded users)
- [ ] Tailscale setup for remote access
- [ ] launchd plist to auto-start server on boot
- [ ] Verify access from both laptops + phones

### Phase 2: Visit Logging + Basic Recommendations
- [ ] visits table + API
- [ ] "Quick Review" phone UI
- [ ] `GET /api/recommend` with basic scoring (award rank + unvisited bonus)
- [ ] "Bucket List" and "Revisit" endpoints
- [ ] Price range + tags for top 50 restaurants (manual entry through UI)

### Phase 3: Weekly Polls + Email
- [ ] polls/votes tables + API
- [ ] Weekly poll creation (cron)
- [ ] Email setup (Gmail SMTP app password)
- [ ] Weekly digest email with poll, suggestions, intel
- [ ] Poll voting UI (email links to web page)

### Phase 4: Reservations + Calendar
- [ ] reservations table + API + UI
- [ ] Calendar view in web UI
- [ ] iCal feed endpoint (subscribe from Apple Calendar)
- [ ] Reservation reminders (email)

### Phase 5: Intelligence Crawler
- [ ] Google News RSS crawler (cron)
- [ ] Website freshness checker (cron)
- [ ] Intel feed in dashboard UI
- [ ] Dismiss/archive intel

### Phase 6: Polish
- [ ] PWA manifest + service worker (offline support, install prompt)
- [ ] Photo uploads for visits
- [ ] Geocoding + map view + "near me" recommendations
- [ ] Smart recommendations (learn from visit history patterns)
- [ ] Reservation platform deep links (OpenTable, Resy)

## Open Questions — Resolved

1. **Hosting:** Digital Ocean servers (always-on, root access). Deployment via `siteman` (Hugo push tool already in use). Stack details deferred until proper GitHub repo is set up in the uni-repo. No Tailscale needed — public server.
2. **Server uptime:** 24/7 on Digital Ocean. Cron jobs will work.
3. **Email:** Deferred to implementation time.
4. **Tagging:** Worth doing. Automate by scraping restaurant websites for price signals, BYOB mentions, vibe keywords, menus, etc. Manual cleanup pass after.
5. **Photos:** Yes — food photo uploads with reviews.
6. **SSH/Deploy:** Keys already working under siteman. Will wire up when ready.
7. **Git repo:** Public GitHub is fine. Only code goes to GitHub — the database (which has no personal data beyond your visit notes) stays on the server, never pushed to git. User passwords would be bcrypt hashes in the DB, not in code. Email addresses could be env vars or a config file that's `.gitignore`d.
