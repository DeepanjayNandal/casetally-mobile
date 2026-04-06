import 'package:flutter/cupertino.dart';

/// Reusable text components with automatic theme adaptation
/// Enforces consistent typography throughout the app
class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve dynamic colors based on current theme
    final resolvedStyle = style.copyWith(
      color: style.color is CupertinoDynamicColor
          ? (style.color as CupertinoDynamicColor).resolveFrom(context)
          : style.color,
    );

    return Text(
      text,
      style: resolvedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // ==================== LARGE TITLES ====================

  /// Large title (34pt, bold, adaptive color)
  /// Used for main page titles: "Home", "Resources", "Settings"
  static Widget largeTitle(BuildContext context, String text,
      {TextAlign? textAlign}) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -1.0,
      ),
      textAlign: textAlign,
    );
  }

  // ==================== HEADINGS ====================

  /// Heading (24pt, semibold, adaptive color)
  /// Used for card titles and section headings
  static Widget heading(BuildContext context, String text,
      {TextAlign? textAlign}) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -0.6,
      ),
      textAlign: textAlign,
    );
  }

  /// Title (20pt, medium, adaptive color)
  /// Used for card titles and emphasized text
  static Widget title(BuildContext context, String text,
      {TextAlign? textAlign}) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -0.5,
      ),
      textAlign: textAlign,
    );
  }

  // ==================== BODY TEXT ====================

  /// Body text (17pt, regular, adaptive color)
  /// Used for primary content text
  /// Line height 1.55 for legal readability
  static Widget body(
    BuildContext context,
    String text, {
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -0.4,
        height: 1.55, // Kept for long-form content
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Secondary text (15pt, regular, gray)
  /// Used for supporting text and descriptions
  static Widget secondary(
    BuildContext context,
    String text, {
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        letterSpacing: -0.4,
        height: 1.5,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // ==================== LABELS & CAPTIONS ====================

  /// Section header (12pt, medium, uppercase, gray)
  /// Used for section headers like "BROWSE", "RECENT ACTIVITY"
  static Widget sectionHeader(BuildContext context, String text) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        letterSpacing: 0.5,
      ),
    );
  }

  /// Caption (14pt, regular, gray)
  /// Used for small helper text
  static Widget caption(
    BuildContext context,
    String text, {
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
        letterSpacing: -0.2,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  // ==================== SPECIAL STYLES ====================

  /// Brand text (20pt, bold, uppercase, adaptive)
  /// Used for "CASETALLY" branding
  static Widget brand(BuildContext context, String text) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: 1.5,
      ),
    );
  }

  /// Subtitle (15pt, regular, gray)
  /// Used for page subtitles under large titles
  static Widget subtitle(BuildContext context, String text,
      {TextAlign? textAlign}) {
    return AppText(
      text: text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        letterSpacing: -0.2,
        height: 1.5,
      ),
      textAlign: textAlign,
    );
  }
}
