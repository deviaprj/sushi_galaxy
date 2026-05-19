import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_components.dart';
import 'package:sushi_galaxy/ui/components/game_widgets.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/services/ads/rewarded_ad_service.dart';
import 'package:sushi_galaxy/services/audio/audio_manager.dart';
import 'package:sushi_galaxy/ui/screens/level_complete_screen.dart';
import 'package:sushi_galaxy/ui/screens/level_fail_screen.dart';
import 'package:sushi_galaxy/ui/screens/shop_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int initialScore;
  final int? startLevelNumber;
  final bool countProgressRewards;

  const GameScreen({
    super.key,
    this.initialScore = 0,
    this.startLevelNumber,
    this.countProgressRewards = true,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GameEngine? _engine;
  Set<GridPosition> _matchedPositions = {};
  bool _isProcessing = false;
  Timer? _gameTimer;
  int _timeRemaining = 0;
  bool _isInitialized = false;

  // Drag gesture state
  GridPosition? _dragStartPosition;

  // Auto-hint system
  Timer? _hintTimer;
  HintResult? _currentHint;
  int _hintDelaySeconds = 10;
  int _hintsUsedThisLevel = 0;

  int get _maxHintsForLevel {
    final level = ref.read(gameStatusProvider).currentLevel;
    if (level > 50) return 1;
    if (level > 10) return 3;
    return 5;
  }

  // Audio
  final _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _hintTimer?.cancel();
    _audioManager.stopMusic();
    super.dispose();
  }

  Future<void> _initGame() async {
    if (!mounted) return;

    // Ensure SFX are ready before the first player interaction.
    await _audioManager.init();

    final progress = ref.read(playerProgressProvider);
    final currentLevel = widget.startLevelNumber ?? progress.currentLevel;
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: currentLevel);

    _engine = GameEngine(
      config: GridConfig(
        rows: level.gridSize,
        cols: level.gridSize,
        sushiTypeCount: level.sushiTypeCount,
        comboTier: level.comboTier,
      ),
    );
    _engine!.initGrid();

    _timeRemaining = _getTimeForLevel(currentLevel);

    // Calculate hint delay: 10s base + 5s every 5 levels
    _hintDelaySeconds = 10 + (currentLevel ~/ 5) * 5;
    _hintsUsedThisLevel = 0;

    ref.read(gameStatusProvider.notifier).startLevel(
          currentLevel,
          level.moveLimit,
          initialScore: widget.initialScore,
        );

    setState(() {
      _isInitialized = true;
    });
    _startTimer();
    _startHintTimer();
    _startMusic();
  }

  Future<void> _startMusic() async {
    await _audioManager.playCalmMusic();
  }

  int _getTimeForLevel(int level) {
    if (level <= 10) return 60;   // 1 min
    if (level <= 30) return 50;   // 50s
    if (level <= 50) return 40;   // 40s
    return 30;                    // 30s pour les niveaux avancés
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });

        // Update music intensity based on time remaining
        final totalTime = _getTimeForLevel(ref.read(gameStatusProvider).currentLevel);
        final timeRatio = _timeRemaining / totalTime;
        _audioManager.updateMusicIntensity(timeRatio);

        if (_timeRemaining <= 10 && _timeRemaining > 0) {
          _audioManager.playTick();
          HapticFeedback.selectionClick();
        }
      } else {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _currentHint = null;
    _hintTimer = Timer(Duration(seconds: _hintDelaySeconds), () {
      if (!mounted || _isProcessing) return;
      _showHint();
    });
  }

  void _resetHintTimer() {
    _hintTimer?.cancel();
    _currentHint = null;
    setState(() {});
    _startHintTimer();
  }

  void _showHint() {
    if (_engine == null) return;
    if (_hintsUsedThisLevel >= _maxHintsForLevel) return;
    final hint = _engine!.getHint();
    if (hint != null) {
      setState(() {
        _currentHint = hint;
        _hintsUsedThisLevel++;
      });
      _audioManager.playHint();
      HapticFeedback.lightImpact();
    }
  }

  void _onTimeUp() {
    final status = ref.read(gameStatusProvider);
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);

    if (status.score >= level.targetScore) {
      ref.read(gameStatusProvider.notifier).completeLevel();
      _showLevelComplete();
    } else {
      ref.read(gameStatusProvider.notifier).failLevel();
      _showLevelFail();
    }
  }

  String get _timerText {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleTileSwap(int startRow, int startCol, double dx, double dy) async {
    if (_isProcessing) return;
    if (_dragStartPosition == null) return;

    const double minSwipe = 20.0;
    if (dx.abs() < minSwipe && dy.abs() < minSwipe) {
      _dragStartPosition = null;
      return;
    }

    GridPosition? targetPos;

    if (dx.abs() > dy.abs()) {
      if (dx > 0 && startCol < _engine!.config.cols - 1) {
        targetPos = GridPosition(startRow, startCol + 1);
      } else if (dx < 0 && startCol > 0) {
        targetPos = GridPosition(startRow, startCol - 1);
      }
    } else {
      if (dy > 0 && startRow < _engine!.config.rows - 1) {
        targetPos = GridPosition(startRow + 1, startCol);
      } else if (dy < 0 && startRow > 0) {
        targetPos = GridPosition(startRow - 1, startCol);
      }
    }

    if (targetPos == null) {
      _dragStartPosition = null;
      return;
    }

    // Reset hint timer on player action
    _resetHintTimer();

    setState(() {
      _isProcessing = true;
    });

    _audioManager.playSwap();
    HapticFeedback.mediumImpact();

    final didSwap = _engine!.swap(_dragStartPosition!, targetPos);

    // Tout swap tenté (réussi ou non) consomme un coup
    ref.read(gameStatusProvider.notifier).decrementMoves();

    if (didSwap) {
      final gainedScore = await _resolveCurrentMatches();
      // Laisser le badge combo visible 1,5s après la fin de la chaîne puis l'effacer
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) ref.read(gameStatusProvider.notifier).resetCombo();
      });

      if (gainedScore > 0) {
        final status = ref.read(gameStatusProvider);
        ref.read(gameStatusProvider.notifier).updateScore(
              status.score + gainedScore,
            );
      }
    } else {
      _audioManager.playInvalid();
      HapticFeedback.lightImpact();
    }

    setState(() {
      _dragStartPosition = null;
      _isProcessing = false;
    });

    _checkGameEnd();
  }

  Future<int> _resolveCurrentMatches() async {
    var totalScore = 0;
    var chainIndex = 0;

    while (true) {
      final matches = _engine!.detectMatches();
      if (matches.isEmpty) {
        return totalScore;
      }

      chainIndex++;

      final comboValue = (chainIndex > 1 || matches.length > 1)
          ? max(chainIndex, matches.length)
          : 0;

      if (comboValue >= 2) {
        _audioManager.playCombo();
        ref.read(gameStatusProvider.notifier).setCombo(comboValue);
      } else {
        _audioManager.playMatch();
        ref.read(gameStatusProvider.notifier).resetCombo();
      }

      setState(() {
        _matchedPositions = matches.expand((match) => match.positions).toSet();
      });

      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 380));

      setState(() {
        _matchedPositions = {};
      });

      final result = _engine!.applyGravity(comboMultiplier: chainIndex);
      totalScore += result.scoreGained;

      if (!mounted) {
        return totalScore;
      }

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  void _checkGameEnd() {
    final status = ref.read(gameStatusProvider);
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);

    if (status.score >= level.targetScore) {
      _gameTimer?.cancel();
      _hintTimer?.cancel();
      ref.read(gameStatusProvider.notifier).completeLevel();
      _showLevelComplete();
      return;
    }

    if (status.movesRemaining <= 0) {
      _gameTimer?.cancel();
      _hintTimer?.cancel();
      ref.read(gameStatusProvider.notifier).failLevel();
      _showLevelFail();
      return;
    }

    if (!_engine!.hasValidMoves()) {
      _engine!.shuffleGrid();
      setState(() {});
    }
  }

  void _showLevelComplete() {
    _audioManager.playVictory();
    _audioManager.stopMusic();
    final status = ref.read(gameStatusProvider);
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);
    final stars = _calculateStars(status.score, level.targetScore);

    var milestoneReached = false;
    final progressNotifier = ref.read(playerProgressProvider.notifier);
    if (widget.countProgressRewards) {
      milestoneReached = progressNotifier.completeLevel(
        status.currentLevel,
        status.score,
        stars,
      );
    } else {
      progressNotifier.completeReplayLevel(status.currentLevel, status.score);
    }
    final totalStars = ref.read(playerProgressProvider).totalStars;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LevelCompleteScreen(
          score: status.score,
          stars: stars,
          level: status.currentLevel,
          milestoneReached: milestoneReached,
          totalStars: totalStars,
        ),
      ),
    );
  }

  void _showLevelFail() {
    _audioManager.playFail();
    _audioManager.stopMusic();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LevelFailScreen(
          score: ref.read(gameStatusProvider).score,
          level: ref.read(gameStatusProvider).currentLevel,
        ),
      ),
    );
  }

  int _calculateStars(int score, int target) {
    final timeForLevel = _getTimeForLevel(ref.read(gameStatusProvider).currentLevel);
    final timeBonus = _timeRemaining / timeForLevel;
    final scoreRatio = score / target;

    if (scoreRatio >= 1.5 || (scoreRatio >= 1.2 && timeBonus > 0.3)) {
      return 3;
    } else if (scoreRatio >= 1.2 || (scoreRatio >= 1.0 && timeBonus > 0.5)) {
      return 2;
    }
    return 1;
  }

  void _useHint() {
    if (_hintsUsedThisLevel >= _maxHintsForLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Limite d\'aides atteinte (max $_maxHintsForLevel par niveau)',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.terracotta,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _showHint();
  }

  void _useHammer() {
    _activateHammer();
  }

  void _useShuffle() {
    _activateShuffle();
  }

  Future<void> _activateHammer() async {
    if (_isProcessing || _engine == null) return;

    final progress = ref.read(playerProgressProvider);
    final notifier = ref.read(playerProgressProvider.notifier);
    final usesStock = progress.hammerBoosters > 0;

    if (!usesStock && progress.gems < 50) {
      _showBoosterUnavailableMessage('Pas assez de gemmes pour utiliser le marteau.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    if (usesStock) {
      notifier.useHammerBooster();
    } else {
      notifier.spendGems(50);
    }

    final target = _currentHint?.from ??
        GridPosition(_engine!.config.rows ~/ 2, _engine!.config.cols ~/ 2);

    _audioManager.playBooster();
    HapticFeedback.heavyImpact();

    setState(() {
      _matchedPositions = {target};
    });

    await Future.delayed(const Duration(milliseconds: 320));

    final result = _engine!.destroyPositions({target});
    final status = ref.read(gameStatusProvider);
    ref.read(gameStatusProvider.notifier).updateScore(
          status.score + result.scoreGained,
        );

    setState(() {
      _matchedPositions = {};
    });

    if (result.hasMoreCascades) {
      final cascadeScore = await _resolveCurrentMatches();
      final currentStatus = ref.read(gameStatusProvider);
      ref.read(gameStatusProvider.notifier).updateScore(
            currentStatus.score + cascadeScore,
          );
    } else {
      setState(() {});
    }

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    _checkGameEnd();
  }

  Future<void> _activateShuffle() async {
    if (_isProcessing || _engine == null) return;

    final progress = ref.read(playerProgressProvider);
    final notifier = ref.read(playerProgressProvider.notifier);
    final usesStock = progress.shuffleBoosters > 0;

    if (!usesStock && progress.gems < 75) {
      _showBoosterUnavailableMessage('Pas assez de gemmes pour melanger la grille.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    if (usesStock) {
      notifier.useShuffleBooster();
    } else {
      notifier.spendGems(75);
    }

    _audioManager.playBooster();
    _engine!.shuffleGrid();
    HapticFeedback.mediumImpact();
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
  }

  void _showBoosterUnavailableMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Ajoute du temps via les stocks accumulés (publicités / boutique)
  void _addExtraTime() {
    final progress = ref.read(playerProgressProvider);
    if (progress.storedTimeSeconds >= 30) {
      ref.read(playerProgressProvider.notifier).useStoredTime(30);
      setState(() {
        _timeRemaining += 30;
      });
      _audioManager.playBooster();
      HapticFeedback.mediumImpact();
    } else {
      // Proposer de regarder une vidéo ou d'aller en boutique
      _showAddTimeDialog();
    }
  }

  void _showAddTimeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '⏱️ Obtenir du temps',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisissez comment obtenir +30 secondes :',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Text('📺', style: TextStyle(fontSize: 20)),
                label: const Text('Regarder une vidéo (+30s)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _watchAdForTime();
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Text('🛒', style: TextStyle(fontSize: 20)),
                label: const Text('Acheter en boutique'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldenRice),
                  foregroundColor: AppColors.goldenRice,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShopScreen(),
                    ),
                  ).then((_) {
                    if (mounted) _startTimer();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watchAdForTime() async {
    _gameTimer?.cancel();
    final rewardEarned = await RewardedAdService.instance.showRewardedAd();
    if (!mounted) return;

    if (rewardEarned) {
      setState(() {
        _timeRemaining += 30;
      });
      _audioManager.playBooster();
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recompense obtenue : +30 secondes'),
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

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _engine == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.terracotta),
        ),
      );
    }

    final status = ref.watch(gameStatusProvider);
    final progress = ref.watch(playerProgressProvider);
    final levelGenerator = ref.watch(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth - 64;
    final tileSizeByWidth = (gridSize - 16) / level.gridSize;

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
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _gameTimer?.cancel();
                          _hintTimer?.cancel();
                          _audioManager.stopMusic();
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Vies
                      Consumer(builder: (ctx, ref2, _) {
                        final lives = ref2.watch(livesProvider);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            lives.maxLives,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Text(
                                i < lives.currentLives ? '❤️' : '🖤',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      }),
                      Expanded(
                        child: Text(
                          level.name.isNotEmpty
                              ? 'Niveau ${status.currentLevel} • ${level.name}'
                              : 'Niveau ${status.currentLevel}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Aide avec compteur restant
                      GestureDetector(
                        onTap: _useHint,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hintsUsedThisLevel >= _maxHintsForLevel
                                  ? AppColors.textSecondary.withOpacity(0.3)
                                  : AppColors.goldenRice.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: _hintsUsedThisLevel >= _maxHintsForLevel
                                    ? AppColors.textSecondary
                                    : (_currentHint != null ? Colors.yellow : AppColors.goldenRice),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${_maxHintsForLevel - _hintsUsedThisLevel}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _hintsUsedThisLevel >= _maxHintsForLevel
                                      ? AppColors.textSecondary
                                      : AppColors.goldenRice,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _timeRemaining <= 10
                          ? [AppColors.error.withOpacity(0.3), AppColors.error.withOpacity(0.15)]
                          : [AppColors.glassWhite.withOpacity(0.2), AppColors.glassWhite.withOpacity(0.08)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _timeRemaining <= 10
                          ? AppColors.error
                          : AppColors.terracotta,
                    ),
                    boxShadow: [
                      if (_timeRemaining <= 10)
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: _timeRemaining <= 10 ? AppColors.error : AppColors.terracotta,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timerText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _timeRemaining <= 10 ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ).animate(target: _timeRemaining <= 10 ? 1 : 0).shake(hz: 2, duration: 500.ms),

                const SizedBox(height: 8),

                GemCounter(gems: progress.gems),

                const SizedBox(height: 8),

                // Score display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedScore(
                    score: status.score,
                    targetScore: level.targetScore,
                  ),
                ),

                const SizedBox(height: 8),

                // Moves and combo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MovesIndicator(moves: status.movesRemaining),
                  ],
                ),

                const SizedBox(height: 4),

                // Flexible game grid area — tileSize contraint par hauteur ET largeur
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Hauteur disponible pour la grille :
                      // padding interne grille (14*2=28) + chaque ligne a Padding(vertical:3) = 6px
                      final rowPadding = level.gridSize * 6.0;
                      final tileSizeByHeight =
                          (constraints.maxHeight - 28.0 - rowPadding - 4.0) / level.gridSize;
                      final tileSize =
                          tileSizeByWidth.clamp(0.0, tileSizeByHeight).clamp(36.0, 56.0);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: _buildGameGrid(level, tileSize),
                          ),
                          Positioned(
                            top: 6,
                            child: IgnorePointer(
                              child: AnimatedCombo(combo: status.combo),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Boosters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BoosterButton(
                        icon: '🔨',
                        label: 'Marteau',
                        subtitle: progress.hammerBoosters > 0
                            ? 'x${progress.hammerBoosters} en stock'
                            : '50 💎',
                        onTap: _useHammer,
                      ),
                      _BoosterButton(
                        icon: '🔀',
                        label: 'Mélanger',
                        subtitle: progress.shuffleBoosters > 0
                            ? 'x${progress.shuffleBoosters} en stock'
                            : '75 💎',
                        onTap: _useShuffle,
                      ),
                      Consumer(builder: (ctx, ref2, _) {
                        final progress = ref2.watch(playerProgressProvider);
                        final stored = progress.storedTimeSeconds;
                        return _BoosterButton(
                          icon: '⏱️',
                          label: '+30s',
                          subtitle: stored >= 30 ? '${stored}s 📦' : '📺 Vidéo',
                          onTap: _addExtraTime,
                        );
                      }),
                      _BoosterButton(
                        icon: '💡',
                        label: 'Aide',
                        subtitle: '${_maxHintsForLevel - _hintsUsedThisLevel}/${_maxHintsForLevel}',
                        onTap: _useHint,
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

  Widget _buildGameGrid(Level level, double tileSize) {
    final double actualTileSize = tileSize.clamp(36.0, 56.0);

    return AnimatedGameGrid(
      grid: _engine!.grid,
      tileSize: actualTileSize,
      matchedPositions: _matchedPositions,
      hintPositions: _currentHint != null
          ? {_currentHint!.from, _currentHint!.to}
          : null,
      onDragStart: (row, col) {
        _dragStartPosition = GridPosition(row, col);
      },
      onDragEnd: (row, col, dx, dy) {
        _handleTileSwap(row, col, dx, dy);
      },
    );
  }
}

class _BoosterButton extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _BoosterButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassWhite.withOpacity(0.2),
              AppColors.glassWhite.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.terracotta.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.terracotta.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}