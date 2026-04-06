import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/artifact.dart';

/// Card displaying a single artifact with metadata
///
/// **Design:**
/// - Tappable card that opens PDF in QuickLook/system viewer
/// - Shows type icon, title, and metadata line
/// - Icon color varies by artifact type
///
/// **PDF Opening:**
/// TODO: Integrate with url_launcher or open_file package to open PDFs
/// Currently shows placeholder action sheet
///
/// **Future Enhancements:**
/// - Long-press for share sheet
/// - Download progress for remote PDFs
/// - Offline caching
class ArtifactCard extends StatelessWidget {
  final Artifact artifact;

  const ArtifactCard({
    super.key,
    required this.artifact,
  });

  /// Get icon for artifact type
  IconData _getTypeIcon(ArtifactType type) {
    switch (type) {
      case ArtifactType.courtCase:
        return CupertinoIcons.hammer_fill;
      case ArtifactType.statute:
        return CupertinoIcons.doc_text_fill;
      case ArtifactType.regulation:
        return CupertinoIcons.building_2_fill;
      case ArtifactType.legalMemo:
        return CupertinoIcons.pencil_outline;
      case ArtifactType.other:
        return CupertinoIcons.doc_fill;
    }
  }

  /// Get icon color for artifact type
  Color _getTypeColor(BuildContext context, ArtifactType type) {
    switch (type) {
      case ArtifactType.courtCase:
        return CupertinoColors.systemBlue.resolveFrom(context);
      case ArtifactType.statute:
        return CupertinoColors.systemGreen.resolveFrom(context);
      case ArtifactType.regulation:
        return CupertinoColors.systemOrange.resolveFrom(context);
      case ArtifactType.legalMemo:
        return CupertinoColors.systemPurple.resolveFrom(context);
      case ArtifactType.other:
        return CupertinoColors.systemGrey.resolveFrom(context);
    }
  }

  /// Format date as "Jun 13, 1966"
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Build metadata string from available fields
  ///
  /// **Format:** "Publisher · Date · Pages"
  /// Skips null fields gracefully
  String _buildMetadata() {
    final parts = <String>[];

    if (artifact.publisher != null) {
      parts.add(artifact.publisher!);
    }

    if (artifact.date != null) {
      parts.add(_formatDate(artifact.date!));
    }

    if (artifact.pages != null) {
      parts.add('${artifact.pages} pg');
    }

    // TODO: Add file size fallback if pages null
    // if (artifact.pages == null && artifact.fileSizeBytes != null) {
    //   parts.add(_formatFileSize(artifact.fileSizeBytes!));
    // }

    return parts.join(' · ');
  }

  /// Open artifact PDF in external application
  Future<void> _openArtifact(BuildContext context) async {
    HapticFeedback.lightImpact();

    try {
      final uri = Uri.parse(artifact.resourceUri);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched && context.mounted) {
        _showOpenError(context);
      }
    } catch (e) {
      if (context.mounted) {
        _showOpenError(context);
      }
    }
  }

  /// Show error when PDF fails to open
  void _showOpenError(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unable to Open'),
        content: const Text('Could not open this document. Please try again.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metadata = _buildMetadata();

    return GestureDetector(
      onTap: () => _openArtifact(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Left: Type icon with colored background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(context, artifact.type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(artifact.type),
                size: 20,
                color: _getTypeColor(context, artifact.type),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Title + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    artifact.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),

                  // Metadata (if any)
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right: Chevron
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }
}
