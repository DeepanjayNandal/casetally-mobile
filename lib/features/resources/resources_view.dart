import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/bottom_bar_metrics.dart';
import '../../components/app_text.dart';
import '../../components/app_scroll_view.dart';
import '../../components/app_card.dart';

/// Resources screen - Category grid
class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.scaffoldBackground(context),
      child: AppScrollView(
        slivers: [
          // Large Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingMd,
              ),
              child: AppText.largeTitle(context, 'Resources'),
            ),
          ),

          // BROWSE Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingMd,
                AppTheme.spacingLg,
                AppTheme.spacingMd,
              ),
              child: AppText.sectionHeader(context, 'BROWSE'),
            ),
          ),

          // Category Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _CategoryCard(
                  icon: CupertinoIcons.shield_fill,
                  title: 'Know Your Rights',
                  description: 'Constitutional protections explained',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/resources/category/know-your-rights');
                  },
                ),
                _CategoryCard(
                  icon: CupertinoIcons.person_2_fill,
                  title: 'Politicians & Officials',
                  description: 'Elected officials & accountability',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/resources/category/politicians-officials');
                  },
                ),
                _CategoryCard(
                  icon: CupertinoIcons.map_fill,
                  title: 'State & County Laws',
                  description: 'Local statutes & regulations',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/resources/category/state-county-laws');
                  },
                ),
                _CategoryCard(
                  icon: CupertinoIcons.building_2_fill,
                  title: 'Federal Laws & Codes',
                  description: 'Browse 54 U.S. Code titles',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/resources/category/federal-laws-codes');
                  },
                ),
              ]),
            ),
          ),

          // Bottom spacer
          SliverToBoxAdapter(
            child: SizedBox(
              height: BottomBarMetrics.scrollSpacerHeight(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category card for the 2x2 grid — icon, title, description
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: CupertinoColors.activeBlue,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E93),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
