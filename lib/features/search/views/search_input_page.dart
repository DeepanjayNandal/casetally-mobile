import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/app_page_container.dart';
import '../../../features/search/providers/search_provider.dart';
import '../../../theme/bottom_bar_metrics.dart';
import 'search_results_page.dart';

class SearchInputPage extends ConsumerStatefulWidget {
  const SearchInputPage({super.key});

  @override
  ConsumerState<SearchInputPage> createState() => _SearchInputPageState();
}

class _SearchInputPageState extends ConsumerState<SearchInputPage> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-focus text field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // 1. Immediately trigger the search.
      ref.read(searchProvider.notifier).submitQuery(query.trim());

      // 2. Replace the current page with the results page.
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => SearchResultsPage(query: query.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      child: Column(
        children: [
          // ── EMPTY EXPANDER (pushes chips + bar to bottom) ────
          const Expanded(child: SizedBox.shrink()),

          // ── CHIPS + SEARCH BAR (rises with keyboard) ─────────
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0
                  ? MediaQuery.of(context).viewInsets.bottom + 8
                  : BottomBarMetrics.floatGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chips tray
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Miranda Rights',
                      'Fourth Amendment',
                      'Right to an Attorney',
                      'Traffic Stop Rights',
                      'Search and Seizure',
                    ].map((topic) {
                      return GestureDetector(
                        onTap: () => _onSubmitted(topic),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: CupertinoColors.activeBlue
                                  .withValues(alpha: 0.4),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Search bar row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'search_hero',
                        // Material wrapper prevents text style conflicts during Hero animation
                        child: Material(
                          type: MaterialType.transparency,
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
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onSubmitted: _onSubmitted,
                                    onChanged: (_) => setState(() {}),
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
                                // Inline X — only visible when text field has content
                                if (_controller.text.isNotEmpty)
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      color: Color(0xFF8E8E93),
                                      size: 18,
                                    ),
                                  ),
                                const SizedBox(width: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
