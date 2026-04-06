import '../search_event.dart';

/// Full source details (websites, databases, documents)
///
/// **UI Response:**
/// - "Sources" section appears
/// - Each source renders with credibility indicator
/// - User can tap to view source
///
/// **Timing:**
/// Usually arrives after citations/summary
/// Contains metadata for attribution
class SourcesEvent extends SearchEvent {
  /// Raw source data (will be parsed by repository)
  /// Each item should match Source JSON structure
  final List<dynamic> data;

  const SourcesEvent({
    required super.requestId,
    super.groupId,
    required this.data,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "sources",
  ///   "requestId": "abc123",
  ///   "data": [
  ///     {
  ///       "name": "Cornell Law School",
  ///       "url": "https://...",
  ///       "type": "legal_database",
  ///       "credibility": "high"
  ///     }
  ///   ]
  /// }
  /// ```
  factory SourcesEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final data = json['data'];
    if (data == null || data is! List) {
      throw FormatException(
        'SourcesEvent: missing or invalid "data" field (expected array)',
      );
    }

    return SourcesEvent(
      requestId: requestId,
      groupId: groupId,
      data: data,
    );
  }

  /// Number of sources in this batch
  int get count => data.length;

  @override
  String toString() => 'SourcesEvent(requestId: $requestId, sources: $count)';
}
