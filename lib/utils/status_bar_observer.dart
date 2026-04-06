import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';

/// Observes theme changes and updates status bar styling accordingly
/// Ensures status bar is always readable in both light and dark modes
class StatusBarObserver {
  /// Updates status bar based on current theme mode and system brightness
  static void updateStatusBar(BuildContext context, AppThemeMode themeMode) {
    final Brightness brightness;

    // Determine actual brightness based on theme mode
    if (themeMode == AppThemeMode.system) {
      // Follow system theme
      brightness = MediaQuery.platformBrightnessOf(context);
    } else if (themeMode == AppThemeMode.dark) {
      brightness = Brightness.dark;
    } else {
      brightness = Brightness.light;
    }

    // Set status bar style
    // iOS uses statusBarBrightness, Android uses statusBarIconBrightness
    // statusBarColor must be transparent to show scaffold background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // iOS status bar
        statusBarBrightness: brightness,
        // Android status bar icons
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light // Dark mode → white icons
            : Brightness.dark, // Light mode → black icons
        // CRITICAL: Transparent to show scaffold background through status bar
        statusBarColor: const Color(0x00000000), // Colors.transparent
      ),
    );
  }

  /// Listens to theme changes and auto-updates status bar
  /// Call this in the build method of your root widget
  static void observe(BuildContext context, AppThemeMode themeMode) {
    // Update status bar whenever theme changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateStatusBar(context, themeMode);
    });
  }
}
