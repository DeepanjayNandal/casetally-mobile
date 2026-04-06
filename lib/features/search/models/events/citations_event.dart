import '../search_event.dart';

/// Legal citations found (laws, cases, statutes)
///
/// **UI Response:**
/// - "Relevant Laws" section appears
/// - Each citation renders as card
/// - Progressive - more citations may arrive in later events
///
/// **Data Format:**
/// Raw JSON list - will be parsed into LawReference objects by repository layer
/// This keeps event models pure and decoupled from domain models
class CitationsEvent extends SearchEvent {
  /// Raw citation data (will be parsed by repository)
  /// Each item should match LawReference JSON structure
  final List<dynamic> data;

  const CitationsEvent({
    required super.requestId,
    super.groupId,
    required this.data,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "citations",
  ///   "requestId": "abc123",
  ///   "data": [
  ///     {
  ///       "id": "miranda-v-arizona",
  ///       "title": "Miranda v. Arizona",
  ///       "citation": "384 U.S. 436 (1966)",
  ///       "summary": "...",
  ///       "jurisdiction": "Federal",
  ///       "type": "case_law",
  ///       "relevance_score": 0.98
  ///     }
  ///   ]
  /// }
  /// ```
  factory CitationsEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final data = json['data'];
    if (data == null || data is! List) {
      throw FormatException(
        'CitationsEvent: missing or invalid "data" field (expected array)',
      );
    }

    return CitationsEvent(
      requestId: requestId,
      groupId: groupId,
      data: data,
    );
  }

  /// Number of citations in this batch
  int get count => data.length;

  @override
  String toString() =>
      'CitationsEvent(requestId: $requestId, citations: $count)';
}
