import '../search_event.dart';

/// Primary legal documents (PDFs: court cases, statutes, regulations)
///
/// **UI Response:**
/// - "Artifacts" pill appears/updates count
/// - User taps pill → bottom sheet with artifact list
/// - User taps artifact → QuickLook opens PDF
///
/// **Timing:**
/// Can arrive multiple times during search (incremental)
/// Each event may contain 1-N artifacts
///
/// **Difference from Sources:**
/// Sources = reference websites/databases (webpages)
/// Artifacts = actual legal documents (PDFs)
class ArtifactsEvent extends SearchEvent {
  /// Raw artifact data (will be parsed into Artifact objects by handler)
  /// Each item should match Artifact JSON structure
  final List<dynamic> data;

  /// Whether this is the final artifacts event
  /// True = no more artifacts will arrive for this query
  /// False = more artifacts may stream in
  final bool isComplete;

  const ArtifactsEvent({
    required super.requestId,
    super.groupId,
    required this.data,
    this.isComplete = false,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "artifacts",
  ///   "requestId": "abc123",
  ///   "data": [
  ///     {
  ///       "title": "Miranda v. Arizona",
  ///       "type": "court_case",
  ///       "resource_uri": "https://example.com/miranda.pdf",
  ///       "publisher": "Supreme Court",
  ///       "date": "1966-06-13",
  ///       "pages": 23
  ///     }
  ///   ],
  ///   "is_complete": true
  /// }
  /// ```
  factory ArtifactsEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final data = json['data'];
    if (data == null || data is! List) {
      throw const FormatException(
        'ArtifactsEvent: missing or invalid "data" field (expected array)',
      );
    }

    // Parse isComplete (supports both snake_case and camelCase)
    final isComplete =
        json['is_complete'] ?? json['isComplete'] ?? false;

    return ArtifactsEvent(
      requestId: requestId,
      groupId: groupId,
      data: data,
      isComplete: isComplete is bool ? isComplete : false,
    );
  }

  /// Number of artifacts in this batch
  int get count => data.length;

  @override
  String toString() =>
      'ArtifactsEvent(requestId: $requestId, artifacts: $count, complete: $isComplete)';
}
