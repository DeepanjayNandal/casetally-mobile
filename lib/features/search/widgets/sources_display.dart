import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../components/glass.dart';
import '../models/source.dart';

class SourcesDisplay extends StatefulWidget {
  final List<Source> sources;
  final int? totalSources;
  final bool isComplete;

  const SourcesDisplay({
    super.key,
    required this.sources,
    this.totalSources,
    required this.isComplete,
  });

  @override
  State<SourcesDisplay> createState() => _SourcesDisplayState();
}

class _SourcesDisplayState extends State<SourcesDisplay> {
  bool _sourcesExpanded = false;

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      final parts = domain.split('.');
      if (parts.length >= 2) {
        return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
      }
      return domain;
    } catch (e) {
      return 'source';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceCount = widget.totalSources ?? widget.sources.length;

    if (sourceCount == 0 && widget.isComplete) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _sourcesExpanded = !_sourcesExpanded);
          },
          child: GlassContainer.surface(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  size: 14,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isComplete
                      ? 'Reviewed $sourceCount sources'
                      : 'Reading sources...',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _sourcesExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 12,
                  color: CupertinoColors.white,
                ),
              ],
            ),
          ),
        ),
        if (_sourcesExpanded && widget.sources.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.sources.map((source) {
              final domain = _extractDomain(source.url);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.globe,
                      size: 12,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
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
          ),
        ],
      ],
    );
  }
}
