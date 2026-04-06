import 'uscode_hierarchy_node.dart';

/// U.S. Code Title model
/// Represents one of the 54 titles in the United States Code
/// Example: Title 18 - Crimes and Criminal Procedure
///
/// **Design Pattern:** Pure Dart data model (no Flutter dependencies)
/// Concept: Separation of concerns - models don't know about UI
/// This allows models to be used in backend, CLI tools, or any Dart environment
class UsCodeTitle {
  /// Title number (1-54)
  /// Concept: int for type safety and arithmetic operations
  final int number;

  /// Full title name
  /// Example: "Crimes and Criminal Procedure"
  final String name;

  /// Optional short description for preview cards
  /// Concept: Nullable field - not all titles need summaries
  final String? summary;

  /// Whether this title appears in home feed preview
  /// Concept: Backend-controlled feature flag
  /// Allows dynamic content curation without app updates
  final bool isFeatured;

  /// Hierarchical children (parts, chapters, sections)
  /// Concept: Composition pattern - title contains hierarchy nodes
  /// Empty list = no hierarchy loaded yet (lazy loading)
  final List<UsCodeHierarchyNode> children;

  /// Immutable constructor
  /// Concept: const constructors enable compile-time constants
  /// Improves performance and memory usage
  const UsCodeTitle({
    required this.number,
    required this.name,
    this.summary,
    this.isFeatured = false,
    this.children = const [],
  });

  /// Parse from JSON (backend API response)
  /// Concept: Factory constructor pattern for deserialization
  /// Handles null values gracefully with ?? operators
  factory UsCodeTitle.fromJson(Map<String, dynamic> json) {
    return UsCodeTitle(
      number: json['number'] as int,
      name: json['name'] as String,
      summary: json['summary'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      // Concept: Recursively parse children array
      // If 'children' key missing, default to empty list
      children: (json['children'] as List<dynamic>?)
              ?.map((child) =>
                  UsCodeHierarchyNode.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON (for logging/debugging)
  /// Concept: Bidirectional serialization
  /// toJson() mirrors fromJson() structure
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      if (summary != null) 'summary': summary,
      'is_featured': isFeatured,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  /// Computed property: Full display name
  /// Example: "Title 18 - Crimes and Criminal Procedure"
  /// Concept: Getter - calculated on-demand, not stored
  String get fullTitle => 'Title $number - $name';

  /// Computed property: Check if hierarchy loaded
  /// Concept: Business logic in model (not in UI)
  bool get hasChildren => children.isNotEmpty;

  /// Computed property: Count total sections (recursive)
  /// Concept: Traversal algorithm - visits all descendant nodes
  int get totalSections {
    int count = 0;
    for (final child in children) {
      if (child.type == HierarchyNodeType.section) {
        count++;
      }
      // Recursive call - count sections in child's descendants
      count += child.totalSections;
    }
    return count;
  }

  /// Create a copy with modified fields
  /// Concept: Immutability pattern - return new instance instead of mutating
  /// Used when updating state (e.g., after loading children from API)
  UsCodeTitle copyWith({
    int? number,
    String? name,
    String? summary,
    bool? isFeatured,
    List<UsCodeHierarchyNode>? children,
  }) {
    return UsCodeTitle(
      number: number ?? this.number,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      isFeatured: isFeatured ?? this.isFeatured,
      children: children ?? this.children,
    );
  }

  @override
  String toString() => 'UsCodeTitle($fullTitle, sections: $totalSections)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsCodeTitle &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}
