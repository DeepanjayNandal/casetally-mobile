import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'state/app_state.dart';
import 'utils/status_bar_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge display (Android)
  // Allows scaffold background to extend behind system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000), // Transparent
      systemNavigationBarColor: Color(0x00000000), // Transparent
    ),
  );

  runApp(
    const ProviderScope(
      child: CaseTallyApp(),
    ),
  );
}

class CaseTallyApp extends ConsumerWidget {
  const CaseTallyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Determine which theme to use
    CupertinoThemeData theme;
    if (themeMode == AppThemeMode.system) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      theme = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    } else if (themeMode == AppThemeMode.dark) {
      theme = AppTheme.dark;
    } else {
      theme = AppTheme.light;
    }

    // Update status bar reactively whenever theme changes
    StatusBarObserver.observe(context, themeMode);

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CaseTally',
      theme: theme,
      routerConfig: router,
    );
  }
}
