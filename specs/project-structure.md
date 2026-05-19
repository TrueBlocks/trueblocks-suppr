# Project Structure

This chapter specifies the folder layout, package organization, dependency graph, build targets, and development workflow for the suppr repository.

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
	├── design/                    # Architecture docs (historical)
	├── articles/                  # Small batch apps article series
	├── original/                  # Archived CheckPlease database
	└── ai/                        # AI agent instructions
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

## Platform Package Integration

	suppr lives in the `trueblocks-art` mono-repo alongside works, poetry, siteman, and acrylic. Shared code lives in `packages/` at the repo root:

	```
	trueblocks-art/
	├── packages/
	│   ├── ui/          → @trueblocks/ui
	│   └── scaffold/    → @trueblocks/scaffold
	├── suppr/
	│   └── frontend/
	│       └── vite.config.ts   ← aliases resolve packages from source
	├── works/
	├── poetry/
	└── siteman/
	```

### Vite Alias Configuration

	In `frontend/vite.config.ts`:

	```typescript
	import path from 'path';

	export default defineConfig({
	  resolve: {
	    alias: {
	      '@': path.resolve(__dirname, './src'),
	      '@app': path.resolve(__dirname, './wailsjs/go/app/App'),
	      '@components': path.resolve(__dirname, './src/components'),
	      '@pages': path.resolve(__dirname, './src/pages'),
	      '@utils': path.resolve(__dirname, './src/utils'),
	      '@hooks': path.resolve(__dirname, './src/hooks'),
	      '@wailsjs': path.resolve(__dirname, './wailsjs'),
	      '@models': path.resolve(__dirname, './wailsjs/go/models'),
	      '@runtime': path.resolve(__dirname, './wailsjs/runtime'),
	      '@trueblocks/ui': path.resolve(__dirname, '../../packages/ui/src'),
	      '@trueblocks/scaffold': path.resolve(__dirname, '../../packages/scaffold/src'),
	    },
	  },
	  server: {
	    proxy: {
	      '/api': 'http://localhost:8420',
	    },
	  },
	});
	```

	Key points:
- **Packages are resolved from source** — not published to npm, not built separately
- `@trueblocks/ui` and `@trueblocks/scaffold` point to `../../packages/{name}/src`
- `@app` points to Wails auto-generated bindings (never edit these files)
- `@models` points to Wails auto-generated Go model types

### What Each Package Provides

	**`@trueblocks/ui`** (used extensively):
- `AppLayout` + `NavItems` — the full app shell with resizable sidebar
- `DataTable` + `createDataTable` — feature-complete data table
- `DetailHeader` — standard detail page header with prev/next navigation
- `EditableField` — click-to-edit inline text editing
- `TabView` — tabbed content with tab persistence
- `DashboardCard` + `StatRow` — dashboard stat display
- `ConfirmDeleteModal` — standardized delete confirmation
- `KeyboardHints` — overlay showing available keyboard shortcuts
- `SplashScreen` — loading screen
- `useTableState`, `useTableKeyboard`, `useTablePersistence` — table state management
- `useWindowGeometry` — window position/size persistence
- `usePersistedTab`, `usePersistedValue`, `createPersistedTabContext` — state persistence
- `createAppTheme`, `ThemeProvider`, `useTheme`, `ThemeSelector` — theming
- `initLogger`, `Log`, `LogErr`, `LogDbg`, `LogWarn` — logging (use instead of console.log)
- `initOS`, `openURL` — OS utilities
- Re-exports of Mantine components and hooks (so you import from `@trueblocks/ui` not directly from `@mantine/*`)

	**`@trueblocks/scaffold`** (used for navigation and data fetching):
- `NavigationProvider` + `useNavigation` — entity navigation context (prev/next/push/pop stack)
- `useDetailPageNavigation` — auto-registers Arrow Left/Right, Home/End, Cmd+Shift+Left for detail pages
- `makeEntityHooks(api)` — factory that creates `useList()` and `useOne()` hooks from an entity API definition
- `useAsync` — generic async data hook (data, loading, error, refetch)
- `ReportShell` — report page chrome (description → loading → error → empty → content)

### Import Patterns in suppr

	```typescript
	// Shell and layout
	import { AppLayout, NavItem } from '@trueblocks/ui';
	import { useHotkeys } from '@trueblocks/ui';  // re-exported from @mantine/hooks

	// Pages
	import { NavigationProvider, useNavigation } from '@trueblocks/scaffold';
	import { TabView, DataTable, DetailHeader, EditableField } from '@trueblocks/ui';
	import { useDetailPageNavigation, makeEntityHooks } from '@trueblocks/scaffold';

	// Logging
	import { Log, LogErr } from '@trueblocks/ui';

	// Theme
	import { ThemeProvider, createAppTheme } from '@trueblocks/ui';

	// Wails bindings (auto-generated — never edit)
	import { RestaurantList, RestaurantGet, RestaurantUpdate } from '@app';
	import { models } from '@models';
	```

---

## Frontend: Wails + PWA from One Codebase

	The same React components serve both the Wails desktop app and the PWA. The difference is how API calls are made:

- **Wails desktop**: Calls Go functions via `wailsjs/` bindings, which delegate to `pkg/client/` (HTTP to API server).
- **PWA mobile**: Calls the API directly via `fetch()` with API key header.

	A `useApi()` hook abstracts this difference — the frontend code doesn't know or care which mode it's running in. See the Client-Server Pattern chapter for the full specification of this abstraction.

	PWA-specific files (manifest.json, service worker, offline fallback) live in `frontend/src/pwa/`.

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
