import '../models/search_response.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../services/realtime_client.dart';
import '../../../services/fake_realtime_client.dart';
import '../models/search_event.dart';
import '../models/law_reference.dart';
import '../models/source.dart';
import '../models/related_article.dart';
import 'search_repository.dart';

/// Streams typed search events from the WebSocket backend (or mock).
/// Inject [fakeClient] for development, [client] for production.
class WebSocketSearchRepository implements SearchRepository {
  final dynamic _client;
  final Uuid _uuid = const Uuid();

  WebSocketSearchRepository({
    RealtimeClient? client,
    FakeRealtimeClient? fakeClient,
  }) : _client = fakeClient ?? client ?? FakeRealtimeClient();

  @override
  Stream<SearchEvent> searchStream(
    String query, {
    String? groupId,
    String? requestId,
  }) async* {
    if (query.trim().isEmpty) {
      yield ErrorEvent(
        requestId: requestId ?? _uuid.v4(),
        groupId: groupId,
        message: 'Please enter a search query',
        errorCode: 'EMPTY_QUERY',
      );
      return;
    }

    final finalRequestId = requestId ?? _uuid.v4();

    debugPrint('[SearchRepo] starting search: "$query"');

    await for (final event in _client.search(
      query: query,
      requestId: finalRequestId,
      groupId: groupId,
    )) {
      yield _processEvent(event);
    }
  }

  /// Validates event data before passing it downstream.
  /// Returns an ErrorEvent if parsing fails so the stream stays open.
  SearchEvent _processEvent(SearchEvent event) {
    try {
      if (event is! CitationsEvent &&
          event is! SourcesEvent &&
          event is! RelatedArticlesEvent) {
        return event;
      }

      if (event is CitationsEvent) {
        for (final item in event.data) {
          if (item is! Map<String, dynamic>) throw const FormatException('invalid citation');
          LawReference.fromJson(item);
        }
      }

      if (event is SourcesEvent) {
        for (final item in event.data) {
          if (item is! Map<String, dynamic>) throw const FormatException('invalid source');
          Source.fromJson(item);
        }
      }

      if (event is RelatedArticlesEvent) {
        for (final item in event.data) {
          if (item is! Map<String, dynamic>) throw const FormatException('invalid article');
          RelatedArticle.fromJson(item);
        }
      }

      return event;
    } catch (e, stackTrace) {
      debugPrint('[SearchRepo] parse error: $e');
      return ErrorEvent(
        requestId: event.requestId,
        groupId: event.groupId,
        message: 'Failed to process search results',
        errorCode: 'PARSE_ERROR',
        stackTrace: stackTrace.toString(),
      );
    }
  }

  @override
  @Deprecated('Use searchStream() instead')
  Future<SearchResponse> search(String query) {
    throw UnsupportedError('Use searchStream() instead.');
  }

  @override
  bool isCached(String query) => false;

  @override
  void clearCache() {}
}
