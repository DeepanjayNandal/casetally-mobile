import '../models/search_response.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../services/realtime_client.dart';
import '../../../services/fake_realtime_client.dart';
import '../models/search_event.dart';
import '../models/law_reference.dart';
import '../models/source.dart';
import '../models/related_article.dart';
import 'search_repository.dart';

/// WebSocket-based search repository
///
/// **Pattern:** Streaming events instead of monolithic response
///
/// **Architecture:**
/// - Uses RealtimeClient for WebSocket connection
/// - Converts raw JSON from events → typed domain models
/// - Accepts requestId from caller (or generates if not provided)
/// - Handles groupId for conversation threading
///
/// **Development Mode:**
/// - Automatically uses FakeRealtimeClient in debug builds
/// - No backend needed for UI development
/// - Clean injection (no runtime flags)
class WebSocketSearchRepository implements SearchRepository {
  /// WebSocket client (real or fake)
  /// Injected at construction time
  final dynamic _client; // RealtimeClient or FakeRealtimeClient

  /// UUID generator for requestId (only used when requestId not provided)
  final Uuid _uuid = const Uuid();

  /// Constructor with automatic fake injection in debug mode
  ///
  /// **Production:** Uses RealtimeClient
  /// **Debug:** Uses FakeRealtimeClient (no backend needed)
  ///
  /// **Clean Injection:**
  /// - No runtime flags
  /// - No if/else in business logic
  /// - Just different client instance

  // WebSocketSearchRepository({
  //   RealtimeClient? client,
  //   FakeRealtimeClient? fakeClient,
  // }) : _client = kDebugMode
  //           ? (fakeClient ?? FakeRealtimeClient())
  //           : (client ?? RealtimeClient(baseUrl: 'ws://localhost:8000'));

  WebSocketSearchRepository({
    RealtimeClient? client,
    FakeRealtimeClient? fakeClient,
  }) : _client = fakeClient ?? FakeRealtimeClient();
  // ↑ ALWAYS use mock - when ready for real backend, change this line (REALBACKEND CHANGE)

  @override
  Stream<SearchEvent> searchStream(
    String query, {
    String? groupId,
    String? requestId, // ← FIXED: Now accepts requestId parameter
  }) async* {
    // Validate query
    if (query.trim().isEmpty) {
      yield ErrorEvent(
        requestId: requestId ?? _uuid.v4(),
        groupId: groupId,
        message: 'Please enter a search query',
        errorCode: 'EMPTY_QUERY',
      );
      return;
    }

    // Use provided requestId or generate new one
    // ← FIXED: Uses passed requestId instead of always generating new one
    final finalRequestId = requestId ?? _uuid.v4();

    print('🔍 [WebSocketRepo] Starting search: "$query"');
    print('🔍 [WebSocketRepo] RequestId: $finalRequestId');
    if (groupId != null) {
      print('🔍 [WebSocketRepo] GroupId: $groupId');
    }

    // Stream events from client
    // ← FIXED: Passes the correct requestId to client
    await for (final event in _client.search(
      query: query,
      requestId: finalRequestId,
      groupId: groupId,
    )) {
      // Parse event data into domain models if needed
      yield _processEvent(event);
    }

    print('🔍 [WebSocketRepo] Search stream ended');
  }

  /// Process raw event and convert data to domain models
  ///
  /// **Why Here?**
  /// - Events contain raw JSON arrays
  /// - Repository knows domain models
  /// - Keeps models decoupled from events
  ///
  /// **What We Parse:**
  /// - CitationsEvent.data → List<LawReference>
  /// - SourcesEvent.data → List<Source>
  /// - RelatedArticlesEvent.data → List<RelatedArticle>
  SearchEvent _processEvent(SearchEvent event) {
    try {
      // Most events pass through unchanged
      if (event is! CitationsEvent &&
          event is! SourcesEvent &&
          event is! RelatedArticlesEvent) {
        return event;
      }

      // Parse citations data
      if (event is CitationsEvent) {
        print('📚 [WebSocketRepo] Parsing ${event.count} citations');
        // Validate data can be parsed
        try {
          for (final item in event.data) {
            if (item is! Map<String, dynamic>) {
              throw FormatException('Invalid citation format');
            }
            // Test parse one item to validate structure
            LawReference.fromJson(item);
          }
          print('✅ [WebSocketRepo] Citations validated');
        } catch (e) {
          print('❌ [WebSocketRepo] Citation parse error: $e');
          return ErrorEvent(
            requestId: event.requestId,
            groupId: event.groupId,
            message: 'Failed to parse legal citations',
            errorCode: 'CITATION_PARSE_ERROR',
          );
        }
      }

      // Parse sources data
      if (event is SourcesEvent) {
        print('📄 [WebSocketRepo] Parsing ${event.count} sources');
        try {
          for (final item in event.data) {
            if (item is! Map<String, dynamic>) {
              throw FormatException('Invalid source format');
            }
            Source.fromJson(item);
          }
          print('✅ [WebSocketRepo] Sources validated');
        } catch (e) {
          print('❌ [WebSocketRepo] Source parse error: $e');
          return ErrorEvent(
            requestId: event.requestId,
            groupId: event.groupId,
            message: 'Failed to parse sources',
            errorCode: 'SOURCE_PARSE_ERROR',
          );
        }
      }

      // Parse related articles data
      if (event is RelatedArticlesEvent) {
        print('📰 [WebSocketRepo] Parsing ${event.count} articles');
        try {
          for (final item in event.data) {
            if (item is! Map<String, dynamic>) {
              throw FormatException('Invalid article format');
            }
            RelatedArticle.fromJson(item);
          }
          print('✅ [WebSocketRepo] Articles validated');
        } catch (e) {
          print('❌ [WebSocketRepo] Article parse error: $e');
          return ErrorEvent(
            requestId: event.requestId,
            groupId: event.groupId,
            message: 'Failed to parse related articles',
            errorCode: 'ARTICLE_PARSE_ERROR',
          );
        }
      }

      // All validations passed, return original event
      return event;
    } catch (e, stackTrace) {
      print('❌ [WebSocketRepo] Unexpected parse error: $e');
      print('Stack: $stackTrace');
      return ErrorEvent(
        requestId: event.requestId,
        groupId: event.groupId,
        message: 'Failed to process search results',
        errorCode: 'PARSE_ERROR',
        stackTrace: stackTrace.toString(),
      );
    }
  }

  @override
  @Deprecated('Use searchStream() instead')
  Future<SearchResponse> search(String query) {
    throw UnsupportedError(
      'WebSocketSearchRepository only supports searchStream(). '
      'Use MockSearchRepository for traditional search().',
    );
  }

  @override
  bool isCached(String query) => false;

  @override
  void clearCache() {
    // No cache in WebSocket repository
  }
}
