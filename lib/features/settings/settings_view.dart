import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/app_state.dart';
import '../../theme/bottom_bar_metrics.dart';
import '../../theme/app_theme.dart';
import '../../components/app_text.dart';
import '../../components/app_scroll_view.dart';
import '../../components/app_card.dart';

/// Settings screen with user preferences
/// Phase 1: Role logic removed
/// Phase 3: Will add auth integration (sign in/out)
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final themeMode = appState.themeMode;
    final authState = appState.auth;

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
                AppTheme.spacingXl,
              ),
              child: AppText.largeTitle(context, 'Settings'),
            ),
          ),

          // Settings List
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APPEARANCE Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: AppText.sectionHeader(context, 'APPEARANCE'),
                ),
                AppCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  padding: EdgeInsets.zero,
                  child: _SettingsItem(
                    title: 'Theme',
                    subtitle: _getThemeLabel(themeMode),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showThemePicker(context, ref, themeMode);
                    },
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // ACCOUNT Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: AppText.sectionHeader(context, 'ACCOUNT'),
                ),
                AppCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      if (authState.status == SessionStatus.guest) ...[
                        const _SettingsItem(
                          title: 'Guest Mode',
                          subtitle: 'Limited access — no sync',
                          onTap: null,
                        ),
                        _Divider(),
                        _SettingsItem(
                          title: 'Sign In to Your Account',
                          titleColor: CupertinoColors.activeBlue,
                          showChevron: true,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await ref.read(appStateProvider.notifier).signOut();
                            if (context.mounted) context.go('/auth');
                          },
                        ),
                      ] else if (authState.status == SessionStatus.authenticated) ...[
                        _SettingsItem(
                          title: 'Signed In',
                          subtitle: authState.email ?? authState.displayName ?? 'Authenticated',
                          onTap: null,
                        ),
                        _Divider(),
                        _SettingsItem(
                          title: 'Sign Out',
                          titleColor: CupertinoColors.destructiveRed,
                          showChevron: false,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _showSignOutDialog(context, ref);
                          },
                        ),
                      ] else ...[
                        const _SettingsItem(
                          title: 'Not Signed In',
                          subtitle: 'Sign in to access all features',
                          onTap: null,
                        ),
                        _Divider(),
                        _SettingsItem(
                          title: 'Sign In',
                          titleColor: CupertinoColors.activeBlue,
                          showChevron: true,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.go('/auth');
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // ABOUT Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: AppText.sectionHeader(context, 'ABOUT'),
                ),
                AppCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsItem(
                        title: 'Version',
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                CupertinoColors.systemGrey.resolveFrom(context),
                          ),
                        ),
                        onTap: null,
                      ),
                      _Divider(),
                      _SettingsItem(
                        title: 'Privacy Policy',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                      _Divider(),
                      _SettingsItem(
                        title: 'Terms of Service',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: BottomBarMetrics.scrollSpacerHeight(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, AppThemeMode currentMode) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: currentMode == AppThemeMode.system,
            onPressed: () {
              HapticFeedback.selectionClick();
              ref
                  .read(appStateProvider.notifier)
                  .setThemeMode(AppThemeMode.system);
              Navigator.pop(context);
            },
            child: const Text('System'),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentMode == AppThemeMode.light,
            onPressed: () {
              HapticFeedback.selectionClick();
              ref
                  .read(appStateProvider.notifier)
                  .setThemeMode(AppThemeMode.light);
              Navigator.pop(context);
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentMode == AppThemeMode.dark,
            onPressed: () {
              HapticFeedback.selectionClick();
              ref
                  .read(appStateProvider.notifier)
                  .setThemeMode(AppThemeMode.dark);
              Navigator.pop(context);
            },
            child: const Text('Dark'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You can sign back in anytime.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              HapticFeedback.mediumImpact();

              // Sign out (clears auth state from SharedPreferences)
              await ref.read(appStateProvider.notifier).signOut();

              // Close dialog
              if (context.mounted) {
                Navigator.pop(context);

                // Navigate to auth screen
                context.go('/auth');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Custom settings item matching iOS style
class _SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showChevron;

  const _SettingsItem({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      color: titleColor ??
                          CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null && showChevron)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 20,
                color: CupertinoColors.systemGrey3,
              ),
          ],
        ),
      ),
    );
  }
}

/// Divider between list items
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingMd),
      child: Container(
        height: 0.5,
        color: CupertinoColors.separator.resolveFrom(context),
      ),
    );
  }
}
