import '../search_event.dart';

/// Search stream has completed successfully
///
/// **UI Response:**
/// - Stop showing loading indicator
/// - Mark search as complete
/// - Enable "share results" actions
/// - Close WebSocket connection
///
/// **Timing:**
/// Always the last event in a successful stream
class DoneEvent extends SearchEvent {
  /// Total processing time in milliseconds
  ///
  /// **Use Cases:**
  /// - Analytics
  /// - Performance monitoring
  /// - Can display "Completed in 2.3s" to user
  final int? processingTimeMs;

  const DoneEvent({
    required super.requestId,
    super.groupId,
    this.processingTimeMs,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "done",
  ///   "requestId": "abc123",
  ///   "processingTimeMs": 2341
  /// }
  /// ```
  factory DoneEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final processingTimeMs = json['processingTimeMs'] as int?;

    return DoneEvent(
      requestId: requestId,
      groupId: groupId,
      processingTimeMs: processingTimeMs,
    );
  }

  /// Processing time as Duration (if available)
  Duration? get processingTime => processingTimeMs != null
      ? Duration(milliseconds: processingTimeMs!)
      : null;

  @override
  String toString() => 'DoneEvent(requestId: $requestId, '
      'time: ${processingTimeMs}ms)';
}
