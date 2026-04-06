import 'package:flutter/cupertino.dart';

/// Wrapper for CustomScrollView with proper iOS bounce physics
/// Guarantees consistent scrolling behavior across all screens
class AppScrollView extends StatelessWidget {
  final List<Widget> slivers;

  const AppScrollView({
    super.key,
    required this.slivers,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: slivers,
    );
  }
}

/// Wrapper for CustomScrollView inside DraggableScrollableSheet
/// Used specifically for overlays and modals with scroll
class AppModalScrollView extends StatelessWidget {
  final ScrollController controller;
  final List<Widget> slivers;

  const AppModalScrollView({
    super.key,
    required this.controller,
    required this.slivers,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: slivers,
    );
  }
}
