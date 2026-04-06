import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/law_reference.dart';
import '../models/related_article.dart';
import '../../../theme/app_theme.dart';

class StreamingAnswer extends StatelessWidget {
  final String summaryText;
  final bool isStreaming;
  final List<LawReference> laws;
  final List<RelatedArticle> relatedArticles;

  const StreamingAnswer({
    super.key,
    required this.summaryText,
    required this.isStreaming,
    required this.laws,
    required this.relatedArticles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summaryText.isNotEmpty) ...[
          _buildFormattedText(
            context,
            summaryText,
            isStreaming: isStreaming,
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
        if (laws.isNotEmpty) ...[
          _buildSectionHeader(context, 'Relevant Laws'),
          const SizedBox(height: AppTheme.spacingMd),
          ...laws.map((law) => _buildLawBullet(context, law)),
          const SizedBox(height: AppTheme.spacingXl),
        ],
        if (relatedArticles.isNotEmpty) ...[
          _buildSectionHeader(context, 'Related Questions'),
          const SizedBox(height: AppTheme.spacingMd),
          ...relatedArticles
              .map((article) => _buildRelatedQuestion(context, article)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildLawBullet(BuildContext context, LawReference law) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  law.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  law.citation,
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                if (law.summary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    law.summary,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      height: 1.4,
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

  Widget _buildRelatedQuestion(BuildContext context, RelatedArticle article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to article
        },
        child: Row(
          children: [
            Icon(
              CupertinoIcons.arrow_turn_down_right,
              size: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                article.title,
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.label.resolveFrom(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(
    BuildContext context,
    String text, {
    bool isStreaming = false,
  }) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('•') || line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: CupertinoColors.label.resolveFrom(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStyledText(
                    context,
                    line.replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStyledText(context, line),
          ),
        );
      }
    }

    if (isStreaming) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              CupertinoActivityIndicator(
                radius: 8,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating...',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildStyledText(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: -0.4,
          height: 1.5,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}
