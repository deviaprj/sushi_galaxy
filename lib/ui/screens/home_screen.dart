import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/level_select_screen.dart';
import 'package:sushi_galaxy/ui/screens/shop_screen.dart';
import 'package:sushi_galaxy/ui/screens/settings_screen.dart';
import 'package:sushi_galaxy/ui/screens/profile_screen.dart';

/// Home Screen - Main menu with warm terracotta theme
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final lives = ref.watch(livesProvider);

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top bar with lives and gems
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lives with glow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.glassWhite.withOpacity(0.2),
                            AppColors.glassWhite.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: lives.currentLives > 0
                              ? AppColors.terracotta.withOpacity(0.5)
                              : AppColors.error.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (lives.currentLives > 0
                                    ? AppColors.terracotta
                                    : AppColors.error)
                                .withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '${lives.currentLives}/${lives.maxLives}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: lives.currentLives > 0
                                  ? AppColors.textPrimary
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gems with glow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.glassWhite.withOpacity(0.2),
                            AppColors.glassWhite.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.goldenRice.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenRice.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '${progress.gems}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldenRice,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.3),

                const Spacer(),

                // Animated logo
                _AnimatedLogo(),

                const SizedBox(height: 20),

                // Title with warm terracotta gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.terracottaLight,
                      AppColors.terracotta,
                      AppColors.goldenRice,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'SUSHI GALAXY',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 5,
                      shadows: [
                        Shadow(
                          color: AppColors.terracotta,
                          blurRadius: 25,
                        ),
                        Shadow(
                          color: AppColors.goldenRice,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                    ),

                const SizedBox(height: 8),

                // Tagline
                const Text(
                  'Match & Feast in Space!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(),

                // Stats card with glass effect
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassWhite.withOpacity(0.2),
                        AppColors.glassWhite.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.terracotta.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.terracotta.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: '🏆',
                        value: '${progress.currentLevel}',
                        label: 'Level',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      _StatColumn(
                        icon: '⭐',
                        value: '${progress.totalStars}',
                        label: 'Stars',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      _StatColumn(
                        icon: '🔥',
                        value: '${progress.currentStreak}',
                        label: 'Streak',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                const SizedBox(height: 28),

                // Play button with terracotta glow
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: lives.canPlay
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LevelSelectScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      disabledBackgroundColor:
                          AppColors.textSecondary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: lives.canPlay ? 10 : 0,
                      shadowColor: lives.canPlay
                          ? AppColors.terracotta.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lives.canPlay ? 'PLAY' : 'WAIT',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        if (!lives.canPlay) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${lives.timeUntilNextLife?.inMinutes ?? 0}m',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms)
                  .slideY(begin: 0.3),

                const SizedBox(height: 20),

                // Bottom buttons
                Row(
                  children: [
                    _EnhancedIconButton(
                      icon: '🛒',
                      label: 'Shop',
                      color: AppColors.goldenRice,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShopScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _EnhancedIconButton(
                      icon: '⚙️',
                      label: 'Settings',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _EnhancedIconButton(
                      icon: '👤',
                      label: 'Profil',
                      color: AppColors.neonPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated logo with rotation and warm glow
class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.terracotta.withOpacity(0.35),
            AppColors.sakuraPink.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracotta.withOpacity(0.45),
            blurRadius: 35,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.goldenRice.withOpacity(0.25),
            blurRadius: 50,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: const Text(
          '🍣',
          style: TextStyle(fontSize: 85),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(
              begin: -0.05,
              end: 0.05,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .rotate(
              begin: 0.05,
              end: -0.05,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EnhancedIconButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EnhancedIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassWhite.withOpacity(0.2),
                AppColors.glassWhite.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}