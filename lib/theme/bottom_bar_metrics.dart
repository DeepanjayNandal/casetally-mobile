// lib/theme/bottom_bar_metrics.dart

import 'package:flutter/cupertino.dart';

/// Centralized utility for calculating bottom navigation bar dimensions.
///
/// This class uses a mix of compile-time constants for fixed design values
/// and runtime methods for calculations that depend on the device's safe area.
class BottomBarMetrics {
  BottomBarMetrics._(); // Private constructor to prevent instantiation.

  /// The intrinsic height of the GlassBottomBar's content.
  /// Derived from the tallest element, the search button (56.0).
  static const double barHeight = 56.0;

  /// The aesthetic vertical gap between the bottom of the screen content area
  /// and the bottom edge of the GlassBottomBar.
  ///
  /// NOTE: This is used inside a widget that is already padded by the safe area.
  /// Do NOT add MediaQuery.viewPadding.bottom to this value for positioning.
  static const double floatGap = 20.0;

  /// Calculates the required height for the tail spacer in scrollable lists.
  ///
  /// This ensures the last item in a list can scroll fully above the floating
  /// navigation bar.
  ///
  /// **Calculation:** `safeAreaBottom + barHeight + floatGap`
  /// - iPhone SE (0px safe area): `0 + 56 + 20 + 24 = 100px`
  /// - iPhone 14 (34px safe area): `34 + 56 + 20 + 24 = 134px`
  static double scrollSpacerHeight(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    // We add an extra bit of padding so the last item doesn't sit exactly
    // on top of the bar, giving it some breathing room.
    const contentPadding = 24.0;
    return safeBottom + barHeight + floatGap + contentPadding;
  }
}
