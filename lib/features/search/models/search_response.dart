import 'ai_summary.dart';
import 'law_reference.dart';
import 'related_article.dart';
import 'source.dart';

/// Top-level response from AI search API
/// Mirrors backend JSON structure exactly
class SearchResponse {
  final String query;
  final DateTime timestamp;
  final SearchResponseData response;
  final SearchMetadata metadata;

  const SearchResponse({
    required this.query,
    required this.timestamp,
    required this.response,
    required this.metadata,
  });

  /// Parse from JSON with validation
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    // Validate query
    final query = json['query'];
    if (query == null || query is! String || query.isEmpty) {
      throw FormatException('SearchResponse: missing or invalid "query" field');
    }

    // Validate timestamp
    final timestampStr = json['timestamp'];
    if (timestampStr == null || timestampStr is! String) {
      throw FormatException(
          'SearchResponse: missing or invalid "timestamp" field');
    }

    DateTime timestamp;
    try {
      timestamp = DateTime.parse(timestampStr);
    } catch (e) {
      throw FormatException(
          'SearchResponse: invalid "timestamp" format (expected ISO 8601)');
    }

    // Validate response object
    final response = json['response'];
    if (response == null || response is! Map<String, dynamic>) {
      throw FormatException(
          'SearchResponse: missing or invalid "response" field (expected object)');
    }

    // Validate metadata object
    final metadata = json['metadata'];
    if (metadata == null || metadata is! Map<String, dynamic>) {
      throw FormatException(
          'SearchResponse: missing or invalid "metadata" field (expected object)');
    }

    return SearchResponse(
      query: query,
      timestamp: timestamp,
      response: SearchResponseData.fromJson(response),
      metadata: SearchMetadata.fromJson(metadata),
    );
  }

  /// Convert to JSON (for logging/debugging)
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'response': response.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

/// The actual response content
class SearchResponseData {
  final AISummary aiSummary;
  final List<LawReference> relevantLaws;
  final List<RelatedArticle> relatedArticles;
  final List<Source> sources;

  const SearchResponseData({
    required this.aiSummary,
    required this.relevantLaws,
    required this.relatedArticles,
    required this.sources,
  });

  factory SearchResponseData.fromJson(Map<String, dynamic> json) {
    // Validate ai_summary
    final aiSummary = json['ai_summary'];
    if (aiSummary == null || aiSummary is! Map<String, dynamic>) {
      throw FormatException(
          'SearchResponseData: missing or invalid "ai_summary" field (expected object)');
    }

    // Validate relevant_laws
    final relevantLaws = json['relevant_laws'];
    if (relevantLaws == null || relevantLaws is! List) {
      throw FormatException(
          'SearchResponseData: missing or invalid "relevant_laws" field (expected array)');
    }

    // Validate related_articles
    final relatedArticles = json['related_articles'];
    if (relatedArticles == null || relatedArticles is! List) {
      throw FormatException(
          'SearchResponseData: missing or invalid "related_articles" field (expected array)');
    }

    // Validate sources
    final sources = json['sources'];
    if (sources == null || sources is! List) {
      throw FormatException(
          'SearchResponseData: missing or invalid "sources" field (expected array)');
    }

    return SearchResponseData(
      aiSummary: AISummary.fromJson(aiSummary),
      relevantLaws: relevantLaws.map((law) {
        if (law is! Map<String, dynamic>) {
          throw FormatException(
              'SearchResponseData: invalid law entry (expected object)');
        }
        return LawReference.fromJson(law);
      }).toList(),
      relatedArticles: relatedArticles.map((article) {
        if (article is! Map<String, dynamic>) {
          throw FormatException(
              'SearchResponseData: invalid article entry (expected object)');
        }
        return RelatedArticle.fromJson(article);
      }).toList(),
      sources: sources.map((source) {
        if (source is! Map<String, dynamic>) {
          throw FormatException(
              'SearchResponseData: invalid source entry (expected object)');
        }
        return Source.fromJson(source);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ai_summary': aiSummary.toJson(),
      'relevant_laws': relevantLaws.map((law) => law.toJson()).toList(),
      'related_articles':
          relatedArticles.map((article) => article.toJson()).toList(),
      'sources': sources.map((source) => source.toJson()).toList(),
    };
  }
}

/// Metadata about the API call
class SearchMetadata {
  final int processingTimeMs;
  final int tokensUsed;
  final bool cached;
  final String? userId;
  final String? sessionId;

  const SearchMetadata({
    required this.processingTimeMs,
    required this.tokensUsed,
    required this.cached,
    this.userId,
    this.sessionId,
  });

  factory SearchMetadata.fromJson(Map<String, dynamic> json) {
    // Validate processing_time_ms
    final processingTimeMs = json['processing_time_ms'];
    if (processingTimeMs == null ||
        processingTimeMs is! int ||
        processingTimeMs < 0) {
      throw FormatException(
          'SearchMetadata: missing or invalid "processing_time_ms" field (must be non-negative integer)');
    }

    // Validate tokens_used
    final tokensUsed = json['tokens_used'];
    if (tokensUsed == null || tokensUsed is! int || tokensUsed < 0) {
      throw FormatException(
          'SearchMetadata: missing or invalid "tokens_used" field (must be non-negative integer)');
    }

    // Validate cached
    final cached = json['cached'];
    if (cached == null || cached is! bool) {
      throw FormatException(
          'SearchMetadata: missing or invalid "cached" field (must be boolean)');
    }

    // Optional fields - validate type if present
    final userId = json['user_id'];
    if (userId != null && userId is! String) {
      throw FormatException(
          'SearchMetadata: invalid "user_id" field (must be string if present)');
    }

    final sessionId = json['session_id'];
    if (sessionId != null && sessionId is! String) {
      throw FormatException(
          'SearchMetadata: invalid "session_id" field (must be string if present)');
    }

    return SearchMetadata(
      processingTimeMs: processingTimeMs,
      tokensUsed: tokensUsed,
      cached: cached,
      userId: userId as String?,
      sessionId: sessionId as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processing_time_ms': processingTimeMs,
      'tokens_used': tokensUsed,
      'cached': cached,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
    };
  }
}
