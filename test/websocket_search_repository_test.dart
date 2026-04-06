import 'package:flutter_test/flutter_test.dart';
import 'package:casetally/features/search/repositories/websocket_search_repository.dart';
import 'package:casetally/features/search/models/search_event.dart';
import 'package:casetally/services/fake_realtime_client.dart';

void main() {
  group('WebSocketSearchRepository', () {
    test('Streams events from FakeRealtimeClient', () async {
      final repository = WebSocketSearchRepository(
        fakeClient: FakeRealtimeClient(),
      );

      final events = <SearchEvent>[];

      await for (final event in repository.searchStream('Test query')) {
        events.add(event);
        print('📥 Repository received: ${event.runtimeType}');
      }

      // Verify event sequence
      expect(events[0], isA<StartedEvent>());
      expect(events[1], isA<SourcesCountEvent>());
      expect(events[2], isA<CitationsEvent>());

      // Verify citations parsed successfully (no error events)
      expect(
        events.where((e) => e is ErrorEvent).isEmpty,
        true,
        reason: 'Should not have parse errors',
      );

      expect(events.last, isA<DoneEvent>());
    });

    test('Validates empty query', () async {
      final repository = WebSocketSearchRepository(
        fakeClient: FakeRealtimeClient(),
      );

      final events = <SearchEvent>[];

      await for (final event in repository.searchStream('   ')) {
        events.add(event);
      }

      expect(events.length, 1);
      expect(events.first, isA<ErrorEvent>());
      expect((events.first as ErrorEvent).errorCode, 'EMPTY_QUERY');
    });

    test('Generates unique requestIds', () async {
      final repository = WebSocketSearchRepository(
        fakeClient: FakeRealtimeClient(),
      );

      String? firstRequestId;
      String? secondRequestId;

      // First query
      await for (final event in repository.searchStream('Query 1')) {
        firstRequestId = event.requestId;
        break; // Just get first event
      }

      // Second query
      await for (final event in repository.searchStream('Query 2')) {
        secondRequestId = event.requestId;
        break; // Just get first event
      }

      expect(firstRequestId, isNotNull);
      expect(secondRequestId, isNotNull);
      expect(firstRequestId, isNot(equals(secondRequestId)));
    });
  });
}
