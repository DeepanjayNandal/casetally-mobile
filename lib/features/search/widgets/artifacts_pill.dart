import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../components/glass.dart';

/// Compact glass capsule displaying artifact count
///
/// **Design:**
/// - Centered horizontally on page
/// - Uses full glass effect (blur + gradient + border)
/// - Wraps content tightly (only as wide as text + icon)
///
/// **Usage:**
/// Only render when `artifacts.isNotEmpty` (parent handles this conditional)
class ArtifactsPill extends StatelessWidget {
  final int artifactsCount;
  final bool isComplete;
  final VoidCallback onTap;

  const ArtifactsPill({
    super.key,
    required this.artifactsCount,
    required this.isComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: GlassContainer.overlay(
          borderRadius: 999, // Pill shape
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                isComplete
                    ? '$artifactsCount artifacts'
                    : 'Loading artifacts...',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
