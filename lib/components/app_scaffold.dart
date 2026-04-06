import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// Wrapper for CupertinoPageScaffold with consistent theming
///
/// **Automatically applies:**
/// - Theme-aware background color (#161616 dark, system color light)
/// - SafeArea for proper status bar/home indicator spacing
/// - Consistent scaffold behavior across all views
///
/// **Usage:**
/// ```dart
/// AppScaffold(
///   navigationBar: CupertinoNavigationBar(middle: Text('Title')),
///   child: YourContent(),
/// )
/// ```
///
/// **Replaces:**
/// ```dart
/// CupertinoPageScaffold(
///   backgroundColor: ...,
///   child: SafeArea(child: YourContent()),
/// )
/// ```
class AppScaffold extends StatelessWidget {
  /// Navigation bar (optional)
  final ObstructingPreferredSizeWidget? navigationBar;

  /// Main content of the scaffold
  final Widget child;

  /// Whether to include SafeArea wrapper (default: true)
  final bool useSafeArea;

  /// Whether to resize when keyboard appears (default: true)
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.child,
    this.navigationBar,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackground(context),
      navigationBar: navigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}
