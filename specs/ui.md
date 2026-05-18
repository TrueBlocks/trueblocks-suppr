# User Interface

This chapter specifies the complete user interface for suppr — both the Wails desktop app and the mobile PWA. The two share a framework (React + Mantine 8) but have distinct layouts appropriate to their form factors.

---

## Desktop Wails App

### Header

```
┌─────────────────────────────────────────────────────────────┐
│ 🍽 suppr                               A Dining Companion   │
└─────────────────────────────────────────────────────────────┘
```

Title left, subtitle center, dark mode toggle right.

### Sidebar Navigation

Collapsible, resizable sidebar with icon + label items.

| # | Nav Item | Icon | Has Tabs | Hotkey |
|---|----------|------|----------|--------|
| 1 | **Dashboard** | `IconChefHat` | No | Cmd+1 |
| 2 | **Restaurants** | `IconToolsKitchen2` | List / Detail | Cmd+2 |
| 3 | **Visits** | `IconCalendarEvent` | List / Detail | Cmd+3 |
| 4 | **Awards** | `IconTrophy` | List / Detail | Cmd+4 |
| 5 | **Episodes** | `IconDeviceTv` | List / Detail | Cmd+5 |
| 6 | **Intel** | `IconNews` | List / Detail | Cmd+6 |
| — | *(bottom section)* | | | |
| 7 | **Recommend** | `IconSparkles` | No (wizard-style) | Cmd+7 |
| 8 | **Settings** | `IconSettings` | Tabbed | Cmd+8 |

---

### Dashboard

At-a-glance stats and actionable items:

```
┌─────────────────────────────────────────────────────────────┐
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ 276      │ │ 42       │ │ 18       │ │ 5 ★      │      │
│  │Restaurants│ │ Visited  │ │ Cuisines │ │ Avg Rating│      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
│  RECENT VISITS                    INTEL ALERTS              │
│  ┌─────────────────────────┐     ┌──────────────────┐      │
│  │ Zahav — ★★★★★ — May 10 │     │ ⚠ Closure: Foo   │      │
│  │ Vernick — ★★★★ — May 3 │     │ 🏆 New award: Bar │      │
│  │ Talula's — ★★★★ — Apr  │     │ 📰 Menu change:..│      │
│  └─────────────────────────┘     └──────────────────┘      │
│                                                             │
│  BUCKET LIST (Top 5 Unvisited)   YOUR PATTERNS             │
│  ┌─────────────────────────┐     ┌──────────────────┐      │
│  │ 1. Restaurant X — 5yr  │     │ Fav cuisine: Ital│      │
│  │ 2. Restaurant Y — 4yr  │     │ Fav hood: Ritten │      │
│  │ 3. Restaurant Z — 3yr  │     │ Avg $/visit: $$  │      │
│  └─────────────────────────┘     └──────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

Dashboard sections:
- **Stat Cards** (top row): Total restaurants, total visited, distinct cuisines, average rating
- **Recent Visits**: Last 3–5 visits with restaurant name, rating, date
- **Intel Alerts**: Undismissed intel items (closures, new awards, menu changes)
- **Bucket List**: Top 5 unvisited award-winning restaurants
- **Your Patterns**: Aggregate insights (favorite cuisine, favorite neighborhood, average spend)

---

### Restaurants — List Tab

DataTable with sorting, filtering, search, persisted state.

| Column | Width | Sortable | Filterable | Notes |
|--------|-------|----------|------------|-------|
| Name | 30% | ✓ | search only | Primary display |
| Cuisine | 15% | ✓ | ✓ dropdown | |
| Neighborhood | 15% | ✓ | ✓ dropdown | |
| Price | 8% | ✓ | ✓ dropdown | $–$$$$ |
| Rating | 8% | ✓ | ✓ range | Avg from Visits |
| Awards | 8% | ✓ | ✓ range | Count of appearances |
| BYOB | 5% | ✓ | ✓ dropdown | Yes/No |
| Status | 8% | ✓ | ✓ dropdown | open/closed/seasonal |

Click row → navigate to Restaurant Detail.

Filter dropdowns loaded dynamically from the backend via `GetRestaurantFilterOptions()`.

---

### Restaurants — Detail Tab

Detail view with vertical sub-tabs:

```
┌──────────────────────────────────────────────────────────────┐
│ ◀ ▶  Zahav                                    12 of 276     │
│      Mediterranean · Rittenhouse · $$$$ · BYOB: No          │
├──────────┬───────────────────────────────────────────────────┤
│ Overview │  [fields, tags, notes, map link]                  │
│ Visits   │                                                   │
│ Awards   │                                                   │
│ Episodes │                                                   │
│ Photos   │                                                   │
│ Intel    │                                                   │
│ Lists    │                                                   │
│ Preview  │                                                   │
└──────────┴───────────────────────────────────────────────────┘
```

**Sub-tabs:**

| Sub-Tab | Content |
|---------|---------|
| **Overview** | Address, phone, website, status, reservations, outdoor, tags, notes, map link — all `EditableField` components |
| **Visits** | DataTable of visits: date, who, rating, occasion, notes. "Log Visit" button. |
| **Awards** | DataTable of award appearances: year, rank, category. Read-only. |
| **Episodes** | DataTable of Check Please! appearances + embedded video player when `embed_url` available |
| **Photos** | Grid of photos. Upload button. Click to enlarge in modal. |
| **Intel** | DataTable of intel items. Dismiss button per row. |
| **Lists** | Which lists contain this restaurant. Add/remove buttons. |
| **Preview** | Cached website preview via local file server. Refresh + Open in Browser buttons. |

Sub-tab cycling: `Option+Shift+2`.

---

### Visits — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 25% | ✓ | search only |
| Date | 12% | ✓ | range |
| Who | 10% | ✓ | ✓ dropdown |
| Rating | 8% | ✓ | ✓ range |
| Occasion | 12% | ✓ | ✓ dropdown |
| Cuisine | 12% | ✓ | ✓ dropdown |
| Neighborhood | 12% | ✓ | ✓ dropdown |
| Notes | 9% | — | search only |

### Visits — Detail Tab

Full visit record with DetailHeader (prev/next), restaurant link, all fields editable. "Return to Restaurant" button when navigated from a restaurant's Visits sub-tab.

---

### Awards — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 30% | ✓ | search only |
| Source | 15% | ✓ | ✓ dropdown |
| Year | 10% | ✓ | ✓ dropdown |
| Rank | 10% | ✓ | ✓ range |
| Category | 20% | ✓ | ✓ dropdown |

---

### Episodes — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 30% | ✓ | search only |
| Season | 10% | ✓ | ✓ dropdown |
| Episode | 10% | ✓ | ✓ range |
| Air Date | 15% | ✓ | range |
| Notes | 35% | — | search only |

---

### Intel — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 25% | ✓ | search only |
| Type | 12% | ✓ | ✓ dropdown |
| Headline | 30% | ✓ | search only |
| Discovered | 12% | ✓ | range |
| Source | 12% | — | — |
| Dismissed | 9% | ✓ | ✓ dropdown |

---

### Recommend Page

Wizard/tool UI — not a standard List/Detail.

```
┌─────────────────────────────────────────────────────┐
│  Where should we eat tonight?                        │
│                                                      │
│  Occasion:  [date night ▼]                           │
│  Cuisine:   [any ▼]                                  │
│  Price:     [any ▼]                                  │
│  BYOB:      [don't care ▼]                           │
│  Mood:      [romantic ▼]                             │
│                                                      │
│  [✨ Recommend]                                      │
│                                                      │
│  ┌──────────────────────────────────────────────┐    │
│  │ 1. Zahav — "Award-winning, you haven't been  │    │
│  │    in 4 months" — $$$$                        │    │
│  │ 2. Vernick — "BYOB you loved last time" — $$ │    │
│  │ 3. Talula's — "New 50 Best, never visited"   │    │
│  └──────────────────────────────────────────────┘    │
│                                                      │
│  Tabs: [Tonight] [Bucket List] [Revisit] [Explore]   │
└─────────────────────────────────────────────────────┘
```

Each recommendation is a clickable card that navigates to Restaurant Detail.

---

### Tit-for-Tat UI (When Enabled)

Tit-for-tat is **off by default**. When disabled, there is zero UI footprint — no indicator, no badge, no empty state message. It does not exist until both users enable it in Settings (mutual consent).

When enabled, the UI is subtle:
- A small text line below the Recommend page's "Where should we eat tonight?" heading: `"Meriam's pick"` or `"Your pick"` — no icon, no animation, no color change
- The turn state is informational only — it influences the scoring algorithm but does not prevent either user from using any feature
- Either user can tap/click the turn indicator to waive their turn

---

### Settings Page

| Tab | Content |
|-----|---------|
| **General** | API server URL, API key display, home location (for distance calc), default search radius |
| **Preferences** | Dietary constraints, hard-no cuisines, hard-no neighborhoods |
| **Recommendation** | Tit-for-tat toggle (mutual consent), friend signal toggle, scoring weight adjustments |
| **Data** | Import/export database, photo sync status, backup info |

---

### Preview System (Desktop Only)

Cached website previews rendered in an iframe via a local file server.

**Flow:**
1. User views Restaurant Detail → clicks Preview sub-tab
2. Frontend calls `GetPreviewURL(restaurantID)`
3. Backend checks local cache: `~/.local/share/trueblocks/suppr/cache/previews/{restaurantID}/`
4. If cache miss or stale: fetch website, parse HTML, rewrite URLs to absolute, download key images, strip scripts, save cleaned HTML
5. Backend returns: `http://127.0.0.1:{port}/preview/{restaurantID}/index.html?t={mtime}`
6. Frontend renders in `<iframe>`

**Cache structure:**
```
cache/previews/{restaurantID}/
├── index.html          ← cleaned, rewritten HTML
├── img/                ← downloaded images
└── meta.json           ← fetch timestamp, original URL, status
```

**Local file server** starts on a dynamic localhost port during `App.Startup()`. Routes:
- `/preview/{restaurantID}/{path}` — serves cached HTML and images
- `/photos/{path}` — serves downloaded photos

No X-Frame-Options blocking (we serve our own copy). Works offline after initial fetch. Scripts stripped for security.

---

### Command Palette (Cmd+Shift+P) — Desktop Only

Fuzzy-searchable list of actions (not data). Distinct from global search (Cmd+K).

| Command | Shortcut |
|---------|----------|
| Go to Dashboard | Cmd+1 |
| Go to Restaurants | Cmd+2 |
| Go to Visits | Cmd+3 |
| Go to Awards | Cmd+4 |
| Go to Episodes | Cmd+5 |
| Go to Intel | Cmd+6 |
| Go to Recommend | Cmd+7 |
| Go to Settings | Cmd+8 |
| Search | Cmd+K |
| Reload View | Cmd+R |
| Toggle Dark Mode | — |
| Toggle Show Deleted | Cmd+Shift+D |

Arrow Up/Down + Enter to execute. Escape to close. Each command shows its keyboard shortcut right-aligned.

---

### Global Search Modal (Cmd+K)

Searches across all entity types:
- Restaurants (by name, cuisine, neighborhood)
- Visits (by restaurant name, notes)
- Intel (by headline, restaurant name)

Results grouped by type with icons. Click → navigate to entity detail.

---

### Hotkeys (Complete)

| Key | Action |
|-----|--------|
| Cmd+1–8 | Navigate to view (or cycle list/detail if already there) |
| Cmd+K | Global search modal |
| Cmd+Shift+P | Command palette |
| Cmd+R | Reload current view |
| Cmd+/ | Focus DataTable search box |
| Arrow Up/Down | Navigate table rows |
| Arrow Left/Right (table) | Navigate pages |
| Arrow Left/Right (detail) | Prev/next item |
| Home/End | First/last row |
| Enter | Open selected row |
| Cmd+Shift+Left | Return to list from detail |
| Option+Shift+2 | Cycle restaurant detail sub-tabs |
| Cmd+Shift+D | Toggle show deleted items |

---

### State Persistence (Six Types)

| # | What | How |
|---|------|-----|
| 1 | Window position/size | `useWindowGeometry()` |
| 2 | Sidebar width | `GetSidebarWidth()` / `SetSidebarWidth()` |
| 3 | Last route | `GetLastRoute()` / `SaveLastRoute()` |
| 4 | Active tab per view | `SetTab(viewId, tab)` |
| 5 | Full route per tab | `SetTabRoute(key, route)` |
| 6 | Table state (sort/search/filter) | Handled by `createDataTable` wrapper |

All stored locally in `state.json` via `appkit.Store`. Not synced to the server.

---

### Cross-Navigation Patterns

Navigation between related entities preserves return context:

- Restaurant Detail → Visits sub-tab → click visit → Visit Detail (with "Return to Zahav" button)
- Visits list → click visit → Visit Detail → click restaurant name → Restaurant Detail (with "Return to Visits" button)
- Dashboard → click bucket list item → Restaurant Detail (with "Return to Dashboard" button)
- Recommend → click recommendation → Restaurant Detail (with "Return to Recommend" button)

Uses `location.state` with `returnTo` and `returnLabel` fields.

---

### Status Bar

Bottom-left status messages:
- Info (data loaded counts)
- Progress (photo uploading, data syncing)
- Success (visit logged, restaurant updated)
- Error (API unreachable, upload failed)

---

### Component Architecture

```
src/pages/
├── DashboardPage.tsx
├── RestaurantsPage.tsx          ← TabView + NavigationProvider
├── RestaurantsList.tsx
├── RestaurantDetail.tsx         ← DetailHeader + sub-tabs
├── VisitsPage.tsx
├── VisitsList.tsx
├── VisitDetail.tsx
├── AwardsPage.tsx / AwardsList.tsx / AwardDetail.tsx
├── EpisodesPage.tsx / EpisodesList.tsx / EpisodeDetail.tsx
├── IntelPage.tsx / IntelList.tsx / IntelDetail.tsx
├── RecommendPage.tsx            ← Wizard UI
└── SettingsPage.tsx             ← Tabbed settings

src/components/
├── DataTable.tsx                ← createDataTable wrapper
├── RestaurantSubTabs/           ← Overview, Visits, Awards, etc.
└── RecommendTabs/               ← Tonight, BucketList, Revisit, Explore
```

---

## Mobile PWA

The phone experience is tailored for mobile use cases: quick lookup, log a visit, snap a photo, browse recommendations. It is **not** a miniaturized desktop app.

### Navigation

Bottom tab bar (standard iOS pattern):

```
┌─────────────────────────────────────────┐
│         [page content]                  │
├─────────────────────────────────────────┤
│  🏠      🍽      ✨      📷      👤    │
│ Home   Browse  Tonight  Log    Profile  │
└─────────────────────────────────────────┘
```

| Tab | Purpose |
|-----|---------|
| **Home** | Dashboard lite: recent visits, intel alerts, quick stats |
| **Browse** | Restaurant list (searchable, filterable). Tap → detail. |
| **Tonight** | Recommendation wizard with filters |
| **Log** | Quick-log a visit: pick restaurant, rate, snap photo, notes |
| **Profile** | Your visits, lists, stats, settings |

### Browse → Restaurant List (Mobile)

Card list with search bar and filter chips. No DataTable — cards are thumb-friendly.

```
┌─────────────────────────────────────────┐
│ 🔍 Search restaurants...                │
│ [Cuisine ▼] [Neighborhood ▼] [Price ▼]  │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ Zahav              ★★★★★ (3 visits)│ │
│ │ Mediterranean · Rittenhouse · $$$$  │ │
│ │ 🏆 5 awards                        │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Browse → Restaurant Detail (Mobile)

Stacked collapsible cards (not sub-tabs):

- Header: name, cuisine, neighborhood, price, rating
- Info: address, phone, website, BYOB, reservations
- Awards (count + list)
- Photos (grid + [+Add] button → camera)
- Your Visits (list + [+Log] button)
- Intel

### Log a Visit (Mobile — Primary Use Case)

Must be fast and frictionless:

```
┌─────────────────────────────────────────┐
│ Log a Visit                             │
│                                         │
│ Restaurant: [search + autocomplete]     │
│ Date: [today ▼]                         │
│ Rating: ☆ ☆ ☆ ☆ ☆                      │
│ Occasion: [casual ▼]                    │
│ Notes: [                            ]   │
│ Photo: [📷 Take Photo] [📁 Choose]      │
│                                         │
│        [Save Visit]                     │
└─────────────────────────────────────────┘
```

Camera via `<input type="file" accept="image/*" capture="environment">` — opens iPhone camera directly.

### Tonight (Mobile Recommendations)

Same concept as desktop but simplified:

```
┌─────────────────────────────────────────┐
│ Where should we eat?                     │
│ [Occasion ▼] [Cuisine ▼] [Price ▼]      │
│ [✨ Recommend]                          │
│                                         │
│ 🥇 Zahav                               │
│ "Award-winning, haven't been in 4mo"   │
│ [View] [Reserve] [Directions]           │
│                                         │
│ [Bucket List] [Revisit] [Explore]       │
└─────────────────────────────────────────┘
```

"Directions" opens Apple Maps. "Reserve" opens the restaurant's reservation platform if known.

### Photos on PWA

The PWA is always online. It:
- **Reads** photos from the server (no local cache, no sync)
- **Uploads** photos to the server (from camera or photo library)

No offline photo viewing. No sync protocol needed for the PWA.

---

## Shared vs. Separate Frontends

| Aspect | Desktop (Wails) | Mobile (PWA) |
|--------|----------------|--------------|
| Framework | React + Mantine 8 | React + Mantine 8 |
| Routing | react-router-dom | react-router-dom |
| Layout | Sidebar + content area | Bottom tab bar + content |
| Components | DataTable, DetailHeader, EditableField | Simplified cards, forms |
| State persistence | Backend via Wails (state.json) | localStorage |
| Build tool | Wails (embeds in Go binary) | Vite (static, served by DO) |
| Preview system | Yes (local file server) | No |
| Command palette | Yes (Cmd+Shift+P) | No |

**Recommendation**: Separate frontends, shared TypeScript types. The layouts are too different to share components. But API response types and error handling should be shared via a common `types.ts`.
