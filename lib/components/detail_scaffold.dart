import 'package:flutter/cupertino.dart';
import 'app_scaffold.dart';

/// Standard scaffold for all detail pages (non-tab pages).
///
/// ShellRoute (via AppShellWrapper) now owns the persistent GlassBottomBar,
/// so DetailScaffold is a simple content wrapper with an optional nav bar.
class DetailScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final ObstructingPreferredSizeWidget? navigationBar;

  const DetailScaffold({
    super.key,
    required this.child,
    this.title,
    this.navigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navigationBar: navigationBar ??
          (title != null
              ? CupertinoNavigationBar(middle: Text(title!))
              : null),
      useSafeArea: false,
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}
