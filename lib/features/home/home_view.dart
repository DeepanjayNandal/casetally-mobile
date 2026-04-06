import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/bottom_bar_metrics.dart';
import '../../components/app_text.dart';
import '../../components/app_scroll_view.dart';
import 'data/news_feed_data.dart';
import 'widgets/top_story_card.dart';
import 'widgets/latest_updates_section.dart';
import 'widgets/learn_today_card.dart';
import 'widgets/continue_reading_section.dart';
import '../uscode/widgets/uscode_preview_section.dart';

/// Home dashboard - Clean, minimal iOS design
/// **Updated:** Now includes U.S. Code preview section
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppTheme.scaffoldBackground(context),
      child: AppScrollView(
        slivers: [
          // Header: OPENRIGHTS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingMd,
              ),
              child: AppText.brand(context, 'OPENRIGHTS'),
            ),
          ),

          // Large Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingMd,
                AppTheme.spacingLg,
                AppTheme.spacingXl,
              ),
              child: AppText.largeTitle(context, 'Home'),
            ),
          ),

          // NEWS FEED CONTENT
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. TOP STORY (Featured)
                AppText.sectionHeader(context, 'TOP STORY'),
                const SizedBox(height: AppTheme.spacingMd),
                TopStoryCard(newsItem: NewsFeedData.topStory),

                const SizedBox(height: AppTheme.spacingXl),

                // 2. LATEST UPDATES
                LatestUpdatesSection(updates: NewsFeedData.latestUpdates),

                const SizedBox(height: AppTheme.spacingXl),

                // 3. CONTINUE READING
                const ContinueReadingSection(),

                const SizedBox(height: AppTheme.spacingXl),

                // 4. BROWSE U.S. CODE
                const UsCodePreviewSection(),

                const SizedBox(height: AppTheme.spacingXl),

                // 5. LEARN TODAY
                LearnTodayCard(tip: NewsFeedData.todaysTip),

                SizedBox(height: BottomBarMetrics.scrollSpacerHeight(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
