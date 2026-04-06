import 'package:flutter/cupertino.dart';
import '../models/article.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';

/// Renders article sections based on type
/// Add new type: just add case, parent unchanged
class ArticleSectionWidget extends StatelessWidget {
  final ArticleSection section;

  const ArticleSectionWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          AppText.title(context, section.heading),
          const SizedBox(height: AppTheme.spacingMd),

          // Content varies by type
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (section.type) {
      case SectionType.paragraph:
        return _ParagraphContent(section.content);

      case SectionType.list:
        return _ListContent(section.content);

      case SectionType.quote:
        return _QuoteContent(section.content);

      case SectionType.highlight:
        return _HighlightContent(section.content);
    }
  }
}

/// Paragraph section
class _ParagraphContent extends StatelessWidget {
  final String content;
  const _ParagraphContent(this.content);

  @override
  Widget build(BuildContext context) {
    return AppText.body(context, content);
  }
}

/// Bullet list section
class _ListContent extends StatelessWidget {
  final String content;
  const _ListContent(this.content);

  @override
  Widget build(BuildContext context) {
    final items = content.split('\n').where((s) => s.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final cleanItem = item.replaceFirst('•', '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              Expanded(
                child: AppText.body(context, cleanItem),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Quote box section
class _QuoteContent extends StatelessWidget {
  final String content;
  const _QuoteContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: const Border(
          left: BorderSide(
            color: CupertinoColors.activeBlue,
            width: 4,
          ),
        ),
      ),
      child: AppText.body(context, content),
    );
  }
}

/// Highlighted box section
class _HighlightContent extends StatelessWidget {
  final String content;
  const _HighlightContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: CupertinoColors.activeBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.info_circle_fill,
            color: CupertinoColors.activeBlue,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: AppText.body(context, content),
          ),
        ],
      ),
    );
  }
}
