import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../features/search/models/search_event.dart';

/// Production WebSocket client for real-time search
///
/// **Lifecycle:**
/// 1. Client calls search() with query
/// 2. Opens WebSocket connection
/// 3. Sends query JSON
/// 4. Listens for events
/// 5. Parses JSON → SearchEvent
/// 6. Closes on done/error
///
/// **Error Handling:**
/// - Connection failures → ErrorEvent in stream
/// - Malformed JSON → ErrorEvent in stream
/// - Timeout → ErrorEvent in stream
///
/// **One Connection Per Query:**
/// - No persistent socket
/// - No heartbeat needed
/// - Mobile-friendly lifecycle
class RealtimeClient {
  /// WebSocket base URL
  ///
  /// **Examples:**
  /// - Local dev: 'ws://localhost:8000'
  /// - Production: 'wss://api.casetally.com'
  final String baseUrl;

  /// Connection timeout duration
  /// If connection doesn't establish in this time, fail with timeout error
  final Duration connectionTimeout;

  /// Query timeout duration
  /// If no events received for this duration, fail with timeout error
  final Duration queryTimeout;

  const RealtimeClient({
    required this.baseUrl,
    this.connectionTimeout = const Duration(seconds: 10),
    this.queryTimeout = const Duration(seconds: 30),
  });

  /// Execute search query via WebSocket
  ///
  /// **Returns:** Stream of SearchEvent objects
  ///
  /// **Flow:**
  /// 1. Connect to WebSocket
  /// 2. Send query JSON
  /// 3. Listen for messages
  /// 4. Parse each message → SearchEvent
  /// 5. Emit events to stream
  /// 6. Close on 'done' event or error
  ///
  /// **Example Usage:**
  /// ```dart
  /// final client = RealtimeClient(baseUrl: 'ws://localhost:8000');
  ///
  /// await for (final event in client.search(
  ///   query: 'What are Miranda rights?',
  ///   requestId: 'abc-123',
  /// )) {
  ///   if (event is StartedEvent) print('Search started');
  ///   if (event is CitationsEvent) print('Got ${event.count} citations');
  ///   if (event is DoneEvent) print('Complete!');
  /// }
  /// ```
  Stream<SearchEvent> search({
    required String query,
    required String requestId,
    String? groupId,
  }) async* {
    WebSocketChannel? channel;
    Timer? timeoutTimer;

    try {
      // Build WebSocket URL
      final wsUrl = Uri.parse('$baseUrl/ws/search');

      print('🔌 [RealtimeClient] Connecting to: $wsUrl');

      // Connect with timeout
      channel = await _connectWithTimeout(wsUrl);

      print('✅ [RealtimeClient] Connected successfully');

      // Build request payload
      final request = {
        'query': query,
        'requestId': requestId,
        if (groupId != null) 'groupId': groupId,
      };

      print('📤 [RealtimeClient] Sending query: ${request['query']}');

      // Send query
      channel.sink.add(jsonEncode(request));

      // Set query timeout (restarts on each message)
      timeoutTimer = Timer(queryTimeout, () {
        channel?.sink.close();
        throw TimeoutException(
          'No events received within ${queryTimeout.inSeconds}s',
        );
      });

      // Listen for messages
      await for (final message in channel.stream) {
        // Reset timeout on each message
        timeoutTimer?.cancel(); // ← Add ? here
        timeoutTimer = Timer(queryTimeout, () {
          channel?.sink.close();
          throw TimeoutException('Stream timed out');
        });

        try {
          // Parse JSON
          final json = jsonDecode(message as String) as Map<String, dynamic>;

          print('📥 [RealtimeClient] Received: ${json['type']}');

          // Convert to typed event
          final event = SearchEvent.fromJson(json);

          // Emit event
          yield event;

          // Close connection on done or error
          if (event is DoneEvent) {
            print('✅ [RealtimeClient] Search completed');
            break;
          } else if (event is ErrorEvent) {
            print('❌ [RealtimeClient] Error event: ${event.message}');
            break;
          }
        } on FormatException catch (e) {
          // Malformed JSON - emit error event
          print('❌ [RealtimeClient] JSON parse error: $e');
          yield ErrorEvent(
            requestId: requestId,
            groupId: groupId,
            message: 'Failed to parse server response',
            errorCode: 'PARSE_ERROR',
          );
          break;
        }
      }
    } on TimeoutException catch (e) {
      print('⏱️ [RealtimeClient] Timeout: $e');
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'Request timed out. Please try again.',
        errorCode: 'TIMEOUT',
      );
    } on WebSocketChannelException catch (e) {
      print('❌ [RealtimeClient] WebSocket error: $e');
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'Connection failed. Check your internet connection.',
        errorCode: 'CONNECTION_ERROR',
      );
    } catch (e, stackTrace) {
      print('❌ [RealtimeClient] Unexpected error: $e');
      print('Stack trace: $stackTrace');
      yield ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'An unexpected error occurred',
        errorCode: 'UNKNOWN_ERROR',
        stackTrace: stackTrace.toString(),
      );
    } finally {
      // Always cleanup
      timeoutTimer?.cancel();
      await channel?.sink.close();
      print('🔌 [RealtimeClient] Connection closed');
    }
  }

  /// Connect to WebSocket with timeout
  Future<WebSocketChannel> _connectWithTimeout(Uri uri) async {
    final completer = Completer<WebSocketChannel>();

    // Start connection
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

      // Wait for first ready event (connection established)
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
