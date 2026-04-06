import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../components/app_scroll_view.dart';
import '../../components/app_text.dart';
import '../../features/home/providers/reading_history_provider.dart';
import 'data/sample_articles.dart';
import 'widgets/article_section_widget.dart';

/// Full article reader
/// Tracks when user opens article for "Continue Reading" feature
/// Uses pure white/black background for optimal reading
class ArticleViewer extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleViewer({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends ConsumerState<ArticleViewer> {
  @override
  void initState() {
    super.initState();

    // Mark article as being read (after frame is built)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingHistoryProvider.notifier).markAsReading(widget.articleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final article = getArticleById(widget.articleId);

    if (article == null) {
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
            AppText.body(context, 'Article not found'),
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
                // Title
                AppText.largeTitle(context, article.title),

                const SizedBox(height: AppTheme.spacingSm),

                // Metadata
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.clock,
                      size: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    AppText.caption(
                      context,
                      '${article.readingMinutes} min read',
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    const Icon(
                      CupertinoIcons.doc_text,
                      size: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    AppText.caption(
                      context,
                      '${article.sections.length} sections',
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Divider
                Container(
                  height: 1,
                  color: CupertinoColors.separator.resolveFrom(context),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Introduction
                AppText.body(context, article.introduction),

                const SizedBox(height: AppTheme.spacingXxl),

                // Sections
                ...article.sections.map(
                  (section) => ArticleSectionWidget(section: section),
                ),

                // Key Takeaways
                _KeyTakeawaysBox(takeaways: article.keyTakeaways),

                const SizedBox(height: 120), // Space for search bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Key takeaways highlight box
class _KeyTakeawaysBox extends StatelessWidget {
  final List<String> takeaways;

  const _KeyTakeawaysBox({required this.takeaways});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: CupertinoColors.systemGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: CupertinoColors.systemGreen,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              AppText.title(context, 'Key Takeaways'),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...takeaways.map((takeaway) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ ',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: AppText.body(context, takeaway),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
