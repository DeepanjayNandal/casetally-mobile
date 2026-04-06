import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Standard card component — Perplexity-style solid surface
/// Uses AppTheme.cardBackground (#1A1A1A dark) + hairline border (#242424)
/// Glass is intentionally removed from cards.
/// Glass lives ONLY in GlassBottomBar (control layer).
///
/// **Automatically handles:**
/// - Consistent padding/spacing/borders
/// - Tap interactions with haptic feedback
/// - Dark mode support
///
/// **Usage:**
/// ```dart
/// AppCard(
///   child: Text('Card content'),
/// )
///
/// AppCard(
///   padding: EdgeInsets.all(16),
///   margin: EdgeInsets.only(bottom: 12),
///   onTap: () => navigate(),
///   child: Row(...),
/// )
/// ```
///
/// **Border radius guide:**
/// - Standard cards: 18px (default)
/// - Feature cards (top story, continue reading): 24px
class AppCard extends StatelessWidget {
  /// Content inside the card
  final Widget child;

  /// Internal padding (default: 20px all sides)
  final EdgeInsetsGeometry? padding;

  /// External margin for spacing between cards
  final EdgeInsetsGeometry? margin;

  /// Tap callback (adds haptic feedback automatically)
  final VoidCallback? onTap;

  /// Custom border radius (default: 18px for standard cards)
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 18;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppTheme.cardBorderColor(context),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: card,
      );
    }

    return card;
  }
}
