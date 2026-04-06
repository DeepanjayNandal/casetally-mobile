import 'package:flutter/cupertino.dart';
import 'components/glass.dart';
import 'theme/app_theme.dart';

/// Glass UI Demo - High-frequency backgrounds to show blur
///
/// **Testing strategy:**
/// - Detailed text behind glass (shows blur clearly)
/// - Colorful images/patterns (shows tint + blur)
/// - Scrolling content (performance test)
/// - Side-by-side comparisons
class GlassDemoPage extends StatelessWidget {
  const GlassDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Title
          Text(
            'Glass Variants',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Testing two-tier glass system: Surface & Overlay',
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 32),

          // Section 1: Detailed text background
          _BackgroundCard(
            title: 'Text Background Test',
            description: 'Blur should make text behind glass look frosted',
            child: Stack(
              children: [
                // Dense text pattern background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemPurple.resolveFrom(context),
                        CupertinoColors.systemBlue.resolveFrom(context),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(8, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'High-frequency text pattern line ${i + 1} - this should blur behind glass',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.white,
                              height: 1.4,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Glass containers ON TOP
                Positioned(
                  left: 20,
                  top: 60,
                  right: 20,
                  child: Column(
                    children: [
                      GlassContainer.surface(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CupertinoColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Surface Glass (cards, pills)',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer.overlay(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CupertinoColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Overlay Glass (nav, modals)',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section 2: Colorful pattern background
          _BackgroundCard(
            title: 'Pattern Background Test',
            description: 'Glass should show gradient highlight',
            child: Stack(
              children: [
                // Colorful checkerboard pattern
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final colors = [
                        CupertinoColors.systemRed,
                        CupertinoColors.systemOrange,
                        CupertinoColors.systemYellow,
                        CupertinoColors.systemGreen,
                        CupertinoColors.systemTeal,
                        CupertinoColors.systemBlue,
                        CupertinoColors.systemIndigo,
                        CupertinoColors.systemPurple,
                      ];
                      return Container(
                        color: colors[index % colors.length],
                      );
                    },
                  ),
                ),

                // Glass on top
                Center(
                  child: GlassContainer.overlay(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          color: CupertinoColors.white,
                          size: 32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Overlay Glass',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'For nav bars & modals',
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section 3: Side-by-side comparison (two-tier system)
          _BackgroundCard(
            title: 'Two-Tier System',
            description: 'Surface vs Overlay presets',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CupertinoColors.systemIndigo.resolveFrom(context),
                    CupertinoColors.systemPink.resolveFrom(context),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer.surface(
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            children: [
                              Text(
                                'Surface',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'cards, pills',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer.overlay(
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            children: [
                              Text(
                                'Overlay',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'nav, modals',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Bottom note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Two-tier glass system:\n'
              '• Surface: lighter blur for cards & pills\n'
              '• Overlay: stronger blur for nav & modals\n'
              '• Dark mode uses black tint (not white)\n'
              '• No global white sheen (clean look)',
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }
}

/// Background card wrapper
class _BackgroundCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _BackgroundCard({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 15,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
