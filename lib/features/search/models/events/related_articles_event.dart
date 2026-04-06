import '../search_event.dart';

/// Related articles from CaseTally's Resources library
///
/// **UI Response:**
/// - "Related Articles" section appears
/// - Links back to existing Resources content
/// - Encourages deeper learning
///
/// **Business Logic:**
/// Connects AI search results to curated educational content
class RelatedArticlesEvent extends SearchEvent {
  /// Raw article data (will be parsed by repository)
  /// Each item should match RelatedArticle JSON structure
  final List<dynamic> data;

  const RelatedArticlesEvent({
    required super.requestId,
    super.groupId,
    required this.data,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "related_articles",
  ///   "requestId": "abc123",
  ///   "data": [
  ///     {
  ///       "id": "miranda-rights-101",
  ///       "title": "Miranda Rights: What You Need to Know",
  ///       "category": "know-your-rights",
  ///       "reading_minutes": 5,
  ///       "relevance_reason": "Comprehensive guide..."
  ///     }
  ///   ]
  /// }
  /// ```
  factory RelatedArticlesEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final data = json['data'];
    if (data == null || data is! List) {
      throw FormatException(
        'RelatedArticlesEvent: missing or invalid "data" field (expected array)',
      );
    }

    return RelatedArticlesEvent(
      requestId: requestId,
      groupId: groupId,
      data: data,
    );
  }

  /// Number of articles in this batch
  int get count => data.length;

  @override
  String toString() =>
      'RelatedArticlesEvent(requestId: $requestId, articles: $count)';
}
