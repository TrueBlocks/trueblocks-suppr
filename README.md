# suppr

A restaurant recommendation and management app for two, built with Wails, Go, React, and TypeScript.

## Overview

suppr helps a couple track, rate, and rediscover Philadelphia-area restaurants. It combines curated data from Philly Mag's 50 Best lists and WHYY's Check, Please! Philly with personal visit history, photos, and notes. A recommendation engine suggests where to eat tonight based on past visits, preferences, and what you haven't tried yet.

The app runs as a Wails desktop app on macOS and as a PWA on iPhones. Both talk to a shared Go API server on Digital Ocean backed by a single SQLite database.

## Architecture

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────────┐
│  Wails App   │     │  PWA (phone) │     │  DO API Server      │
│  (macOS)     │────▶│  (Safari)    │────▶│  Go + chi + SQLite  │
│  Go → HTTP   │     │  fetch()     │     │  suppr.trueblocks.io│
└──────────────┘     └──────────────┘     └─────────────────────┘
```

- **Desktop**: Wails v2 app. Go backend acts as HTTP client to the API server via `pkg/client/`.
- **Mobile**: PWA served by siteman. Direct `fetch()` calls to the API with API key auth.
- **Server**: Go binary with chi router, SQLite via modernc.org/sqlite, deployed on Digital Ocean.

## Features

- **Restaurant Database**: 276+ restaurants with cuisine, neighborhood, chef, website, awards, and episode appearances
- **Visit Logging**: Track where you ate, when, what you ordered, your rating, and notes
- **Photo Capture**: Upload photos from desktop or snap them at the restaurant via PWA camera
- **Awards Tracking**: Philly Mag 50 Best lists (2015–2026), with Michelin and James Beard ready
- **Episode Archive**: All 41 Check, Please! Philly episodes with WHYY video links
- **Recommendation Engine**: Four modes — Tonight, Bucket List, Revisit, Explore
- **Intel Feed**: Collect restaurant news, closings, openings, and tips
- **Lists**: Create custom lists (Date Night, BYOB favorites, etc.)
- **Preview**: View restaurant websites inline (curl + cache + local file server)
- **Search**: Full-text search across restaurants, visits, notes, and intel (⌘K)
- **Two Users**: You and Meriam, each with API key auth

## Tech Stack

- **Backend**: Go 1.24+ with SQLite (modernc.org/sqlite)
- **Frontend**: React 18 + TypeScript 5 + Mantine 8
- **Framework**: Wails v2 (desktop), PWA (mobile)
- **API**: Go + chi router, API key auth
- **Package Manager**: Yarn

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘K | Open search |
| ⌘⇧P | Command palette |
| ⌘1 | Dashboard |
| ⌘2 | Restaurants |
| ⌘3 | Visits |
| ⌘4 | Awards |
| ⌘5 | Episodes |
| ⌘6 | Intel |
| ⌘7 | Recommend |
| ⌘8 | Settings |

## Data

### Source Data

The `original/` directory contains the archived CheckPlease database (276 restaurants, 455 awards, 41 episodes, 120 appearances) and its schema. This data is migrated into suppr via `cmd/suppr-import/`.

### Database Tables

| Table | Description |
|-------|-------------|
| Restaurants | Core restaurant records with location, cuisine, chef, status |
| AwardSources | Award-granting organizations (Philly Mag, Michelin, etc.) |
| AwardSourceUrls | Provenance URLs for each year's award list |
| Awards | Restaurant ↔ award source ↔ year with rank |
| Episodes | Check, Please! appearances per restaurant |
| Users | Two users with API keys |
| Visits | Visit log with ratings, notes, spend |
| Photos | Photo metadata (files on DO filesystem) |
| Tags | Flexible tagging system |
| Intel | News, tips, and notes about restaurants |
| Lists | Custom named lists |
| ListItems | List membership |

### Data Storage

- **Server**: SQLite on Digital Ocean at `/data/suppr/suppr.db`
- **Photos**: DO filesystem at `/data/suppr/photos/`
- **Desktop state**: `~/.local/share/trueblocks/suppr/` (UI preferences only — no data)

## Project Structure

```
suppr/
├── main.go               # Wails app entry point
├── app/                   # Wails bindings (Go → frontend)
├── cmd/
│   ├── suppr-server/      # API server binary
│   ├── suppr-import/      # One-time migration from checkplease.db
│   └── suppr-geocode/     # Address/lat-lng enrichment tool
├── pkg/
│   └── client/            # Go HTTP client (used by Wails app + CLI tools)
├── internal/
│   ├── api/               # HTTP handlers + middleware
│   ├── db/                # SQLite operations
│   └── models/            # Shared Go types
├── frontend/              # React + Mantine (Wails app + PWA)
├── design/                # Architecture and design documents
├── articles/              # Small batch apps article series
├── original/              # Archived CheckPlease database
└── ai/                    # AI agent instructions
```

## Development

### Prerequisites

- Go 1.24+
- Node.js 18+
- Yarn
- Wails CLI (`go install github.com/wailsapp/wails/v2/cmd/wails@latest`)

### Live Development

```fish
wails dev
```

### Building

```fish
wails build
```

### After Go Changes

```fish
wails generate module
```
