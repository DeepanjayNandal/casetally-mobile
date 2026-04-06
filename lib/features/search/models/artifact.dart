/// Types of primary legal documents (artifacts)
///
/// **Purpose:** Categorize artifacts for icon/color display
/// **Extensibility:** Add new types as backend evolves
enum ArtifactType {
  courtCase('Court Case'),
  statute('Statute'),
  regulation('Regulation'),
  legalMemo('Legal Memo'),
  other('Document');

  final String displayName;
  const ArtifactType(this.displayName);

  /// Parse from string (case-insensitive, handles snake_case)
  ///
  /// **Defensive:** Returns `other` for unknown types
  static ArtifactType fromString(String value) {
    final normalized = value.toLowerCase().replaceAll('_', '');
    return ArtifactType.values.firstWhere(
      (type) => type.name.toLowerCase() == normalized,
      orElse: () => ArtifactType.other,
    );
  }
}

/// Primary legal document (PDF) returned during search
///
/// **Design Principles:**
/// - REQUIRED fields: title, type, resourceUri (without these, artifact is invalid)
/// - OPTIONAL fields: Use nullable types for fields backend may not always provide
/// - Extensible: Add new fields as backend schema evolves
///
/// **Usage:**
/// Artifacts are streamed via WebSocket during search.
/// Unlike sources (reference websites), artifacts are actual legal documents
/// (court cases, statutes, regulations) that can be viewed as PDFs.
///
/// **Future Considerations:**
/// - Download progress tracking for remote PDFs
/// - Local caching of frequently accessed documents
/// - Offline access support
class Artifact {
  // ==================== REQUIRED FIELDS ====================

  /// Document title (e.g., "Miranda v. Arizona")
  /// **Required:** Must be non-empty
  final String title;

  /// Document type for categorization and icon display
  /// **Required:** Determines icon color in UI
  final ArtifactType type;

  /// URL or file path to access the PDF
  /// **Required:** Used to open document in QuickLook
  /// Can be remote URL (https://...) or local file path
  final String resourceUri;

  // ==================== OPTIONAL FIELDS ====================
  // These may not be provided by backend in all cases.
  // UI should handle null gracefully.

  /// Publishing authority (e.g., "Supreme Court", "Congress")
  /// **Optional:** Displayed in metadata line if available
  final String? publisher;

  /// Document date (decision date, enactment date, etc.)
  /// **Optional:** Formatted as "MMM d, yyyy" in UI
  final DateTime? date;

  /// Number of pages in the document
  /// **Optional:** Displayed as "XX pg" in metadata
  final int? pages;

  /// File size in bytes
  /// **Optional:** Could be displayed if pages is null
  /// TODO: Backend may add this field - implement display when available
  final int? fileSizeBytes;

  // ==================== CONSTRUCTOR ====================

  const Artifact({
    required this.title,
    required this.type,
    required this.resourceUri,
    this.publisher,
    this.date,
    this.pages,
    this.fileSizeBytes,
  });

  // ==================== JSON PARSING ====================

  /// Parse from WebSocket JSON with validation
  ///
  /// **Required Fields:**
  /// - title: String (non-empty)
  /// - type: String (maps to ArtifactType)
  /// - resource_uri: String (non-empty)
  ///
  /// **Optional Fields:**
  /// - publisher: String (nullable)
  /// - date: String in ISO 8601 format (nullable)
  /// - pages: int (nullable)
  /// - file_size_bytes: int (nullable)
  ///
  /// **Error Handling:**
  /// Throws FormatException if required fields are missing/invalid.
  /// Optional fields that fail to parse are silently set to null.
  ///
  /// **Example JSON:**
  /// ```json
  /// {
  ///   "title": "Miranda v. Arizona",
  ///   "type": "court_case",
  ///   "resource_uri": "https://example.com/miranda.pdf",
  ///   "publisher": "Supreme Court",
  ///   "date": "1966-06-13",
  ///   "pages": 23
  /// }
  /// ```
  factory Artifact.fromJson(Map<String, dynamic> json) {
    // Validate title (REQUIRED)
    final title = json['title'];
    if (title == null || title is! String || title.isEmpty) {
      throw FormatException('Artifact: missing or invalid "title" field');
    }

    // Validate type (REQUIRED)
    final type = json['type'];
    if (type == null || type is! String) {
      throw FormatException('Artifact: missing or invalid "type" field');
    }

    // Validate resourceUri (REQUIRED)
    // Backend may use snake_case (resource_uri) or camelCase (resourceUri)
    final resourceUri = json['resource_uri'] ?? json['resourceUri'];
    if (resourceUri == null || resourceUri is! String || resourceUri.isEmpty) {
      throw FormatException(
        'Artifact: missing or invalid "resource_uri" field',
      );
    }

    // Parse optional fields defensively
    String? publisher;
    if (json['publisher'] is String && json['publisher'].isNotEmpty) {
      publisher = json['publisher'];
    }

    DateTime? date;
    if (json['date'] is String) {
      try {
        date = DateTime.parse(json['date']);
      } catch (_) {
        // Invalid date format - silently ignore
        // TODO: Log warning when proper logging is integrated
      }
    }

    int? pages;
    if (json['pages'] is int) {
      pages = json['pages'];
    } else if (json['pages'] is String) {
      pages = int.tryParse(json['pages']);
    }

    int? fileSizeBytes;
    final sizeField = json['file_size_bytes'] ?? json['fileSizeBytes'];
    if (sizeField is int) {
      fileSizeBytes = sizeField;
    } else if (sizeField is String) {
      fileSizeBytes = int.tryParse(sizeField);
    }

    return Artifact(
      title: title,
      type: ArtifactType.fromString(type),
      resourceUri: resourceUri,
      publisher: publisher,
      date: date,
      pages: pages,
      fileSizeBytes: fileSizeBytes,
    );
  }

  /// Convert to JSON for debugging/logging
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'resource_uri': resourceUri,
      if (publisher != null) 'publisher': publisher,
      if (date != null) 'date': date!.toIso8601String(),
      if (pages != null) 'pages': pages,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
    };
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Check if this is a remote URL (vs local file)
  bool get isRemote =>
      resourceUri.startsWith('http://') || resourceUri.startsWith('https://');

  /// Check if artifact has any metadata to display
  bool get hasMetadata => publisher != null || date != null || pages != null;

  @override
  String toString() => 'Artifact(title: "$title", type: ${type.name})';
}
