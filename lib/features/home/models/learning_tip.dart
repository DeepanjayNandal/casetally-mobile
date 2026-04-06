/// Daily legal tip/concept for educational content
/// Pure Dart - no Flutter dependencies
class LearningTip {
  final String id;
  final String title;
  final String description;
  final String? articleId; // Links to Resources article for more info

  const LearningTip({
    required this.id,
    required this.title,
    required this.description,
    this.articleId,
  });

  /// Check if this tip has a linked article for more details
  bool get hasArticleLink => articleId != null;
}
