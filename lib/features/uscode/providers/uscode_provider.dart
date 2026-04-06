import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/uscode_title.dart';
import '../repositories/uscode_repository.dart';
import '../repositories/mock_uscode_repository.dart';

// ==================== RIVERPOD STATE MANAGEMENT ====================
//
// **How Riverpod Works (Short Version):**
//
// 1. STATE = Data that changes (titles list, loading status, errors)
// 2. PROVIDER = Exposes state to widgets
// 3. NOTIFIER = Updates state when user does something
// 4. WIDGETS = Watch providers and rebuild when state changes
//
// **Flow:**
// User taps button → Widget calls notifier.loadTitles() →
// Notifier fetches from repository → Notifier updates state →
// Riverpod notifies watching widgets → Widgets rebuild with new data
//
// **Key Concept:** Like Redux/Bloc but simpler - just providers + notifiers
// ===================================================================

/// Status enum - tracks what's happening right now
/// Concept: Finite state machine - only ONE status at a time
enum UsCodeStatus {
  idle, // Fresh start, nothing loaded
  loading, // Fetching data from repository
  success, // Data loaded successfully
  error, // Something went wrong
}

/// State class - holds ALL data for U.S. Code feature
/// Concept: Immutable state object - never modify, always replace
///
/// **Why immutable?**
/// - Riverpod detects changes by reference comparison
/// - Prevents accidental mutations
/// - Makes debugging easier (can track state history)
class UsCodeState {
  final UsCodeStatus status;
  final List<UsCodeTitle> titles; // All loaded titles
  final UsCodeTitle? selectedTitle; // Currently viewing title
  final String? errorMessage;

  const UsCodeState({
    required this.status,
    this.titles = const [],
    this.selectedTitle,
    this.errorMessage,
  });

  // Named constructors - shortcuts for common states
  const UsCodeState.idle()
      : status = UsCodeStatus.idle,
        titles = const [],
        selectedTitle = null,
        errorMessage = null;

  const UsCodeState.loading()
      : status = UsCodeStatus.loading,
        titles = const [],
        selectedTitle = null,
        errorMessage = null;

  UsCodeState.success({required List<UsCodeTitle> titles})
      : status = UsCodeStatus.success,
        titles = titles,
        selectedTitle = null,
        errorMessage = null;

  UsCodeState.error({required String message})
      : status = UsCodeStatus.error,
        titles = const [],
        selectedTitle = null,
        errorMessage = message;

  // Convenience getters - make UI code cleaner
  bool get isIdle => status == UsCodeStatus.idle;
  bool get isLoading => status == UsCodeStatus.loading;
  bool get hasData => status == UsCodeStatus.success && titles.isNotEmpty;
  bool get hasError => status == UsCodeStatus.error;

  // copyWith - creates new state with some fields changed
  // Concept: Immutability pattern - return new object instead of mutating
  UsCodeState copyWith({
    UsCodeStatus? status,
    List<UsCodeTitle>? titles,
    UsCodeTitle? selectedTitle,
    bool clearSelectedTitle = false,
    String? errorMessage,
  }) {
    return UsCodeState(
      status: status ?? this.status,
      titles: titles ?? this.titles,
      selectedTitle:
          clearSelectedTitle ? null : (selectedTitle ?? this.selectedTitle),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier - manages state changes
/// Concept: State machine controller - handles transitions between states
///
/// **Pattern:** Similar to SearchNotifier
/// Extends StateNotifier<UsCodeState> means:
/// - Has a `state` property (current state)
/// - Can update state by assigning: state = newState
/// - Riverpod auto-notifies watching widgets
class UsCodeNotifier extends StateNotifier<UsCodeState> {
  final UsCodeRepository _repository;

  // Constructor - starts with idle state
  UsCodeNotifier(this._repository) : super(const UsCodeState.idle());

  /// Load featured titles (for home preview)
  /// **Execution Flow:**
  /// 1. Set state to loading (UI shows spinner)
  /// 2. Call repository (1.5s mock delay)
  /// 3. If success: update state with titles (UI shows cards)
  /// 4. If error: update state with error (UI shows error message)
  Future<void> loadFeaturedTitles() async {
    // Step 1: Show loading state
    state = const UsCodeState.loading();

    try {
      // Step 2: Fetch from repository (mock or real API)
      final titles = await _repository.getFeaturedTitles();

      // Step 3: Success - update state with data
      state = UsCodeState.success(titles: titles);
    } on UsCodeException catch (e) {
      // Step 4a: Typed error - use exception message
      state = UsCodeState.error(message: _getErrorMessage(e));
    } catch (e) {
      // Step 4b: Unexpected error - generic message
      state = UsCodeState.error(
        message: 'Failed to load titles. Please try again.',
      );
    }
  }

  /// Load all titles (for "View All" screen)
  Future<void> loadAllTitles() async {
    state = const UsCodeState.loading();

    try {
      final titles = await _repository.getAllTitles();
      state = UsCodeState.success(titles: titles);
    } on UsCodeException catch (e) {
      state = UsCodeState.error(message: _getErrorMessage(e));
    } catch (e) {
      state = UsCodeState.error(
        message: 'Failed to load titles. Please try again.',
      );
    }
  }

  /// Load single title with full hierarchy
  Future<void> loadTitleById(int titleNumber) async {
    // Preserve existing titles list — only update status and selectedTitle
    // Do NOT wipe titles with UsCodeState.loading() here
    state = state.copyWith(
      status: UsCodeStatus.loading,
      clearSelectedTitle: true,
      errorMessage: null,
    );

    try {
      final title = await _repository.getTitleById(titleNumber);

      // Preserve existing titles, only update selectedTitle
      state = state.copyWith(
        status: UsCodeStatus.success,
        selectedTitle: title,
        errorMessage: null,
      );
    } on UsCodeException catch (e) {
      state = state.copyWith(
        status: UsCodeStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: UsCodeStatus.error,
        errorMessage: 'Failed to load title. Please try again.',
      );
    }
  }

  /// Clear state back to idle
  void reset() {
    state = const UsCodeState.idle();
  }

  /// Convert exception type to user-friendly message
  String _getErrorMessage(UsCodeException e) {
    switch (e.type) {
      case UsCodeExceptionType.network:
        return 'No internet connection. Please check your network.';
      case UsCodeExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case UsCodeExceptionType.server:
        return 'Server error. Please try again later.';
      case UsCodeExceptionType.notFound:
        return e.message; // Already user-friendly
      case UsCodeExceptionType.validation:
        return e.message;
      case UsCodeExceptionType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ==================== GLOBAL PROVIDERS ====================
//
// **How Widgets Use This:**
//
// 1. Watch state:
//    final state = ref.watch(usCodeProvider);
//    if (state.isLoading) return Spinner();
//
// 2. Call actions:
//    ref.read(usCodeProvider.notifier).loadFeaturedTitles();
//
// **Riverpod Magic:**
// - Auto-rebuilds widgets when state changes
// - Auto-disposes when no widgets watching
// - Thread-safe (can't have race conditions)
// ======================================================

/// Main provider - exposes state to widgets
/// **ONE-LINE SWAP:** Change MockUsCodeRepository → APIUsCodeRepository
final usCodeProvider =
    StateNotifierProvider<UsCodeNotifier, UsCodeState>((ref) {
  // Phase 1: Mock repository (hardcoded data)
  final repository = MockUsCodeRepository();

  // Phase 3: Uncomment this to use real API
  // final repository = APIUsCodeRepository(
  //   baseUrl: 'https://api.casetally.com',
  // );

  return UsCodeNotifier(repository);
});

/// Convenience provider - just featured titles
/// **Why separate provider?**
/// - Home widget only needs featured titles
/// - Don't re-fetch when other state changes
/// - Cleaner widget code
final featuredTitlesProvider = Provider<List<UsCodeTitle>>((ref) {
  final state = ref.watch(usCodeProvider);
  return state.titles.where((t) => t.isFeatured).toList();
});
