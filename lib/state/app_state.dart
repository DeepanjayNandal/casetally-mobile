import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

enum AuthMethod { google, apple, email, phone }

/// Session modeled as an explicit finite state machine.
/// Three mutually exclusive states — no boolean flags, no ambiguity.
enum SessionStatus {
  unauthenticated,
  guest,
  authenticated,
}

class AuthState {
  final SessionStatus status;
  final String? email;
  final String? displayName;
  final AuthMethod? method;

  const AuthState({
    this.status = SessionStatus.unauthenticated,
    this.email,
    this.displayName,
    this.method,
  });

  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
  bool get isGuest => status == SessionStatus.guest;
  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get canAccessApp => isGuest || isAuthenticated;

  AuthState copyWith({
    SessionStatus? status,
    String? email,
    String? displayName,
    AuthMethod? method,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      method: method ?? this.method,
    );
  }
}

class AppState {
  final AuthState auth;
  final AppThemeMode themeMode;

  const AppState({
    this.auth = const AuthState(),
    this.themeMode = AppThemeMode.dark,
  });

  AppState copyWith({AuthState? auth, AppThemeMode? themeMode}) {
    return AppState(
      auth: auth ?? this.auth,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _loadPersistedState();
  }

  static T _parseEnum<T extends Enum>(
      String? value, List<T> values, T fallback) {
    if (value == null) return fallback;
    return values.firstWhere(
      (e) => e.name == value || e.toString() == value,
      orElse: () => fallback,
    );
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    final themeMode = _parseEnum(
      prefs.getString('theme_mode'),
      AppThemeMode.values,
      AppThemeMode.dark,
    );

    var status = _parseEnum(
      prefs.getString('session_status'),
      SessionStatus.values,
      SessionStatus.unauthenticated,
    );

    final email = prefs.getString('email');
    final displayName = prefs.getString('displayName');
    final methodString = prefs.getString('authMethod');
    final method = methodString != null
        ? _parseEnum(methodString, AuthMethod.values, AuthMethod.email)
        : null;

    // If persisted status claims authenticated but no email exists,
    // downgrade to unauthenticated to avoid a ghost session.
    if (status == SessionStatus.authenticated &&
        (email == null || email.isEmpty)) {
      status = SessionStatus.unauthenticated;
      await prefs.remove('email');
      await prefs.remove('displayName');
      await prefs.remove('authMethod');
      await prefs.setString('session_status', SessionStatus.unauthenticated.name);

      state = AppState(
        themeMode: themeMode,
        auth: const AuthState(status: SessionStatus.unauthenticated),
      );
      return;
    }

    state = AppState(
      themeMode: themeMode,
      auth: AuthState(
        status: status,
        email: email,
        displayName: displayName,
        method: method,
      ),
    );

    debugPrint('[Auth] session restored: ${status.name}');
  }

  Future<void> _saveThemePreference(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_status', SessionStatus.guest.name);
    await prefs.remove('email');
    await prefs.remove('displayName');
    await prefs.remove('authMethod');

    state = state.copyWith(
      auth: const AuthState(status: SessionStatus.guest),
    );

    debugPrint('[Auth] signed in as guest');
  }

  Future<void> signIn({
    required String email,
    String? displayName,
    AuthMethod method = AuthMethod.email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_status', SessionStatus.authenticated.name);
    await prefs.setString('email', email);
    if (displayName != null) await prefs.setString('displayName', displayName);
    await prefs.setString('authMethod', method.toString());

    state = state.copyWith(
      auth: AuthState(
        status: SessionStatus.authenticated,
        email: email,
        displayName: displayName,
        method: method,
      ),
    );

    debugPrint('[Auth] signed in: $email');
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_status', SessionStatus.unauthenticated.name);
    await prefs.remove('email');
    await prefs.remove('displayName');
    await prefs.remove('authMethod');

    state = state.copyWith(
      auth: const AuthState(status: SessionStatus.unauthenticated),
    );

    debugPrint('[Auth] signed out');
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveThemePreference(mode);
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(appStateProvider).auth;
});

final sessionStatusProvider = Provider<SessionStatus>((ref) {
  return ref.watch(appStateProvider).auth.status;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.isAuthenticated;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.isGuest;
});

final canAccessAppProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.canAccessApp;
});

final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});

/// Active tab index — shared between AppShell and DetailScaffold
/// 0 = Home, 1 = Resources, 2 = Settings
final activeTabProvider = StateProvider<int>((ref) => 0);
