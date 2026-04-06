import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_scroll_view.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/app_card.dart';
import '../providers/uscode_provider.dart';
import '../models/uscode_title.dart';

/// U.S. Code List View - All 54 titles
/// **Pattern:** Reuses resources_view.dart structure
/// iOS Settings style: Large title + scrollable list of cards
class UsCodeListView extends ConsumerStatefulWidget {
  const UsCodeListView({super.key});

  @override
  ConsumerState<UsCodeListView> createState() => _UsCodeListViewState();
}

class _UsCodeListViewState extends ConsumerState<UsCodeListView> {
  @override
  void initState() {
    super.initState();

    // Load all titles on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usCodeProvider.notifier).loadAllTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usCodeProvider);

    return AppScrollView(
      slivers: [
        // Large Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              AppTheme.spacingMd,
            ),
            child: AppText.largeTitle(context, 'U.S. Code'),
          ),
        ),

        // Loading/Error/Content States
        if (state.isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXxl),
                child: CupertinoActivityIndicator(radius: 16),
              ),
            ),
          )
        else if (state.hasError)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 48,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    AppText.title(context, 'Failed to load titles'),
                    const SizedBox(height: AppTheme.spacingSm),
                    AppText.secondary(
                      context,
                      state.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    CupertinoButton.filled(
                      onPressed: () {
                        ref.read(usCodeProvider.notifier).loadAllTitles();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (state.hasData)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            sliver: SliverToBoxAdapter(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(state.titles.length, (index) {
                    final title = state.titles[index];
                    return Column(
                      children: [
                        _TitleRow(
                          title: title,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/uscode/title/${title.number}');
                          },
                        ),
                        if (index < state.titles.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppTheme.spacingLg),
                            child: Container(
                              height: 0.5,
                              color: CupertinoColors.separator
                                  .resolveFrom(context),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  final UsCodeTitle title;
  final VoidCallback onTap;

  const _TitleRow({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemIndigo.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${title.number}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemIndigo,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppTheme.spacingMd),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title ${title.number}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

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
