/// AI-generated summary with confidence metrics
/// Supports markdown formatting (bold, bullets, etc.)
class AISummary {
  final String text;
  final double confidenceScore;
  final String modelUsed;
  final DateTime generatedAt;

  const AISummary({
    required this.text,
    required this.confidenceScore,
    required this.modelUsed,
    required this.generatedAt,
  });

  /// Parse from JSON with validation
  factory AISummary.fromJson(Map<String, dynamic> json) {
    // Validate text
    final text = json['text'];
    if (text == null || text is! String || text.isEmpty) {
      throw FormatException('AISummary: missing or invalid "text" field');
    }

    // Validate confidence_score
    final confidenceScore = json['confidence_score'];
    if (confidenceScore == null || confidenceScore is! num) {
      throw FormatException(
          'AISummary: missing or invalid "confidence_score" field');
    }
    final score = (confidenceScore as num).toDouble();
    if (score < 0.0 || score > 1.0) {
      throw FormatException(
          'AISummary: "confidence_score" must be between 0 and 1 (got $score)');
    }

    // Validate model_used
    final modelUsed = json['model_used'];
    if (modelUsed == null || modelUsed is! String || modelUsed.isEmpty) {
      throw FormatException('AISummary: missing or invalid "model_used" field');
    }

    // Validate generated_at
    final generatedAt = json['generated_at'];
    if (generatedAt == null || generatedAt is! String) {
      throw FormatException(
          'AISummary: missing or invalid "generated_at" field');
    }

    DateTime timestamp;
    try {
      timestamp = DateTime.parse(generatedAt);
    } catch (e) {
      throw FormatException(
          'AISummary: invalid "generated_at" timestamp format (expected ISO 8601)');
    }

    return AISummary(
      text: text,
      confidenceScore: score,
      modelUsed: modelUsed,
      generatedAt: timestamp,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence_score': confidenceScore,
      'model_used': modelUsed,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  /// Check if confidence is high enough to display
  bool get isHighConfidence => confidenceScore >= 0.8;

  /// Format confidence as percentage for UI
  String get confidencePercentage => '${(confidenceScore * 100).toInt()}%';
}
