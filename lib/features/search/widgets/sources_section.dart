import 'package:flutter/cupertino.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../models/source.dart';

/// Displays external sources/citations
/// Simple list with credibility indicators
class SourcesSection extends StatelessWidget {
  final List<Source> sources;

  const SourcesSection({
    super.key,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.book_circle,
                size: 16,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppText.title(context, 'Sources'),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Sources list
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < sources.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: _SourceItem(source: sources[i]),
                ),
                if (i < sources.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                    ),
                    child: Container(
                      height: 0.5,
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual source item
class _SourceItem extends StatelessWidget {
  final Source source;

  const _SourceItem({required this.source});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Credibility icon
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            source.credibilityIcon,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(width: AppTheme.spacingSm),

        // Source info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body(context, source.name),
              const SizedBox(height: 4),
              AppText.caption(
                context,
                '${source.type.displayName} • ${source.credibility.displayName}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
