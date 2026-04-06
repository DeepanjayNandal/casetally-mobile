// Import all event types (so factory can use them)
import 'events/started_event.dart';
import 'events/sources_count_event.dart';
import 'events/citations_event.dart';
import 'events/summary_chunk_event.dart';
import 'events/sources_event.dart';
import 'events/artifacts_event.dart';
import 'events/related_articles_event.dart';
import 'events/done_event.dart';
import 'events/error_event.dart';
import 'events/unknown_event.dart';

// Export all event types (so consumers can import just search_event.dart)
export 'events/started_event.dart';
export 'events/sources_count_event.dart';
export 'events/citations_event.dart';
export 'events/summary_chunk_event.dart';
export 'events/sources_event.dart';
export 'events/artifacts_event.dart';
export 'events/related_articles_event.dart';
export 'events/done_event.dart';
export 'events/error_event.dart';
export 'events/unknown_event.dart';

/// Base class for all WebSocket search events
/// ... rest of file unchanged
/// Base class for all WebSocket search events
///
/// **Design Principles:**
/// - Every event MUST have requestId (ties to specific query)
/// - groupId is optional (for conversation threading)
/// - Factory pattern allows easy addition of new event types
/// - Unknown events don't crash the app (graceful degradation)
///
/// **Adding New Events:**
/// 1. Create new event class extending SearchEvent
/// 2. Add case to factory switch statement
/// 3. That's it - architecture handles the rest
abstract class SearchEvent {
  /// Unique identifier for this specific query/request
  final String requestId;

  /// Optional conversation thread identifier
  /// Used for multi-turn context (e.g., "What about X?" after "Tell me about Y")
  final String? groupId;

  const SearchEvent({
    required this.requestId,
    this.groupId,
  });

  /// Parse JSON into typed event
  ///
  /// **Error Handling:**
  /// - Missing 'type' field → returns ErrorEvent
  /// - Unknown type → returns UnknownEvent (doesn't crash)
  /// - Malformed JSON → returns ErrorEvent with details
  ///
  /// **Example JSON:**
  /// ```json
  /// {
  ///   "type": "started",
  ///   "requestId": "abc123",
  ///   "groupId": "conversation-456",
  ///   "query": "What are Miranda rights?"
  /// }
  /// ```
  factory SearchEvent.fromJson(Map<String, dynamic> json) {
    try {
      // Extract type field
      final type = json['type'];
      if (type == null || type is! String) {
        return ErrorEvent(
          requestId: json['requestId'] as String? ?? 'unknown',
          groupId: json['groupId'] as String?,
          message: 'Missing or invalid "type" field in event',
          errorCode: 'INVALID_EVENT_TYPE',
        );
      }

      // Extract common fields
      final requestId = json['requestId'] as String?;
      if (requestId == null || requestId.isEmpty) {
        return ErrorEvent(
          requestId: 'unknown',
          groupId: json['groupId'] as String?,
          message: 'Missing required "requestId" field',
          errorCode: 'MISSING_REQUEST_ID',
        );
      }

      final groupId = json['groupId'] as String?;

      // Route to specific event type
      switch (type) {
        case 'started':
          return StartedEvent.fromJson(json, requestId, groupId);

        case 'sources_count':
          return SourcesCountEvent.fromJson(json, requestId, groupId);

        case 'citations':
          return CitationsEvent.fromJson(json, requestId, groupId);

        case 'summary_chunk':
          return SummaryChunkEvent.fromJson(json, requestId, groupId);

        case 'sources':
          return SourcesEvent.fromJson(json, requestId, groupId);

        case 'artifacts':
          return ArtifactsEvent.fromJson(json, requestId, groupId);

        case 'related_articles':
          return RelatedArticlesEvent.fromJson(json, requestId, groupId);

        case 'done':
          return DoneEvent.fromJson(json, requestId, groupId);

        case 'error':
          return ErrorEvent.fromJson(json, requestId, groupId);

        default:
          // Unknown event type - don't crash, just log and continue
          return UnknownEvent(
            requestId: requestId,
            groupId: groupId,
            eventType: type,
            rawJson: json,
          );
      }
    } catch (e, stackTrace) {
      // Parsing failed catastrophically
      return ErrorEvent(
        requestId: json['requestId'] as String? ?? 'unknown',
        groupId: json['groupId'] as String?,
        message: 'Failed to parse event: $e',
        errorCode: 'PARSE_ERROR',
        stackTrace: stackTrace.toString(),
      );
    }
  }
}
