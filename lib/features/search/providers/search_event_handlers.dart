import 'package:flutter/foundation.dart';
import '../models/artifact.dart';
import '../models/search_event.dart';
import '../models/law_reference.dart';
import '../models/source.dart';
import '../models/related_article.dart';
import 'search_state.dart';

/// Pure functions that map (SearchState, SearchEvent) → SearchState.
/// All handlers check requestId before applying updates to prevent
/// stale events from a previous query corrupting the current one.
class SearchEventHandlers {
  SearchEventHandlers._();

  static SearchState handleStarted(SearchState state, StartedEvent event) {
    if (event.requestId != state.currentRequestId) return state;
    return state;
  }

  static SearchState handleSourcesCount(
    SearchState state,
    SourcesCountEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;
    return state.copyWith(totalSourcesCount: event.count);
  }

  static SearchState handleCitations(
    SearchState state,
    CitationsEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;

    final newLaws = event.data
        .map((json) => LawReference.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      laws: [...state.laws, ...newLaws],
      citationsComplete: true,
    );
  }

  static SearchState handleSummaryChunk(
    SearchState state,
    SummaryChunkEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;

    return state.copyWith(
      summaryChunks: [...state.summaryChunks, event.chunk],
      summaryComplete: event.isComplete,
    );
  }

  static SearchState handleSources(
    SearchState state,
    SourcesEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;

    final newSources = event.data
        .map((json) => Source.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      sources: [...state.sources, ...newSources],
      sourcesComplete: true,
    );
  }

  static SearchState handleArtifacts(
    SearchState state,
    ArtifactsEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;

    final newArtifacts = <Artifact>[];
    for (final json in event.data) {
      try {
        newArtifacts.add(Artifact.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[Search] failed to parse artifact: $e');
      }
    }

    return state.copyWith(
      artifacts: [...state.artifacts, ...newArtifacts],
      artifactsComplete: event.isComplete,
    );
  }

  static SearchState handleRelatedArticles(
    SearchState state,
    RelatedArticlesEvent event,
  ) {
    if (event.requestId != state.currentRequestId) return state;

    final newArticles = event.data
        .map((json) => RelatedArticle.fromJson(json as Map<String, dynamic>))
        .toList();

    return state.copyWith(
      relatedArticles: [...state.relatedArticles, ...newArticles],
      relatedArticlesComplete: true,
    );
  }

  static SearchState handleDone(SearchState state, DoneEvent event) {
    if (event.requestId != state.currentRequestId) return state;

    debugPrint('[Search] completed in ${event.processingTimeMs}ms');

    return state.copyWith(
      status: SearchStatus.success,
      processingTime: event.processingTime,
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );
  }

  static SearchState handleError(SearchState state, ErrorEvent event) {
    if (event.requestId != state.currentRequestId) return state;

    debugPrint('[Search] error: ${event.message} (${event.errorCode})');

    return state.copyWith(
      status: SearchStatus.error,
      errorMessage: event.message,
      citationsComplete: true,
      summaryComplete: true,
      sourcesComplete: true,
      artifactsComplete: true,
      relatedArticlesComplete: true,
    );
  }

  static SearchState handleUnknown(SearchState state, UnknownEvent event) {
    debugPrint('[Search] unknown event type: ${event.eventType}');
    return state;
  }
}
