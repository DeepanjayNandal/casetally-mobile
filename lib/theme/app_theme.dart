import 'package:flutter/cupertino.dart';

/// Global Cupertino theme - visual identity for entire app
/// Automatically adapts to light/dark mode via system dynamic colors
///
/// **SINGLE SOURCE OF TRUTH for all colors, spacing, and decorations**
///
/// Dark mode colors:
/// - Background: #0F0F0F (scaffold)
/// - Cards/Surfaces: #1A1A1A (cards)
///
/// Light mode: Uses system defaults
class AppTheme {
  AppTheme._();

  // ==================== CUPERTINO THEME DATA ====================

  static CupertinoThemeData get light => const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontSize: 17,
            color: CupertinoColors.label,
            letterSpacing: -0.4,
          ),
          navTitleTextStyle: TextStyle(
            inherit: false,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
            letterSpacing: -0.6,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label,
            letterSpacing: -1.0,
          ),
        ),
      );

  static CupertinoThemeData get dark => const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: _darkScaffoldBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontSize: 17,
            color: CupertinoColors.label,
            letterSpacing: -0.4,
          ),
          navTitleTextStyle: TextStyle(
            inherit: false,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
            letterSpacing: -0.6,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label,
            letterSpacing: -1.0,
          ),
        ),
      );

  // ==================== TYPOGRAPHY ====================

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: CupertinoColors.white,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    color: CupertinoColors.white,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: CupertinoColors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: CupertinoColors.systemGrey,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: CupertinoColors.systemGrey,
  );

  // ==================== SPACING SYSTEM ====================

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 20;
  static const double spacingXl = 28;
  static const double spacingXxl = 48;

  // ==================== BORDER RADIUS ====================

  static const double radiusXs = 3;   // Micro highlights, emphasis marks
  static const double radiusSm = 8;   // Small containers, list items
  static const double radiusMd = 26;  // Surfaces, search bar, inputs (Apple style)
  static const double radiusLg = 26;  // Cards (Apple Card style - very rounded)
  static const double radiusXl = 18;  // Standard buttons
  static const double radiusXxl = 26; // Large surfaces
  static const double radiusPill = 30; // Selection pills
  static const double radiusFull = 40; // Bottom bar, fully rounded

  // ==================== ICON SIZES ====================

  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;

  // ==================== DARK MODE CONSTANTS ====================

  /// Custom dark mode scaffold background
  static const Color _darkScaffoldBackground = Color(0xFF0F0F0F);

  /// Custom dark mode card/surface background
  static const Color _darkCardBackground = Color(0xFF1A1A1A);

  /// Custom dark mode search bar background (slightly lighter than scaffold for elevation)
  static const Color _darkSearchBackground = Color(0xFF1A1A1A);

  /// Hairline border for dark mode cards (Perplexity-style precision border)
  static const Color _darkCardBorder = Color(0xFF242424);

  /// Light mode search bar background (pure white for clean Apple aesthetic)
  static const Color _lightSearchBackground = Color(0xFFFFFFFF);

  /// Light mode scaffold background (exact iOS system color)
  static const Color _lightScaffoldBackground = Color(0xFFF2F1F6);

  // ==================== COLOR METHODS (THEME-AWARE) ====================

  /// Returns scaffold background color based on current theme
  ///
  /// Dark mode: #161616 (custom)
  /// Light mode: #F2F1F6 (exact iOS system color)
  static Color scaffoldBackground(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return _darkScaffoldBackground;
    }
    return _lightScaffoldBackground;
  }

  /// Returns card background color based on current theme
  ///
  /// Used for: All cards, containers with content
  /// Dark mode: #292929 (custom)
  /// Light mode: Tertiary system background
  static Color cardBackground(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return _darkCardBackground;
    }
    return CupertinoColors.tertiarySystemBackground.resolveFrom(context);
  }

  /// Returns surface background color based on current theme
  ///
  /// Used for: Bottom nav, modals, elevated surfaces
  /// Dark mode: #292929 (same as cards for consistency)
  /// Light mode: System background
  static Color surfaceBackground(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return _darkCardBackground;
    }
    return CupertinoColors.systemBackground.resolveFrom(context);
  }

  /// Returns search bar background color based on current theme
  ///
  /// Used for: Main search/question box
  /// Dark mode: #1E1E1E (slightly lighter than scaffold for elevated appearance)
  /// Light mode: #FFFFFF (pure white for clean Apple Music/News style)
  static Color searchBarBackground(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return _darkSearchBackground;
    }
    return _lightSearchBackground;
  }

  /// Returns card border color based on current theme
  /// Dark mode: #242424 hairline (precision machined look)
  /// Light mode: system separator
  static Color cardBorderColor(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return _darkCardBorder;
    }
    return CupertinoColors.separator.resolveFrom(context);
  }

  /// Returns article background color based on current theme
  ///
  /// Used for: Article viewer (long-form reading content)
  /// Dark mode: #000000 (pure black for maximum readability)
  /// Light mode: #FFFFFF (pure white for maximum readability)
  static Color articleBackground(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return const Color(0xFF000000); // Pure black
    }
    return const Color(0xFFFFFFFF); // Pure white
  }

  // ==================== DECORATION METHODS ====================

  /// Standard card decoration used throughout the app
  ///
  /// Features:
  /// - Theme-aware background color
  /// - Consistent border radius (14px)
  /// - Subtle border for definition
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: AppTheme.cardDecoration(context),
  ///   child: Text('Card content'),
  /// )
  /// ```
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardBackground(context),
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: cardBorderColor(context),
        width: 0.5,
      ),
    );
  }

  /// Surface decoration for elevated UI elements
  ///
  /// Used for: Search bar, bottom navigation, modals
  ///
  /// Features:
  /// - Theme-aware background color
  /// - Slightly smaller radius (13px) for surfaces
  /// - Optional border
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: AppTheme.surfaceDecoration(context),
  ///   child: TextField(...),
  /// )
  /// ```
  static BoxDecoration surfaceDecoration(
    BuildContext context, {
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: surfaceBackground(context),
      borderRadius: BorderRadius.circular(radiusMd),
      border: showBorder
          ? Border.all(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            )
          : null,
    );
  }

  // ==================== SHADOW SYSTEM ====================

  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.02),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.02),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get modalShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.12),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];
}
