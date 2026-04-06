/// Types of nodes in U.S. Code hierarchy
/// Concept: Enum for type safety - prevents typos and invalid states
/// Each title may have different combinations of these levels
///
/// Examples:
/// - Title 18: Part → Chapter → Section
/// - Title 26: Subtitle → Chapter → Subchapter → Section
/// - Title 42: Chapter → Subchapter → Part → Section
enum HierarchyNodeType {
  part('Part'),
  subtitle('Subtitle'),
  chapter('Chapter'),
  subchapter('Subchapter'),
  section('Section');

  final String displayName;
  const HierarchyNodeType(this.displayName);

  /// Parse from string (for JSON deserialization)
  /// Concept: Case-insensitive matching with fallback
  /// Default to section if unknown type received from backend
  static HierarchyNodeType fromString(String value) {
    return HierarchyNodeType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => HierarchyNodeType.section,
    );
  }

  /// Check if this node type contains actual legal text
  /// Concept: Business logic - only sections have content
  bool get isLeafNode => this == HierarchyNodeType.section;
}

/// Recursive node representing any level in U.S. Code hierarchy
/// Concept: Tree data structure - node can contain children nodes
///
/// **Why Recursive?**
/// Different titles have inconsistent hierarchy depths (3-6 levels)
/// This single class handles ALL levels by referencing itself
///
/// **Example Tree:**
/// Title 18
///   ├─ Part I (HierarchyNode)
///   │   ├─ Chapter 1 (HierarchyNode)
///   │   │   ├─ §1 (HierarchyNode with content)
///   │   │   └─ §2 (HierarchyNode with content)
///   │   └─ Chapter 2 (HierarchyNode)
///   └─ Part II (HierarchyNode)
class UsCodeHierarchyNode {
  /// Unique identifier (for routing and caching)
  /// Example: "18-part1-ch1-s241"
  /// Concept: Composite key - includes all parent IDs for uniqueness
  final String id;

  /// Node type (part, chapter, section, etc.)
  /// Concept: Tagged union - type determines available fields
  final HierarchyNodeType type;

  /// Display label
  /// Examples: "Part I", "Chapter 13", "§242"
  /// Concept: Formatted string ready for UI display
  final String label;

  /// Full name/heading (optional)
  /// Example: "Deprivation of rights under color of law"
  /// Concept: Nullable - not all nodes have descriptive names
  final String? name;

  /// Legal text content (only for sections)
  /// Concept: Leaf nodes contain data, intermediate nodes don't
  /// null for non-section nodes (parts, chapters, etc.)
  final String? content;

  /// Child nodes (recursive)
  /// Concept: Self-referential structure - enables infinite depth
  /// Empty list = leaf node OR not yet loaded (lazy loading)
  final List<UsCodeHierarchyNode> children;

  /// Metadata: Last update timestamp (optional)
  /// Concept: Audit trail - track when section text changed
  /// Useful for cache invalidation and "Updated X days ago" UI
  final DateTime? lastUpdated;

  /// Immutable constructor
  /// Concept: const for compile-time optimization when possible
  const UsCodeHierarchyNode({
    required this.id,
    required this.type,
    required this.label,
    this.name,
    this.content,
    this.children = const [],
    this.lastUpdated,
  });

  /// Parse from JSON
  /// Concept: Recursive deserialization - children are also HierarchyNodes
  factory UsCodeHierarchyNode.fromJson(Map<String, dynamic> json) {
    return UsCodeHierarchyNode(
      id: json['id'] as String,
      type: HierarchyNodeType.fromString(json['type'] as String),
      label: json['label'] as String,
      name: json['name'] as String?,
      content: json['content'] as String?,
      // Recursive call - parse children array
      children: (json['children'] as List<dynamic>?)
              ?.map((child) =>
                  UsCodeHierarchyNode.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  /// Convert to JSON
  /// Concept: Mirrors fromJson structure for bidirectional serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      'children': children.map((child) => child.toJson()).toList(),
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }

  /// Computed: Full display text
  /// Example: "Part I - General Provisions" or "§242 - Deprivation of rights"
  /// Concept: Combines label + name for complete heading
  String get fullLabel => name != null ? '$label - $name' : label;

  /// Computed: Check if node has children
  /// Concept: Encapsulation - hide implementation detail of empty list check
  bool get hasChildren => children.isNotEmpty;

  /// Computed: Check if this is a section (leaf node with content)
  /// Concept: Derived state - combination of type and content existence
  bool get isSection => type.isLeafNode && content != null;

  /// Computed: Count total sections in this subtree (recursive)
  /// Concept: Tree traversal - depth-first search counting leaf nodes
  /// Example: Chapter with 5 sections returns 5
  int get totalSections {
    if (isSection) return 1;

    int count = 0;
    for (final child in children) {
      count += child.totalSections; // Recursive call
    }
    return count;
  }

  /// Computed: Get depth level (0 = root)
  /// Concept: Not stored - calculated by traversing parent chain
  /// Note: Requires parent reference OR ID parsing (current: ID parsing)
  int get depth {
    // Simple heuristic: count dashes in ID
    // Example: "18-part1-ch1-s241" has 3 dashes = depth 3
    return id.split('-').length - 1;
  }

  /// Find a child node by ID (recursive search)
  /// Concept: Tree search algorithm - breadth-first or depth-first
  /// Returns null if not found
  UsCodeHierarchyNode? findChildById(String childId) {
    // Base case: this node matches
    if (id == childId) return this;

    // Recursive case: search children
    for (final child in children) {
      final found = child.findChildById(childId);
      if (found != null) return found;
    }

    // Not found in this subtree
    return null;
  }

  /// Create a copy with modified fields
  /// Concept: Immutability pattern - critical for state management
  /// Used when loading children lazily or updating content
  UsCodeHierarchyNode copyWith({
    String? id,
    HierarchyNodeType? type,
    String? label,
    String? name,
    String? content,
    List<UsCodeHierarchyNode>? children,
    DateTime? lastUpdated,
  }) {
    return UsCodeHierarchyNode(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      name: name ?? this.name,
      content: content ?? this.content,
      children: children ?? this.children,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'UsCodeHierarchyNode($fullLabel, type: ${type.name}, sections: $totalSections)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsCodeHierarchyNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
