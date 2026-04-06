import 'package:flutter_test/flutter_test.dart';
import 'package:casetally/services/fake_realtime_client.dart';
import 'package:casetally/features/search/models/search_event.dart';

void main() {
  group('FakeRealtimeClient', () {
    test('Simulates complete event stream', () async {
      final client = FakeRealtimeClient();
      final events = <SearchEvent>[];

      await for (final event in client.search(
        query: 'Test query',
        requestId: 'test-123',
      )) {
        events.add(event);
        print('Received: ${event.runtimeType}');
      }

      // Verify event sequence
      expect(events[0], isA<StartedEvent>());
      expect(events[1], isA<SourcesCountEvent>());
      expect(events[2], isA<CitationsEvent>());
      expect(events[3], isA<SummaryChunkEvent>());
      expect(events.last, isA<DoneEvent>());

      // Verify total events
      expect(events.length, greaterThan(5));
    });

    test('Error simulation works', () async {
      final client = FakeRealtimeClient();
      final events = <SearchEvent>[];

      await for (final event in client.searchWithError(
        query: 'Test error',
        requestId: 'test-456',
      )) {
        events.add(event);
      }

      expect(events.last, isA<ErrorEvent>());
    });
  });
}
