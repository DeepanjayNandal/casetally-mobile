import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../components/app_text.dart';
import '../../components/app_scroll_view.dart';
import '../../components/app_scaffold.dart';
import '../../components/app_card.dart';
import 'models/article.dart';
import 'data/sample_articles.dart';

/// Shows list of articles in a category
/// Doesn't know data source - just displays
class CategoryDetailView extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryDetailView({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final articles = getArticlesByCategory(categoryId);

    return AppScrollView(
      slivers: [
        // Large title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              AppTheme.spacingMd,
            ),
            child: AppText.largeTitle(context, categoryTitle),
          ),
        ),

        // Article count
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              0,
              AppTheme.spacingLg,
              AppTheme.spacingXl,
            ),
            child: AppText.secondary(
              context,
              '${articles.length} ${articles.length == 1 ? 'article' : 'articles'}',
            ),
          ),
        ),

        // Article list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index];
                return _ArticleListItem(
                  article: article,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/resources/article/${article.id}');
                  },
                );
              },
              childCount: articles.length,
            ),
          ),
        ),

        // Bottom spacing for search bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }
}

/// Article list item card
class _ArticleListItem extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleListItem({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.doc_text_fill,
              color: CupertinoColors.activeBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.title(context, article.title),
                const SizedBox(height: 4),
                AppText.caption(
                  context,
                  '${article.readingMinutes} min read • ${article.sections.length} sections',
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
    );
  }
}
