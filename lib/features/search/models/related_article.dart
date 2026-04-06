/// Link to our existing articles (from Resources tab)
/// Connects AI search results back to our educational content
class RelatedArticle {
  final String id;
  final String title;
  final String category;
  final int readingMinutes;
  final String relevanceReason;

  const RelatedArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.readingMinutes,
    required this.relevanceReason,
  });

  /// Parse from JSON with validation
  factory RelatedArticle.fromJson(Map<String, dynamic> json) {
    // Validate id
    final id = json['id'];
    if (id == null || id is! String || id.isEmpty) {
      throw FormatException('RelatedArticle: missing or invalid "id" field');
    }

    // Validate title
    final title = json['title'];
    if (title == null || title is! String || title.isEmpty) {
      throw FormatException('RelatedArticle: missing or invalid "title" field');
    }

    // Validate category
    final category = json['category'];
    if (category == null || category is! String || category.isEmpty) {
      throw FormatException(
          'RelatedArticle: missing or invalid "category" field');
    }

    // Validate reading_minutes
    final readingMinutes = json['reading_minutes'];
    if (readingMinutes == null ||
        readingMinutes is! int ||
        readingMinutes <= 0) {
      throw FormatException(
          'RelatedArticle: missing or invalid "reading_minutes" field (must be positive integer)');
    }

    // Validate relevance_reason
    final relevanceReason = json['relevance_reason'];
    if (relevanceReason == null ||
        relevanceReason is! String ||
        relevanceReason.isEmpty) {
      throw FormatException(
          'RelatedArticle: missing or invalid "relevance_reason" field');
    }

    return RelatedArticle(
      id: id,
      title: title,
      category: category,
      readingMinutes: readingMinutes,
      relevanceReason: relevanceReason,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'reading_minutes': readingMinutes,
      'relevance_reason': relevanceReason,
    };
  }

  /// Format reading time for display
  String get readingTimeText => '$readingMinutes min read';

  /// Get route path for navigation
  String get routePath => '/resources/article/$id';

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'know-your-rights':
        return 'Know Your Rights';
      case 'politicians-officials':
        return 'Politicians & Officials';
      case 'state-county-laws':
        return 'State & County Laws';
      case 'federal-laws-codes':
        return 'Federal Laws & Codes';
      default:
        return category;
    }
  }
}
