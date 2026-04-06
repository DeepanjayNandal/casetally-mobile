import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../providers/uscode_provider.dart';

/// U.S. Code preview section for Home — compact list design
///
/// Vertical padding only — horizontal padding comes from parent SliverPadding.
class UsCodePreviewSection extends ConsumerStatefulWidget {
  const UsCodePreviewSection({super.key});

  @override
  ConsumerState<UsCodePreviewSection> createState() =>
      _UsCodePreviewSectionState();
}

class _UsCodePreviewSectionState extends ConsumerState<UsCodePreviewSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usCodeProvider.notifier).loadFeaturedTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usCodeProvider);

    // LOADING STATE
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.sectionHeader(context, 'U.S. CODE'),
            const SizedBox(height: AppTheme.spacingMd),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXl),
                child: CupertinoActivityIndicator(radius: 14),
              ),
            ),
          ],
        ),
      );
    }

    // ERROR STATE
    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.sectionHeader(context, 'U.S. CODE'),
            const SizedBox(height: AppTheme.spacingMd),
            AppCard(
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 32,
                    color: CupertinoColors.systemRed,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  AppText.secondary(
                    context,
                    state.errorMessage ?? 'Failed to load',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(usCodeProvider.notifier).loadFeaturedTitles();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // EMPTY STATE
    if (!state.hasData || state.titles.isEmpty) {
      return const SizedBox.shrink();
    }

    // SUCCESS STATE
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.sectionHeader(context, 'U.S. CODE'),

          const SizedBox(height: AppTheme.spacingMd),

          const AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _CodeItem(label: 'Criminal Law',  titleNum: 18, icon: CupertinoIcons.lock_shield),
                _Divider(),
                _CodeItem(label: 'Civil Rights',  titleNum: 42, icon: CupertinoIcons.person_2),
                _Divider(),
                _CodeItem(label: 'Immigration',   titleNum: 8,  icon: CupertinoIcons.airplane),
                _Divider(),
                _CodeItem(label: 'Tax Law',       titleNum: 26, icon: CupertinoIcons.money_dollar),
                _Divider(),
                _CodeItem(label: 'Armed Forces',  titleNum: 10, icon: CupertinoIcons.shield),
                _Divider(),
                _CodeItem(label: 'Public Health', titleNum: 42, icon: CupertinoIcons.heart),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/uscode');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View All 54 Titles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeItem extends StatelessWidget {
  final String label;
  final int titleNum;
  final IconData icon;

  const _CodeItem({
    required this.label,
    required this.titleNum,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/uscode/title/$titleNum');
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemIndigo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: CupertinoColors.systemIndigo,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Text(
              'Title $titleNum',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.systemGrey,
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingMd),
      child: Container(
        height: 0.5,
        color: CupertinoColors.separator.resolveFrom(context),
      ),
    );
  }
}
