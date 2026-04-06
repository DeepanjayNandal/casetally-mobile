import '../models/search_response.dart';
import '../models/search_event.dart';
import '../data/mock_responses.dart';
import 'search_repository.dart';

/// Mock implementation of SearchRepository
/// Uses static mock data with simulated network delay
/// Will be replaced with APISearchRepository when backend is ready
class MockSearchRepository implements SearchRepository {
  /// Simulate network delay (realistic API response time)
  final Duration delay;

  const MockSearchRepository({
    this.delay = const Duration(milliseconds: 1500),
  });

  @override
  Future<SearchResponse> search(String query) async {
    // Validate query
    if (query.trim().isEmpty) {
      throw const SearchException(
        message: 'Please enter a search query',
        type: SearchExceptionType.validation,
      );
    }

    // Simulate network delay
    await Future.delayed(delay);

    // Get mock response based on query
    try {
      return MockSearchResponses.getResponseForQuery(query);
    } catch (e) {
      throw SearchException(
        message: 'Failed to get search results: $e',
        type: SearchExceptionType.unknown,
      );
    }
  }

  @override
  Stream<SearchEvent> searchStream(String query, {String? groupId}) {
    throw UnimplementedError(
      'MockSearchRepository does not support streaming. '
      'Use WebSocketSearchRepository for streaming search.',
    );
  }

  @override
  bool isCached(String query) => false;

  @override
  void clearCache() {
    // No cache in mock implementation
  }
}
