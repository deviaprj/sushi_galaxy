import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_widgets.dart';
import 'package:sushi_galaxy/ui/components/restaurant_background.dart';
import 'package:sushi_galaxy/ui/screens/level_select_screen.dart';
import 'package:sushi_galaxy/ui/screens/shop_screen.dart';
import 'package:sushi_galaxy/ui/screens/settings_screen.dart';
import 'package:sushi_galaxy/ui/screens/level_complete_screen.dart';

/// Home Screen - Main menu
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final lives = ref.watch(livesProvider);

    return Scaffold(
      body: RestaurantBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top bar with lives and gems
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LivesIndicator(
                      lives: lives.currentLives,
                      maxLives: lives.maxLives,
                    ),
                    GemCounter(gems: progress.gems),
                  ],
                ),

                const Spacer(),

                // Logo and title
                const Text(
                  '🍣',
                  style: TextStyle(fontSize: 80),
                ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 16),
                const Text(
                  'SUSHI GALAXY',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const Text(
                  'Match & Feast in Space!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: '🏆',
                        value: '${progress.currentLevel}',
                        label: 'Level',
                      ),
                      _StatColumn(
                        icon: '⭐',
                        value: '${progress.totalStars}',
                        label: 'Stars',
                      ),
                      _StatColumn(
                        icon: '🔥',
                        value: '${progress.currentStreak}',
                        label: 'Streak',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                // Play button
                SizedBox(
                  width: double.infinity,
                  height: 56,
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
                      backgroundColor: AppColors.sakuraPink,
                      disabledBackgroundColor:
                          AppColors.textSecondary.withOpacity(0.3),
                    ),
                    child: Text(
                      lives.canPlay
                          ? 'PLAY'
                          : 'Wait for lives: ${lives.timeUntilNextLife?.inMinutes ?? 0}m',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),

                // Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: _IconButton(
                        icon: '🛒',
                        label: 'Shop',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShopScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IconButton(
                        icon: '⚙️',
                        label: 'Settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IconButton(
                        icon: '👤',
                        label: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
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
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

class _IconButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile screen (placeholder)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LevelCompleteScreen(score: 1000, stars: 3, level: 1);
  }
}