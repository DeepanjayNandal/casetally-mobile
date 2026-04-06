import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an article the user has recently opened
class ReadingProgress {
  final String articleId;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.articleId,
    required this.lastReadAt,
  });

  /// Copy with new values
  ReadingProgress copyWith({
    String? articleId,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      articleId: articleId ?? this.articleId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

/// Tracks which articles the user is currently reading
/// Phase 1: In-memory only (resets when app closes)
/// Phase 2: Add SharedPreferences for persistence
/// Phase 3: Sync with backend API
class ReadingHistoryNotifier extends StateNotifier<List<ReadingProgress>> {
  ReadingHistoryNotifier() : super([]);

  /// Mark an article as being read
  /// Adds to top of list, removes duplicate if exists
  void markAsReading(String articleId) {
    // Remove existing entry for this article (if any)
    final filtered =
        state.where((item) => item.articleId != articleId).toList();

    // Add new entry at the top
    state = [
      ReadingProgress(
        articleId: articleId,
        lastReadAt: DateTime.now(),
      ),
      ...filtered,
    ];
  }

  /// Get recently read articles (last N)
  List<ReadingProgress> getRecent({int limit = 3}) {
    return state.take(limit).toList();
  }

  /// Clear all reading history
  void clearHistory() {
    state = [];
  }

  /// Remove specific article from history
  void removeArticle(String articleId) {
    state = state.where((item) => item.articleId != articleId).toList();
  }
}

/// Global provider for reading history
final readingHistoryProvider =
    StateNotifierProvider<ReadingHistoryNotifier, List<ReadingProgress>>(
  (ref) => ReadingHistoryNotifier(),
);
