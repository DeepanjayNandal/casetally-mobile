import '../search_event.dart';

/// Incremental chunk of AI-generated summary text
///
/// **UI Response:**
/// - Append chunk to existing summary
/// - Creates typing/streaming effect
/// - Throttle UI updates (100ms buffer) for performance
///
/// **Perplexity Pattern:**
/// Text streams in word-by-word or sentence-by-sentence
///
/// **Performance Note:**
/// Backend may send many chunks rapidly - use throttling in provider
class SummaryChunkEvent extends SearchEvent {
  /// Text chunk to append
  final String chunk;

  /// Whether this is the final chunk (summary complete)
  ///
  /// **Why this matters:**
  /// - UI can show "complete" indicator
  /// - Stops waiting for more chunks
  /// - Can enable "copy summary" action
  final bool isComplete;

  const SummaryChunkEvent({
    required super.requestId,
    super.groupId,
    required this.chunk,
    this.isComplete = false,
  });

  /// Parse from WebSocket JSON
  ///
  /// **Expected Format:**
  /// ```json
  /// {
  ///   "type": "summary_chunk",
  ///   "requestId": "abc123",
  ///   "chunk": "Miranda rights are constitutional protections",
  ///   "isComplete": false
  /// }
  /// ```
  factory SummaryChunkEvent.fromJson(
    Map<String, dynamic> json,
    String requestId,
    String? groupId,
  ) {
    final chunk = json['chunk'];
    if (chunk == null || chunk is! String) {
      throw FormatException(
        'SummaryChunkEvent: missing or invalid "chunk" field',
      );
    }

    final isComplete = json['isComplete'] as bool? ?? false;

    return SummaryChunkEvent(
      requestId: requestId,
      groupId: groupId,
      chunk: chunk,
      isComplete: isComplete,
    );
  }

  @override
  String toString() => 'SummaryChunkEvent(requestId: $requestId, '
      'chunk: "${chunk.length} chars", isComplete: $isComplete)';
}
