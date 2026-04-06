import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../providers/reading_history_provider.dart';
import '../../resources/data/sample_articles.dart';
import '../../resources/models/article.dart';

/// Section showing articles user recently opened
/// Gets data from reading history provider
/// Hides entirely if no reading history (Apple News style)
class ContinueReadingSection extends ConsumerWidget {
  const ContinueReadingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingHistory = ref.watch(readingHistoryProvider);

    // Get last 3 articles from reading history
    final recentArticles = readingHistory
        .take(3)
        .map((progress) {
          return getArticleById(progress.articleId);
        })
        .whereType<Article>()
        .toList();

    // Hide section if no reading history (Apple News style)
    if (recentArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          AppText.sectionHeader(context, 'CONTINUE READING'),

          const SizedBox(height: AppTheme.spacingMd),

          // List of articles
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(recentArticles.length, (index) {
                final article = recentArticles[index];
                return Column(
                  children: [
                    _ArticleRow(
                      article: article,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.push('/resources/article/${article.id}');
                      },
                    ),
                    if (index < recentArticles.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: AppTheme.spacingLg),
                        child: Container(
                          height: 0.5,
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleRow({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 13,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${article.readingMinutes} min read · ${article.sections.length} sections',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ),
      ),
    );
  }
}
