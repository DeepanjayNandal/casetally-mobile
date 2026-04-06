import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../models/news_item.dart';

/// Displays latest news updates in a compact list
/// Apple News-style compact items with timestamps
///
/// **Width Fix:** Removed horizontal padding to match Top Story & Learn Today
/// Concept: Parent (home_view.dart) provides horizontal padding via SliverPadding
/// Child widgets only add vertical padding to avoid double-padding
class LatestUpdatesSection extends StatelessWidget {
  final List<NewsItem> updates;

  const LatestUpdatesSection({
    super.key,
    required this.updates,
  });

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) return const SizedBox.shrink();

    // Concept: Only vertical padding - horizontal comes from home_view.dart
    // This matches the pattern used in learn_today_card.dart (line 22-25)
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          AppText.sectionHeader(context, 'LATEST UPDATES'),

          const SizedBox(height: AppTheme.spacingMd),

          // Updates container - using AppCard with zero padding
          // Concept: AppCard provides base styling (#292929 dark, borders, haptics)
          // padding: EdgeInsets.zero allows _UpdateItem to handle internal spacing
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < updates.length; i++) ...[
                  _UpdateItem(
                    update: updates[i],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (updates[i].hasArticleLink) {
                        context
                            .push('/resources/article/${updates[i].articleId}');
                      }
                    },
                  ),
                  // Divider between items (not after last item)
                  // Concept: iOS Settings-style dividers for list separation
                  if (i < updates.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                      ),
                      child: Container(
                        height: 0.5,
                        color: CupertinoColors.separator.resolveFrom(context),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual update item
/// Concept: Private widget (_prefix) - only used within this file
/// Follows iOS list item pattern: bullet + content + chevron
class _UpdateItem extends StatelessWidget {
  final NewsItem update;
  final VoidCallback onTap;

  const _UpdateItem({
    required this.update,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: category badge + spacer + timestamp
            Row(
              children: [
                Text(
                  update.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  update.timeAgo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Title row: title + chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    update.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: CupertinoColors.systemGrey3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
