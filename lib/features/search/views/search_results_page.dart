import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/app_scroll_view.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/bottom_bar_metrics.dart';
import '../providers/search_provider.dart';
import '../widgets/artifacts_bottom_sheet.dart';
import '../widgets/artifacts_pill.dart';
import '../widgets/query_pill.dart';
import '../widgets/search_error_display.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/sources_display.dart';
import '../widgets/streaming_answer.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNewSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).submitQuery(query.trim());
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => SearchResultsPage(query: query.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // ── Layer 1: scroll content ──────────────────────────
          AppScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  topPadding + AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  80, // clearance for bottom search bar
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.chevron_left,
                                color: CupertinoColors.activeBlue,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Query pill header
                      QueryPill(query: widget.query),
                      const SizedBox(height: 24),

                      // Loading state
                      if (searchState.isSearching && !searchState.hasAnyResults)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: SearchLoadingIndicator(),
                        ),

                      // Error state
                      if (searchState.hasError && !searchState.hasAnyResults)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: SearchErrorDisplay(
                            errorMessage: searchState.errorMessage,
                            onRetry: () => ref
                                .read(searchProvider.notifier)
                                .submitQuery(widget.query),
                          ),
                        ),

                      // Results
                      if (searchState.hasAnyResults) ...[
                        if (searchState.artifacts.isNotEmpty) ...[
                          ArtifactsPill(
                            artifactsCount: searchState.artifacts.length,
                            isComplete: searchState.artifactsComplete,
                            onTap: () => showArtifactsSheet(
                              context,
                              searchState.artifacts,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        SourcesDisplay(
                          sources: searchState.sources,
                          totalSources: searchState.totalSourcesCount,
                          isComplete: searchState.sourcesComplete,
                        ),
                        const SizedBox(height: 24),
                        StreamingAnswer(
                          summaryText: searchState.summaryText,
                          isStreaming: searchState.isSummaryStreaming,
                          laws: searchState.laws,
                          relatedArticles: searchState.relatedArticles,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Layer 2: bottom search bar (rises with keyboard) ─
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset > 0
                ? bottomInset + 8
                : BottomBarMetrics.floatGap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    CupertinoIcons.search,
                    color: Color(0xFF8E8E93),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _searchController,
                      onSubmitted: _onNewSearch,
                      placeholder: 'Ask a legal question...',
                      placeholderStyle: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 16,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: const BoxDecoration(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
