import '../search_event.dart';

/// Search query has been received and processing started
///
/// **UI Response:**
/// - Show "Searching..." state
/// - Display query text
/// - Show loading indicator
///
/// **Typical Flow:**
/// User submits query → WebSocket connects → StartedEvent arrives → UI shows loading
class StartedEvent extends SearchEvent {
  /// The original query text user submitted
  final String query;

  const StartedEvent({
    required super.requestId,
    super.groupId,
    required this.query,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "started",
  ///   "requestId": "abc123",
  ///   "groupId": "conv-456",
  ///   "query": "What are Miranda rights?"
  /// }
  /// ```
  factory StartedEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final query = json['query'] as String?;
    if (query == null || query.isEmpty) {
      throw FormatException('StartedEvent: missing "query" field');
    }

    return StartedEvent(
      requestId: requestId,
      groupId: groupId,
      query: query,
    );
  }

  @override
  String toString() => 'StartedEvent(requestId: $requestId, query: "$query")';
}
