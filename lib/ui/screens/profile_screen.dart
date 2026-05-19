import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/auth_providers.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/services/ads/rewarded_ad_service.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/auth_screen.dart';

/// Écran profil du joueur
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider);
    final session = auth.session;
    final progress = ref.watch(playerProgressProvider);
    final lives = ref.watch(livesProvider);

    return Scaffold(
      body: CosmicBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.deepSpaceBlue, AppColors.cosmosDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      const Expanded(
                        child: Text(
                          'MON PROFIL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Avatar + nom
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.terracotta.withOpacity(0.2),
                                AppColors.nebulaPurple.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.terracotta.withOpacity(0.4)),
                          ),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [AppColors.terracottaLight, AppColors.terracotta],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.terracotta.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('🍣', style: TextStyle(fontSize: 50)),
                                ),
                              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                              const SizedBox(height: 16),
                              Text(
                                session?.displayName ?? 'Sushi Master',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${session?.provider.label ?? 'Local'} • ${session?.email ?? 'compte local'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Niveau ${progress.currentLevel} • 🔥 ${progress.currentStreak} jours',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                        const SizedBox(height: 20),

                        // Statistiques
                        _SectionTitle(title: '📊 STATISTIQUES'),
                        const SizedBox(height: 12),

                        _StatsGrid(
                          stats: [
                            _StatData(icon: '🏆', value: '${progress.currentLevel}', label: 'Niveau actuel'),
                            _StatData(icon: '⭐', value: '${progress.totalStars}', label: 'Étoiles totales'),
                            _StatData(icon: '💎', value: '${progress.gems}', label: 'Gemmes'),
                            _StatData(icon: '🎯', value: '${progress.completedLevels.length}', label: 'Niveaux complétés'),
                            _StatData(icon: '🏅', value: '${progress.highScore}', label: 'Meilleur score'),
                            _StatData(icon: '🔥', value: '${progress.currentStreak}', label: 'Série de jours'),
                          ],
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 20),

                        // Vies
                        _SectionTitle(title: '❤️ VIES'),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.glassWhite.withOpacity(0.15),
                                AppColors.glassWhite.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.terracotta.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  lives.maxLives,
                                  (i) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      i < lives.currentLives ? '❤️' : '🖤',
                                      style: const TextStyle(fontSize: 32),
                                    ).animate(onPlay: (c) => c.repeat()).scaleXY(
                                      begin: 1.0,
                                      end: i < lives.currentLives ? 1.1 : 1.0,
                                      duration: 800.ms,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${lives.currentLives} / ${lives.maxLives} vies disponibles',
                                style: TextStyle(
                                  color: lives.currentLives > 0
                                      ? AppColors.textPrimary
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (lives.currentLives < lives.maxLives) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Prochaine vie dans ${lives.timeUntilNextLife?.inMinutes ?? 0} min',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Text('📺'),
                                  label: const Text('Gagner une vie (vidéo)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.terracotta,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final rewardEarned = await RewardedAdService.instance.showRewardedAd();
                                    if (context.mounted) {
                                      if (rewardEarned) {
                                        ref.read(livesProvider.notifier).addLife();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Recompense obtenue : +1 vie'),
                                            backgroundColor: AppColors.avocado,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Aucune recompense obtenue. Video indisponible ou fermee trop tot.'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                        const SizedBox(height: 20),

                        // Temps stocké
                        _SectionTitle(title: '⏱️ TEMPS BONUS STOCKÉ'),
                        const SizedBox(height: 12),

                        Consumer(builder: (ctx, ref2, _) {
                          final prog = ref2.watch(playerProgressProvider);
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.goldenRice.withOpacity(0.15),
                                  AppColors.glassWhite.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.goldenRice.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('⏰', style: TextStyle(fontSize: 36)),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${prog.storedTimeSeconds} secondes',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.goldenRice,
                                      ),
                                    ),
                                    const Text(
                                      'disponibles en jeu',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 32),

                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authSessionProvider.notifier).signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuthGateScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: const Text(
                            'Changer de compte',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _StatData {
  final String icon;
  final String value;
  final String label;
  const _StatData({required this.icon, required this.value, required this.label});
}

class _StatsGrid extends StatelessWidget {
  final List<_StatData> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassWhite.withOpacity(0.18),
                AppColors.glassWhite.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.terracotta.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stat.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                stat.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                stat.label,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
