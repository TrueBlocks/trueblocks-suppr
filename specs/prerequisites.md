# Prerequisites & Dependencies

This chapter specifies the exact tools, languages, and frameworks required to build suppr. The spec is prescriptive — it assumes this stack. An AI reading this book should install and configure these dependencies before generating any code.

---

## Philosophy: Get Out of the Browser

suppr is a desktop application. It runs on your machine. It is not a web app hosted somewhere. The browser is someone else's house — Wails lets you build your own.

Every dependency below serves one principle: sovereignty. Your data stays on your hardware. Your app runs without an internet connection. Your tools are open source with no vendor lock-in.

---

## Required Stack

### Go (1.22+)
- Backend language for all server logic, API endpoints, and CLI tools
- Compiles to a single binary with zero runtime dependencies
- https://go.dev/dl/

### Wails 2
- Desktop application framework: Go backend + WebView frontend
- Produces native .app (macOS), .exe (Windows), or Linux binary
- No Electron. No embedded Chromium. Uses the system's native WebView.
- Wails 3 exists but is still alpha — use Wails 2.
- https://wails.io/

### Node.js (20 LTS+) + Yarn
- Frontend build toolchain only — does not run in production
- Yarn (not npm, not npx) for all package management
- Use the latest stable Yarn version at the time of build
- https://nodejs.org/ and https://yarnpkg.com/

### React 18 + TypeScript 5 + Mantine 8
- Frontend UI framework
- Mantine provides the component library (tables, forms, navigation, modals)
- TypeScript for all frontend code — no .js files, no `any` types
- https://mantine.dev/

### Vite
- Frontend bundler and dev server
- Provides hot module replacement (HMR) during development
- Produces optimized production builds
- https://vite.dev/

### ESLint + Vitest
- ESLint for code linting (enforces consistent style, catches errors)
- Vitest for unit and integration tests (fast, Vite-native)
- Both run via Makefile targets: `make lint`, `make test`

### SQLite (WAL mode)
- Embedded database — a single file on disk
- WAL (Write-Ahead Logging) mode for concurrent read/write
- No database server. No connection strings. No credentials.
- Ships with Go via modernc.org/sqlite (pure Go, no CGO required)

### chi
- Lightweight HTTP router for Go
- Used for the REST API layer
- https://github.com/go-chi/chi

### Make
- Build orchestration — all commands run via Makefile targets
- `make build`, `make dev`, `make test`, `make lint`

### Git
- Version control
- Repository hosts on GitHub (for collaboration and issue tracking)

---

## Deployment Dependencies (Phase 2+)

These are needed only when running the server component (before the desktop-becomes-the-server migration):

### Caddy
- Reverse proxy with automatic HTTPS
- Sits in front of the Go server on a VPS
- https://caddyserver.com/

### Digital Ocean (or any VPS)
- Smallest droplet sufficient (~$6/month)
- Only needed while the server is remote
- Long-term goal: eliminate this entirely (Essay 11 — "The Desktop Becomes the Server")

---

## Optional / Enrichment

### Python 3
- Data enrichment scripts (geocoding, cuisine classification)
- Not required for core functionality
- Used during initial data import from legacy sources

### ImageMagick or similar
- Photo manipulation (resize, crop for restaurant photos)
- Only needed if the photo feature is implemented

---

## What You Do NOT Need

- Docker
- Kubernetes
- AWS / GCP / Azure
- PostgreSQL / MySQL / MongoDB
- Redis
- A CI/CD pipeline
- A domain name (Caddy can use the droplet IP)
- Electron
- Next.js, Vite, or any SSR framework

The absence of these is intentional. Every tool not listed here is a dependency you don't have — a thing that can't break, can't be deprecated, can't raise its prices.

---

## Installation Verification

After installing the required stack, verify with:

```
go version          → go1.22+
wails doctor        → all checks pass
node --version      → v20+
yarn --version      → latest stable
sqlite3 --version   → 3.35+ (WAL support)
make --version      → GNU Make 3.81+
git --version       → any recent version
```

If `wails doctor` passes, you're ready to build.
