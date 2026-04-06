# CaseTally

AI powered legal research app for lawyers, law students, and clients. Ask legal questions in natural language and get streaming AI answers with inline citations, source references, and relevant laws rendered progressively as they arrive.

Connects to a self-hosted LLM backend over WebSocket. Backend lives in [casetally-backend](https://github.com/DeepanjayNandal/casetally-backend).

## Tech Stack

Flutter (iOS) · Riverpod · go_router · WebSocket · Apple Sign In

## Features

**AI Legal Search**
Users type a legal question and results stream in progressively: source count first, then citations, then the AI summary word by word, then full sources, then related articles. Each section renders independently as its event arrives rather than waiting for the full response.

**U.S. Code Browser**
Browse all 54 titles of the U.S. Code with hierarchical drill-down through parts, chapters, and individual sections. Backed by a live REST API with a mock repository for offline development.

**Legal News Feed**
Home dashboard with a featured top story, latest legal updates, and a daily learning tip. Reading history is tracked locally and surfaced in a Continue Reading section.

**Resources Library**
Categorized legal education articles covering constitutional rights, state and federal law, and elected officials. Full article viewer with section-based rendering.

**Authentication**
Apple Sign In with guest mode. Session state drives all router redirects through a truth table, no boolean flags anywhere.

## Architecture

**Streaming search state**

The search feature is built around an accumulative state model. When a query is submitted, a UUID is generated and stored as the active request ID. The WebSocket client opens a connection, sends the query, and emits a typed stream of events. The `SearchNotifier` subscribes to that stream and routes each event to a pure handler function that returns the next state.

Every event carries the request ID it belongs to. Handlers check it before applying any state update, so a slow previous query completing late cannot corrupt the UI for a new search.

```
SearchNotifier.submitQuery()
  → generates UUID requestId
  → sets SearchState.loading
  → subscribes to WebSocketSearchRepository.searchStream()
      → RealtimeClient opens WebSocket, emits SearchEvent stream
  → each event routed to SearchEventHandlers (pure functions)
  → state accumulates: laws, summaryChunks, sources, artifacts, relatedArticles
  → DoneEvent → SearchState.success
```

Nine typed events make up the protocol:

```
started · sources_count · citations · summary_chunk · sources · artifacts · related_articles · done · error
```

**Repository pattern**

Every feature has a typed interface and separate mock and live implementations. Switching data sources is one line in the provider. During development the mock runs locally with no backend dependency.

```dart
// development
WebSocketSearchRepository(fakeClient: FakeRealtimeClient())

// production (one line change)
WebSocketSearchRepository(client: RealtimeClient(baseUrl: 'wss://api.casetally.com'))
```

Same pattern applies to U.S. Code: `MockUsCodeRepository` and `APIUsCodeRepository` both implement `UsCodeRepository`. The provider decides which one runs.

**Session state as a finite state machine**

Auth is modeled with three explicit states: `unauthenticated`, `guest`, `authenticated`. The router reads a single `SessionStatus` value and applies a complete truth table for redirects. No computed boolean combinations, no edge cases.

```
unauthenticated + /app/* → redirect /auth
guest/authenticated + /auth → redirect /app
guest/authenticated + /app/* → allow
```

**Persistent navigation with ShellRoute**

The bottom navigation bar is declared once inside a `ShellRoute` in the router config. All in-app routes are children of that shell. The bar never rebuilds or flashes during route transitions because it is never part of any page scaffold.

**Search transition**

Navigating into the search input plays a compound animation: the current view fades to 85% opacity and scales to 0.97 while the search page fades in, scales up from 0.96, and slides in 6% from the right. 280ms, `easeOutCubic`, no overshoot.

## Project Structure

```
lib/
├── components/          # Shared UI: AppCard, AppText, GlassBottomBar, DetailScaffold
├── features/
│   ├── auth/            # Authentication view and session handling
│   ├── home/            # News feed, reading history, home dashboard
│   ├── search/
│   │   ├── models/      # SearchState, SearchEvent, typed event subclasses
│   │   ├── providers/   # SearchNotifier, SearchEventHandlers
│   │   ├── repositories/# SearchRepository interface, WebSocket + Mock implementations
│   │   ├── views/       # SearchInputPage, SearchResultsPage
│   │   └── widgets/     # AiSummarySection, SourcesSection, ArtifactCard, StreamingAnswer
│   ├── uscode/
│   │   ├── models/      # UsCodeTitle, UsCodeHierarchyNode
│   │   ├── providers/   # UsCodeNotifier
│   │   ├── repositories/# UsCodeRepository interface, API + Mock implementations
│   │   └── views/       # UsCodeListView, UsCodeHierarchyView, UsCodeSectionView
│   ├── resources/       # Article viewer, category drill-down, sample content
│   └── settings/        # Theme switching, session controls
├── routes/              # GoRouter config with ShellRoute and truth table redirects
├── services/            # RealtimeClient (WebSocket), FakeRealtimeClient (mock)
├── state/               # AppState, SessionStatus FSM
└── theme/               # AppTheme, GlassTokens, BottomBarMetrics, AppConstants
```

## Local Development

```bash
flutter pub get
flutter run
```

The app runs fully on mock data out of the box. To connect to a real backend, update the client in `search_provider.dart`:

```dart
// current (mock)
WebSocketSearchRepository(fakeClient: FakeRealtimeClient())

// live backend
WebSocketSearchRepository(client: RealtimeClient(baseUrl: 'ws://localhost:8000'))
```

## Related Repositories

[casetally-backend](https://github.com/DeepanjayNandal/casetally-backend) — FastAPI, PostgreSQL, pgvector, Ollama, hybrid RAG pipeline

[casetally-web](https://github.com/DeepanjayNandal/casetally-web) — Next.js web client
