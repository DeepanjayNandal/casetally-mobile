import 'package:flutter/cupertino.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../models/ai_summary.dart';

/// Displays AI-generated summary with confidence indicator
/// Supports markdown formatting (bold text, bullets)
class AISummarySection extends StatelessWidget {
  final AISummary summary;

  const AISummarySection({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with icon
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppText.title(context, 'AI Summary'),
            const Spacer(),
            // Confidence indicator (if high confidence)
            if (summary.isHighConfidence)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  summary.confidencePercentage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Summary card
        AppCard(
          child: _buildFormattedText(context, summary.text),
        ),
      ],
    );
  }

  /// Parse markdown-style text and render with proper formatting
  /// Supports: **bold**, bullet points (•)
  Widget _buildFormattedText(BuildContext context, String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: AppTheme.spacingSm));
        continue;
      }

      // Bullet point line
      if (line.startsWith('•') || line.startsWith('*')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppTheme.spacingSm,
              left: AppTheme.spacingSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label.resolveFrom(context),
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: _buildStyledText(
                    context,
                    line.replaceFirst(RegExp(r'^[•*]\s*'), ''),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: _buildStyledText(context, line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Build text with bold support (**text**)
  Widget _buildStyledText(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before bold
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
        ));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
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
