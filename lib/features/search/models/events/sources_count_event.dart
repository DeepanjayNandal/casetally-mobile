import '../search_event.dart';

/// Early notification of how many sources were found
///
/// **UI Response:**
/// - Show badge: "Found 5 sources"
/// - Gives user confidence results are coming
/// - Can display before actual sources arrive
///
/// **Perplexity Pattern:**
/// Shows "Searching 10 sources..." while processing
class SourcesCountEvent extends SearchEvent {
  /// Total number of sources found
  final int count;

  const SourcesCountEvent({
    required super.requestId,
    super.groupId,
    required this.count,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "sources_count",
  ///   "requestId": "abc123",
  ///   "count": 5
  /// }
  /// ```
  factory SourcesCountEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final count = json['count'];
    if (count == null || count is! int || count < 0) {
      throw FormatException(
        'SourcesCountEvent: invalid "count" field (must be non-negative integer)',
      );
    }

    return SourcesCountEvent(
      requestId: requestId,
      groupId: groupId,
      count: count,
    );
  }

  @override
  String toString() =>
      'SourcesCountEvent(requestId: $requestId, count: $count)';
}
