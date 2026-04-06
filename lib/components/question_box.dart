import '../features/search/providers/search_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../features/search/providers/search_provider.dart';

/// State provider for QuestionBox
class QuestionBoxState {
  final String query;
  final bool showOverlay;

  const QuestionBoxState({
    this.query = '',
    this.showOverlay = false,
  });

  QuestionBoxState copyWith({
    String? query,
    bool? showOverlay,
  }) {
    return QuestionBoxState(
      query: query ?? this.query,
      showOverlay: showOverlay ?? this.showOverlay,
    );
  }
}

class QuestionBoxNotifier extends StateNotifier<QuestionBoxState> {
  final Ref ref;

  QuestionBoxNotifier(this.ref) : super(const QuestionBoxState()) {
    // Listen to SearchProvider state changes
    ref.listen<SearchState>(
      searchProvider,
      (previous, next) {
        _handleSearchStateChange(previous, next);
      },
    );
  }

  /// React to search state changes
  /// Easy to modify behavior without touching other code
  void _handleSearchStateChange(SearchState? previous, SearchState next) {
    // BEHAVIOR 1: Keep overlay open during loading/success/error
    // (User manually closes via X button or swipe)
    if (next.isSearching) {
      // Search started - overlay already open from submit
      // Keep it open
    }

    if (next.hasAnyResults) {
      // Search succeeded - keep overlay open to show results
      // User can read and manually close
    }

    if (next.hasError) {
      // Search failed - keep overlay open to show error
      // User can retry or manually close
    }

    // BEHAVIOR MODIFICATION NOTES:
    // - To auto-close on success after 5s: Add timer in hasAnyResults block
    // - To auto-close on error: Set showOverlay = false in hasError block
    // - To persist query: Remove query clearing in dismissOverlay()
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void showOverlay() {
    state = state.copyWith(showOverlay: true);
  }

  /// BEHAVIOR 3: Clear query on tab switch (current: 3B)
  /// To keep query across tabs: Make this method do nothing
  /// To remember per-tab: Store query in tab-specific state
  void clearQuery() {
    state = state.copyWith(query: '');
  }

  /// BEHAVIOR 2: Clear query on dismiss (easy to change)
  /// To keep query: Remove 'query: ''' from copyWith
  void dismissOverlay() {
    state = state.copyWith(
      showOverlay: false,
      query: '', // ⚠️ Change this to keep query after dismiss
    );
  }
}

final questionBoxProvider =
    StateNotifierProvider<QuestionBoxNotifier, QuestionBoxState>(
  (ref) => QuestionBoxNotifier(ref),
);

/// Persistent search/ask bar that appears above bottom navigation
class QuestionBox extends ConsumerStatefulWidget {
  const QuestionBox({super.key});

  @override
  ConsumerState<QuestionBox> createState() => _QuestionBoxState();
}

class _QuestionBoxState extends ConsumerState<QuestionBox> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Listen to questionBoxProvider state changes to sync controller
    // This ensures TextField clears when query is cleared externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<QuestionBoxState>(
        questionBoxProvider,
        (previous, next) {
          // Sync controller with state when query changes externally
          if (_controller.text != next.query) {
            _controller.text = next.query;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final query = _controller.text.trim();

    if (query.isEmpty) return;

    // Unfocus keyboard
    _focusNode.unfocus();

    // Haptic feedback
    await HapticFeedback.mediumImpact();

    // Show overlay immediately
    ref.read(questionBoxProvider.notifier).showOverlay();

    // Trigger search through search provider
    await ref.read(searchProvider.notifier).submitQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionBoxProvider);
    final searchState = ref.watch(searchProvider);

    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
        top: AppTheme.spacingMd,
        bottom: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.searchBarBackground(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          Icon(
            CupertinoIcons.search,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            size: 20,
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Text input
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              focusNode: _focusNode,
              placeholder: 'Ask a legal question...',
              decoration: const BoxDecoration(),
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 17,
              ),
              placeholderStyle: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 17,
              ),
              onChanged: (value) {
                ref.read(questionBoxProvider.notifier).updateQuery(value);
              },
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Submit button / Loading indicator
          if (searchState.isSearching)
            const CupertinoActivityIndicator()
          else if (state.query.isNotEmpty)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleSubmit,
              child: Icon(
                CupertinoIcons.arrow_up_circle_fill,
                color: CupertinoColors.activeBlue.resolveFrom(context),
                size: 32,
              ),
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }
}
