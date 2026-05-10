import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/game_screen.dart';
import 'package:sushi_galaxy/ui/screens/home_screen.dart';

/// Level Fail Screen with warm terracotta theme
class LevelFailScreen extends ConsumerWidget {
  final int score;
  final int level;

  const LevelFailScreen({
    super.key,
    required this.score,
    required this.level,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final canContinue = progress.gems >= 50;

    return Scaffold(
      body: CosmicBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepSpaceBlue,
                AppColors.cosmosDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Sad emoji
                  const Text(
                    '😢',
                    style: TextStyle(fontSize: 80),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // Title with warm gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.terracotta,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'LEVEL FAILED',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 8),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Score with glass effect
                  Container(
                    padding: const EdgeInsets.all(28),
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
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                  const Spacer(),

                  // Continue option
                  if (canContinue) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.terracotta.withOpacity(0.25),
                            AppColors.sakuraPink.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.terracotta),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.terracotta.withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Continue with +5 moves',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '50',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.terracottaLight,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 14),
                  ],

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: canContinue
                          ? () {
                              ref.read(playerProgressProvider.notifier).spendGems(50);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const GameScreen()),
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
                      ),
                      child: Text(
                        canContinue ? 'CONTINUE (50 💎)' : 'NOT ENOUGH GEMS',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.terracotta),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'RETRY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracottaLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}