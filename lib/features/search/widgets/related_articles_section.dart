import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../models/related_article.dart';

/// Displays related articles from our Resources library
/// Tappable cards that navigate to full article
class RelatedArticlesSection extends StatelessWidget {
  final List<RelatedArticle> articles;

  const RelatedArticlesSection({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.link,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppText.title(context, 'Related Articles'),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Article cards
        ...articles.map((article) => _ArticleCard(article: article)),
      ],
    );
  }
}

/// Individual article card (tappable)
class _ArticleCard extends StatelessWidget {
  final RelatedArticle article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(article.routePath);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Document icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.doc_text_fill,
                color: CupertinoColors.activeBlue,
                size: 20,
              ),
            ),

            const SizedBox(width: AppTheme.spacingMd),

            // Article info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.title(context, article.title),
                  const SizedBox(height: 4),
                  AppText.caption(
                    context,
                    '${article.readingTimeText} • ${article.categoryDisplayName}',
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.spacingSm),

            // Chevron
            const Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ),
      ),
    );
  }
}
