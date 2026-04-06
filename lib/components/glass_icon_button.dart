import 'package:flutter/cupertino.dart';
import '../theme/glass_tokens.dart';
import 'glass.dart';

/// Reusable circular glass icon button
///
/// Consolidates the glass button pattern used throughout the app.
/// Prevents duplication and ensures consistent styling.
///
/// **Usage:**
/// ```dart
/// // Presets (recommended)
/// GlassIconButton.search(onTap: () => ...)
/// GlassIconButton.close(onTap: () => ...)
///
/// // Custom
/// GlassIconButton(
///   icon: CupertinoIcons.star,
///   onTap: () => ...,
/// )
/// ```
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final String? heroTag;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 56,
    this.iconSize = 24,
    this.iconColor = CupertinoColors.white,
    this.heroTag,
  });

  /// Search button preset with Hero animation
  const GlassIconButton.search({
    super.key,
    required this.onTap,
    this.heroTag = 'search_hero',
  })  : icon = CupertinoIcons.search,
        size = 56,
        iconSize = 24,
        iconColor = CupertinoColors.white;

  /// Close button preset (no Hero)
  const GlassIconButton.close({
    super.key,
    required this.onTap,
  })  : icon = CupertinoIcons.xmark,
        size = 56,
        iconSize = 24,
        iconColor = CupertinoColors.white,
        heroTag = null;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: GlassContainer(
          borderRadius: size / 2,
          blur: kDockGlassBlur,
          gradient: kDockGlassGradient,
          borderColor: kDockGlassBorderColor,
          borderWidth: kDockGlassBorderWidth,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        // Use non-blurred shuttle during flight to avoid overlay blur issues
        // BackdropFilter in Hero overlay blurs the overlay layer, not screen content
        flightShuttleBuilder: _buildFlightShuttle,
        child: button,
      );
    }
    return button;
  }

  /// Builds a simple tinted container for Hero flight animation
  /// Avoids BackdropFilter in overlay layer which causes incorrect blur
  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: kDockGlassGradient,
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: kDockGlassBorderColor,
              width: kDockGlassBorderWidth,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        );
      },
    );
  }
}
