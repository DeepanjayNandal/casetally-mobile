import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/search_event.dart';
import '../repositories/websocket_search_repository.dart';
import '../../../services/fake_realtime_client.dart';
import 'search_state.dart';
import 'search_event_handlers.dart';

/// Search state notifier with WebSocket streaming
///
/// **Architecture:**
/// - Subscribes to event stream from WebSocketSearchRepository
/// - Routes events to pure handler functions
/// - Updates state progressively as events arrive
/// - Cancels previous stream on new query (request-scoped)
///
/// **Lifecycle:**
/// 1. User submits query
/// 2. Generate unique requestId
/// 3. Set state to loading
/// 4. Subscribe to event stream
/// 5. Process events → update state
/// 6. Complete or error → finalize
///
/// **Cancellation:**
/// - New query cancels previous stream
/// - Dispose cancels active stream
/// - Prevents stale events via requestId check in handlers
class SearchNotifier extends StateNotifier<SearchState> {
  final WebSocketSearchRepository _repository;
  final Uuid _uuid = const Uuid();

  /// Active stream subscription (nullable - only exists during search)
  StreamSubscription<SearchEvent>? _streamSubscription;

  /// Current groupId for conversation threading
  /// **Phase 4:** Always null (no threading yet)
  /// **Future:** Will be set for multi-turn conversations
  String? _currentGroupId;

  SearchNotifier(this._repository) : super(const SearchState.idle());

  /// Submit a search query
  ///
  /// **Flow:**
  /// 1. Cancel any active search
  /// 2. Generate new requestId
  /// 3. Set loading state
  /// 4. Subscribe to event stream
  /// 5. Process events progressively
  ///
  /// **Request Scoping:**
  /// Each query gets unique requestId stored in state.
  /// Event handlers ignore events with mismatched requestId.
  Future<void> submitQuery(String query) async {
    print('\n🔍 ========== NEW SEARCH ==========');
    print('Query: "$query"');

    // Cancel previous search if active
    await _cancelActiveSearch();

    // Generate unique request ID
    final requestId = _uuid.v4();
    print('RequestId: $requestId');
    print('GroupId: ${_currentGroupId ?? "(none - first query)"}');

    // Set loading state
    state = SearchState.loading(
      query: query,
      requestId: requestId,
      groupId: _currentGroupId,
    );

    try {
      // Subscribe to event stream
      // ← FIXED: Changed from search() to searchStream() and passes requestId
      final eventStream = _repository.searchStream(
        query,
        groupId: _currentGroupId,
        requestId: requestId,
      );

      _streamSubscription = eventStream.listen(
        (event) => _handleEvent(event),
        onError: (error) => _handleStreamError(error),
        onDone: () => _handleStreamComplete(),
        cancelOnError: false, // Continue processing other events
      );
    } catch (e) {
      print('❌ Failed to start search: $e');
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Failed to start search. Please try again.',
      );
    }
  }

  /// Handle incoming search event
  ///
  /// **Pattern:** Route to pure handler functions
  /// Handlers enforce request scoping internally
  void _handleEvent(SearchEvent event) {
    print('📩 Event received: ${event.runtimeType}');

    // Route to appropriate handler
    if (event is StartedEvent) {
      state = SearchEventHandlers.handleStarted(state, event);
    } else if (event is SourcesCountEvent) {
      state = SearchEventHandlers.handleSourcesCount(state, event);
    } else if (event is CitationsEvent) {
      state = SearchEventHandlers.handleCitations(state, event);
    } else if (event is SummaryChunkEvent) {
      state = SearchEventHandlers.handleSummaryChunk(state, event);
    } else if (event is SourcesEvent) {
      state = SearchEventHandlers.handleSources(state, event);
    } else if (event is ArtifactsEvent) {
      state = SearchEventHandlers.handleArtifacts(state, event);
    } else if (event is RelatedArticlesEvent) {
      state = SearchEventHandlers.handleRelatedArticles(state, event);
    } else if (event is DoneEvent) {
      state = SearchEventHandlers.handleDone(state, event);
      _streamSubscription?.cancel(); // Clean up after completion
    } else if (event is ErrorEvent) {
      state = SearchEventHandlers.handleError(state, event);
      _streamSubscription?.cancel(); // Clean up after error
    }
  }

  /// Handle stream-level errors (connection failures, etc.)
  ///
  /// **Note:** Different from ErrorEvent (backend errors)
  /// This handles Dart stream errors (network, parsing, etc.)
  void _handleStreamError(dynamic error) {
    print('❌ Stream error: $error');

    state = state.copyWith(
      status: SearchStatus.error,
      errorMessage: 'Connection error. Please try again.',
      // Mark all sections complete to stop loading indicators
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );

    _streamSubscription?.cancel();
  }

  /// Handle stream completion (no more events)
  ///
  /// **Note:** This is redundant if DoneEvent received
  /// But serves as safety net if backend closes without DoneEvent
  void _handleStreamComplete() {
    print('🏁 Stream closed');

    // If not already marked complete, mark as success
    if (state.status == SearchStatus.loading) {
      state = state.copyWith(
        status: SearchStatus.success,
        citationsComplete: true,
        summaryComplete: true,
        sourcesComplete: true,
        artifactsComplete: true,
        relatedArticlesComplete: true,
      );
    }
  }

  /// Cancel active search stream
  ///
  /// **Called:**
  /// - When new query submitted (cancels previous)
  /// - When notifier disposed (cleanup)
  Future<void> _cancelActiveSearch() async {
    if (_streamSubscription != null) {
      print('🛑 Canceling previous search');
      await _streamSubscription?.cancel();
      _streamSubscription = null;
    }
  }

  /// Clear search results back to idle
  ///
  /// **Use Cases:**
  /// - User closes overlay
  /// - App needs to reset search state
  void clearResults() {
    print('🧹 Clearing search results');
    _cancelActiveSearch();
    state = const SearchState.idle();
  }

  /// Set groupId for conversation threading
  ///
  /// **Phase 4:** Not used yet (always null)
  /// **Future:** Call this to start threaded conversation
  ///
  /// **Example:**
  /// ```dart
  /// notifier.setGroupId('conversation-123');
  /// notifier.submitQuery('First question');
  /// notifier.submitQuery('Follow-up question'); // Same groupId
  /// ```
  void setGroupId(String? groupId) {
    print('🔗 GroupId set: ${groupId ?? "(cleared)"}');
    _currentGroupId = groupId;
  }

  @override
  void dispose() {
    print('♻️ SearchNotifier disposed');
    _cancelActiveSearch();
    super.dispose();
  }
}

// ==================== PROVIDER DECLARATIONS ====================

/// WebSocket search repository provider
///
/// **Phase 4:** Uses FakeRealtimeClient (development mode)
/// **Phase 5:** Will use RealtimeClient (production)
///
/// **Auto-injection:** WebSocketSearchRepository receives FakeRealtimeClient in debug mode
final _searchRepositoryProvider = Provider<WebSocketSearchRepository>((ref) {
  final client = FakeRealtimeClient();
  return WebSocketSearchRepository(fakeClient: client);
});

/// Main search provider
///
/// **ONE-LINE SWAP:** This now uses WebSocketSearchRepository
/// Old: MockSearchRepository with Future<SearchResponse>
/// New: WebSocketSearchRepository with Stream<SearchEvent>
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(_searchRepositoryProvider);
  return SearchNotifier(repository);
});

/// Convenience provider for current query
final currentQueryProvider = Provider<String?>((ref) {
  return ref.watch(searchProvider).currentQuery;
});

/// Convenience provider for search status
final searchStatusProvider = Provider<SearchStatus>((ref) {
  return ref.watch(searchProvider).status;
});

/// Convenience provider for checking if searching
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).isSearching;
});
