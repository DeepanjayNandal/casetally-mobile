import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// Surface container for elevated UI elements
///
/// **Used for:**
/// - Search bar backgrounds
/// - Bottom navigation backgrounds
/// - Modal/sheet backgrounds
/// - Input field containers
///
/// **Features:**
/// - Theme-aware colors (#292929 dark, system background light)
/// - Consistent border radius (13px)
/// - Optional border
/// - Consistent spacing
///
/// **Usage:**
/// ```dart
/// AppSurface(
///   child: TextField(...),
/// )
///
/// AppSurface(
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   showBorder: false,
///   child: Row(...),
/// )
/// ```
///
/// **Replaces:**
/// ```dart
/// Container(
///   padding: EdgeInsets.all(...),
///   decoration: BoxDecoration(
///     color: CupertinoColors.systemBackground.resolveFrom(context),
///     borderRadius: BorderRadius.circular(13),
///   ),
///   child: ...,
/// )
/// ```
class AppSurface extends StatelessWidget {
  /// Content inside the surface
  final Widget child;

  /// Internal padding (default: 16px all sides)
  final EdgeInsetsGeometry? padding;

  /// External margin for spacing
  final EdgeInsetsGeometry? margin;

  /// Whether to show border (default: true)
  final bool showBorder;

  /// Custom border radius (default: 13px from theme)
  final double? borderRadius;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.showBorder = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBackground(context),
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMd,
        ),
        border: showBorder
            ? Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
                width: 0.5,
              )
            : null,
      ),
      child: child,
    );
  }
}
