import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum AppThemeMode {
  system, // Follow OS
  light, // Always light
  dark, // Always dark
}

/// Authentication methods (for future OAuth integration)
enum AuthMethod {
  google,
  apple,
  email,
  phone,
}

// ==================== ENTERPRISE-LEVEL SESSION MODEL ====================
//
// **CRITICAL ARCHITECTURE DECISION:**
// Session is modeled as an EXPLICIT finite state machine.
// This prevents ambiguity and "flag soup" anti-pattern.
//
// **Why enum over booleans:**
// ❌ BAD: isAuthenticated + isGuest (computed) → ambiguous states possible
// ✅ GOOD: SessionStatus enum → mutually exclusive, no contradictions
//
// **Future-proof:**
// Easy to add: expired, blocked, needsProfileCompletion, pendingVerification
// =========================================================================

/// Session status - mutually exclusive states
///
/// **NEVER derive one status from another** (e.g., guest = !authenticated)
/// Each state is EXPLICIT to prevent bugs.
///
/// **State transitions:**
/// - unauthenticated → guest (via continueAsGuest)
/// - unauthenticated → authenticated (via signIn)
/// - authenticated → unauthenticated (via signOut)
/// - guest → unauthenticated (via signOut)
enum SessionStatus {
  /// Must see auth screen - no persisted session
  /// Router shows: /auth
  unauthenticated,

  /// In app without account - persisted choice
  /// Router shows: /app
  /// User chose "Continue as Guest" and we persisted that
  guest,

  /// In app with account - persisted credentials
  /// Router shows: /app
  /// User signed in successfully
  authenticated,
}

/// Clean authentication state using enterprise-level session model
///
/// **ARCHITECTURE RULE:**
/// Guest is EXPLICIT, never computed from !authenticated
/// This prevents ambiguity that causes router bugs.
class AuthState {
  /// Current session status (single source of truth)
  final SessionStatus status;

  /// User's email (null for guest/unauthenticated)
  final String? email;

  /// User's display name (null for guest/unauthenticated or if not provided)
  final String? displayName;

  /// Authentication method used (null for guest/unauthenticated)
  final AuthMethod? method;

  const AuthState({
    this.status = SessionStatus.unauthenticated,
    this.email,
    this.displayName,
    this.method,
  });

  // ==================== CONVENIENCE GETTERS ====================
  // These are COMPUTED from status, not stored separately
  // This prevents contradictions (single source of truth)
  // =============================================================

  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
  bool get isGuest => status == SessionStatus.guest;
  bool get isAuthenticated => status == SessionStatus.authenticated;

  /// Check if user can access app (guest OR authenticated)
  /// Used by router to determine if /app routes are allowed
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

/// App-wide state management
class AppState {
  final AuthState auth;
  final AppThemeMode themeMode;

  const AppState({
    this.auth = const AuthState(),
    this.themeMode = AppThemeMode.dark, // Default to dark
  });

  AppState copyWith({
    AuthState? auth,
    AppThemeMode? themeMode,
  }) {
    return AppState(
      auth: auth ?? this.auth,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// State notifier for app state with enterprise-level session management
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _loadPersistedState();
  }

  /// Parse enum from persisted string with fallback
  /// Handles both `.name` format ("dark") and `.toString()` format ("AppThemeMode.dark")
  static T _parseEnum<T extends Enum>(String? value, List<T> values, T fallback) {
    if (value == null) return fallback;
    return values.firstWhere(
      (e) => e.name == value || e.toString() == value,
      orElse: () => fallback,
    );
  }

  /// Load persisted state on app launch with sanity check
  ///
  /// **CRITICAL SANITY CHECK:**
  /// If status claims "authenticated" but no valid auth proof exists,
  /// downgrade to "unauthenticated" to prevent ghost authenticated state.
  ///
  /// **Why this matters:**
  /// Prevents UI showing "authenticated" when credentials are missing/invalid.
  /// This can happen if:
  /// - User manually edited SharedPreferences
  /// - Token expired (Phase 4+)
  /// - Data corruption
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme preference
    final themeMode = _parseEnum(
      prefs.getString('theme_mode'),
      AppThemeMode.values,
      AppThemeMode.dark,
    );

    // Load session status
    var status = _parseEnum(
      prefs.getString('session_status'),
      SessionStatus.values,
      SessionStatus.unauthenticated,
    );

    // Load auth fields
    final email = prefs.getString('email');
    final displayName = prefs.getString('displayName');
    final methodString = prefs.getString('authMethod');
    final method = methodString != null
        ? _parseEnum(methodString, AuthMethod.values, AuthMethod.email)
        : null;

    // ==================== SANITY CHECK ====================
    // **ENTERPRISE GUARDRAIL:**
    // If status claims authenticated but no valid auth proof,
    // downgrade to unauthenticated + clear stale fields.
    //
    // **ONLY checks authenticated status** (guest doesn't need proof)
    // ======================================================

    if (status == SessionStatus.authenticated) {
      if (!_hasValidAuthProof(email, method)) {
        print(
            '⚠️ [AppState] Authenticated status with invalid proof - downgrading to unauthenticated');
        status = SessionStatus.unauthenticated;

        // Clear stale authenticated-only fields to prevent half-lingering state
        // **CRITICAL:** Prevents displayName/method from showing when user isn't actually authenticated
        await prefs.remove('email');
        await prefs.remove('displayName');
        await prefs.remove('authMethod');
        await prefs.setString(
            'session_status', SessionStatus.unauthenticated.name);

        // Nullify in-memory state too
        state = AppState(
          themeMode: themeMode,
          auth: const AuthState(status: SessionStatus.unauthenticated),
        );

        print('📱 [AppState] Loaded persisted state (DOWNGRADED):');
        print(
            '   Session: unauthenticated (was authenticated with invalid proof)');
        print('   Theme: $themeMode');
        return;
      }
    }

    // Normal load (no sanity check triggered)
    state = AppState(
      themeMode: themeMode,
      auth: AuthState(
        status: status,
        email: email,
        displayName: displayName,
        method: method,
      ),
    );

    print('📱 [AppState] Loaded persisted state:');
    print(
        '   Session: ${status.name}${status == SessionStatus.authenticated ? " ($email)" : ""}');
    print('   Theme: $themeMode');
  }

  /// Check if we have valid auth proof for authenticated status
  ///
  /// **PHASE-AWARE IMPLEMENTATION:**
  /// Phase 2-3 (current): Valid proof = email exists
  /// Phase 4+ (OAuth):    Valid proof = token exists + not expired
  ///
  /// **DO NOT call this for guest/unauthenticated** - they don't need proof
  ///
  /// **Future implementation (Phase 4+):**
  /// ```dart
  /// bool _hasValidAuthProof(String? email, AuthMethod? method) {
  ///   final token = prefs.getString('authToken');
  ///   final expiry = prefs.getString('tokenExpiry');
  ///
  ///   if (token == null || token.isEmpty) return false;
  ///   if (expiry == null) return true; // No expiry = valid
  ///
  ///   return DateTime.now().isBefore(DateTime.parse(expiry));
  /// }
  /// ```
  bool _hasValidAuthProof(String? email, AuthMethod? method) {
    // Phase 2-3: Valid proof = email exists
    return email != null && email.isNotEmpty;
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  /// Continue as guest (persists choice)
  ///
  /// **State transition:** unauthenticated → guest
  ///
  /// User won't see auth screen again until they sign out.
  /// This is an EXPLICIT choice, not a computed state.
  Future<void> continueAsGuest() async {
    print('👤 [AppState] User continuing as guest');

    final prefs = await SharedPreferences.getInstance();

    // Persist guest status
    await prefs.setString('session_status', SessionStatus.guest.name);

    // Clear any auth fields (guest has no credentials)
    // **ARCHITECTURE NOTE:** Always clear auth fields when entering guest mode
    // to prevent stale data from appearing if user later authenticates
    await prefs.remove('email');
    await prefs.remove('displayName');
    await prefs.remove('authMethod');

    state = state.copyWith(
      auth: const AuthState(status: SessionStatus.guest),
    );

    print('✅ [AppState] Session status: guest (persisted)');
  }

  /// Sign in with credentials
  ///
  /// **State transition:** unauthenticated → authenticated
  ///
  /// Placeholder for now - backend will handle real OAuth in Phase 4+
  ///
  /// **ARCHITECTURE NOTE:**
  /// When real OAuth is implemented, this method should:
  /// 1. Validate token from OAuth provider
  /// 2. Store token + expiry in secure storage
  /// 3. Store email/displayName in SharedPreferences
  /// 4. Set status to authenticated
  Future<void> signIn({
    required String email,
    String? displayName,
    AuthMethod method = AuthMethod.email,
  }) async {
    print('🔐 [AppState] User signed in: $email ($method)');

    final prefs = await SharedPreferences.getInstance();

    // Persist authenticated status
    await prefs.setString('session_status', SessionStatus.authenticated.name);
    await prefs.setString('email', email);
    if (displayName != null) {
      await prefs.setString('displayName', displayName);
    }
    await prefs.setString('authMethod', method.toString());

    state = state.copyWith(
      auth: AuthState(
        status: SessionStatus.authenticated,
        email: email,
        displayName: displayName,
        method: method,
      ),
    );

    print('✅ [AppState] Session status: authenticated (persisted)');
  }

  /// Sign out (clears all auth data, forces auth screen)
  ///
  /// **State transition:** guest/authenticated → unauthenticated
  ///
  /// **CRITICAL:** Sign out MUST set status to unauthenticated (not guest)
  /// to force user to see auth screen again.
  ///
  /// **What gets cleared:**
  /// - Session status → unauthenticated
  /// - Email, displayName, authMethod → removed
  /// - Theme preference → PRESERVED (user setting, not auth-related)
  ///
  /// **What happens next:**
  /// Router redirect will send user to /auth screen
  Future<void> signOut() async {
    print('🚪 [AppState] User signed out');

    final prefs = await SharedPreferences.getInstance();

    // Set status to unauthenticated (forces auth screen on next navigation)
    await prefs.setString('session_status', SessionStatus.unauthenticated.name);

    // Clear ALL auth-related data to prevent stale state
    // **ARCHITECTURE NOTE:** Clear everything, even if user was just guest
    // This ensures clean slate for next auth flow
    await prefs.remove('email');
    await prefs.remove('displayName');
    await prefs.remove('authMethod');

    // Theme is preserved - it's a user preference, not auth data

    state = state.copyWith(
      auth: const AuthState(status: SessionStatus.unauthenticated),
    );

    print(
        '✅ [AppState] Session status: unauthenticated (will show auth screen)');
  }

  /// Set theme mode and persist to disk
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveThemePreference(mode);
  }
}

/// Global provider for app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

/// Convenience provider for auth state
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(appStateProvider).auth;
});

/// Convenience provider for session status
final sessionStatusProvider = Provider<SessionStatus>((ref) {
  return ref.watch(appStateProvider).auth.status;
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.isAuthenticated;
});

/// Active tab index — shared between AppShell and DetailScaffold
/// 0 = Home, 1 = Resources, 2 = Settings
final activeTabProvider = StateProvider<int>((ref) => 0);

/// Convenience provider for checking if user is guest
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.isGuest;
});

/// Convenience provider for checking if user can access app (guest OR authenticated)
final canAccessAppProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).auth.canAccessApp;
});

/// Convenience provider for theme mode
final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});
