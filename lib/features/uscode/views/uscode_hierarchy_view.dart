import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../components/app_text.dart';
import '../../../components/app_scroll_view.dart';
import '../../../components/app_scaffold.dart';
import '../providers/uscode_provider.dart';
import '../models/uscode_hierarchy_node.dart';
import '../widgets/ios_hierarchy_item.dart';

/// Hierarchy View - iOS-styled expandable tree
/// Clean, thin items with indentation (no bulky cards)
class UsCodeHierarchyView extends ConsumerStatefulWidget {
  final int titleNumber;

  const UsCodeHierarchyView({
    super.key,
    required this.titleNumber,
  });

  @override
  ConsumerState<UsCodeHierarchyView> createState() =>
      _UsCodeHierarchyViewState();
}

class _UsCodeHierarchyViewState extends ConsumerState<UsCodeHierarchyView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usCodeProvider.notifier).loadTitleById(widget.titleNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usCodeProvider);

    return AppScrollView(
      slivers: [
        // LOADING
        if (state.isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXl),
                child: CupertinoActivityIndicator(radius: 16),
              ),
            ),
          ),

        // ERROR
        if (state.hasError)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 48,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    AppText.secondary(
                      context,
                      state.errorMessage ?? 'Failed to load',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    CupertinoButton.filled(
                      onPressed: () {
                        ref
                            .read(usCodeProvider.notifier)
                            .loadTitleById(widget.titleNumber);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // SUCCESS - Hierarchy Tree
        if (state.hasData && state.selectedTitle != null)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    AppTheme.spacingLg,
                    AppTheme.spacingLg,
                    AppTheme.spacingSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.largeTitle(
                        context,
                        'Title ${state.selectedTitle!.number}',
                      ),
                      const SizedBox(height: 4),
                      AppText.secondary(
                        context,
                        state.selectedTitle!.name,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Hierarchy Tree (iOS-styled items)
                ...state.selectedTitle!.children.map(
                  (node) => _HierarchyNodeWidget(node: node, depth: 0),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
      ],
    );
  }
}

/// Recursive node widget - uses IosHierarchyItem
class _HierarchyNodeWidget extends StatefulWidget {
  final UsCodeHierarchyNode node;
  final int depth;

  const _HierarchyNodeWidget({
    required this.node,
    required this.depth,
  });

  @override
  State<_HierarchyNodeWidget> createState() => _HierarchyNodeWidgetState();
}

class _HierarchyNodeWidgetState extends State<_HierarchyNodeWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // SECTION (leaf node) - navigate to text
    if (widget.node.isSection) {
      return IosHierarchyItem(
        label: widget.node.label,
        subtitle: widget.node.name,
        depth: widget.depth,
        isSection: true,
        onTap: () {
          context.push('/uscode/section/${widget.node.id}');
        },
      );
    }

    // BRANCH (part/chapter) - expandable
    return Column(
      children: [
        // Header
        IosHierarchyItem(
          label: widget.node.label,
          subtitle: widget.node.name,
          depth: widget.depth,
          isExpandable: true,
          isExpanded: _isExpanded,
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
          },
        ),

        // Children (recursive)
        if (_isExpanded && widget.node.hasChildren)
          ...widget.node.children.map(
            (child) => _HierarchyNodeWidget(
              node: child,
              depth: widget.depth + 1,
            ),
          ),
      ],
    );
  }
}
