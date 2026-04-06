import 'package:flutter/cupertino.dart';

/// Standardized icon container with glass-style colored background
///
/// **Features:**
/// - Consistent size and shape (48x48 default)
/// - Color with 15% opacity background
/// - Subtle colored border (glass aesthetic)
/// - Rounded corners (12px)
/// - Automatic icon sizing (50% of container size)
///
/// **Usage:**
/// ```dart
/// AppIconContainer(
///   icon: CupertinoIcons.book_fill,
///   color: CupertinoColors.systemGreen,
/// )
///
/// AppIconContainer(
///   icon: CupertinoIcons.lightbulb_fill,
///   color: CupertinoColors.systemYellow,
///   size: 48,
/// )
/// ```
class AppIconContainer extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Icon and background color
  final Color color;

  /// Container size (default: 48px)
  final double size;

  /// Background opacity (default: 0.15)
  final double backgroundOpacity;

  /// Border radius (default: 12px)
  final double borderRadius;

  const AppIconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.backgroundOpacity = 0.15,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3), // Glass-style colored border
          width: 0.5,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.5, // Icon is 50% of container size
        color: color,
      ),
    );
  }
}
