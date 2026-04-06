import 'package:flutter/widgets.dart';

/// Two-tier glass morphism system
///
/// **OVERLAY TIER** (kDockGlass*): Strong blur for floating elements
/// - Bottom navigation bar (already uses this)
/// - Modal sheets
/// - Overlays that sit on top of content
///
/// **SURFACE TIER** (kSurfaceGlass*): Lighter blur for content
/// - Cards (news, resources, etc)
/// - Pills (query, sources)
/// - Content that needs to be readable
///
/// **SHARED**: Border color/width consistent across both tiers

// ============================================================================
// TIER 1: OVERLAY (Nav bar, modals, floating elements)
// ============================================================================

/// Blur intensity for the glass background.
const kDockGlassBlur = 10.0;

/// Main tint for the glass. A dark, semi-transparent gradient.
const kDockGlassGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x22000000), // Black at ~13% opacity
    Color(0x11000000), // Black at ~7% opacity
  ],
);

/// Subtle top-down highlight to simulate a "lit edge" on the glass.
const kDockLitEdgeGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x1AFFFFFF), // White at 10% opacity
    Color(0x00FFFFFF), // Fully transparent
  ],
  stops: [0.0, 0.8], // Apply the highlight only at the very top
);

/// Border color for glass components.
const kDockGlassBorderColor = Color(0x1AFFFFFF); // White at 10% opacity

/// Border width for glass components.
const kDockGlassBorderWidth = 0.5;

// ============================================================================
// TIER 2: SURFACE (Cards, pills, content elements)
// ============================================================================

/// Blur intensity for content cards and pills (lighter than overlay)
const kSurfaceGlassBlur = 6.0;

/// Gradient for content cards (slightly lighter than overlay)
const kSurfaceGlassGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x18000000), // Black at ~9% opacity (lighter than overlay)
    Color(0x0D000000), // Black at ~5% opacity (lighter than overlay)
  ],
);
