import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/authentication_view.dart';
import '../features/resources/category_detail_view.dart';
import '../features/resources/article_viewer.dart';
import '../features/search/views/search_input_page.dart';
import '../features/uscode/views/uscode_list_view.dart';
import '../features/uscode/views/uscode_hierarchy_view.dart';
import '../features/uscode/views/uscode_section_view.dart';
import '../glass_demo_page.dart';
import '../app_shell.dart';
import '../components/app_shell_wrapper.dart';
import '../components/detail_scaffold.dart';
import '../state/app_state.dart';

/// Route paths as constants for type safety
class AppRoutes {
  static const auth = '/auth';
  static const app = '/app';

  // Resources routes
  static const resourcesCategory = '/resources/category/:categoryId';
  static const resourcesArticle = '/resources/article/:articleId';

  // U.S. Code routes
  static const usCodeList = '/uscode';
  static const usCodeTitle = '/uscode/title/:titleNumber';
  static const usCodeSection = '/uscode/section/:sectionId';

  // Demo routes
  static const glassDemo = '/demo/glass';

  // Helper to build category route
  static String categoryRoute(String categoryId) =>
      '/resources/category/$categoryId';

  // Helper to build article route
  static String articleRoute(String articleId) =>
      '/resources/article/$articleId';

  // Helper to build title route
  static String titleRoute(int titleNumber) => '/uscode/title/$titleNumber';

  // Helper to build section route
  static String sectionRoute(String sectionId) => '/uscode/section/$sectionId';
}

/// Router configuration with auth-based redirects
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // ==================== ENTERPRISE-LEVEL REDIRECT ====================
    // **TRUTH TABLE ARCHITECTURE:**
    // Router decisions based on single SessionStatus value (no ambiguity)
    //
    // | SessionStatus    | Route      | Action              |
    // |------------------|------------|---------------------|
    // | unauthenticated  | /auth      | Allow (show auth)   |
    // | unauthenticated  | /app/*     | Redirect to /auth   |
    // | guest            | /auth      | Redirect to /app    |
    // | guest            | /app/*     | Allow (access app)  |
    // | authenticated    | /auth      | Redirect to /app    |
    // | authenticated    | /app/*     | Allow (access app)  |
    //
    // **ARCHITECTURE NOTE:**
    // This is a COMPLETE truth table - no edge cases, no ambiguity.
    // If you add new SessionStatus values (expired, blocked, etc.),
    // add rows to this table - don't add boolean flags elsewhere.
    // ====================================================================
    observers: [
      RouteObserver(),
    ],
    redirect: (context, state) {
      final appState = ref.read(appStateProvider);
      final sessionStatus = appState.auth.status;
      final isAuthRoute = state.matchedLocation == '/auth';

      print('🧭 [Router] Navigation to: ${state.matchedLocation}');
      print('🧭 [Router] Session status: ${sessionStatus.name}');

      // Truth table implementation
      switch (sessionStatus) {
        case SessionStatus.unauthenticated:
          // Unauthenticated users MUST go to /auth
          if (!isAuthRoute && state.matchedLocation != '/') {
            print('🧭 [Router] Unauthenticated → redirecting to /auth');
            return '/auth';
          }
          break;

        case SessionStatus.guest:
        case SessionStatus.authenticated:
          // Guest and authenticated users CANNOT go to /auth
          if (isAuthRoute) {
            print('🧭 [Router] Already in session → redirecting to /app');
            return '/app';
          }
          break;
      }

      // Allow navigation (no redirect needed)
      return null;
    },

    routes: [
      // ==================== ROOT ROUTE ====================

      /// Root - redirects based on session status
      /// unauthenticated → /auth
      /// guest/authenticated → /app
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final appState = ref.read(appStateProvider);
          final canAccessApp = appState.auth.canAccessApp;

          if (canAccessApp) {
            return '/app'; // Guest or authenticated → go to main app
          }
          return '/auth'; // Unauthenticated → show auth screen
        },
      ),

      // ==================== AUTHENTICATION ====================

      /// Authentication screen — outside shell, full screen
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => const CupertinoPage(
          child: AuthenticationView(),
        ),
      ),

      // ==================== SEARCH ====================

      /// Search Input Page — outside shell, full screen with custom transition
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            child: const SearchInputPage(),
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 280),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const curve = Curves.easeOutCubic;
              final curved =
                  CurvedAnimation(parent: animation, curve: curve);

              final slide = Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved);

              final fade =
                  Tween<double>(begin: 0.0, end: 1.0).animate(curved);

              final scale =
                  Tween<double>(begin: 0.96, end: 1.0).animate(curved);

              final outFade = Tween<double>(begin: 1.0, end: 0.85).animate(
                CurvedAnimation(
                    parent: secondaryAnimation, curve: curve),
              );

              final outScale = Tween<double>(begin: 1.0, end: 0.97).animate(
                CurvedAnimation(
                    parent: secondaryAnimation, curve: curve),
              );

              return Stack(
                children: [
                  FadeTransition(
                    opacity: outFade,
                    child: ScaleTransition(
                      scale: outScale,
                      child: Container(),
                    ),
                  ),
                  FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: SlideTransition(
                        position: slide,
                        child: child,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      // ==================== SHELL (persistent bar) ====================

      /// ShellRoute wraps all in-app routes.
      /// AppShellWrapper owns the single GlassBottomBar — it never
      /// rebuilds or animates during page transitions.
      ShellRoute(
        builder: (context, state, child) => AppShellWrapper(child: child),
        routes: [
          // ==================== MAIN APP ====================

          /// Main App - Contains tab scaffold with 3 tabs
          GoRoute(
            path: '/app',
            pageBuilder: (context, state) => const CupertinoPage(
              child: AppShell(),
            ),
          ),

          // ==================== RESOURCES ROUTES ====================

          /// Category Detail - Shows articles in a category
          GoRoute(
            path: '/resources/category/:categoryId',
            pageBuilder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              final categoryTitle = _getCategoryTitle(categoryId);

              return CupertinoPage(
                child: DetailScaffold(
                  navigationBar: const CupertinoNavigationBar(
                    previousPageTitle: 'Resources',
                    border: null,
                  ),
                  child: CategoryDetailView(
                    categoryId: categoryId,
                    categoryTitle: categoryTitle,
                  ),
                ),
              );
            },
          ),

          /// Article Viewer - Shows full article content
          GoRoute(
            path: '/resources/article/:articleId',
            pageBuilder: (context, state) {
              final articleId = state.pathParameters['articleId']!;

              return CupertinoPage(
                child: DetailScaffold(
                  navigationBar: const CupertinoNavigationBar(
                    previousPageTitle: 'Back',
                    border: null,
                  ),
                  child: ArticleViewer(articleId: articleId),
                ),
              );
            },
          ),

          // ==================== U.S. CODE ROUTES ====================

          /// U.S. Code List - All 54 titles
          GoRoute(
            path: '/uscode',
            pageBuilder: (context, state) => const CupertinoPage(
              child: DetailScaffold(
                navigationBar: CupertinoNavigationBar(
                  previousPageTitle: 'Home',
                  middle: Text('U.S. Code'),
                  border: null,
                ),
                child: UsCodeListView(),
              ),
            ),
          ),

          /// Title Hierarchy View - Drill-down into parts/chapters/sections
          GoRoute(
            path: '/uscode/title/:titleNumber',
            pageBuilder: (context, state) {
              final titleNumber =
                  int.parse(state.pathParameters['titleNumber']!);

              return CupertinoPage(
                child: DetailScaffold(
                  navigationBar: CupertinoNavigationBar(
                    previousPageTitle: 'Titles',
                    middle: Text('Title $titleNumber'),
                    border: null,
                  ),
                  child: UsCodeHierarchyView(titleNumber: titleNumber),
                ),
              );
            },
          ),

          /// Section Viewer - Full legal text
          GoRoute(
            path: '/uscode/section/:sectionId',
            pageBuilder: (context, state) {
              final sectionId = state.pathParameters['sectionId']!;

              return CupertinoPage(
                child: DetailScaffold(
                  navigationBar: const CupertinoNavigationBar(
                    previousPageTitle: 'Back',
                    border: null,
                  ),
                  child: UsCodeSectionView(sectionId: sectionId),
                ),
              );
            },
          ),

          // ==================== DEMO ROUTES ====================

          /// Glass Demo - Testing glass container variants
          GoRoute(
            path: '/demo/glass',
            pageBuilder: (context, state) => const CupertinoPage(
              child: DetailScaffold(
                title: 'Glass Demo',
                child: GlassDemoPage(),
              ),
            ),
          ),
        ],
      ),
    ],

    // ==================== ERROR HANDLING ====================

    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Error'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: const TextStyle(color: CupertinoColors.systemGrey),
            ),
          ],
        ),
      ),
    ),
  );
});

// ==================== HELPER FUNCTIONS ====================

/// Maps category IDs to display titles
String _getCategoryTitle(String categoryId) {
  switch (categoryId) {
    case 'know-your-rights':
      return 'Know Your Rights';
    case 'politicians-officials':
      return 'Politicians & Officials';
    case 'state-county-laws':
      return 'State & County Laws';
    case 'federal-laws-codes':
      return 'Federal Laws & Codes';
    default:
      return 'Resources';
  }
}
