import '../models/search_response.dart';
import '../models/search_event.dart';

/// Abstract interface for search data sources
///
/// **Two Patterns Supported:**
///
/// 1. **Traditional Request/Response** (Mock)
///    - Returns Future<SearchResponse>
///    - Monolithic response
///    - Used by MockSearchRepository
///
/// 2. **Streaming Events** (WebSocket)
///    - Returns Stream<SearchEvent>
///    - Progressive updates
///    - Used by WebSocketSearchRepository
///
/// **Why Both?**
/// - Mock repository still works (tests, offline mode)
/// - WebSocket repository enables real-time streaming
/// - Providers can choose which pattern to use
abstract class SearchRepository {
  /// Traditional search (monolithic response)
  ///
  /// **Deprecated:** Use searchStream() for new features
  /// **Still Supported:** For mock repository and tests
  @Deprecated('Use searchStream() for progressive updates')
  Future<SearchResponse> search(String query) {
    throw UnimplementedError('Deprecated - use searchStream()');
  }

  /// Streaming search (progressive events)
  ///
  /// **Returns:** Stream of SearchEvent objects
  ///
  /// **Event Flow:**
  /// 1. StartedEvent - Search began
  /// 2. SourcesCountEvent - Found X sources
  /// 3. CitationsEvent - Legal citations
  /// 4. SummaryChunkEvent (multiple) - AI summary streaming
  /// 5. SourcesEvent - Source details
  /// 6. RelatedArticlesEvent - Related content
  /// 7. DoneEvent - Complete
  /// 8. ErrorEvent - If failure
  ///
  /// **Example:**
  /// ```dart
  /// await for (final event in repository.searchStream(query)) {
  ///   if (event is CitationsEvent) {
  ///     // Update UI with citations
  ///   }
  /// }
  /// ```
  Stream<SearchEvent> searchStream(String query, {String? groupId}) {
    throw UnimplementedError('Subclass must implement searchStream()');
  }

  /// Check if query results are cached (optional)
  bool isCached(String query) => false;

  /// Clear any cached results (optional)
  void clearCache() {}
}

/// Custom exception for search errors
class SearchException implements Exception {
  final String message;
  final SearchExceptionType type;

  const SearchException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => message;
}

/// Types of search errors
enum SearchExceptionType {
  network, // No internet connection
  timeout, // Request took too long
  server, // API returned error
  validation, // Invalid query
  unknown, // Unknown error
}
