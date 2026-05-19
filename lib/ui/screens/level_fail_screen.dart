import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/services/ads/rewarded_ad_service.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/game_screen.dart';
import 'package:sushi_galaxy/ui/screens/shop_screen.dart';

/// Paramètres passés depuis game_screen lors du game over chrono
class TimeUpParams {
  final int savedScore;         // score au moment où le temps s'est arrêté
  final List<List<dynamic>>? gridSnapshot; // snapshot de la grille (non utilisé pour l'instant)

  const TimeUpParams({required this.savedScore, this.gridSnapshot});
}

/// Écran fin de niveau - Temps écoulé
/// 3 boutons : Réessayer (perd une vie) | Continuer (rewarded ad) | Menu (boutique)
class LevelFailScreen extends ConsumerStatefulWidget {
  final int score;
  final int level;
  final bool isTimeUp;  // true si c'est le temps qui s'est écoulé (vs 0 coups)

  const LevelFailScreen({
    super.key,
    required this.score,
    required this.level,
    this.isTimeUp = true,
  });

  @override
  ConsumerState<LevelFailScreen> createState() => _LevelFailScreenState();
}

class _LevelFailScreenState extends ConsumerState<LevelFailScreen> {
  bool _isWatchingAd = false;
  int _validatedAds = 0;
  Timer? _refreshTicker;

  int get _requiredAdsForContinue => widget.level > 20 ? 2 : 1;
  bool get _hasSpecialEventNow {
    final level = LevelGenerator().generate(levelNumber: widget.level);
    return level.isEvent;
  }

  @override
  void initState() {
    super.initState();
    _refreshTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTicker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _watchAdAndContinue() async {
    if (_isWatchingAd) return;

    setState(() {
      _isWatchingAd = true;
      _validatedAds = 0;
    });

    final rewardEarned = await RewardedAdService.instance.showRewardedAdsSequence(
      count: _requiredAdsForContinue,
      onAdValidated: (validatedAds, totalAds) {
        if (!mounted) return;
        setState(() => _validatedAds = validatedAds);
      },
    );

    if (!mounted) return;

    if (!rewardEarned) {
      setState(() => _isWatchingAd = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recompense non validee. Il faut relancer les $_requiredAdsForContinue videos.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isWatchingAd = false);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Recompense obtenue',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          _requiredAdsForContinue == 2
              ? '2 videos valides. Tentative bonus debloquee sans consommer de vie.'
              : 'Tentative bonus debloquee. Le niveau redemarre sans consommer de vie.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Continuer',
              style: TextStyle(color: AppColors.goldenRice),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(initialScore: widget.score)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lives = ref.watch(livesProvider);
    final progress = ref.watch(playerProgressProvider);
    final hasNoLives = lives.currentLives <= 0;
    final nextLifeCountdown = lives.timeUntilNextLife ?? Duration.zero;
    final fullLivesCountdown = lives.timeUntilFullLives;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                  const SizedBox(height: 8),

                  // Emoji + titre
                  Text(
                    widget.isTimeUp ? '⏰' : '😢',
                    style: const TextStyle(fontSize: 80),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.error, AppColors.terracotta],
                    ).createShader(bounds),
                    child: Text(
                      widget.isTimeUp ? 'TEMPS ÉCOULÉ !' : 'NIVEAU ÉCHOUÉ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 6),
                  Text(
                    'Niveau ${widget.level}',
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 10),

                  // Petite barre d'info : niveau + etoiles
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Niveau ${widget.level}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '${progress.totalStars} etoiles',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 28),

                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 40),
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
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('SCORE', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.score}',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        // Vies restantes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Vies : ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ...List.generate(lives.maxLives, (i) => Text(
                              i < lives.currentLives ? '❤️' : '🖤',
                              style: const TextStyle(fontSize: 18),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 20),

                  // Si visionnage pub en cours
                  if (_isWatchingAd) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.nebulaPurple,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.terracotta),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(color: AppColors.terracotta),
                          SizedBox(height: 16),
                          Text('📺 Chargement de la video...', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                          SizedBox(height: 6),
                          Text('La rewarded ad de test va s\'ouvrir en plein ecran',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    if (_requiredAdsForContinue > 1) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Progression recompense : $_validatedAds/$_requiredAdsForContinue videos',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ] else if (hasNoLives) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.nebulaPurple.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.error.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plus de vies disponibles',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tu ne peux pas relancer la partie maintenant. Achète des vies en boutique, participe à un événement spécial s\'il est actif, ou attends la recharge automatique.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Prochaine vie dans ${_formatDuration(nextLifeCountdown)}',
                            style: const TextStyle(
                              color: AppColors.goldenRice,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (fullLivesCountdown != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Vies pleines dans ${_formatDuration(fullLivesCountdown)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Une notification te sera envoyée lorsque le stock de vies sera plein.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 780.ms),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Text('🛒', style: TextStyle(fontSize: 20)),
                        label: const Text(
                          'ALLER EN BOUTIQUE',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ShopScreen()),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 900.ms),

                    if (_hasSpecialEventNow) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          icon: const Text('🎉', style: TextStyle(fontSize: 20)),
                          label: const Text(
                            'PARTICIPER À L\'ÉVÉNEMENT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldenRice,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.goldenRice, width: 1.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const GameScreen()),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 980.ms),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Aucun événement spécial actif en ce moment.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ).animate().fadeIn(delay: 980.ms),
                    ],
                  ] else ...[
                    // Bouton 1 : RÉESSAYER (perd une vie)
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton.icon(
                        icon: const Text('💔', style: TextStyle(fontSize: 20)),
                        label: const Text(
                          'RÉESSAYER (−1 ❤️)',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: lives.currentLives > 0
                            ? () {
                                ref.read(livesProvider.notifier).useLife();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GameScreen()),
                                );
                              }
                            : null,
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 12),

                    // Bouton 2 : CONTINUER (rewarded ad)
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton.icon(
                        icon: const Text('📺', style: TextStyle(fontSize: 22)),
                        label: Text(
                          _requiredAdsForContinue == 2
                              ? 'CONTINUER  (Regarder 2 videos)'
                              : 'CONTINUER  (Regarder une video)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          shadowColor: AppColors.terracotta.withOpacity(0.5),
                        ),
                        onPressed: _watchAdAndContinue,
                      ),
                    ).animate().fadeIn(delay: 950.ms),

                    const SizedBox(height: 12),

                    // Bouton 3 : MENU → Boutique
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        icon: const Text('🛒', style: TextStyle(fontSize: 20)),
                        label: const Text(
                          'MENU  →  Boutique',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldenRice,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.goldenRice, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ShopScreen()),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 1100.ms),
                  ],

                  const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}