import '../search_event.dart';

/// Event type not recognized by current client version
///
/// **Purpose:**
/// - Backend can add new event types without breaking Flutter
/// - Client gracefully ignores unknown events
/// - Logs event for debugging
/// - Prevents app crashes from schema evolution
///
/// **Example Scenario:**
/// Backend adds "code_snippet" event type in API v2
/// Flutter client v1 doesn't know about it yet
/// → Creates UnknownEvent, logs it, continues processing
/// → App doesn't crash, other events still work
///
/// **This Is Good Architecture:**
/// Allows backend and frontend to evolve independently
class UnknownEvent extends SearchEvent {
  /// The unrecognized event type string
  final String eventType;

  /// Raw JSON for debugging/logging
  final Map<String, dynamic> rawJson;

  const UnknownEvent({
    required super.requestId,
    super.groupId,
    required this.eventType,
    required this.rawJson,
  });

  @override
  String toString() => 'UnknownEvent(requestId: $requestId, '
      'type: "$eventType", json: $rawJson)';
}
