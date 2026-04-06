import '../models/uscode_title.dart';
import '../models/uscode_hierarchy_node.dart';

/// Abstract interface for U.S. Code data sources
/// Concept: Repository Pattern - abstracts data source implementation
/// UI code doesn't know if data comes from: Mock, API, Database, or Cache
///
/// **Benefits:**
/// 1. Swap implementations without changing UI code
/// 2. Easy testing - inject mock repository
/// 3. Single Responsibility - repository only handles data fetching
///
/// **Pattern Origin:** Domain-Driven Design (DDD)
/// Separates domain logic from data access logic
abstract class UsCodeRepository {
  /// Get featured titles for home preview (3-5 titles)
  /// Concept: Curated content - backend controls what appears on home
  ///
  /// Returns: List of titles with `isFeatured = true`
  /// Throws: UsCodeException on error
  ///
  /// **Example Use:**
  /// ```dart
  /// final featured = await repository.getFeaturedTitles();
  /// // Display in home preview section
  /// ```
  Future<List<UsCodeTitle>> getFeaturedTitles();

  /// Get all 54 U.S. Code titles
  /// Concept: Full catalog for "View All" screen
  ///
  /// Returns: All titles (1-54), may have shallow or empty children
  /// Throws: UsCodeException on error
  ///
  /// **Example Use:**
  /// ```dart
  /// final allTitles = await repository.getAllTitles();
  /// // Display in title list view
  /// ```
  Future<List<UsCodeTitle>> getAllTitles();

  /// Get single title with full hierarchy tree
  /// Concept: Lazy loading - only fetch full tree when user taps title
  ///
  /// Parameters:
  ///   - titleNumber: 1-54
  ///
  /// Returns: Title with complete children hierarchy (all parts/chapters/sections)
  /// Throws: UsCodeException if title not found or load fails
  ///
  /// **Example Use:**
  /// ```dart
  /// final title18 = await repository.getTitleById(18);
  /// // Display hierarchy drill-down view
  /// ```
  Future<UsCodeTitle> getTitleById(int titleNumber);

  /// Get single section content by ID
  /// Concept: Direct access - for deep linking or search results
  ///
  /// Parameters:
  ///   - sectionId: Composite ID like "18-part1-ch1-s241"
  ///
  /// Returns: Section node with full text content
  /// Throws: UsCodeException if section not found
  ///
  /// **Example Use:**
  /// ```dart
  /// final section = await repository.getSectionById('18-part1-ch1-s241');
  /// // Display in section viewer
  /// ```
  Future<UsCodeHierarchyNode> getSectionById(String sectionId);

  /// Search sections by text content (optional - Phase 3)
  /// Concept: Full-text search across all legal text
  ///
  /// Parameters:
  ///   - query: Search terms
  ///   - titleNumber: Optional - limit to specific title
  ///
  /// Returns: List of matching sections with relevance scores
  /// Throws: UsCodeException on error
  ///
  /// **Example Use:**
  /// ```dart
  /// final results = await repository.searchSections('miranda rights');
  /// // Display search results
  /// ```
  Future<List<UsCodeHierarchyNode>> searchSections(
    String query, {
    int? titleNumber,
  }) async {
    // Default implementation - override in subclasses
    throw UnimplementedError('Search not yet implemented');
  }

  /// Check if data is cached locally (optional)
  /// Concept: Offline-first architecture - serve cached data when available
  ///
  /// Returns: true if data exists in local cache
  bool isCached(int titleNumber) => false;

  /// Clear local cache (optional)
  /// Concept: Cache invalidation - force fresh data fetch
  void clearCache() {}
}

/// Custom exception for U.S. Code errors
/// Concept: Typed exceptions - easier error handling than generic Exception
///
/// **Pattern:** Similar to SearchException in search_repository.dart
class UsCodeException implements Exception {
  final String message;
  final UsCodeExceptionType type;

  const UsCodeException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => message;
}

/// Types of U.S. Code errors
/// Concept: Enum for error categorization
/// Allows UI to show appropriate error messages per type
///
/// **Example:**
/// - network → "No internet connection"
/// - notFound → "Title not found"
/// - server → "Server error, try again later"
enum UsCodeExceptionType {
  /// No internet connection
  network,

  /// Request took too long
  timeout,

  /// API returned error (500, 503, etc.)
  server,

  /// Title or section doesn't exist
  notFound,

  /// Invalid input (e.g., title number > 54)
  validation,

  /// Unknown error
  unknown,
}
