import '../models/uscode_title.dart';
import '../models/uscode_hierarchy_node.dart';
import '../data/mock_uscode_data.dart';
import 'uscode_repository.dart';

/// Mock implementation of UsCodeRepository
/// Concept: Test double pattern - simulates real API behavior
///
/// **Purpose:**
/// 1. Frontend development without backend dependency
/// 2. Consistent test data for UI screenshots
/// 3. Network delay simulation for realistic UX testing
/// 4. Easy swap to real API (just change provider)
///
/// **Pattern:** Implements interface, delegates to static data class
/// Similar to MockSearchRepository in search feature
class MockUsCodeRepository implements UsCodeRepository {
  /// Simulated network delay (realistic API response time)
  /// Concept: Configurable delay for different test scenarios
  ///
  /// Examples:
  /// - const Duration.zero - instant (screenshot mode)
  /// - const Duration(milliseconds: 500) - fast network
  /// - const Duration(milliseconds: 1500) - typical network
  /// - const Duration(seconds: 3) - slow network testing
  final Duration delay;

  /// Constructor with default 1.5s delay
  /// Concept: const constructor - compile-time optimization
  const MockUsCodeRepository({
    this.delay = Duration.zero,
  });

  @override
  Future<List<UsCodeTitle>> getFeaturedTitles() async {
    // Simulate network delay
    // Concept: await Future.delayed - pauses execution without blocking thread
    await Future.delayed(delay);

    // Return hardcoded featured titles
    // Concept: Deterministic data - same result every time (good for testing)
    return MockUsCodeData.featuredTitles;
  }

  @override
  Future<List<UsCodeTitle>> getAllTitles() async {
    // Simulate network delay
    await Future.delayed(delay);

    // Return all titles (currently 7 sample titles)
    // In production: 54 titles from backend
    return MockUsCodeData.allTitles;
  }

  @override
  Future<UsCodeTitle> getTitleById(int titleNumber) async {
    // Validate input
    // Concept: Fail-fast - catch errors early with clear messages
    if (titleNumber < 1 || titleNumber > 54) {
      throw const UsCodeException(
        message: 'Title number must be between 1 and 54',
        type: UsCodeExceptionType.validation,
      );
    }

    // Simulate network delay
    await Future.delayed(delay);

    // Find title in mock data
    final title = MockUsCodeData.findTitleByNumber(titleNumber);

    // Handle not found case
    // Concept: Throw typed exception - UI can show appropriate error
    if (title == null) {
      throw UsCodeException(
        message: 'Title $titleNumber not found',
        type: UsCodeExceptionType.notFound,
      );
    }

    return title;
  }

  @override
  Future<UsCodeHierarchyNode> getSectionById(String sectionId) async {
    // Validate input
    // Concept: Empty string check - prevent meaningless queries
    if (sectionId.trim().isEmpty) {
      throw const UsCodeException(
        message: 'Section ID cannot be empty',
        type: UsCodeExceptionType.validation,
      );
    }

    // Simulate network delay
    await Future.delayed(delay);

    // Search for section across all titles
    // Concept: Linear search - acceptable for small mock dataset
    // Real API would use database index
    final section = MockUsCodeData.findSectionById(sectionId);

    // Handle not found case
    if (section == null) {
      throw UsCodeException(
        message: 'Section "$sectionId" not found',
        type: UsCodeExceptionType.notFound,
      );
    }

    // Verify it's actually a section (not chapter/part)
    // Concept: Type validation - ensure correct data returned
    if (!section.isSection) {
      throw UsCodeException(
        message: 'Node "$sectionId" is not a section',
        type: UsCodeExceptionType.validation,
      );
    }

    return section;
  }

  @override
  Future<List<UsCodeHierarchyNode>> searchSections(
    String query, {
    int? titleNumber,
  }) async {
    // Validate query
    if (query.trim().isEmpty) {
      throw const UsCodeException(
        message: 'Search query cannot be empty',
        type: UsCodeExceptionType.validation,
      );
    }

    // Simulate network delay
    await Future.delayed(delay);

    // Simple mock search: find sections containing query text
    // Concept: Case-insensitive substring match
    // Real implementation would use full-text search with ranking
    final results = <UsCodeHierarchyNode>[];
    final lowerQuery = query.toLowerCase();

    // Filter by title if specified
    final titlesToSearch = titleNumber != null
        ? [MockUsCodeData.findTitleByNumber(titleNumber)]
            .whereType<UsCodeTitle>()
        : MockUsCodeData.allTitles;

    // Search through all sections
    // Concept: Recursive tree traversal - visit all nodes
    for (final title in titlesToSearch) {
      _searchInNodes(title.children, lowerQuery, results);
    }

    return results;
  }

  /// Recursive helper to search through hierarchy nodes
  /// Concept: Depth-first search - explores each branch fully
  void _searchInNodes(
    List<UsCodeHierarchyNode> nodes,
    String query,
    List<UsCodeHierarchyNode> results,
  ) {
    for (final node in nodes) {
      // Check if this node is a section with matching content
      if (node.isSection) {
        final content = node.content?.toLowerCase() ?? '';
        final name = node.name?.toLowerCase() ?? '';

        // Match in content OR section name
        if (content.contains(query) || name.contains(query)) {
          results.add(node);
        }
      }

      // Recursively search children
      if (node.hasChildren) {
        _searchInNodes(node.children, query, results);
      }
    }
  }

  @override
  bool isCached(int titleNumber) {
    // Mock repository doesn't use cache
    // Concept: No-op implementation - satisfies interface contract
    return false;
  }

  @override
  void clearCache() {
    // Mock repository doesn't use cache
    // No-op implementation
  }
}
