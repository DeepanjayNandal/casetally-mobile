# CaseTally — AI Powered Legal Research iOS App

> iOS client for real-time AI legal search with streaming LLM answers, U.S. Code browsing, and a native glass design system. Built with Flutter and Riverpod.

## Overview

CaseTally is an iOS application that brings AI powered legal research to lawyers, law students, and clients. Users ask natural language legal questions and receive streaming AI answers with inline citations and source references rendered progressively as they arrive from the backend.

The app communicates with a self-hosted LLM backend over WebSocket, consuming a typed event stream and rendering results in real time. Backend lives in a separate repository.

## Technical Highlights

**Real-Time Streaming Client**
- WebSocket based search with per-query connection lifecycle — no persistent socket, intentionally mobile-friendly
- Event-driven protocol consuming 9 distinct typed events: `started`, `sources_count`, `citations`, `summary_chunk`, `sources`, `artifacts`, `related_articles`, `done`, `error`
- Progressive UI rendering where sources, citations, and AI summary each render independently as their event arrives
- Request-scoped event handling with UUID based correlation to prevent stale events from a slow previous query corrupting active search state

**Flutter iOS App**
- Pure Cupertino widget tree throughout, no Material widgets
- Riverpod for state management with an explicit `SessionStatus` finite state machine — no boolean flag combinations, no ambiguous computed states
- go_router with ShellRoute for persistent glass bottom navigation with zero flash across route transitions
- Repository pattern across every feature — switching from mock to live backend is a single line change

**Glass Design System**
- Two-tier glass morphism system: overlay tier for navigation bars, surface tier for content cards
- All values centralized in `glass_tokens.dart` — one file controls the entire visual system
- Navigation pill with easeOutCubic animation, mathematically verified coordinate space to avoid double-counted padding offsets

## Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (iOS, Cupertino) |
| State Management | Riverpod |
| Navigation | go_router |
| Real-Time | WebSocket (per-query lifecycle) |
| Auth | Apple Sign In |

## Features

**AI Legal Search** — Natural language queries with streaming LLM answers, inline citations, and source references rendered progressively

**U.S. Code Browser** — Browse all 54 U.S. Code titles with hierarchical drill-down to individual sections, backed by a live API

**Legal News Feed** — Curated legal updates with article viewer and reading history tracking

**Resources Library** — Categorized legal education articles with full-text reading experience

**Authentication** — Apple Sign In with guest mode and session state management

**Settings** — Theme switching (light/dark/system), session controls, account management

## Architecture Decisions Worth Noting

**Repository Pattern** — Every feature (search, U.S. Code, articles) has a typed repository interface with separate mock and live implementations. Swapping data sources for any feature is one line. Local development and backend integration are completely decoupled.

**Request-Scoped WebSocket Events** — Each search query generates a UUID. All incoming events are validated against the active request ID before being applied to state. A slow previous query finishing late cannot corrupt the current search UI.

**SessionStatus FSM** — Auth state is modeled as a finite state machine with three explicit values: `unauthenticated`, `guest`, `authenticated`. Router redirects are a simple truth table lookup with no computed boolean logic.

**ShellRoute Persistent Navigation** — The glass bottom bar lives at the router level in a ShellRoute, not inside individual page scaffolds. Route transitions never flash or rebuild the navigation bar.

**Two-Tier Glass System** — Navigation bars need strong blur as floating elements. Content cards need lighter blur for readability. These are separate tiers driven by a single token file rather than per-component hardcoded values.

## Project Structure

```
lib/
├── components/          # Shared UI components (AppCard, AppText, GlassBottomBar, etc.)
├── features/
│   ├── auth/            # Authentication flow
│   ├── home/            # News feed, reading history, home dashboard
│   ├── search/          # AI search — models, events, providers, repositories, views, widgets
│   ├── uscode/          # U.S. Code browser — hierarchy, sections, repository
│   ├── resources/       # Legal education articles
│   └── settings/        # App settings
├── routes/              # go_router configuration with ShellRoute
├── services/            # WebSocket RealtimeClient
├── state/               # Global app state
├── theme/               # AppTheme, GlassTokens, BottomBarMetrics
└── utils/               # StatusBarObserver
```

## Local Development

```bash
flutter pub get
flutter run
```

Switch between mock and live backend in the search provider:

```dart
// Mock (default for local dev)
final repository = MockSearchRepository();

// Live backend
final repository = WebSocketSearchRepository(baseUrl: 'ws://localhost:8000');
```

## Related

- [casetally-backend](https://github.com/DeepanjayNandal/casetally-backend) — FastAPI, pgvector, Ollama, hybrid RAG pipeline
- [casetally-web](https://github.com/DeepanjayNandal/casetally-web) — Next.js web client
