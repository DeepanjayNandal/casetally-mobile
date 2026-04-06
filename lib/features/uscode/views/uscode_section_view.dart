import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_scroll_view.dart';
import '../../../components/app_text.dart';
import '../data/mock_uscode_data.dart';

/// Section Viewer - Displays full legal text
/// **Pattern:** Reuses article_viewer pattern
/// Pure white/black background for optimal reading
/// No Riverpod provider needed - reads directly from static data
class UsCodeSectionView extends ConsumerWidget {
  final String sectionId;

  const UsCodeSectionView({
    super.key,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find section in mock data
    final section = MockUsCodeData.findSectionById(sectionId);

    // NOT FOUND STATE
    if (section == null || !section.isSection) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            AppText.body(context, 'Section not found'),
          ],
        ),
      );
    }

    return SafeArea(
      child: AppScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section label (e.g., "§242")
                Text(
                  section.label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label.resolveFrom(context),
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingSm),

                // Section name
                if (section.name != null)
                  AppText.title(context, section.name!),

                const SizedBox(height: AppTheme.spacingXl),

                // Divider
                Container(
                  height: 1,
                  color: CupertinoColors.separator.resolveFrom(context),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Legal text content
                if (section.content != null)
                  AppText.body(context, section.content!),

                const SizedBox(height: AppTheme.spacingXxl),

                // Metadata section
                if (section.lastUpdated != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          size: 16,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: AppText.caption(
                            context,
                            'Last updated: ${_formatDate(section.lastUpdated!)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 120), // Space for tab bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
