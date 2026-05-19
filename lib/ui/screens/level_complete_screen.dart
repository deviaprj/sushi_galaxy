import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_widgets.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/game_screen.dart';
import 'package:sushi_galaxy/ui/screens/home_screen.dart';

/// Level Complete Screen
class LevelCompleteScreen extends StatelessWidget {
  final int score;
  final int stars;
  final int level;
  final bool milestoneReached;
  final int totalStars;

  const LevelCompleteScreen({
    super.key,
    required this.score,
    required this.stars,
    required this.level,
    this.milestoneReached = false,
    this.totalStars = 0,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Zone scrollable : contenu variable (gift card peut être volumineuse)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Column(
                      children: [
                  // Celebration emoji
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 80),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // Title with warm gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.terracottaLight,
                        AppColors.goldenRice,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'LEVEL COMPLETE!',
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

                  // Stars
                  StarRating(stars: stars),

                  const SizedBox(height: 32),

                  // Score with warm glass effect
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
                        color: AppColors.goldenRice.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldenRice.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
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
                            color: AppColors.goldenRice,
                            shadows: [
                              Shadow(
                                color: AppColors.goldenRice,
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 24),

                  // Star milestone progress
                  _StarProgressCard(
                    totalStars: totalStars,
                    milestoneReached: milestoneReached,
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Boutons épinglés en bas — toujours visibles
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                  // Next Level button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.terracotta.withOpacity(0.5),
                      ),
                      child: const Text(
                        'NEXT LEVEL',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back to Menu',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barre de progression étoiles + animation cadeau si palier atteint
class _StarProgressCard extends StatelessWidget {
  final int totalStars;
  final bool milestoneReached;

  const _StarProgressCard({
    required this.totalStars,
    required this.milestoneReached,
  });

  @override
  Widget build(BuildContext context) {
    final starsInCurrentCycle = totalStars % 50;
    final nextMilestone = (totalStars ~/ 50 + (milestoneReached ? 0 : 1)) * 50;
    final progress = milestoneReached ? 1.0 : starsInCurrentCycle / 50.0;

    return Column(
      children: [
        // Cadeau débloqué
        if (milestoneReached) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldenRice.withOpacity(0.25),
                  AppColors.terracotta.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldenRice, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenRice.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 44))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .moveY(begin: 0, end: -6, duration: 800.ms, curve: Curves.easeInOut)
                    .then()
                    .moveY(begin: -6, end: 0, duration: 800.ms, curve: Curves.easeInOut),
                const SizedBox(height: 8),
                const Text(
                  'CADEAU DÉBLOQUÉ !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenRice,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '50 étoiles atteintes',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldenRice.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.goldenRice.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💎', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 6),
                      Text(
                        '+50 GEMS CRÉDITÉS',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldenRice,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.elasticOut),
              ],
            ),
          ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 14),
        ],

        // Barre de progression vers le prochain palier
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glassWhite.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⭐ $totalStars étoiles au total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    milestoneReached
                        ? '🎁 Palier atteint !'
                        : 'Prochain 🎁 : $nextMilestone ⭐',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.glassWhite.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    milestoneReached ? AppColors.goldenRice : AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}