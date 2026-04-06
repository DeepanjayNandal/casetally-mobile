import '../search_event.dart';

/// Error occurred during search processing
///
/// **UI Response:**
/// - Show error message to user
/// - Keep overlay open (graceful degradation)
/// - Show "Try Again" button
/// - Display any partial results already received
///
/// **Error Severity:**
/// Determined by whether partial results exist:
/// - Has citations/summary → Warning (partial success)
/// - No results yet → Error (complete failure)
class ErrorEvent extends SearchEvent {
  /// Human-readable error message
  final String message;

  /// Optional machine-readable error code
  ///
  /// **Examples:**
  /// - 'TIMEOUT' - Request took too long
  /// - 'INVALID_QUERY' - Query format invalid
  /// - 'RATE_LIMIT' - Too many requests
  /// - 'INTERNAL_ERROR' - Backend failure
  final String? errorCode;

  /// Optional stack trace (for debugging)
  /// Should NOT be shown to user in production
  final String? stackTrace;

  const ErrorEvent({
    required super.requestId,
    super.groupId,
    required this.message,
    this.errorCode,
    this.stackTrace,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "error",
  ///   "requestId": "abc123",
  ///   "message": "Failed to connect to legal database",
  ///   "errorCode": "DATABASE_UNAVAILABLE"
  /// }
  /// ```
  factory ErrorEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final message = json['message'] as String?;
    if (message == null || message.isEmpty) {
      // Error event without message - use generic
      return ErrorEvent(
        requestId: requestId,
        groupId: groupId,
        message: 'An unknown error occurred',
        errorCode: json['errorCode'] as String?,
      );
    }

    return ErrorEvent(
      requestId: requestId,
      groupId: groupId,
      message: message,
      errorCode: json['errorCode'] as String?,
      stackTrace: json['stackTrace'] as String?,
    );
  }

  /// Whether this is a timeout error
  bool get isTimeout =>
      errorCode?.toUpperCase() == 'TIMEOUT' ||
      message.toLowerCase().contains('timeout');

  /// Whether this is a network error
  bool get isNetworkError =>
      errorCode?.toUpperCase() == 'NETWORK_ERROR' ||
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection');

  @override
  String toString() => 'ErrorEvent(requestId: $requestId, '
      'code: $errorCode, message: "$message")';
}
