import '../models/artifact.dart';
import '../models/search_event.dart';
import '../models/law_reference.dart';
import '../models/source.dart';
import '../models/related_article.dart';
import 'search_state.dart';

/// Event handling logic for SearchNotifier
///
/// **Design:**
/// - Pure functions: Event + State → New State
/// - No side effects
/// - Easy to test
/// - Clear mutation rules
///
/// **Request Scoping:**
/// ALL handlers check `event.requestId == state.currentRequestId`
/// to prevent stale events from corrupting UI
class SearchEventHandlers {
  SearchEventHandlers._(); // Private constructor - static class

  /// Handle StartedEvent
  ///
  /// **Mutation:** None (state already set to loading by submitQuery)
  /// **Purpose:** Confirms search began, could log analytics
  static SearchState handleStarted(SearchState state, StartedEvent event) {
    // Ignore if from old request
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring StartedEvent from stale request: ${event.requestId}');
      return state;
    }

    print('▶️ Search started: "${event.query}"');
    return state; // No state change needed
  }

  /// Handle SourcesCountEvent
  ///
  /// **Mutation:** Set totalSourcesCount
  /// **UI Impact:** Badge shows "Found X sources"
  static SearchState handleSourcesCount(
    SearchState state,
    SourcesCountEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring SourcesCountEvent from stale request');
      return state;
    }

    print('📊 Sources count: ${event.count}');
    return state.copyWith(totalSourcesCount: event.count);
  }

  /// Handle CitationsEvent
  ///
  /// **Mutation:** Append citations to laws list, mark complete
  /// **UI Impact:** "Relevant Laws" section appears
  static SearchState handleCitations(
    SearchState state,
    CitationsEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring CitationsEvent from stale request');
      return state;
    }

    print('📚 Received ${event.count} citations');

    // Parse citations
    final newLaws = event.data
        .map((json) => LawReference.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      laws: [...state.laws, ...newLaws],
      citationsComplete: true, // Assume one CitationsEvent per query
    );
  }

  /// Handle SummaryChunkEvent
  ///
  /// **Mutation:** Append chunk to summaryChunks, mark complete if final
  /// **UI Impact:** Text streams in progressively
  static SearchState handleSummaryChunk(
    SearchState state,
    SummaryChunkEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring SummaryChunkEvent from stale request');
      return state;
    }

    print('💬 Summary chunk received (${event.chunk.length} chars)');

    return state.copyWith(
      summaryChunks: [...state.summaryChunks, event.chunk],
      summaryComplete: event.isComplete,
    );
  }

  /// Handle SourcesEvent
  ///
  /// **Mutation:** Append sources, mark complete
  /// **UI Impact:** "Sources" section appears
  static SearchState handleSources(
    SearchState state,
    SourcesEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring SourcesEvent from stale request');
      return state;
    }

    print('📄 Received ${event.count} sources');

    final newSources = event.data
        .map((json) => Source.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      sources: [...state.sources, ...newSources],
      sourcesComplete: true,
    );
  }

  /// Handle ArtifactsEvent
  ///
  /// **Mutation:** Append artifacts, mark complete if isComplete=true
  /// **UI Impact:** "Artifacts" pill appears/updates
  ///
  /// **Note:** Multiple ArtifactsEvent can arrive (incremental streaming)
  /// isComplete flag indicates whether more artifacts will arrive
  static SearchState handleArtifacts(
    SearchState state,
    ArtifactsEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring ArtifactsEvent from stale request');
      return state;
    }

    print('📄 Received ${event.count} artifacts (complete: ${event.isComplete})');

    // Parse artifacts with error handling
    // If individual artifact fails to parse, log and skip (don't crash stream)
    final newArtifacts = <Artifact>[];
    for (final json in event.data) {
      try {
        newArtifacts.add(Artifact.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        // Log error but continue processing other artifacts
        print('⚠️ Failed to parse artifact: $e');
        // TODO: Add proper error reporting when Sentry integrated
      }
    }

    print('   Successfully parsed: ${newArtifacts.length}');
    print('   Total artifacts: ${state.artifacts.length + newArtifacts.length}');

    return state.copyWith(
      artifacts: [...state.artifacts, ...newArtifacts],
      artifactsComplete: event.isComplete,
    );
  }

  /// Handle RelatedArticlesEvent
  ///
  /// **Mutation:** Append articles, mark complete
  /// **UI Impact:** "Related Articles" section appears
  static SearchState handleRelatedArticles(
    SearchState state,
    RelatedArticlesEvent event,
  ) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring RelatedArticlesEvent from stale request');
      return state;
    }

    print('📰 Received ${event.count} related articles');

    final newArticles = event.data
        .map((json) => RelatedArticle.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      relatedArticles: [...state.relatedArticles, ...newArticles],
      relatedArticlesComplete: true,
    );
  }

  /// Handle DoneEvent
  ///
  /// **Mutation:** Set status to success, mark all sections complete
  /// **UI Impact:** Stop loading indicators, enable share actions
  static SearchState handleDone(SearchState state, DoneEvent event) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring DoneEvent from stale request');
      return state;
    }

    print('✅ Search completed (${event.processingTimeMs}ms)');

    return state.copyWith(
      status: SearchStatus.success,
      processingTime: event.processingTime,
      // Mark all sections complete (even if some didn't arrive)
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );
  }

  /// Handle ErrorEvent
  ///
  /// **Mutation:** Set status to error, preserve partial results
  /// **UI Impact:** Show error message, keep overlay open with partial data
  static SearchState handleError(SearchState state, ErrorEvent event) {
    if (event.requestId != state.currentRequestId) {
      print('⚠️ Ignoring ErrorEvent from stale request');
      return state;
    }

    print('❌ Error: ${event.message} (${event.errorCode})');

    return state.copyWith(
      status: SearchStatus.error,
      errorMessage: event.message,
      // Mark all sections complete to stop loading indicators
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );
  }

  /// Handle UnknownEvent
  ///
  /// **Mutation:** None, just log
  /// **Purpose:** Backend added new event type, client gracefully ignores
  static SearchState handleUnknown(
    SearchState state,
    UnknownEvent event,
  ) {
    print('❓ Unknown event type: ${event.eventType}');
    return state; // No state change
  }
}
