# Glossary

**API (Application Programming Interface)** — The set of HTTP endpoints through which suppr's frontend communicates with its backend server. All state changes flow through the API.

**API key** — A secret string assigned to each user, sent in the `X-API-Key` header on every request. suppr's sole authentication mechanism — no sessions, no JWT, no OAuth.

**Audience of two** — The design constraint at the heart of suppr: software built for exactly two people (a couple), not scaled to serve thousands.

**Caddy** — The reverse proxy server that sits in front of suppr on Digital Ocean, handling TLS certificates automatically and forwarding traffic to the Go binary.

**Chi** — A lightweight Go HTTP router used by suppr's server. Chosen for its minimal API and stdlib compatibility.

**Collaborative filtering** — A recommendation technique that uses overlapping taste profiles to predict preferences. In suppr, the "collaborators" are two people, not millions.

**Digital Ocean** — The cloud hosting provider where suppr's API server runs on a $6/month droplet.

**Federation** — The protocol by which independent suppr instances share restaurant data and recommendations across households without a central server.

**Go** — The programming language used for suppr's backend, CLI tools, and server binary. Chosen for single-binary deployment, fast compilation, and no runtime dependencies.

**Mantine** — A React component library (version 8) providing the UI primitives for suppr's frontend — buttons, tables, modals, navigation.

**md2docx** — A custom CLI tool that converts markdown files to Word (.docx) format using a template, preserving styles (Title, Subtitle, Normal, Heading) for book production.

**PWA (Progressive Web App)** — The mobile interface to suppr, accessed via a phone browser. Shares the React/Mantine codebase with the desktop app but uses a layout suited to small screens.

**React** — The JavaScript UI framework used for suppr's frontend, running inside both the Wails desktop app and the mobile PWA.

**Recommendation engine** — The scoring algorithm that answers "where should we eat tonight?" by combining ratings, recency, visit frequency, and mood preferences into a ranked list.

**Saturday Night Test** — The informal benchmark for whether suppr is working: can a couple open the app at 5pm on Saturday and get a useful dinner suggestion without friction?

**Small batch** — A philosophy borrowed from craft brewing: make something for a small audience, make it well, don't scale it. The organizing metaphor of this book.

**SQLite** — The embedded database engine used by suppr. Runs in WAL mode as a single file — no separate database server required.

**Vibe coding** — Writing software by describing intent to an AI and iterating on its output, rather than typing every line by hand. The method used to build suppr.

**Vibe designing** — Extending vibe coding to architecture: describing system shape, constraints, and goals in conversation with an AI, then refining the design through dialogue.

**Wails** — A Go framework for building desktop applications with web frontends. suppr's desktop app is a Wails binary — Go backend communicating with a React frontend via bindings.

**WAL mode (Write-Ahead Logging)** — A SQLite journaling mode that allows concurrent reads during writes. Used by suppr for better performance under simultaneous desktop and phone access.
