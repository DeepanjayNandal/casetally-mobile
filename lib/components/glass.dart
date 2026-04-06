import 'dart:ui';
import 'package:flutter/cupertino.dart';

import '../theme/glass_tokens.dart';

/// Authentic iOS glass morphism container
///
/// **Based on production implementations:**
/// - Repo: RitickSaha/glassmorphism (proven pattern)
/// - Repo: sbis04/liquid_glass_demo (iOS bottom bar)
///
/// **Key techniques:**
/// 1. Asymmetric blur (sigmaY = 2x sigmaX) for realistic glass
/// 2. LinearGradient tint (not solid) for light refraction
/// 3. Light borders (1-2px max, 15-20% white)
/// 4. Theme-aware (white tint dark mode, black tint light mode)
/// 5. RepaintBoundary for performance
///
/// **Two-Tier System (recommended):**
/// ```dart
/// // OVERLAY - nav bar, modals, floating elements
/// GlassContainer.overlay(child: Text('Nav bar'))
///
/// // SURFACE - cards, pills, content elements
/// GlassContainer.surface(child: Text('Content card'))
/// ```
///
/// **Legacy presets:**
/// ```dart
/// GlassContainer.light(child: ...)   // Subtle
/// GlassContainer.medium(child: ...)  // Standard
/// GlassContainer.heavy(child: ...)   // Prominent
/// ```
///
/// **Custom:**
/// ```dart
/// GlassContainer(blur: 10, child: ...)
/// ```
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Gradient? gradient;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.gradient,
    this.borderRadius = 20,
    this.borderColor,
    this.borderWidth = 0.5,
    this.padding,
    this.margin,
    this.boxShadow,
  });

  /// Light glass preset - subtle, barely-there
  ///
  /// **Specs (from repos):**
  /// - Blur: 5 (asymmetric 5x10)
  /// - Gradient: white 15% → 8% (top-left to bottom-right)
  /// - Border: 1px, white 15%
  ///
  /// **Use for:** Buttons, pills, subtle backgrounds
  const GlassContainer.light({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : blur = 5,
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x26FFFFFF), // white 15%
            Color(0x14FFFFFF), // white 8%
          ],
        ),
        borderRadius = 20,
        borderColor = const Color(0x26FFFFFF), // white 15%
        borderWidth = 1.0;

  /// Medium glass preset - standard iOS glass
  ///
  /// **Specs (from repos):**
  /// - Blur: 8 (asymmetric 8x16)
  /// - Gradient: white 18% → 10%
  /// - Border: 1.5px, white 18%
  ///
  /// **Use for:** Bottom bar, cards, standard surfaces
  const GlassContainer.medium({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : blur = 8,
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x2EFFFFFF), // white 18%
            Color(0x1AFFFFFF), // white 10%
          ],
        ),
        borderRadius = 20,
        borderColor = const Color(0x2EFFFFFF), // white 18%
        borderWidth = 1.5;

  /// Heavy glass preset - prominent, modal-style
  ///
  /// **Specs (from repos):**
  /// - Blur: 15 (asymmetric 15x30)
  /// - Gradient: white 22% → 12%
  /// - Border: 2px, white 20%
  ///
  /// **Use for:** Modals, overlays, prominent surfaces
  const GlassContainer.heavy({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : blur = 15,
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x38FFFFFF), // white 22%
            Color(0x1FFFFFFF), // white 12%
          ],
        ),
        borderRadius = 20,
        borderColor = const Color(0x33FFFFFF), // white 20%
        borderWidth = 2.0;

  // ==========================================================================
  // TWO-TIER SYSTEM PRESETS (use these for consistency)
  // ==========================================================================

  /// **OVERLAY TIER** - Strong glass for floating elements
  ///
  /// Uses tokens from glass_tokens.dart for consistency.
  ///
  /// **Use for:**
  /// - Bottom navigation bar
  /// - Modal sheets
  /// - Floating overlays
  /// - Artifacts pill (currently)
  const GlassContainer.overlay({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : blur = kDockGlassBlur,
        gradient = kDockGlassGradient,
        borderColor = kDockGlassBorderColor,
        borderWidth = kDockGlassBorderWidth;

  /// **SURFACE TIER** - Lighter glass for content elements
  ///
  /// Uses tokens from glass_tokens.dart for consistency.
  ///
  /// **Use for:**
  /// - Cards (news, resources)
  /// - Pills (query, sources)
  /// - Content that needs to be readable
  const GlassContainer.surface({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : blur = kSurfaceGlassBlur,
        gradient = kSurfaceGlassGradient,
        borderColor = kDockGlassBorderColor, // Shared border styling
        borderWidth = kDockGlassBorderWidth;

  @override
  Widget build(BuildContext context) {
    // Get theme brightness for potential theme-aware variants
    final brightness = CupertinoTheme.brightnessOf(context);

    // Default gradient if none provided (black tint in dark mode, white tint in light mode)
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [
                  const Color(0x22000000), // black ~13% (dark absorption)
                  const Color(0x11000000), // black ~7%
                ]
              : [
                  const Color(0x26FFFFFF), // white 15% for light mode
                  const Color(0x14FFFFFF), // white 8%
                ],
        );

    // Default border color if none provided
    final effectiveBorderColor = borderColor ??
        (brightness == Brightness.dark
            ? const Color(0x1AFFFFFF) // white 10%
            : const Color(0x26000000)); // black 15%

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Only include user-provided shadows (removed global white sheen)
        boxShadow: boxShadow,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur * 2, // ASYMMETRIC - critical for realistic glass
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: effectiveGradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: borderWidth,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
