import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../../../components/app_icon_container.dart';
import '../models/learning_tip.dart';

/// Card displaying daily legal tip/concept
/// Highlighted educational content with yellow accent
class LearnTodayCard extends StatelessWidget {
  final LearningTip tip;

  const LearnTodayCard({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          AppText.sectionHeader(context, 'LEARN TODAY'),

          const SizedBox(height: AppTheme.spacingMd),

          // Tip card
          AppCard(
            onTap: tip.hasArticleLink
                ? () {
                    context.push('/resources/article/${tip.articleId}');
                  }
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                AppIconContainer(
                  icon: CupertinoIcons.lightbulb_fill,
                  color: CupertinoColors.systemYellow,
                ),

                const SizedBox(width: AppTheme.spacingMd),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.title(context, tip.title),
                      const SizedBox(height: AppTheme.spacingSm),
                      AppText.secondary(context, tip.description),

                      // Show "Learn More" link if article exists
                      if (tip.hasArticleLink) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            Text(
                              'Learn More',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              CupertinoIcons.arrow_right,
                              size: 14,
                              color: CupertinoColors.activeBlue,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
