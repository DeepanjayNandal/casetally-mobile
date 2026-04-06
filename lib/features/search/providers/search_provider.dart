import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/search_event.dart';
import '../repositories/websocket_search_repository.dart';
import '../../../services/fake_realtime_client.dart';
import 'search_state.dart';
import 'search_event_handlers.dart';

/// Manages search state and coordinates the WebSocket event stream.
///
/// Each query gets a unique requestId. Event handlers use it to
/// discard any events that arrive from a previous query.
class SearchNotifier extends StateNotifier<SearchState> {
  final WebSocketSearchRepository _repository;
  final Uuid _uuid = const Uuid();

  StreamSubscription<SearchEvent>? _streamSubscription;
  String? _currentGroupId;

  SearchNotifier(this._repository) : super(const SearchState.idle());

  Future<void> submitQuery(String query) async {
    await _cancelActiveSearch();

    final requestId = _uuid.v4();

    debugPrint('[Search] query: "$query" ($requestId)');

    state = SearchState.loading(
      query: query,
      requestId: requestId,
      groupId: _currentGroupId,
    );

    try {
      final eventStream = _repository.searchStream(
        query,
        groupId: _currentGroupId,
        requestId: requestId,
      );

      _streamSubscription = eventStream.listen(
        (event) => _handleEvent(event),
        onError: (error) => _handleStreamError(error),
        onDone: () => _handleStreamComplete(),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[Search] failed to start: $e');
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Failed to start search. Please try again.',
      );
    }
  }

  void _handleEvent(SearchEvent event) {
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
      _streamSubscription?.cancel();
    } else if (event is ErrorEvent) {
      state = SearchEventHandlers.handleError(state, event);
      _streamSubscription?.cancel();
    }
  }

  void _handleStreamError(dynamic error) {
    debugPrint('[Search] stream error: $error');
    state = state.copyWith(
      status: SearchStatus.error,
      errorMessage: 'Connection error. Please try again.',
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );
    _streamSubscription?.cancel();
  }

  void _handleStreamComplete() {
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

  Future<void> _cancelActiveSearch() async {
    if (_streamSubscription != null) {
      await _streamSubscription?.cancel();
      _streamSubscription = null;
    }
  }

  void clearResults() {
    _cancelActiveSearch();
    state = const SearchState.idle();
  }

  void setGroupId(String? groupId) {
    _currentGroupId = groupId;
  }

  @override
  void dispose() {
    _cancelActiveSearch();
    super.dispose();
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

final _searchRepositoryProvider = Provider<WebSocketSearchRepository>((ref) {
  return WebSocketSearchRepository(fakeClient: FakeRealtimeClient());
});

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(_searchRepositoryProvider));
});

final currentQueryProvider = Provider<String?>((ref) {
  return ref.watch(searchProvider).currentQuery;
});

final searchStatusProvider = Provider<SearchStatus>((ref) {
  return ref.watch(searchProvider).status;
});

final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).isSearching;
});
