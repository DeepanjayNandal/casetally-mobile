/// Global constants for CaseTally app
///
/// **Organization:**
/// - Sizes (icons, containers, UI elements)
/// - Borders (widths for different contexts)
/// - Opacity (background transparency levels)
/// - U.S. Code specific constants
///
/// **Usage Pattern:**
/// ```dart
/// AppIconContainer(size: AppSizes.containerMd)
/// Border.all(width: AppBorders.thin)
/// color.withValues(alpha: AppOpacity.light)
/// ```
///
/// **Modification Guide:**
/// Change values here → cascades to entire app automatically
/// No need to touch individual widget files

// ==================== ICON SIZES ====================
/// Icon sizes for SF Symbols and Cupertino icons
/// Follow Apple's HIG standards for tap targets and visual hierarchy
class AppSizes {
  AppSizes._(); // Private constructor - prevent instantiation

  // -------------------- Icons --------------------

  /// Extra small icons (14pt)
  /// Used in: Metadata displays, compact info badges
  /// Example: Clock icon next to "2 min read"
  static const double iconXs = 14;

  /// Small icons (16pt)
  /// Used in: Search icons, section headers, tight spacing lists
  /// Example: Search icon in query display card, info icons
  static const double iconSm = 16;

  /// Medium icons (20pt)
  /// Used in: Standard list items, card actions, most UI elements
  /// Example: Chevrons in cards, category icons
  static const double iconMd = 20;

  /// Large icons (24pt)
  /// Used in: Feature cards, prominent actions, category headers
  /// Example: Book icon in resources categories
  static const double iconLg = 24;

  /// Extra large icons (28pt)
  /// Used in: Hero sections, modal headers, back buttons
  /// Example: Close button in search overlay (28pt for easy tapping)
  static const double iconXl = 28;

  /// Double extra large icons (32pt)
  /// Used in: Large action buttons, feature highlights
  /// Example: Section header icons in search results
  static const double iconXxl = 32;

  // -------------------- Icon Containers --------------------

  /// Small icon container (32x32pt)
  /// Used in: Compact section headers, inline badges
  /// Example: Sparkles icon in AI summary section header
  /// Contains: 16pt icon (iconSm)
  static const double containerSm = 32;

  /// Standard icon container (40x40pt)
  /// Used in: Most cards, list items, standard features
  /// Example: Book icon in continue reading cards, learn today
  /// Contains: 20pt icon (iconMd)
  static const double containerMd = 40;

  /// Large icon container (48x48pt)
  /// Used in: Feature cards, role selection, prominent items
  /// Example: Role icons in select role view, title numbers in U.S. Code
  /// Contains: 24pt icon (iconLg)
  static const double containerLg = 48;

  // -------------------- Chevrons --------------------

  /// Small chevron (16pt)
  /// Used in: Compact lists, tight spacing hierarchies
  /// Example: U.S. Code hierarchy expandable items
  static const double chevronSm = 16;

  /// Standard chevron (20pt)
  /// Used in: Most cards, navigation indicators, list items
  /// Example: Article cards, category items, settings rows
  static const double chevronMd = 20;

  // -------------------- Loading Indicators --------------------

  /// Small spinner radius (14pt)
  /// Used in: Inline loading, compact spaces
  /// Example: Button loading states, small cards
  static const double spinnerSm = 14;

  /// Standard spinner radius (16pt)
  /// Used in: Full screen loading, modal loading
  /// Example: Search overlay loading, U.S. Code hierarchy loading
  static const double spinnerMd = 16;
}

// ==================== BORDER WIDTHS ====================
/// Border and divider widths following iOS standards
/// Hairline = 0.33pt, Thin = 0.5pt (iOS separator standard)
class AppBorders {
  AppBorders._();

  /// Hairline border (0.33pt)
  /// Used in: U.S. Code hierarchy dividers, ultra-thin separators
  /// Rationale: Matches iOS Files app hierarchy dividers exactly
  /// Visual: Nearly invisible, just enough to separate items
  static const double hairline = 0.33;

  /// Thin border (0.5pt)
  /// Used in: Card borders, list dividers, most separators
  /// Rationale: iOS standard separator width (CupertinoColors.separator default)
  /// Example: AppCard borders, settings list dividers, surface borders
  static const double thin = 0.5;

  /// Standard border (1.0pt)
  /// Used in: Badge outlines, prominent borders, focus states
  /// Example: Role badge borders, category badge outlines
  static const double standard = 1.0;

  /// Thick border (2.0pt)
  /// Used in: Emphasized elements, selection states, hero cards
  /// Example: Selected role card in onboarding
  static const double thick = 2.0;

  /// Divider height for iOS-style list separators
  /// Used in: latest_updates_section, settings lists, any list with dividers
  /// Rationale: Same as thin (0.5pt) but named for semantic clarity
  /// Pattern: Container(height: AppBorders.dividerHeight, color: separator)
  static const double dividerHeight = thin;
}

// ==================== OPACITY VALUES ====================
/// Background opacity levels for consistency
/// Light = 0.15 (subtle tint), Medium = 0.2 (visible), Heavy = 0.3 (prominent)
class AppOpacity {
  AppOpacity._();

  /// Light opacity (15% / 0.15)
  /// Used in: Icon container backgrounds, subtle highlights
  /// Visual: Barely tinted, maintains readability of content behind
  /// Example: Blue icon containers (blue.withValues(alpha: 0.15))
  /// Result: Soft colored background that doesn't overpower icon
  static const double light = 0.15;

  /// Medium opacity (20% / 0.2)
  /// Used in: Badge backgrounds, emphasized containers
  /// Visual: Noticeable tint, clear differentiation from background
  /// Example: Role badges, category tags in top story
  /// Result: Colored background with clear visibility
  static const double medium = 0.2;

  /// Heavy opacity (30% / 0.3)
  /// Used in: Modal overlays, dimmed backgrounds, glass effects
  /// Visual: Significant transparency, creates depth/layering
  /// Example: Black overlay behind search result sheet
  /// Result: Dims content behind to focus on foreground
  static const double heavy = 0.3;
}

// ==================== U.S. CODE SPECIFIC ====================
/// Constants specific to U.S. Code hierarchy feature
/// Designed to match iOS Files and Reminders apps hierarchy style
class USCodeSizes {
  USCodeSizes._();

  /// Indentation per hierarchy level (20pt)
  /// Used in: ios_hierarchy_item.dart left margin calculation
  /// Pattern: margin: EdgeInsets.only(left: depth * USCodeSizes.indent)
  /// Example: Level 0 = 0pt, Level 1 = 20pt, Level 2 = 40pt
  /// Rationale: Matches iOS Files app nested folder indentation
  static const double indent = 20.0;

  /// Horizontal padding inside hierarchy items (16pt)
  /// Used in: ios_hierarchy_item.dart container padding
  /// Rationale: Standard iOS list item padding for comfortable tap targets
  /// Ensures content doesn't touch container edges
  static const double itemPaddingH = 16.0;

  /// Vertical padding inside hierarchy items (12pt)
  /// Used in: ios_hierarchy_item.dart container padding
  /// Rationale: Provides breathing room, matches iOS compact lists
  /// Comfortable tap target height (~48pt with text)
  static const double itemPaddingV = 12.0;

  /// Icon size in hierarchy items (16pt)
  /// Used in: Document icon for sections, folder icon for chapters
  /// Rationale: Smaller icons in hierarchies maintain clean visual flow
  /// Matches iconSm but named separately for semantic clarity
  static const double iconSize = 16;

  /// Trailing chevron size in hierarchy (18pt)
  /// Used in: Right-side chevron for sections (navigates to full text)
  /// Rationale: Slightly larger than iconSm for better tap target
  /// Differentiates from expandable chevron (16pt)
  static const double chevronSize = 18;

  /// Spacing between icon and text (12pt)
  /// Used in: Gap between chevron/icon and label text
  /// Rationale: Comfortable breathing room, not too cramped or loose
  static const double spacing = 12.0;

  /// Label font size (16pt)
  /// Used in: Main text in hierarchy items (e.g., "Part I", "Chapter 13")
  /// Rationale: Standard iOS list item text size, readable without being huge
  static const double labelFont = 16.0;

  /// Subtitle font size (14pt)
  /// Used in: Secondary text (e.g., "Crimes and Criminal Procedure")
  /// Rationale: Clearly differentiates from label, maintains hierarchy
  static const double subtitleFont = 14.0;
}
