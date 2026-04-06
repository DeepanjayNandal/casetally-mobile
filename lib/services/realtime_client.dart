import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../features/search/models/search_event.dart';

/// Production WebSocket client for real-time search
///
/// Lifecycle: connect → send query → stream typed events → close
/// One connection per query. No persistent socket, no heartbeat.
class RealtimeClient {
  final String baseUrl;
  final Duration connectionTimeout;
  final Duration queryTimeout;

  const RealtimeClient({
    required this.baseUrl,
    this.connectionTimeout = const Duration(seconds: 10),
    this.queryTimeout = const Duration(seconds: 30),
  });

  Stream<SearchEvent> search({
    required String query,
    required String requestId,
    String? groupId,
  }) async* {
    WebSocketChannel? channel;
    Timer? timeoutTimer;

    try {
      final wsUrl = Uri.parse('$baseUrl/ws/search');

      debugPrint('[WS] connecting to $wsUrl');

      channel = await _connectWithTimeout(wsUrl);

      debugPrint('[WS] connected');

      final request = {
        'query': query,
        'requestId': requestId,
        if (groupId != null) 'groupId': groupId,
      };

      channel.sink.add(jsonEncode(request));

      timeoutTimer = Timer(queryTimeout, () {
        channel?.sink.close();
        throw TimeoutException(
          'No events received within ${queryTimeout.inSeconds}s',
        );
      });

      await for (final message in channel.stream) {
        timeoutTimer?.cancel();
        timeoutTimer = Timer(queryTimeout, () {
          channel?.sink.close();
          throw TimeoutException('Stream timed out');
        });

        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final event = SearchEvent.fromJson(json);

          yield event;

          if (event is DoneEvent) {
            debugPrint('[WS] search complete');
            break;
          } else if (event is ErrorEvent) {
            debugPrint('[WS] error: ${event.message}');
            break;
          }
        } on FormatException {
          yield ErrorEvent(
            requestId: requestId,
            groupId: groupId,
            message: 'Failed to parse server response',
            errorCode: 'PARSE_ERROR',
          );
          break;
        }
      }
    } on TimeoutException {
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'Request timed out. Please try again.',
        errorCode: 'TIMEOUT',
      );
    } on WebSocketChannelException catch (e) {
      debugPrint('[WS] connection error: $e');
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'Connection failed. Check your internet connection.',
        errorCode: 'CONNECTION_ERROR',
      );
    } catch (e, stackTrace) {
      debugPrint('[WS] unexpected error: $e');
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'An unexpected error occurred',
        errorCode: 'UNKNOWN_ERROR',
        stackTrace: stackTrace.toString(),
      );
    } finally {
      timeoutTimer?.cancel();
      await channel?.sink.close();
      debugPrint('[WS] connection closed');
    }
  }

  Future<WebSocketChannel> _connectWithTimeout(Uri uri) async {
    final completer = Completer<WebSocketChannel>();

    Timer(connectionTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
              'Connection timeout after ${connectionTimeout.inSeconds}s'),
        );
      }
    });

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready.timeout(connectionTimeout);

      if (!completer.isCompleted) {
        completer.complete(channel);
      }

      return completer.future;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    }
  }
}
