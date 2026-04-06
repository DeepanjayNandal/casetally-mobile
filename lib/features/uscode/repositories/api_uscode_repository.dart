import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/uscode_title.dart';
import '../models/uscode_hierarchy_node.dart';
import 'uscode_repository.dart';

/// Real API implementation of UsCodeRepository
/// Connects to FastAPI backend
class APIUsCodeRepository implements UsCodeRepository {
  final String baseUrl;
  final http.Client client;

  APIUsCodeRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<List<UsCodeTitle>> getFeaturedTitles() async {
    try {
      print(
          '🌐 [API] Fetching featured titles from: $baseUrl/api/v1/uscode/titles');

      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/uscode/titles'),
      );

      print('📡 [API] Response status: ${response.statusCode}');
      print(
          '📄 [API] Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ [API] Parsed ${data.length} titles');
        return data
            .where((item) => item['is_featured'] == true)
            .map((item) => _parseTitleFromAPI(item))
            .toList();
      } else {
        throw UsCodeException(
          message: 'Failed to load featured titles: ${response.statusCode}',
          type: UsCodeExceptionType.server,
        );
      }
    } catch (e) {
      print('❌ [API] Error fetching featured titles: $e');
      print('❌ [API] Error type: ${e.runtimeType}');
      throw UsCodeException(
        message: 'Network error: $e',
        type: UsCodeExceptionType.network,
      );
    }
  }

  @override
  Future<List<UsCodeTitle>> getAllTitles() async {
    try {
      print('🌐 [API] Fetching all titles from: $baseUrl/api/v1/uscode/titles');

      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/uscode/titles'),
      );

      print('📡 [API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ [API] Parsed ${data.length} titles');
        return data.map((item) => _parseTitleFromAPI(item)).toList();
      } else {
        throw UsCodeException(
          message: 'Failed to load titles: ${response.statusCode}',
          type: UsCodeExceptionType.server,
        );
      }
    } catch (e) {
      print('❌ [API] Error fetching all titles: $e');
      throw UsCodeException(
        message: 'Network error: $e',
        type: UsCodeExceptionType.network,
      );
    }
  }

  @override
  Future<UsCodeTitle> getTitleById(int titleNumber) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/uscode/titles/$titleNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTitleWithSections(data);
      } else if (response.statusCode == 404) {
        throw UsCodeException(
          message: 'Title $titleNumber not found',
          type: UsCodeExceptionType.notFound,
        );
      } else {
        throw UsCodeException(
          message: 'Failed to load title: ${response.statusCode}',
          type: UsCodeExceptionType.server,
        );
      }
    } catch (e) {
      if (e is UsCodeException) rethrow;
      throw UsCodeException(
        message: 'Network error: $e',
        type: UsCodeExceptionType.network,
      );
    }
  }

  @override
  Future<UsCodeHierarchyNode> getSectionById(String sectionId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/uscode/sections/$sectionId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UsCodeHierarchyNode.fromJson(data);
      } else if (response.statusCode == 404) {
        throw UsCodeException(
          message: 'Section $sectionId not found',
          type: UsCodeExceptionType.notFound,
        );
      } else {
        throw UsCodeException(
          message: 'Failed to load section: ${response.statusCode}',
          type: UsCodeExceptionType.server,
        );
      }
    } catch (e) {
      if (e is UsCodeException) rethrow;
      throw UsCodeException(
        message: 'Network error: $e',
        type: UsCodeExceptionType.network,
      );
    }
  }

  @override
  Future<List<UsCodeHierarchyNode>> searchSections(
    String query, {
    int? titleNumber,
  }) async {
    // Not implemented yet - will add later
    throw UnimplementedError('Search not yet implemented');
  }

  /// Parse basic title info from API (without sections)
  UsCodeTitle _parseTitleFromAPI(Map<String, dynamic> json) {
    return UsCodeTitle(
      number: json['number'] as int,
      name: json['name'] as String,
      summary: json['summary'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      children: const [],
    );
  }

  /// Parse title with full sections array
  UsCodeTitle _parseTitleWithSections(Map<String, dynamic> json) {
    final List<dynamic> sectionsData = json['sections'] as List<dynamic>;

    final children = sectionsData.map((sectionJson) {
      return UsCodeHierarchyNode(
        id: sectionJson['id'] as String,
        type: HierarchyNodeType.section,
        label: sectionJson['label'] as String,
        name: sectionJson['name'] as String?,
        content: sectionJson['content'] as String?,
        children: const [],
        lastUpdated: null,
      );
    }).toList();

    return UsCodeTitle(
      number: json['number'] as int,
      name: json['name'] as String,
      summary: json['summary'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      children: children,
    );
  }

  @override
  bool isCached(int titleNumber) => false;

  @override
  void clearCache() {}
}
