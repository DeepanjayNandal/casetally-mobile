import 'package:flutter_test/flutter_test.dart';
import 'package:casetally/features/search/providers/search_state.dart';
import 'package:casetally/features/search/providers/search_event_handlers.dart';
import 'package:casetally/features/search/models/search_event.dart';
import 'package:casetally/features/search/models/law_reference.dart';
import 'package:casetally/features/search/models/source.dart';
import 'package:casetally/features/search/models/related_article.dart';

void main() {
  group('SearchState', () {
    test('Initial state is idle', () {
      const state = SearchState.idle();

      expect(state.status, SearchStatus.idle);
      expect(state.currentQuery, isNull);
      expect(state.currentRequestId, isNull);
      expect(state.laws, isEmpty);
      expect(state.summaryChunks, isEmpty);
      expect(state.sources, isEmpty);
      expect(state.relatedArticles, isEmpty);
      expect(state.hasAnyResults, false);
    });

    test('Loading state sets up correctly', () {
      final state = SearchState.loading(
        query: 'Test query',
        requestId: 'req-123',
        groupId: 'group-456',
      );

      expect(state.status, SearchStatus.loading);
      expect(state.currentQuery, 'Test query');
      expect(state.currentRequestId, 'req-123');
      expect(state.groupId, 'group-456');
      expect(state.queryStartTime, isNotNull);
      expect(state.isSearching, true);
    });

    test('copyWith works correctly', () {
      const initial = SearchState.idle();
      final updated = initial.copyWith(
        currentQuery: 'New query',
        status: SearchStatus.loading,
      );

      expect(updated.currentQuery, 'New query');
      expect(updated.status, SearchStatus.loading);
      expect(updated.laws, isEmpty); // Unchanged fields preserved
    });

    test('hasAnyResults works correctly', () {
      const empty = SearchState.idle();
      expect(empty.hasAnyResults, false);

      final withLaws = empty.copyWith(laws: [
        const LawReference(
          id: 'test',
          title: 'Test Law',
          citation: 'Test',
          summary: 'Test',
          jurisdiction: 'Federal',
          type: LawType.statute,
          relevanceScore: 0.9,
        ),
      ]);
      expect(withLaws.hasAnyResults, true);
    });

    test('summaryText joins chunks correctly', () {
      final state = const SearchState.idle().copyWith(
        summaryChunks: ['Hello ', 'world', '!'],
      );

      expect(state.summaryText, 'Hello world!');
    });

    test('isSummaryStreaming works correctly', () {
      const idle = SearchState.idle();
      expect(idle.isSummaryStreaming, false);

      final streaming = idle.copyWith(
        summaryChunks: ['Chunk 1'],
        summaryComplete: false,
      );
      expect(streaming.isSummaryStreaming, true);

      final complete = streaming.copyWith(summaryComplete: true);
      expect(complete.isSummaryStreaming, false);
    });
  });

  group('SearchEventHandlers', () {
    test('handleStarted ignores stale events', () {
      final state = SearchState.loading(
        query: 'Current query',
        requestId: 'req-current',
      );

      final staleEvent = StartedEvent(
        requestId: 'req-old',
        query: 'Old query',
      );

      final newState = SearchEventHandlers.handleStarted(state, staleEvent);

      expect(newState, same(state)); // No change
    });

    test('handleSourcesCount updates count', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event = SourcesCountEvent(
        requestId: 'req-123',
        count: 5,
      );

      final newState = SearchEventHandlers.handleSourcesCount(state, event);

      expect(newState.totalSourcesCount, 5);
    });

    test('handleCitations accumulates laws', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event = CitationsEvent(
        requestId: 'req-123',
        data: [
          {
            'id': 'law-1',
            'title': 'Test Law',
            'citation': 'Test Citation',
            'summary': 'Summary',
            'jurisdiction': 'Federal',
            'type': 'statute',
            'relevance_score': 0.9,
          },
        ],
      );

      final newState = SearchEventHandlers.handleCitations(state, event);

      expect(newState.laws.length, 1);
      expect(newState.laws.first.title, 'Test Law');
      expect(newState.citationsComplete, true);
    });

    test('handleSummaryChunk accumulates chunks', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      // First chunk
      final chunk1 = SummaryChunkEvent(
        requestId: 'req-123',
        chunk: 'Hello ',
        isComplete: false,
      );

      final state2 = SearchEventHandlers.handleSummaryChunk(state, chunk1);
      expect(state2.summaryChunks, ['Hello ']);
      expect(state2.summaryComplete, false);

      // Second chunk
      final chunk2 = SummaryChunkEvent(
        requestId: 'req-123',
        chunk: 'world!',
        isComplete: true,
      );

      final state3 = SearchEventHandlers.handleSummaryChunk(state2, chunk2);
      expect(state3.summaryChunks, ['Hello ', 'world!']);
      expect(state3.summaryText, 'Hello world!');
      expect(state3.summaryComplete, true);
    });

    test('handleSources accumulates sources', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event = SourcesEvent(
        requestId: 'req-123',
        data: [
          {
            'name': 'Test Source',
            'url': 'https://example.com',
            'type': 'legal_database',
            'credibility': 'high',
          },
        ],
      );

      final newState = SearchEventHandlers.handleSources(state, event);

      expect(newState.sources.length, 1);
      expect(newState.sources.first.name, 'Test Source');
      expect(newState.sourcesComplete, true);
    });

    test('handleRelatedArticles accumulates articles', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event = RelatedArticlesEvent(
        requestId: 'req-123',
        data: [
          {
            'id': 'article-1',
            'title': 'Test Article',
            'category': 'test',
            'reading_minutes': 5,
            'relevance_reason': 'Relevant',
          },
        ],
      );

      final newState = SearchEventHandlers.handleRelatedArticles(state, event);

      expect(newState.relatedArticles.length, 1);
      expect(newState.relatedArticles.first.title, 'Test Article');
      expect(newState.relatedArticlesComplete, true);
    });

    test('handleDone marks search complete', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      ).copyWith(
        summaryChunks: ['Some result'],
      );

      final event = DoneEvent(
        requestId: 'req-123',
        processingTimeMs: 2500,
      );

      final newState = SearchEventHandlers.handleDone(state, event);

      expect(newState.status, SearchStatus.success);
      expect(newState.isComplete, true);
      expect(newState.processingTime?.inMilliseconds, 2500);
      expect(newState.citationsComplete, true);
      expect(newState.summaryComplete, true);
      expect(newState.sourcesComplete, true);
      expect(newState.relatedArticlesComplete, true);
    });

    test('handleError preserves partial results', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      ).copyWith(
        laws: [
          const LawReference(
            id: 'law-1',
            title: 'Already Loaded',
            citation: 'Test',
            summary: 'Test',
            jurisdiction: 'Federal',
            type: LawType.statute,
            relevanceScore: 0.9,
          ),
        ],
      );

      final event = ErrorEvent(
        requestId: 'req-123',
        message: 'Connection failed',
        errorCode: 'NETWORK_ERROR',
      );

      final newState = SearchEventHandlers.handleError(state, event);

      expect(newState.status, SearchStatus.error);
      expect(newState.hasError, true);
      expect(newState.errorMessage, 'Connection failed');
      expect(newState.laws.length, 1); // Partial results preserved!
      expect(newState.hasAnyResults, true);
    });

    test('Request scoping prevents stale event corruption', () {
      final state = SearchState.loading(
        query: 'Current query',
        requestId: 'req-current',
      );

      // Simulate late arrival of event from previous query
      final staleEvent = CitationsEvent(
        requestId: 'req-old',
        data: [
          {
            'id': 'stale-law',
            'title': 'Stale Law',
            'citation': 'Old',
            'summary': 'Old',
            'jurisdiction': 'Federal',
            'type': 'statute',
            'relevance_score': 0.9,
          },
        ],
      );

      final newState = SearchEventHandlers.handleCitations(state, staleEvent);

      expect(newState.laws, isEmpty); // No corruption!
      expect(newState, same(state)); // State unchanged
    });
  });

  group('Edge Cases', () {
    test('Multiple CitationsEvents accumulate', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event1 = CitationsEvent(
        requestId: 'req-123',
        data: [
          {
            'id': 'law-1',
            'title': 'Law 1',
            'citation': 'C1',
            'summary': 'S1',
            'jurisdiction': 'Federal',
            'type': 'statute',
            'relevance_score': 0.9,
          },
        ],
      );

      final event2 = CitationsEvent(
        requestId: 'req-123',
        data: [
          {
            'id': 'law-2',
            'title': 'Law 2',
            'citation': 'C2',
            'summary': 'S2',
            'jurisdiction': 'State',
            'type': 'case_law',
            'relevance_score': 0.8,
          },
        ],
      );

      final state2 = SearchEventHandlers.handleCitations(state, event1);
      final state3 = SearchEventHandlers.handleCitations(state2, event2);

      expect(state3.laws.length, 2);
      expect(state3.laws[0].title, 'Law 1');
      expect(state3.laws[1].title, 'Law 2');
    });

    test('UnknownEvent does not crash', () {
      final state = SearchState.loading(
        query: 'Test',
        requestId: 'req-123',
      );

      final event = UnknownEvent(
        requestId: 'req-123',
        eventType: 'future_event_v2',
        rawJson: {'type': 'future_event_v2'},
      );

      final newState = SearchEventHandlers.handleUnknown(state, event);

      expect(newState, same(state)); // Gracefully ignored
    });
  });
}
