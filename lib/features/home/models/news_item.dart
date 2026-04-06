/// News item for home feed
/// Can link to Resources article OR external URL (future)
/// Pure Dart - no Flutter dependencies
class NewsItem {
  final String id;
  final String title;
  final String category;
  final DateTime timestamp;
  final String? summary; // Brief description (optional)
  final String? articleId; // Links to Resources article
  final String? externalUrl; // For external news links (future)

  const NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timestamp,
    this.summary,
    this.articleId,
    this.externalUrl,
  });

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  /// Check if this news item has a linked article
  bool get hasArticleLink => articleId != null;

  /// Check if this news item has an external URL
  bool get hasExternalLink => externalUrl != null;
}
