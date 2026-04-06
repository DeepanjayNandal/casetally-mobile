import 'package:flutter/cupertino.dart';
import '../theme/glass_tokens.dart';
import 'glass.dart';
import 'search_button.dart';

// Animation constants
const _kAnimationDuration = Duration(milliseconds: 320);
const _kAnimationCurve = Curves.easeOutCubic; // Smooth deceleration (Apple Music style)

// A flag to enable visual debugging guides for alignment and sizing.
const bool _debugLayout = false;

class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSearchTap;

  const GlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      {'icon': CupertinoIcons.house_fill, 'label': 'Home'},
      {'icon': CupertinoIcons.book_fill, 'label': 'Resources'},
      {'icon': CupertinoIcons.gear_alt_fill, 'label': 'Settings'},
    ];
    final numTabs = tabs.length;

    // Use the centralized lit edge gradient for a subtle top highlight.
    final litEdgeDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      gradient: kDockLitEdgeGradient,
    );

    return Row(
      children: [
        // Left: Group pill containing all tabs
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const containerPadding = 4.0;
              final availableWidth = constraints.maxWidth - (containerPadding * 2) - (kDockGlassBorderWidth * 2);
              final tabAreaWidth = availableWidth / numTabs;

              const pillRatio = 0.88;
              final pillWidth = tabAreaWidth * pillRatio;

              final pillLeft = (currentIndex * tabAreaWidth) + ((tabAreaWidth - pillWidth) / 2);

              return Container(
                decoration: litEdgeDecoration,
                child: GlassContainer(
                  // Use shared glass theme tokens
                  blur: kDockGlassBlur,
                  gradient: kDockGlassGradient,
                  borderRadius: 40,
                  borderColor: kDockGlassBorderColor,
                  borderWidth: kDockGlassBorderWidth,
                  padding: const EdgeInsets.all(containerPadding),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated selection pill — hidden when no tab is active
                      if (currentIndex >= 0)
                        AnimatedPositioned(
                          duration: _kAnimationDuration,
                          curve: _kAnimationCurve,
                          left: pillLeft,
                          // REVERT: Pill vertical inset removed. It now fills the height.
                          top: 0,
                          bottom: 0,
                          width: pillWidth,
                          child: const _SelectionPill(),
                        ),
                      // Tab items
                      Row(
                        children: List.generate(numTabs, (index) {
                          return Expanded(
                            child: _TabItem(
                              icon: tabs[index]['icon'] as IconData,
                              label: tabs[index]['label'] as String,
                              isSelected: currentIndex == index,
                              onTap: () => onTabChanged(index),
                              accentColor: CupertinoColors.activeBlue,
                            ),
                          );
                        }),
                      ),
                      if (_debugLayout) const _DebugOverlay(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Right: Circular search button
        SearchButton(onTap: onSearchTap),
      ],
    );
  }
}

// The moving pill behind the selected tab, styled to look "pressed in".
class _SelectionPill extends StatelessWidget {
  const _SelectionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Dark pressed-in look using black alpha (not light grey which causes milky wash)
        color: const Color(0x66000000), // 40% black
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

/// Individual tab item (vertical stack: icon above label)
class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = CupertinoColors.white.withAlpha(200); // 80% white
    final selectedColor = accentColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: isSelected ? selectedColor : unselectedColor),
            duration: const Duration(milliseconds: 280),
            builder: (context, color, child) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A simple debug overlay to visualize layout guides.
class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: const Color(0x1AFF0000), // debug red 10%
        child: Stack(
          children: [
            // Horizontal center line
            Center(
              child: Container(
                height: 0.5,
                color: CupertinoColors.systemRed,
              ),
            ),
            // Vertical center line
            Center(
              child: Container(
                width: 0.5,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}