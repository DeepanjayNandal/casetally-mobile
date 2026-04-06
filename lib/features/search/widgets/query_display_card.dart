import 'package:flutter/cupertino.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_card.dart';

/// Displays the user's search query in a styled card
/// Apple Music-inspired design with search icon
class QueryDisplayCard extends StatelessWidget {
  final String query;

  const QueryDisplayCard({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              CupertinoIcons.search,
              size: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Query text
          Expanded(
            child: AppText.secondary(
              context,
              '"$query"',
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
