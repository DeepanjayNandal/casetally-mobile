import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// Enterprise-level page container
///
/// Provides consistent background color across ALL pages regardless of
/// how they are navigated to (GoRouter, Navigator.push, CustomTransitionPage, etc.)
///
/// **Why this exists:**
/// - CupertinoPage auto-applies scaffold background
/// - CustomTransitionPage does NOT
/// - Navigator.push does NOT
/// - This ensures consistency everywhere
///
/// **Usage:**
/// ```dart
/// return AppPageContainer(
///   child: YourPageContent(),
/// );
/// ```
class AppPageContainer extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const AppPageContainer({
    super.key,
    required this.child,
    this.useSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return ColoredBox(
      color: AppTheme.scaffoldBackground(context),
      child: content,
    );
  }
}
