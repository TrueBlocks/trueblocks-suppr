# suppr UI Design — Desktop (Wails) & Mobile (PWA)

This document captures the full UI design discussion for the `suppr` restaurant recommendation and management app. It covers both the Wails desktop app and the mobile PWA, including navigation, layout, hotkeys, and component patterns.

---

## Desktop Wails App

### Header

```
┌─────────────────────────────────────────────────────────────┐
│ 🍽 suppr                               A Dining Companion   │
└─────────────────────────────────────────────────────────────┘
```

Follows the works pattern: Title left, subtitle center, dark mode toggle right.

### Sidebar Navigation

Collapsible, resizable sidebar with icon + label items. Matches the works pattern exactly.

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

The Dashboard shows at-a-glance stats and actionable items:

```
┌─────────────────────────────────────────────────────────────┐
│ 🍽 suppr                               A Dining Companion   │
├────┬────────────────────────────────────────────────────────┤
│    │                                                        │
│ D  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│ a  │  │ 276      │ │ 42       │ │ 18       │ │ 5 ★      │  │
│ s  │  │Restaurants│ │ Visited  │ │ Cuisines │ │ Avg Rating│  │
│ h  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│ b  │                                                        │
│ o  │  RECENT VISITS                    INTEL ALERTS          │
│ a  │  ┌─────────────────────────┐     ┌──────────────────┐  │
│ r  │  │ Zahav — ★★★★★ — May 10 │     │ ⚠ Closure: Foo   │  │
│ d  │  │ Vernick — ★★★★ — May 3 │     │ 🏆 New award: Bar │  │
│    │  │ Talula's — ★★★★ — Apr  │     │ 📰 Menu change:..│  │
│    │  └─────────────────────────┘     └──────────────────┘  │
│    │                                                        │
│    │  BUCKET LIST (Top 5 Unvisited)   YOUR PATTERNS         │
│    │  ┌─────────────────────────┐     ┌──────────────────┐  │
│    │  │ 1. Restaurant X — 5yr  │     │ Fav cuisine: Ital│  │
│    │  │ 2. Restaurant Y — 4yr  │     │ Fav hood: Ritten │  │
│    │  │ 3. Restaurant Z — 3yr  │     │ Avg $/visit: $$  │  │
│    │  └─────────────────────────┘     └──────────────────┘  │
│    │                                                        │
├────┴────────────────────────────────────────────────────────┤
│ ℹ️ 276 restaurants, 455 awards, 120 episodes loaded         │
└─────────────────────────────────────────────────────────────┘
```

Dashboard sections:
- **Stat Cards** (top row): Total restaurants, total visited, distinct cuisines, average rating
- **Recent Visits**: Last 3-5 visits with restaurant name, rating, date
- **Intel Alerts**: Undismissed intel items (closures, new awards, menu changes)
- **Bucket List**: Top 5 unvisited award-winning restaurants, sorted by number of award appearances
- **Your Patterns**: Aggregate insights from visit history (favorite cuisine, favorite neighborhood, average spend)

---

### Restaurants — List Tab

DataTable with full sorting, filtering, search, persistence. Follows the works DataTable pattern exactly (createDataTable wrapper, persisted state, keyboard navigation).

| Column | Width | Sortable | Filterable | Notes |
|--------|-------|----------|------------|-------|
| Name | 30% | ✓ | search only | Primary display |
| Cuisine | 15% | ✓ | ✓ dropdown | 76 distinct values |
| Neighborhood | 15% | ✓ | ✓ dropdown | 18 values |
| Price | 8% | ✓ | ✓ dropdown | $–$$$$ |
| Rating | 8% | ✓ | ✓ range | Your avg rating (from Visits) |
| Awards | 8% | ✓ | ✓ range | Count of 50 Best appearances |
| BYOB | 5% | ✓ | ✓ dropdown | Yes/No |
| Status | 8% | ✓ | ✓ dropdown | open/closed/seasonal |

Click row → navigate to Restaurant Detail (URL: `/restaurants/:id`).

Filter options for Cuisine and Neighborhood are loaded dynamically from the backend via `GetRestaurantFilterOptions()` (returns a struct wrapping multiple `[]string` arrays per the Wails multi-return pattern).

---

### Restaurants — Detail Tab

The detail view is the richest, with **vertical sub-tabs** matching the Collection detail pattern in works (Matter sub-tabs, Marketing sub-tabs).

```
┌──────────────────────────────────────────────────────────────┐
│ ◀ ▶  Zahav                                    12 of 276     │
│      Mediterranean · Rittenhouse · $$$$ · BYOB: No          │
├──────────┬───────────────────────────────────────────────────┤
│          │                                                   │
│ Overview │  ADDRESS: 237 St James Pl, Philadelphia           │
│          │  PHONE: (215) 625-8800                            │
│ Visits   │  WEBSITE: zahavrestaurant.com                     │
│          │  STATUS: Open                                     │
│ Awards   │  RESERVATIONS: Required                           │
│          │  OUTDOOR: No                                      │
│ Episodes │                                                   │
│          │  TAGS: romantic, celebration, splurge              │
│ Photos   │                                                   │
│          │  NOTES:                                            │
│ Intel    │  [editable text area]                              │
│          │                                                   │
│ Lists    │  MAP: [link to Google Maps]                        │
│          │                                                   │
└──────────┴───────────────────────────────────────────────────┘
```

Uses `DetailHeader` from `@trueblocks/ui` with prev/next navigation. All fields use `EditableField` for inline editing.

**Sub-tabs within Restaurant Detail:**

| Sub-Tab | Content |
|---------|---------|
| **Overview** | Address, phone, website, status, reservations, outdoor, tags, notes, map link — all `EditableField` components |
| **Visits** | DataTable of this restaurant's visits: date, who, rating, occasion, notes. "Log Visit" button at top. |
| **Awards** | DataTable of this restaurant's 50 Best appearances: year, rank, category. Read-only data. |
| **Episodes** | DataTable of Check Please! appearances: season, episode, air date, notes. Read-only data. |
| **Photos** | Grid of photos (from visits or general). Upload button. Click to enlarge in modal. |
| **Intel** | DataTable of intel items: type, headline, date, source URL. Dismiss button per row. |
| **Lists** | Which lists this restaurant is on (bucket list, favorites, etc.). Add/remove buttons. |

Sub-tab cycling: `Option+Shift+2` cycles through sub-tabs (matching works' Matter sub-tab cycling pattern via `window.dispatchEvent(new CustomEvent('cycleRestaurantSubTab'))`).

---

### Visits — List Tab

A global view of all visits across all restaurants. This is a denormalized view joining Visits with Restaurants for display.

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 25% | ✓ | search only |
| Date | 12% | ✓ | range |
| Who | 10% | ✓ | ✓ dropdown (you/Meriam) |
| Rating | 8% | ✓ | ✓ range |
| Occasion | 12% | ✓ | ✓ dropdown |
| Cuisine | 12% | ✓ | ✓ dropdown |
| Neighborhood | 12% | ✓ | ✓ dropdown |
| Notes | 9% | — | search only |

Click row → navigate to Visit Detail.

### Visits — Detail Tab

Shows the full visit record with:
- `DetailHeader` with prev/next
- Restaurant name as a link (click to navigate to Restaurant detail, with return context preserved)
- Date, rating (editable), occasion (editable dropdown), notes (editable textarea)
- Associated photos (if any)
- "Return to Restaurant" button if navigated from Restaurant → Visits sub-tab

---

### Awards — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 30% | ✓ | search only |
| Source | 15% | ✓ | ✓ dropdown |
| Year | 10% | ✓ | ✓ dropdown |
| Rank | 10% | ✓ | ✓ range |
| Category | 20% | ✓ | ✓ dropdown |

### Awards — Detail Tab

Read-only display of the award with restaurant link, source, year, rank, category.

---

### Episodes — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 30% | ✓ | search only |
| Season | 10% | ✓ | ✓ dropdown |
| Episode | 10% | ✓ | ✓ range |
| Air Date | 15% | ✓ | range |
| Notes | 35% | — | search only |

### Episodes — Detail Tab

Read-only display with restaurant link, season, episode, air date, segment notes.

---

### Intel — List Tab

| Column | Width | Sortable | Filterable |
|--------|-------|----------|------------|
| Restaurant | 25% | ✓ | search only |
| Type | 12% | ✓ | ✓ dropdown (closure, award, menu-change, event, news) |
| Headline | 30% | ✓ | search only |
| Discovered | 12% | ✓ | range |
| Source | 12% | — | — |
| Dismissed | 9% | ✓ | ✓ dropdown (yes/no) |

### Intel — Detail Tab

Full intel item with restaurant link, type, headline, detail text, source URL (clickable), discovered date. Dismiss/undismiss button.

---

### Recommend Page

Not a standard List/Detail — this is a **wizard/tool** UI with tabbed result modes.

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

**Recommendation sub-tabs:**

| Sub-Tab | Description |
|---------|-------------|
| **Tonight** | Scored recommendations with filters (occasion, cuisine, price, mood). Returns 3-5 items with one-line reason. |
| **Bucket List** | Unvisited award-winners sorted by quality signal (multi-year appearances, never visited). |
| **Revisit** | Restaurants rated 4+ stars but not visited in 3+ months. |
| **Explore** | Cuisines or neighborhoods you rarely visit but that have strong quality signals. |

Each recommendation result is a card that can be clicked to navigate to the Restaurant detail.

---

### Settings Page

Tabbed settings view:

| Tab | Content |
|-----|---------|
| **General** | API server URL, API key display, home location (lat/lng for distance calculations), default search radius |
| **Preferences** | Dietary constraints, hard-no cuisines, hard-no neighborhoods |
| **Data** | Import/export database, photo sync status, backup info |

---

### Hotkeys (Complete)

| Key | Action |
|-----|--------|
| Cmd+1 | Navigate to Dashboard |
| Cmd+2 | Navigate to Restaurants (or cycle list/detail if already there) |
| Cmd+3 | Navigate to Visits (or cycle) |
| Cmd+4 | Navigate to Awards (or cycle) |
| Cmd+5 | Navigate to Episodes (or cycle) |
| Cmd+6 | Navigate to Intel (or cycle) |
| Cmd+7 | Navigate to Recommend |
| Cmd+8 | Navigate to Settings |
| Cmd+K | Open global search modal (restaurants, visits, intel) |
| Cmd+R | Reload current view (dispatches `reloadCurrentView` event) |
| Cmd+/ | Focus DataTable search box |
| Arrow Up/Down | Navigate table rows |
| Arrow Left/Right (in table) | Navigate table pages |
| Arrow Left/Right (in detail) | Prev/next item |
| Home/End | First/last row in table |
| Enter | Open selected row |
| Cmd+Shift+Left | Return to list from detail |
| Option+Shift+2 | Cycle restaurant detail sub-tabs |
| Cmd+Shift+D | Toggle show deleted items |

All hotkeys use the `handleNavigateOrCycle` pattern from works: if not on the view, navigate and restore last-visited tab/route; if already on the view, cycle to next tab by index.

---

### State Persistence (Six Types)

Following the works pattern exactly:

| # | What | How |
|---|------|-----|
| 1 | Window position/size | `useWindowGeometry(SaveWindowGeometry, WindowGetPosition, WindowGetSize)` |
| 2 | Sidebar width | `GetSidebarWidth()` on startup, `SetSidebarWidth()` on resize |
| 3 | Last route | `GetLastRoute()` on startup, `SaveLastRoute()` on every pathname change |
| 4 | Active tab per view | `SetTab(viewId, tab)` in each Page component's `useEffect` |
| 5 | Full route per tab | `SetTabRoute(key, route)` on every pathname change |
| 6 | Table state (sort/search/filter) | Handled automatically by `createDataTable` wrapper |

---

### Component Architecture

Following the Entity Triad Pattern (Page / List / Detail) for every entity:

```
src/pages/
├── DashboardPage.tsx
├── RestaurantsPage.tsx          ← TabView + NavigationProvider
├── RestaurantsList.tsx          ← DataTable with columns, search, filters
├── RestaurantDetail.tsx         ← DetailHeader + sub-tabs (Overview, Visits, Awards, etc.)
├── VisitsPage.tsx
├── VisitsList.tsx
├── VisitDetail.tsx
├── AwardsPage.tsx
├── AwardsList.tsx
├── AwardDetail.tsx
├── EpisodesPage.tsx
├── EpisodesList.tsx
├── EpisodeDetail.tsx
├── IntelPage.tsx
├── IntelList.tsx
├── IntelDetail.tsx
├── RecommendPage.tsx            ← Wizard UI, not standard triad
└── SettingsPage.tsx             ← Tabbed settings
```

Shared components:
```
src/components/
├── DataTable.tsx                ← createDataTable wrapper (persistence)
├── RestaurantSubTabs/
│   ├── OverviewTab.tsx
│   ├── VisitsTab.tsx
│   ├── AwardsTab.tsx
│   ├── EpisodesTab.tsx
│   ├── PhotosTab.tsx
│   ├── IntelTab.tsx
│   └── ListsTab.tsx
└── RecommendTabs/
    ├── TonightTab.tsx
    ├── BucketListTab.tsx
    ├── RevisitTab.tsx
    └── ExploreTab.tsx
```

---

## Mobile PWA UI

The phone experience is **not** a copy of the desktop. It is tailored for mobile use cases: quick lookup, log a visit, snap a photo, browse recommendations.

### Navigation

Bottom tab bar (standard iOS pattern), not a sidebar:

```
┌─────────────────────────────────────────┐
│                                         │
│         [page content]                  │
│                                         │
├─────────────────────────────────────────┤
│  🏠      🍽      ✨      📷      👤    │
│ Home   Browse  Tonight  Log    Profile  │
└─────────────────────────────────────────┘
```

| Tab | Purpose |
|-----|---------|
| **Home** | Dashboard lite: recent visits, intel alerts, quick stats |
| **Browse** | Restaurant list (searchable, filterable). Tap → restaurant detail. |
| **Tonight** | Recommendation wizard — "Where should we eat?" with filters |
| **Log** | Quick-log a visit: pick restaurant, rate, snap photo, add notes |
| **Profile** | Your visits, your lists, your stats, settings |

### Browse → Restaurant List (Mobile)

Simplified list — no DataTable, uses a Mantine-styled card list with search bar at top:

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
│ ┌─────────────────────────────────────┐ │
│ │ Vernick Food & Drink    ★★★★ (2)   │ │
│ │ American · Rittenhouse · $$$       │ │
│ │ 🏆 4 awards                        │ │
│ └─────────────────────────────────────┘ │
│ ...                                     │
└─────────────────────────────────────────┘
```

### Browse → Restaurant Detail (Mobile)

Stacked cards instead of sub-tabs (tabs don't work well on small screens):

```
┌─────────────────────────────────────────┐
│ ← Zahav                    ★★★★★ (3)   │
├─────────────────────────────────────────┤
│ Mediterranean · Rittenhouse · $$$$      │
│ 📍 237 St James Pl · 📞 (215) 625-8800 │
│ 🌐 zahavrestaurant.com                  │
│ BYOB: No · Reservations: Required       │
├─────────────────────────────────────────┤
│ 🏆 Awards (5)                           │
│ · 50 Best 2026 (#12) · 50 Best 2024... │
├─────────────────────────────────────────┤
│ 📸 Photos (3)                    [+Add] │
│ [thumb] [thumb] [thumb]                 │
├─────────────────────────────────────────┤
│ 📝 Your Visits (3)              [+Log]  │
│ May 10 — ★★★★★ — "Amazing lamb"        │
│ Feb 14 — ★★★★ — Date night             │
├─────────────────────────────────────────┤
│ 📰 Intel                                │
│ "New tasting menu launched" — May 1     │
└─────────────────────────────────────────┘
```

All sections are collapsible/expandable. Photos have an [+Add] button that opens the camera. Visits have a [+Log] button that opens the visit form pre-filled with this restaurant.

### Log a Visit (Mobile — Primary Use Case)

This is the most important mobile screen. It must be fast and frictionless.

```
┌─────────────────────────────────────────┐
│ Log a Visit                             │
│                                         │
│ Restaurant: [search + autocomplete]     │
│                                         │
│ Date: [today ▼]                         │
│                                         │
│ Rating: ☆ ☆ ☆ ☆ ☆                      │
│                                         │
│ Occasion: [casual ▼]                    │
│                                         │
│ Notes: [                            ]   │
│                                         │
│ Photo: [📷 Take Photo] [📁 Choose]      │
│                                         │
│        [Save Visit]                     │
└─────────────────────────────────────────┘
```

Camera integration via `<input type="file" accept="image/*" capture="environment">` — opens iPhone camera directly. No need for native app or App Store.

The restaurant field uses autocomplete search against the API. After saving, shows a success toast and optionally navigates to the restaurant detail.

### Tonight (Mobile Recommendations)

Same concept as the desktop Recommend page but simplified for mobile:

```
┌─────────────────────────────────────────┐
│ Where should we eat?                     │
│                                         │
│ [Occasion ▼] [Cuisine ▼] [Price ▼]      │
│                                         │
│ [✨ Recommend]                          │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🥇 Zahav                           │ │
│ │ "Award-winning, haven't been in    │ │
│ │  4 months"  $$$$                   │ │
│ │ [View] [Reserve] [Directions]      │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 🥈 Vernick                         │ │
│ │ "BYOB you loved last time"  $$    │ │
│ │ [View] [Reserve] [Directions]      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Bucket List] [Revisit] [Explore]       │
└─────────────────────────────────────────┘
```

"Directions" opens Apple Maps. "Reserve" opens the restaurant's reservation platform (Resy, OpenTable) if known. "View" navigates to the restaurant detail.

### Profile (Mobile)

```
┌─────────────────────────────────────────┐
│ 👤 Your Name                            │
│                                         │
│ Stats                                   │
│ ┌─────────────────────────────────────┐ │
│ │ 42 visited · 234 to go · ★4.2 avg  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Recent Visits                           │
│ · Zahav — May 10 — ★★★★★               │
│ · Vernick — May 3 — ★★★★               │
│ · See all →                             │
│                                         │
│ Your Lists                              │
│ · Bucket List (12)                      │
│ · Favorites (8)                         │
│ · Date Night Spots (5)                  │
│                                         │
│ Settings                                │
│ · API Key: ••••••••                     │
│ · Server: suppr.trueblocks.io           │
│ · Home Location: [Set]                  │
└─────────────────────────────────────────┘
```

---

## Shared vs. Separate Frontend Code

| Aspect | Desktop (Wails) | Mobile (PWA) |
|--------|----------------|--------------|
| Framework | React + Mantine 8 | React + Mantine 8 |
| Routing | react-router-dom | react-router-dom |
| Data access | Wails bindings → `pkg/client/` HTTP | Direct HTTP to API |
| Layout | Sidebar + content area | Bottom tab bar + content |
| Components | DataTable, DetailHeader, EditableField | Simplified cards, forms |
| State persistence | Backend via Wails calls (state.json) | localStorage + API |
| Build tool | Wails (embeds frontend in Go binary) | Vite (static build, served by DO) |

**Recommendation**: Separate frontends, shared TypeScript types. The layouts are too different to share components meaningfully. But the API response types and client code should be shared — either as a shared `types.ts` or a small shared package.

---

## Cross-Navigation Patterns

A key UX pattern: navigation between related entities with return context.

**Examples:**
- Restaurant Detail → Visits sub-tab → click a visit → Visit Detail (with "Return to Zahav" button)
- Visits list → click visit → Visit Detail → click restaurant name → Restaurant Detail (with "Return to Visits" button)
- Dashboard → click bucket list item → Restaurant Detail (with "Return to Dashboard" button)
- Recommend → click recommendation → Restaurant Detail (with "Return to Recommend" button)

This uses the same `location.state` pattern as works (Collection → Work navigation):
```ts
navigate(`/restaurants/${id}`, {
  state: {
    returnTo: '/visits',
    returnLabel: 'Visits'
  }
})
```

---

## Status Bar

Bottom-left status messages matching the works pattern:
- Info messages (data loaded counts)
- Progress messages (photo uploading, data syncing)
- Success messages (visit logged, restaurant updated)
- Error messages (API unreachable, upload failed)

Uses the same `EventsOn('status:message', ...)` pattern from the Go backend.

---

## Global Search Modal (Cmd+K)

Searches across all entity types:
- Restaurants (by name, cuisine, neighborhood)
- Visits (by restaurant name, notes)
- Intel (by headline, restaurant name)

Results grouped by type with icons. Click result → navigate to that entity's detail.

---

## Command Palette (Cmd+Shift+P)

Distinct from search (Cmd+K). The command palette is a fuzzy-searchable list of **actions** (not data), matching the VS Code pattern.

### Architecture

- `CommandPaletteModal` triggered by `Cmd+Shift+P`
- A registry of commands: `{ id, label, icon, action, shortcut? }`
- Fuzzy matching on label text as you type
- Arrow Up/Down + Enter to execute, Escape to close
- Each command shows its keyboard shortcut (if any) right-aligned

### Initial Commands

Even if no app-specific commands exist at launch, these navigation/utility commands are wired up:

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

### Platform Component

The command palette should be built as a shared component in `packages/ui` so all Wails apps (works, acrylic, poetry, siteman, suppr) can adopt it. Each app registers its own commands.

---

## Preview System (Restaurant Website Previews)

### Approach: Curl + Local Cache + Local File Server

Following the same pattern as works' document preview system (which serves PDFs from a local file server on a dynamic port, rendered in an `<iframe>`), suppr previews restaurant websites by fetching, cleaning, and serving them locally.

### Flow

```
1. User views Restaurant Detail → clicks Preview sub-tab
2. Frontend calls GetPreviewURL(restaurantID)
3. Backend checks local cache: ~/.local/share/trueblocks/suppr/cache/previews/{restaurantID}/
4. If cache miss or stale:
   a. HTTP GET the restaurant's website
   b. Parse HTML, rewrite relative URLs to absolute
   c. Download key images to local cache
   d. Rewrite img src to point to local file server
   e. Strip scripts (security + performance)
   f. Save cleaned HTML to cache
5. Backend returns: http://127.0.0.1:{port}/preview/{restaurantID}/index.html?t={mtime}
6. Frontend renders in <iframe src={url}>
```

### Cache Structure

```
cache/previews/{restaurantID}/
├── index.html          ← cleaned, rewritten HTML
├── img/
│   ├── hero.jpg        ← downloaded images
│   ├── logo.png
│   └── ...
└── meta.json           ← fetch timestamp, original URL, status
```

### Local File Server

Follows the works pattern exactly:
- Starts on a dynamic localhost port during `App.Startup()`
- Route: `/preview/{restaurantID}/{path}` serves cached HTML and images
- Route: `/photos/{path}` serves downloaded photos (from DO or local cache)
- CORS header set for the Wails webview

### Why This Works

- No `X-Frame-Options` blocking — we serve our own cached copy, not the live site
- Works offline after initial fetch (cached content persists)
- Fast — no network latency after first fetch
- Safe — scripts stripped, no third-party JavaScript executing in the webview
- Staleness control — `meta.json` tracks when we last fetched; "Refresh" button re-fetches

### Preview Sub-Tab UI

```
┌──────────────────────────────────────────────────────────────┐
│ ◀ ▶  Zahav                                    12 of 276     │
├──────────┬───────────────────────────────────────────────────┤
│ Overview │                                                   │
│ Visits   │  [Refresh ↻]  [Open in Browser ↗]                │
│ Awards   │  ┌─────────────────────────────────────────────┐  │
│ Episodes │  │                                             │  │
│ Photos   │  │   [zahavrestaurant.com — cached preview]    │  │
│ Intel    │  │                                             │  │
│ Lists    │  │   (cleaned HTML, local images, no scripts)  │  │
│ ──────── │  │                                             │  │
│ Preview  │  └─────────────────────────────────────────────┘  │
└──────────┴───────────────────────────────────────────────────┘
```

### Platform Opportunity

The local-file-server pattern is currently works-specific (`works/internal/server/`). It should be extracted into a shared package (`packages/fileserver` or added to `packages/appkit`) so suppr and future apps can reuse it.

---

## Episode Video Embeds

### YouTube Embeds

YouTube provides embeddable players that work perfectly in iframes — they are designed for this:

```html
<iframe src="https://www.youtube.com/embed/{videoID}" allowfullscreen />
```

### Episodes Sub-Tab Behavior

- If `embed_url` exists → inline YouTube player rendered in the sub-tab
- If only `video_url` exists → "Watch on YouTube" button (opens default browser via `BrowserOpenURL`)
- If neither → just the episode metadata (season, episode, air date, notes)

### Schema Additions

```sql
ALTER TABLE Episodes ADD COLUMN video_url TEXT;   -- YouTube or PBS URL
ALTER TABLE Episodes ADD COLUMN embed_url TEXT;    -- YouTube embed URL if available
```

### Updated Restaurant Detail Sub-Tabs

| Sub-Tab | Content |
|---------|---------|
| **Overview** | Core fields, "Open Website" / "Open Reviews" buttons, all EditableField |
| **Visits** | Visit history DataTable for this restaurant. "Log Visit" button. |
| **Awards** | Award appearances DataTable. Read-only. |
| **Episodes** | Episode DataTable + embedded video player when `embed_url` available |
| **Photos** | Photo grid with upload. Click to enlarge in modal. |
| **Intel** | Intel items DataTable. Dismiss button per row. |
| **Lists** | List membership. Add/remove buttons. |
| **Preview** | Cached website preview via local file server. Refresh + Open in Browser buttons. |
