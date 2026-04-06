import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../components/app_text.dart';
import '../../components/app_scroll_view.dart';

/// Apple-style minimal authentication screen
/// Clean, centered, premium iOS feel
///
/// **Features:**
/// - 4 OAuth buttons (Apple, Google, Email, Phone)
/// - "Continue as Guest" option
/// - Placeholder "Coming Soon" for OAuth (Phase 2)
/// - Guest flow fully functional
/// - Persists auth state via SharedPreferences
///
/// **Design Philosophy:**
/// - Centered content (Apple onboarding style)
/// - Minimal text, maximum clarity
/// - Premium spacing and typography
/// - Subtle shadows for depth
/// - Press states with scale animation (iOS 18 feel)
/// - Reduced motion support for accessibility
class AuthenticationView extends ConsumerWidget {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackground(context),
      child: SafeArea(
        child: AppScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    // Logo/Icon (centered)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          CupertinoIcons.building_2_fill,
                          size: 40,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Brand name
                    Center(
                      child: AppText.brand(context, 'CaseTally'),
                    ),

                    const SizedBox(height: AppTheme.spacingSm),

                    // Subtitle
                    Center(
                      child: AppText.subtitle(
                        context,
                        'Legal AI Assistant',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXxl * 1.5),

                    // Auth buttons - Perplexity style with press states
                    _AuthButton(
                      variant: AuthButtonVariant.apple,
                      icon: CupertinoIcons.command,
                      label: 'Continue with Apple',
                      onPressed: () => _handleAppleSignIn(context, ref),
                    ),

                    const SizedBox(height: 12),

                    _AuthButton(
                      variant: AuthButtonVariant.google,
                      icon: CupertinoIcons.globe,
                      label: 'Continue with Google',
                      onPressed: () => _handleGoogleSignIn(context, ref),
                    ),

                    const SizedBox(height: 12),

                    _AuthButton(
                      variant: AuthButtonVariant.email,
                      icon: CupertinoIcons.envelope,
                      label: 'Continue with Email',
                      onPressed: () => _handleEmailSignIn(context, ref),
                    ),

                    const SizedBox(height: 12),

                    _AuthButton(
                      variant: AuthButtonVariant.phone,
                      icon: CupertinoIcons.phone,
                      label: 'Continue with Phone',
                      onPressed: () => _handlePhoneSignIn(context, ref),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Guest button (subtle, text-only)
                    CupertinoButton(
                      onPressed: () => _handleGuestContinue(context, ref),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Terms & Privacy (bottom)
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms and Privacy Policy',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.tertiaryLabel
                              .resolveFrom(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EVENT HANDLERS ====================

  void _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await _showComingSoonDialog(context, 'Apple Sign In');
  }

  void _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await _showComingSoonDialog(context, 'Google Sign In');
  }

  void _handleEmailSignIn(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await _showComingSoonDialog(context, 'Email Sign In');
  }

  void _handlePhoneSignIn(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await _showComingSoonDialog(context, 'Phone Sign In');
  }

  void _handleGuestContinue(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref.read(appStateProvider.notifier).continueAsGuest();
    if (context.mounted) context.go('/app');
  }

  Future<void> _showComingSoonDialog(
      BuildContext context, String feature) async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('$feature Coming Soon'),
        content: const Text(
          'This authentication method will be available soon.',
        ),
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
}

// ==================== AUTH BUTTON VARIANT ENUM ====================

/// Authentication button variants
///
/// **Enterprise Pattern:** Explicit enum instead of string matching
///
/// **Why:**
/// - Type-safe (prevents typos)
/// - Survives localization (label can change, variant doesn't)
/// - A/B test friendly (can change label without breaking logic)
/// - Self-documenting code
///
/// **Usage:**
/// ```dart
/// _AuthButton(
///   variant: AuthButtonVariant.apple,
///   label: 'Continue with Apple', // Can be localized
///   ...
/// )
/// ```
enum AuthButtonVariant {
  /// Apple Sign In (white button, dark text)
  apple,

  /// Google Sign In (dark gray button, white text)
  google,

  /// Email Sign In (dark gray button, white text)
  email,

  /// Phone Sign In (dark gray button, white text)
  phone,
}

// ==================== AUTH BUTTON COMPONENT ====================

/// Authentication button with press states and shadows
///
/// **Architecture:**
/// - `CupertinoButton` owns action (semantics, disabled state, platform behavior)
/// - `Listener` tracks press state (visual feedback only)
/// - `AnimatedScale` provides press animation
/// - No competing gesture recognizers
///
/// **Features:**
/// - iOS 18-style press animation (0.96 scale)
/// - Theme-aware shadows (stronger for white button in dark mode)
/// - Haptic feedback on press
/// - Reduced motion support (accessibility)
/// - Explicit variant (no string matching)
///
/// **Design:**
/// - White button for Apple (Perplexity style)
/// - Dark gray (#2C2C2E) for other providers
/// - Centered icon + text
/// - 14px border radius
/// - Subtle shadows for depth
class _AuthButton extends StatefulWidget {
  final AuthButtonVariant variant;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.variant,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  /// Press state for visual feedback
  /// Updated by Listener (pointer events), not by CupertinoButton
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Accessibility: Check if user has reduced motion enabled
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    // Get theme brightness for shadow calculation
    final brightness = CupertinoTheme.brightnessOf(context);

    // Get button style based on variant
    final style = _getButtonStyle(widget.variant, brightness);

    return Listener(
      // Listener passively observes pointer events
      // Does NOT interfere with CupertinoButton's tap handling
      onPointerDown: (_) {
        HapticFeedback.lightImpact();
        if (mounted) setState(() => _isPressed = true);
      },
      onPointerUp: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      onPointerCancel: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        // Press animation: scale to 96% (iOS standard)
        scale: _isPressed ? 0.96 : 1.0,
        // Reduced motion: instant snap instead of animation
        duration:
            reducedMotion ? Duration.zero : const Duration(milliseconds: 150),
        curve: Curves.easeInOutCubicEmphasized, // iOS 18 feel
        child: CupertinoButton(
          // CupertinoButton owns the action
          // Provides: semantics, disabled state, platform behavior
          padding: EdgeInsets.zero,
          onPressed: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(50),
              // Subtle shadows for depth
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(
                    alpha: style.shadowAlpha,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: style.foregroundColor,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: style.foregroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get button style based on variant and theme brightness
  ///
  /// **Style Rules:**
  /// - Apple button: White background, black text
  ///   - Stronger shadow in dark mode (0.15) for visibility
  ///   - Lighter shadow in light mode (0.12)
  /// - Other buttons: Dark gray background, white text
  ///   - Lighter shadow in dark mode (0.10) to avoid heavy look
  ///   - Even lighter in light mode (0.08)
  ///
  /// **Theme-aware but restrained:**
  /// Small deltas between light/dark to maintain consistency
  _ButtonStyle _getButtonStyle(
      AuthButtonVariant variant, Brightness brightness) {
    switch (variant) {
      case AuthButtonVariant.apple:
        return _ButtonStyle(
          backgroundColor: CupertinoColors.white,
          foregroundColor: CupertinoColors.black,
          // White button needs stronger shadow in dark mode
          shadowAlpha: brightness == Brightness.dark ? 0.15 : 0.12,
        );

      case AuthButtonVariant.google:
      case AuthButtonVariant.email:
      case AuthButtonVariant.phone:
        return _ButtonStyle(
          backgroundColor: const Color(0xFF2C2C2E), // iOS dark gray
          foregroundColor: CupertinoColors.white,
          // Dark buttons need lighter shadow to avoid heavy look
          shadowAlpha: brightness == Brightness.dark ? 0.10 : 0.08,
        );
    }
  }
}

// ==================== BUTTON STYLE HELPER ====================

/// Button style configuration
///
/// **Encapsulation:** Groups related style properties
/// Makes _getButtonStyle() return type explicit and type-safe
class _ButtonStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final double shadowAlpha;

  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadowAlpha,
  });
}
