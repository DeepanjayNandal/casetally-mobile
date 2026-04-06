import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/app_page_container.dart';
import 'features/home/home_view.dart';
import 'features/resources/resources_view.dart';
import 'features/settings/settings_view.dart';
import 'state/app_state.dart';

/// Main app shell — manages the IndexedStack of tab views.
///
/// The GlassBottomBar now lives in AppShellWrapper (ShellRoute) and is
/// fully persistent across all route transitions. AppShell only handles
/// tab content switching.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(activeTabProvider);

    final List<Widget> tabViews = [
      const HomeView(),
      const ResourcesView(),
      const SettingsView(),
    ];

    return AppPageContainer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Main content views
          IndexedStack(
            index: currentIndex,
            children: List.generate(tabViews.length, (index) {
              return CupertinoTabView(
                builder: (context) {
                  return SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        tabViews[index],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
