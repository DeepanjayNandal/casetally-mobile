import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/app_text.dart';
import '../components/app_scroll_view.dart';
import '../features/search/providers/search_provider.dart';
import '../features/search/providers/search_state.dart';
import '../components/question_box.dart';

/// Perplexity-style search overlay with clean, continuous text flow
///
/// **Design Philosophy:**
/// - No section cards or containers
/// - Sources badge at top (expandable)
/// - Continuous text with inline citations
/// - Bold section headers (not separate UI elements)
/// - Minimal, clean typography
///
/// **Key Differences from Old Design:**
/// ❌ Removed: AppCard wrappers, section icons, separate source cards
/// ✅ Added: Sources badge, inline citations, text-only flow
class SearchResultOverlay extends ConsumerStatefulWidget {
  const SearchResultOverlay({super.key});

  @override
  ConsumerState<SearchResultOverlay> createState() =>
      _SearchResultOverlayState();
}

class _SearchResultOverlayState extends ConsumerState<SearchResultOverlay> {
  /// Controls sources badge expansion
  bool _sourcesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final questionBoxState = ref.watch(questionBoxProvider);
    final searchState = ref.watch(searchProvider);

    if (!questionBoxState.showOverlay) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: questionBoxState.showOverlay ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(questionBoxProvider.notifier).dismissOverlay();
        },
        child: Container(
          color: CupertinoColors.black.withValues(alpha: 0.3),
          child: GestureDetector(
            onTap: () {}, // Prevent tap-through
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.0,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.5, 0.95],
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    if (notification.extent <= 0.05) {
                      Future.microtask(() {
                        ref.read(questionBoxProvider.notifier).dismissOverlay();
                      });
                    }
                    return true;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          CupertinoColors.systemBackground.resolveFrom(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusXxl),
                        topRight: Radius.circular(AppTheme.radiusXxl),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag Handle
                        Container(
                          margin: const EdgeInsets.only(
                            top: AppTheme.spacingMd,
                            bottom: AppTheme.spacingSm,
                          ),
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey3,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Header Row: Query Pill + Close Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLg,
                            vertical: AppTheme.spacingSm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Query Pill (Perplexity style)
                              if (searchState.currentQuery != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.tertiarySystemFill
                                          .resolveFrom(context),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      searchState.currentQuery!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: CupertinoColors.secondaryLabel
                                            .resolveFrom(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                              const SizedBox(width: 12),

                              // Close Button
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(questionBoxProvider.notifier)
                                      .dismissOverlay();
                                },
                                child: const Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  color: CupertinoColors.systemGrey,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Main Content
                        Expanded(
                          child: AppModalScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingLg,
                                  vertical: AppTheme.spacingMd,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    // LOADING STATE
                                    if (searchState.isSearching &&
                                        !searchState.hasAnyResults) ...[
                                      const SizedBox(height: 60),
                                      const Center(
                                        child: Column(
                                          children: [
                                            CupertinoActivityIndicator(
                                                radius: 16),
                                            SizedBox(height: 16),
                                            Text(
                                              'Searching the web',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]

                                    // ERROR STATE
                                    else if (searchState.hasError &&
                                        !searchState.hasAnyResults) ...[
                                      const SizedBox(height: 40),
                                      Center(
                                        child: Column(
                                          children: [
                                            const Icon(
                                              CupertinoIcons
                                                  .exclamationmark_triangle,
                                              size: 64,
                                              color: CupertinoColors.systemRed,
                                            ),
                                            const SizedBox(height: 16),
                                            AppText.title(context,
                                                'Something went wrong'),
                                            const SizedBox(height: 8),
                                            AppText.secondary(
                                              context,
                                              searchState.errorMessage ??
                                                  'Unknown error',
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 24),
                                            CupertinoButton.filled(
                                              onPressed: () {
                                                if (searchState.currentQuery !=
                                                    null) {
                                                  ref
                                                      .read(searchProvider
                                                          .notifier)
                                                      .submitQuery(searchState
                                                          .currentQuery!);
                                                }
                                              },
                                              child: const Text('Try Again'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]

                                    // RESULTS STATE (Perplexity-style)
                                    else if (searchState.hasAnyResults) ...[
                                      // Sources Badge (appears first, like Perplexity)
                                      _buildSourcesBadge(context, searchState),

                                      const SizedBox(
                                          height: AppTheme.spacingLg),

                                      // Expandable Source Pills
                                      if (_sourcesExpanded &&
                                          searchState.sources.isNotEmpty)
                                        _buildSourcePills(context, searchState),

                                      if (_sourcesExpanded &&
                                          searchState.sources.isNotEmpty)
                                        const SizedBox(
                                            height: AppTheme.spacingLg),

                                      // Main Answer Text (continuous flow, no cards)
                                      _buildAnswerText(context, searchState),

                                      const SizedBox(height: 60),
                                    ],
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Sources badge: "Reviewed X sources ▽"
  Widget _buildSourcesBadge(BuildContext context, SearchState state) {
    final sourceCount = state.totalSourcesCount ?? state.sources.length;

    if (sourceCount == 0 && state.sourcesComplete) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _sourcesExpanded = !_sourcesExpanded);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 14,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: 6),
            Text(
              state.sourcesComplete
                  ? 'Reviewed $sourceCount sources'
                  : 'Reading sources...',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _sourcesExpanded
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
              size: 12,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Expandable source pills (Perplexity's "READING" section)
  Widget _buildSourcePills(BuildContext context, SearchState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.sources.map((source) {
        // Extract domain from URL
        final domain = _extractDomain(source.url);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple icon (no favicons for now)
              Icon(
                CupertinoIcons.globe,
                size: 12,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              const SizedBox(width: 6),
              Text(
                domain,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.label.resolveFrom(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Main answer text with inline citations and section headers
  Widget _buildAnswerText(BuildContext context, SearchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main summary text
        if (state.summaryChunks.isNotEmpty) ...[
          _buildFormattedText(
            context,
            state.summaryText,
            isStreaming: state.isSummaryStreaming,
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],

        // Relevant Laws (as section header + bullets, not cards)
        if (state.laws.isNotEmpty) ...[
          _buildSectionHeader(context, 'Relevant Laws'),
          const SizedBox(height: AppTheme.spacingMd),
          ...state.laws.map((law) => _buildLawBullet(context, law)),
          const SizedBox(height: AppTheme.spacingXl),
        ],

        // Related Articles (converted to simple links)
        if (state.relatedArticles.isNotEmpty) ...[
          _buildSectionHeader(context, 'Related Questions'),
          const SizedBox(height: AppTheme.spacingMd),
          ...state.relatedArticles
              .map((article) => _buildRelatedQuestion(context, article)),
        ],
      ],
    );
  }

  /// Bold section header (Perplexity style)
  Widget _buildSectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.label.resolveFrom(context),
        letterSpacing: -0.5,
      ),
    );
  }

  /// Law as bullet point (not card)
  Widget _buildLawBullet(BuildContext context, law) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  law.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  law.citation,
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                if (law.summary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    law.summary,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Related question link (simple, like Perplexity)
  Widget _buildRelatedQuestion(BuildContext context, article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // Navigate to article - implement later
        },
        child: Row(
          children: [
            Icon(
              CupertinoIcons.arrow_turn_down_right,
              size: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                article.title,
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.label.resolveFrom(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format text with bold markdown and inline citations
  Widget _buildFormattedText(
    BuildContext context,
    String text, {
    bool isStreaming = false,
  }) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Bullet point
      if (line.startsWith('•') || line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: CupertinoColors.label.resolveFrom(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStyledText(
                    context,
                    line.replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStyledText(context, line),
          ),
        );
      }
    }

    // Add streaming indicator
    if (isStreaming) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              CupertinoActivityIndicator(
                radius: 8,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating...',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Build text with **bold** markdown support
  Widget _buildStyledText(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before bold
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: -0.4,
          height: 1.5,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }

  /// Extract domain from URL
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;

      // Remove 'www.' prefix
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }

      // Return first two parts (e.g., 'law.cornell.edu' -> 'cornell.edu')
      final parts = domain.split('.');
      if (parts.length >= 2) {
        return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
      }

      return domain;
    } catch (e) {
      return 'source';
    }
  }
}
