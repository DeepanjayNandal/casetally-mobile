import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

/// iOS-style hierarchy item (thin, clean, indented)
/// Used ONLY for U.S. Code hierarchy navigation
/// Different from AppCard (which is bulkier for news/articles)
class IosHierarchyItem extends StatelessWidget {
  final String label;
  final String? subtitle;
  final int depth; // 0 = root, 1 = first level, 2 = second level
  final bool isExpandable;
  final bool isExpanded;
  final bool isSection; // true = navigates to text, false = expands
  final VoidCallback onTap;

  const IosHierarchyItem({
    super.key,
    required this.label,
    this.subtitle,
    this.depth = 0,
    this.isExpandable = false,
    this.isExpanded = false,
    this.isSection = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(
          left: depth * 20.0, // 20px indent per level
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.33,
            ),
          ),
        ),
        child: Row(
          children: [
            // Chevron (only if expandable)
            if (isExpandable)
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0, // 90° rotation
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              )
            else if (isSection)
              Icon(
                CupertinoIcons.doc_text,
                size: 16,
                color: CupertinoColors.systemIndigo.resolveFrom(context),
              )
            else
              const SizedBox(width: 16),

            const SizedBox(width: 12),

            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing chevron (only for sections)
            if (isSection)
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: CupertinoColors.systemGrey3.resolveFrom(context),
              ),
          ],
        ),
      ),
    );
  }
}
