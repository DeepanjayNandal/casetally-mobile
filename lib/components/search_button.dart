import 'package:flutter/cupertino.dart';
import 'glass_icon_button.dart';

/// Reusable search button component
///
/// Used in both glass nav bar (main tabs) and as floating button (detail pages).
/// Delegates to GlassIconButton for consistent styling and Hero animation.
class SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const SearchButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassIconButton.search(onTap: onTap);
  }
}
