import 'package:flutter/cupertino.dart';

import '../models/artifact.dart';
import 'artifact_card.dart';

/// Show bottom sheet with list of artifacts
///
/// **Design:**
/// - iOS-style modal bottom sheet (CupertinoModalPopup)
/// - 60% of screen height
/// - Swipe down to dismiss
/// - Header with title and close button
/// - Scrollable list of ArtifactCard widgets
///
/// **Usage:**
/// ```dart
/// showArtifactsSheet(context, searchState.artifacts);
/// ```
void showArtifactsSheet(BuildContext context, List<Artifact> artifacts) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => _ArtifactsBottomSheet(artifacts: artifacts),
  );
}

/// Internal widget for artifacts bottom sheet content
class _ArtifactsBottomSheet extends StatelessWidget {
  final List<Artifact> artifacts;

  const _ArtifactsBottomSheet({required this.artifacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            _buildDragHandle(context),

            // Header
            _buildHeader(context),

            // Divider
            Container(
              height: 0.5,
              color: CupertinoColors.separator.resolveFrom(context),
            ),

            // Artifacts list
            Expanded(
              child: _buildArtifactsList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Build drag handle for swipe-to-dismiss affordance
  Widget _buildDragHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4.resolveFrom(context),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  /// Build header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Text(
              'Primary Materials',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),

          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                size: 16,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build scrollable list of artifacts
  Widget _buildArtifactsList(BuildContext context) {
    if (artifacts.isEmpty) {
      return Center(
        child: Text(
          'No primary materials found',
          style: TextStyle(
            fontSize: 15,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artifacts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < artifacts.length - 1 ? 12 : 0,
          ),
          child: ArtifactCard(artifact: artifacts[index]),
        );
      },
    );
  }
}
