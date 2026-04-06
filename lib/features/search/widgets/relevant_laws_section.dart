import 'package:flutter/cupertino.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';
import '../models/law_reference.dart';

/// Displays list of relevant laws, cases, and statutes
/// Each law shown as a card with emoji icon
class RelevantLawsSection extends StatelessWidget {
  final List<LawReference> laws;

  const RelevantLawsSection({
    super.key,
    required this.laws,
  });

  @override
  Widget build(BuildContext context) {
    if (laws.isEmpty) return const SizedBox.shrink();

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
                color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.book,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppText.title(context, 'Relevant Laws'),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Law cards
        ...laws.map((law) => _LawCard(law: law)),
      ],
    );
  }
}

/// Individual law reference card
class _LawCard extends StatelessWidget {
  final LawReference law;

  const _LawCard({required this.law});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with emoji
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                law.typeEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: AppText.title(context, law.title),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingSm),

          // Citation
          AppText.secondary(context, law.citation),

          const SizedBox(height: AppTheme.spacingSm),

          // Metadata (jurisdiction • type)
          Row(
            children: [
              Text(
                law.jurisdiction,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
              Text(
                law.type.displayName,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),

          // Summary (optional, show if relevant)
          if (law.isHighlyRelevant) ...[
            const SizedBox(height: AppTheme.spacingMd),
            AppText.caption(context, law.summary),
          ],
        ],
      ),
    );
  }
}
