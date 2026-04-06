import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../models/news_item.dart';

/// Large featured news card (hero section)
/// Apple News-style top story with gradient overlay on AppCard
class TopStoryCard extends StatelessWidget {
  final NewsItem newsItem;

  const TopStoryCard({
    super.key,
    required this.newsItem,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 24, // Feature card = larger radius
      onTap: () {
        if (newsItem.hasArticleLink) {
          context.push('/resources/article/${newsItem.articleId}');
        }
      },
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                newsItem.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Title (large and prominent)
            AppText.heading(context, newsItem.title),

            const SizedBox(height: AppTheme.spacingSm),

            // Summary (if available)
            if (newsItem.summary != null) ...[
              AppText.secondary(
                context,
                newsItem.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],

            // Timestamp and chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 14,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                    const SizedBox(width: 4),
                    AppText.caption(context, newsItem.timeAgo),
                  ],
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: CupertinoColors.systemGrey3,
                ),
              ],
            ),
          ],
        ),
    );
  }
}
