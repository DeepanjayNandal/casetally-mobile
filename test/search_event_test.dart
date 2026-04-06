import 'package:flutter_test/flutter_test.dart';
import 'package:casetally/features/search/models/search_event.dart';

void main() {
  group('SearchEvent Parsing', () {
    test('StartedEvent parses correctly', () {
      final json = {
        'type': 'started',
        'requestId': 'test-123',
        'groupId': 'group-456',
        'query': 'What are Miranda rights?',
      };

      final event = SearchEvent.fromJson(json);

      expect(event, isA<StartedEvent>());
      expect(event.requestId, 'test-123');
      expect(event.groupId, 'group-456');
      expect((event as StartedEvent).query, 'What are Miranda rights?');
    });

    test('SourcesCountEvent parses correctly', () {
      final json = {
        'type': 'sources_count',
        'requestId': 'test-123',
        'count': 5,
      };

      final event = SearchEvent.fromJson(json);

      expect(event, isA<SourcesCountEvent>());
      expect((event as SourcesCountEvent).count, 5);
    });

    test('UnknownEvent handles future event types', () {
      final json = {
        'type': 'future_feature_v2',
        'requestId': 'test-123',
        'someNewField': 'data',
      };

      final event = SearchEvent.fromJson(json);

      expect(event, isA<UnknownEvent>());
      expect((event as UnknownEvent).eventType, 'future_feature_v2');
    });

    test('ErrorEvent handles missing type', () {
      final json = {
        'requestId': 'test-123',
        // Missing 'type' field
      };

      final event = SearchEvent.fromJson(json);

      expect(event, isA<ErrorEvent>());
      expect((event as ErrorEvent).message, contains('type'));
    });

    test('SummaryChunkEvent with completion flag', () {
      final json = {
        'type': 'summary_chunk',
        'requestId': 'test-123',
        'chunk': 'Miranda rights are...',
        'isComplete': true,
      };

      final event = SearchEvent.fromJson(json);

      expect(event, isA<SummaryChunkEvent>());
      expect((event as SummaryChunkEvent).chunk, 'Miranda rights are...');
      expect(event.isComplete, true);
    });
  });
}
