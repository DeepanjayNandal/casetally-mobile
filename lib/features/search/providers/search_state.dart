import '../models/artifact.dart';
import '../models/law_reference.dart';
import '../models/source.dart';
import '../models/related_article.dart';

/// Streaming search state - accumulates data progressively
///
/// **Design Principles:**
/// - Starts empty, fills incrementally
/// - Each artifact has independent loading state
/// - Supports partial success (some sections loaded, others failed)
/// - Request-scoped (ignores events from old queries)
///
/// **Perplexity-Style UX:**
/// - Citations appear first
/// - Summary streams in word-by-word
/// - Sources appear independently
/// - Related articles appear last
class SearchState {
  // ==================== REQUEST TRACKING ====================

  /// Current query being processed
  final String? currentQuery;

  /// Unique ID for current request
  /// **Critical:** Used to ignore stale events from previous queries
  final String? currentRequestId;

  /// Conversation thread ID for multi-turn context
  /// Stored in state for debugging and future threading UI
  final String? groupId;

  // ==================== OVERALL STATUS ====================

  /// Overall search status
  final SearchStatus status;

  /// Error message if overall search failed
  final String? errorMessage;

  /// Processing time (from DoneEvent)
  final Duration? processingTime;

  // ==================== ACCUMULATIVE DATA ====================

  /// Legal citations (laws, cases, statutes)
  /// Accumulates as CitationsEvent arrives
  final List<LawReference> laws;

  /// AI summary text chunks
  /// Accumulates as SummaryChunkEvent arrives
  /// Join with empty string to display: `summaryChunks.join()`
  final List<String> summaryChunks;

  /// Source citations
  /// Accumulates as SourcesEvent arrives
  final List<Source> sources;

  /// Primary legal documents (PDFs: court cases, statutes, regulations)
  /// Accumulates as ArtifactsEvent arrives
  /// **Note:** Different from sources (reference websites vs actual documents)
  final List<Artifact> artifacts;

  /// Related articles from Resources
  /// Accumulates as RelatedArticlesEvent arrives
  final List<RelatedArticle> relatedArticles;

  // ==================== METADATA ====================

  /// Total sources found (from SourcesCountEvent)
  /// Appears before actual sources arrive
  final int? totalSourcesCount;

  /// Timestamp when search started
  final DateTime? queryStartTime;

  // ==================== COMPLETION FLAGS ====================

  /// Whether citations have finished loading
  /// True after CitationsEvent received or DoneEvent
  final bool citationsComplete;

  /// Whether summary has finished streaming
  /// True when SummaryChunkEvent.isComplete or DoneEvent
  final bool summaryComplete;

  /// Whether sources have finished loading
  /// True after SourcesEvent received or DoneEvent
  final bool sourcesComplete;

  /// Whether artifacts have finished loading
  /// True after final ArtifactsEvent (isComplete=true) or DoneEvent
  final bool artifactsComplete;

  /// Whether related articles have finished loading
  /// True after RelatedArticlesEvent received or DoneEvent
  final bool relatedArticlesComplete;

  // ==================== CONSTRUCTOR ====================

  const SearchState({
    this.currentQuery,
    this.currentRequestId,
    this.groupId,
    this.status = SearchStatus.idle,
    this.errorMessage,
    this.processingTime,
    this.laws = const [],
    this.summaryChunks = const [],
    this.sources = const [],
    this.artifacts = const [],
    this.relatedArticles = const [],
    this.totalSourcesCount,
    this.queryStartTime,
    this.citationsComplete = false,
    this.summaryComplete = false,
    this.sourcesComplete = false,
    this.artifactsComplete = false,
    this.relatedArticlesComplete = false,
  });

  // ==================== NAMED CONSTRUCTORS ====================

  /// Initial idle state
  const SearchState.idle()
      : currentQuery = null,
        currentRequestId = null,
        groupId = null,
        status = SearchStatus.idle,
        errorMessage = null,
        processingTime = null,
        laws = const [],
        summaryChunks = const [],
        sources = const [],
        artifacts = const [],
        relatedArticles = const [],
        totalSourcesCount = null,
        queryStartTime = null,
        citationsComplete = false,
        summaryComplete = false,
        sourcesComplete = false,
        artifactsComplete = false,
        relatedArticlesComplete = false;

  /// Loading state (query submitted, waiting for first event)
  SearchState.loading({
    required String query,
    required String requestId,
    String? groupId,
  })  : currentQuery = query,
        currentRequestId = requestId,
        groupId = groupId,
        status = SearchStatus.loading,
        errorMessage = null,
        processingTime = null,
        laws = const [],
        summaryChunks = const [],
        sources = const [],
        artifacts = const [],
        relatedArticles = const [],
        totalSourcesCount = null,
        queryStartTime = DateTime.now(),
        citationsComplete = false,
        summaryComplete = false,
        sourcesComplete = false,
        artifactsComplete = false,
        relatedArticlesComplete = false;

  // ==================== COMPUTED PROPERTIES ====================

  /// Whether any results have been received
  bool get hasAnyResults =>
      laws.isNotEmpty ||
      summaryChunks.isNotEmpty ||
      sources.isNotEmpty ||
      artifacts.isNotEmpty ||
      relatedArticles.isNotEmpty;

  /// Whether search is currently active
  bool get isSearching => status == SearchStatus.loading;

  /// Whether search completed successfully
  bool get isComplete => status == SearchStatus.success;

  /// Whether search failed
  bool get hasError => status == SearchStatus.error;

  /// Full summary text (all chunks joined)
  String get summaryText => summaryChunks.join();

  /// Whether summary is currently streaming
  bool get isSummaryStreaming => summaryChunks.isNotEmpty && !summaryComplete;

  // ==================== COPY WITH ====================

  SearchState copyWith({
    String? currentQuery,
    String? currentRequestId,
    String? groupId,
    SearchStatus? status,
    String? errorMessage,
    Duration? processingTime,
    List<LawReference>? laws,
    List<String>? summaryChunks,
    List<Source>? sources,
    List<Artifact>? artifacts,
    List<RelatedArticle>? relatedArticles,
    int? totalSourcesCount,
    DateTime? queryStartTime,
    bool? citationsComplete,
    bool? summaryComplete,
    bool? sourcesComplete,
    bool? artifactsComplete,
    bool? relatedArticlesComplete,
  }) {
    return SearchState(
      currentQuery: currentQuery ?? this.currentQuery,
      currentRequestId: currentRequestId ?? this.currentRequestId,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      processingTime: processingTime ?? this.processingTime,
      laws: laws ?? this.laws,
      summaryChunks: summaryChunks ?? this.summaryChunks,
      sources: sources ?? this.sources,
      artifacts: artifacts ?? this.artifacts,
      relatedArticles: relatedArticles ?? this.relatedArticles,
      totalSourcesCount: totalSourcesCount ?? this.totalSourcesCount,
      queryStartTime: queryStartTime ?? this.queryStartTime,
      citationsComplete: citationsComplete ?? this.citationsComplete,
      summaryComplete: summaryComplete ?? this.summaryComplete,
      sourcesComplete: sourcesComplete ?? this.sourcesComplete,
      artifactsComplete: artifactsComplete ?? this.artifactsComplete,
      relatedArticlesComplete:
          relatedArticlesComplete ?? this.relatedArticlesComplete,
    );
  }

  @override
  String toString() => 'SearchState('
      'query: "$currentQuery", '
      'status: $status, '
      'laws: ${laws.length}, '
      'summaryChunks: ${summaryChunks.length}, '
      'sources: ${sources.length}, '
      'artifacts: ${artifacts.length}, '
      'articles: ${relatedArticles.length}'
      ')';
}

/// Search status enum
enum SearchStatus {
  idle, // No search active
  loading, // Search in progress
  success, // Search completed successfully
  error, // Search failed
}
