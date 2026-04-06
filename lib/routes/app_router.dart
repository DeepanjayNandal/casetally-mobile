import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/authentication_view.dart';
import '../features/resources/category_detail_view.dart';
import '../features/resources/article_viewer.dart';
import '../features/search/views/search_input_page.dart';
import '../features/uscode/views/uscode_list_view.dart';
import '../features/uscode/views/uscode_hierarchy_view.dart';
import '../features/uscode/views/uscode_section_view.dart';
import '../app_shell.dart';
import '../components/app_shell_wrapper.dart';
import '../components/detail_scaffold.dart';
import '../state/app_state.dart';

class AppRoutes {
  static const auth = '/auth';
  static const app = '/app';

  static const resourcesCategory = '/resources/category/:categoryId';
  static const resourcesArticle = '/resources/article/:articleId';

  static const usCodeList = '/uscode';
  static const usCodeTitle = '/uscode/title/:titleNumber';
  static const usCodeSection = '/uscode/section/:sectionId';

  static String categoryRoute(String categoryId) =>
      '/resources/category/$categoryId';
  static String articleRoute(String articleId) =>
      '/resources/article/$articleId';
  static String titleRoute(int titleNumber) => '/uscode/title/$titleNumber';
  static String sectionRoute(String sectionId) => '/uscode/section/$sectionId';
}

/// Router with session-based redirects.
///
/// Redirect truth table:
///   unauthenticated + /app/*  → /auth
///   guest/authenticated + /auth → /app
///   guest/authenticated + /app/* → allow
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    observers: [RouteObserver()],
    redirect: (context, state) {
      final sessionStatus = ref.read(appStateProvider).auth.status;
      final isAuthRoute = state.matchedLocation == '/auth';

      switch (sessionStatus) {
        case SessionStatus.unauthenticated:
          if (!isAuthRoute && state.matchedLocation != '/') return '/auth';
          break;
        case SessionStatus.guest:
        case SessionStatus.authenticated:
          if (isAuthRoute) return '/app';
          break;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final canAccessApp = ref.read(appStateProvider).auth.canAccessApp;
          return canAccessApp ? '/app' : '/auth';
        },
      ),

      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => const CupertinoPage(
          child: AuthenticationView(),
        ),
      ),

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
                CurvedAnimation(parent: secondaryAnimation, curve: curve),
              );
              final outScale = Tween<double>(begin: 1.0, end: 0.97).animate(
                CurvedAnimation(parent: secondaryAnimation, curve: curve),
              );

              return Stack(
                children: [
                  FadeTransition(
                    opacity: outFade,
                    child: ScaleTransition(scale: outScale, child: Container()),
                  ),
                  FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: SlideTransition(position: slide, child: child),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) => AppShellWrapper(child: child),
        routes: [
          GoRoute(
            path: '/app',
            pageBuilder: (context, state) => const CupertinoPage(
              child: AppShell(),
            ),
          ),

          GoRoute(
            path: '/resources/category/:categoryId',
            pageBuilder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return CupertinoPage(
                child: DetailScaffold(
                  navigationBar: const CupertinoNavigationBar(
                    previousPageTitle: 'Resources',
                    border: null,
                  ),
                  child: CategoryDetailView(
                    categoryId: categoryId,
                    categoryTitle: _getCategoryTitle(categoryId),
                  ),
                ),
              );
            },
          ),

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
        ],
      ),
    ],

    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Error')),
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
