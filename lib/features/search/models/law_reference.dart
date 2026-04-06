/// Types of legal references
enum LawType {
  caseLaw('Case Law'),
  constitutional('Constitutional'),
  statute('Statute'),
  regulation('Regulation'),
  code('Code');

  final String displayName;
  const LawType(this.displayName);

  /// Parse from string (for JSON deserialization)
  static LawType fromString(String value) {
    return LawType.values.firstWhere(
      (type) => type.name == value.toLowerCase().replaceAll(' ', '_'),
      orElse: () => LawType.statute,
    );
  }
}

/// Legal citation with metadata
class LawReference {
  final String id;
  final String title;
  final String citation;
  final String summary;
  final String jurisdiction;
  final LawType type;
  final double relevanceScore;

  const LawReference({
    required this.id,
    required this.title,
    required this.citation,
    required this.summary,
    required this.jurisdiction,
    required this.type,
    required this.relevanceScore,
  });

  /// Parse from JSON with validation
  factory LawReference.fromJson(Map<String, dynamic> json) {
    // Validate id
    final id = json['id'];
    if (id == null || id is! String || id.isEmpty) {
      throw FormatException('LawReference: missing or invalid "id" field');
    }

    // Validate title
    final title = json['title'];
    if (title == null || title is! String || title.isEmpty) {
      throw FormatException('LawReference: missing or invalid "title" field');
    }

    // Validate citation
    final citation = json['citation'];
    if (citation == null || citation is! String || citation.isEmpty) {
      throw FormatException(
          'LawReference: missing or invalid "citation" field');
    }

    // Validate summary
    final summary = json['summary'];
    if (summary == null || summary is! String || summary.isEmpty) {
      throw FormatException('LawReference: missing or invalid "summary" field');
    }

    // Validate jurisdiction
    final jurisdiction = json['jurisdiction'];
    if (jurisdiction == null ||
        jurisdiction is! String ||
        jurisdiction.isEmpty) {
      throw FormatException(
          'LawReference: missing or invalid "jurisdiction" field');
    }

    // Validate type
    final type = json['type'];
    if (type == null || type is! String) {
      throw FormatException('LawReference: missing or invalid "type" field');
    }

    // Validate relevance_score
    final relevanceScore = json['relevance_score'];
    if (relevanceScore == null || relevanceScore is! num) {
      throw FormatException(
          'LawReference: missing or invalid "relevance_score" field');
    }
    final score = (relevanceScore as num).toDouble();
    if (score < 0.0 || score > 1.0) {
      throw FormatException(
          'LawReference: "relevance_score" must be between 0 and 1 (got $score)');
    }

    return LawReference(
      id: id,
      title: title,
      citation: citation,
      summary: summary,
      jurisdiction: jurisdiction,
      type: LawType.fromString(type),
      relevanceScore: score,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'citation': citation,
      'summary': summary,
      'jurisdiction': jurisdiction,
      'type': type.name,
      'relevance_score': relevanceScore,
    };
  }

  /// Check if highly relevant
  bool get isHighlyRelevant => relevanceScore >= 0.9;

  /// Get emoji icon based on type
  String get typeEmoji {
    switch (type) {
      case LawType.caseLaw:
        return 'âš–ï¸';
      case LawType.constitutional:
        return 'ðŸ“œ';
      case LawType.statute:
        return 'ðŸ“‹';
      case LawType.regulation:
        return 'ðŸ“‘';
      case LawType.code:
        return 'ðŸ“–';
    }
  }
}
