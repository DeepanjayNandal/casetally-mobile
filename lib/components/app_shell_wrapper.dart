import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/bottom_bar_metrics.dart';
import 'glass_bottom_bar.dart';

/// Persistent shell that wraps all in-app routes.
/// Owns the single GlassBottomBar instance — never rebuilt on navigation.
/// Page content renders as [child] (injected by ShellRoute) and slides
/// underneath the bar.
class AppShellWrapper extends ConsumerWidget {
  final Widget child; // Injected by ShellRoute (current page content)

  const AppShellWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(activeTabProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackground(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Page content — routes render here, slide under bar
          child,

          // Persistent GlassBottomBar — never rebuilds on navigation
          Positioned(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            bottom: BottomBarMetrics.floatGap,
            child: GlassBottomBar(
              currentIndex: currentIndex,
              onTabChanged: (index) {
                ref.read(activeTabProvider.notifier).state = index;
                context.go('/app');
              },
              onSearchTap: () {
                context.push('/search');
              },
            ),
          ),
        ],
      ),
    );
  }
}
