/// Credibility levels for sources
enum SourceCredibility {
  primary('Primary Source'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String displayName;
  const SourceCredibility(this.displayName);

  /// Parse from string
  static SourceCredibility fromString(String value) {
    return SourceCredibility.values.firstWhere(
      (cred) => cred.name == value.toLowerCase(),
      orElse: () => SourceCredibility.medium,
    );
  }
}

/// Source types
enum SourceType {
  legalDatabase('Legal Database'),
  primarySource('Primary Source'),
  government('Government'),
  academic('Academic'),
  news('News'),
  other('Other');

  final String displayName;
  const SourceType(this.displayName);

  /// Parse from string
  static SourceType fromString(String value) {
    return SourceType.values.firstWhere(
      (type) => type.name == value.toLowerCase().replaceAll('_', ''),
      orElse: () => SourceType.other,
    );
  }
}

/// External source citation
class Source {
  final String name;
  final String url;
  final SourceType type;
  final SourceCredibility credibility;

  const Source({
    required this.name,
    required this.url,
    required this.type,
    required this.credibility,
  });

  /// Parse from JSON with validation
  factory Source.fromJson(Map<String, dynamic> json) {
    // Validate name
    final name = json['name'];
    if (name == null || name is! String || name.isEmpty) {
      throw FormatException('Source: missing or invalid "name" field');
    }

    // Validate url
    final url = json['url'];
    if (url == null || url is! String || url.isEmpty) {
      throw FormatException('Source: missing or invalid "url" field');
    }

    // Validate type
    final type = json['type'];
    if (type == null || type is! String) {
      throw FormatException('Source: missing or invalid "type" field');
    }

    // Validate credibility
    final credibility = json['credibility'];
    if (credibility == null || credibility is! String) {
      throw FormatException('Source: missing or invalid "credibility" field');
    }

    return Source(
      name: name,
      url: url,
      type: SourceType.fromString(type),
      credibility: SourceCredibility.fromString(credibility),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type.name,
      'credibility': credibility.name,
    };
  }

  /// Check if source is trustworthy
  bool get isTrustworthy =>
      credibility == SourceCredibility.primary ||
      credibility == SourceCredibility.high;

  /// Get icon based on credibility
  String get credibilityIcon {
    switch (credibility) {
      case SourceCredibility.primary:
        return 'â­';
      case SourceCredibility.high:
        return 'âœ“';
      case SourceCredibility.medium:
        return 'â—‹';
      case SourceCredibility.low:
        return 'âš ';
    }
  }
}
