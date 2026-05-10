import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_components.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/services/audio/audio_manager.dart';
import 'package:sushi_galaxy/ui/screens/level_complete_screen.dart';
import 'package:sushi_galaxy/ui/screens/level_fail_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

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

  void _initGame() {
    if (!mounted) return;

    final progress = ref.read(playerProgressProvider);
    final currentLevel = progress.currentLevel;
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: currentLevel);

    _engine = GameEngine(
      config: GridConfig(
        rows: level.gridSize,
        cols: level.gridSize,
        sushiTypeCount: level.sushiTypeCount,
      ),
    );
    _engine!.initGrid();

    _timeRemaining = _getTimeForLevel(currentLevel);

    // Calculate hint delay: 10s base + 5s every 5 levels
    _hintDelaySeconds = 10 + (currentLevel ~/ 5) * 5;

    ref.read(gameStatusProvider.notifier).startLevel(
          currentLevel,
          level.moveLimit,
        );
    ref.read(livesProvider.notifier).useLife();

    setState(() {
      _isInitialized = true;
    });
    _startTimer();
    _startHintTimer();
    _startMusic();
  }

  Future<void> _startMusic() async {
    await _audioManager.init();
    await _audioManager.playCalmMusic();
  }

  int _getTimeForLevel(int level) {
    if (level <= 10) return 120;
    if (level <= 30) return 90;
    if (level <= 50) return 60;
    return 45;
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
    final hint = _engine!.getHint();
    if (hint != null) {
      setState(() {
        _currentHint = hint;
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

    final result = await _engine!.processTurn(_dragStartPosition!, targetPos);

    if (result.scoreGained > 0) {
      final status = ref.read(gameStatusProvider);
      ref.read(gameStatusProvider.notifier).updateScore(
            status.score + result.scoreGained,
          );
      ref.read(gameStatusProvider.notifier).decrementMoves();

      if (result.matches.length > 1) {
        _audioManager.playCombo();
        ref.read(gameStatusProvider.notifier).incrementCombo();
      } else {
        _audioManager.playMatch();
        ref.read(gameStatusProvider.notifier).resetCombo();
      }

      if (result.matches.isNotEmpty) {
        setState(() {
          _matchedPositions = result.matches
              .expand((m) => m.positions)
              .toSet();
        });

        HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(milliseconds: 400));

        setState(() {
          _matchedPositions = {};
        });
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

    ref.read(playerProgressProvider.notifier).completeLevel(
          status.currentLevel,
          status.score,
          stars,
        );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LevelCompleteScreen(
          score: status.score,
          stars: stars,
          level: status.currentLevel,
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
    _showHint();
  }

  void _useHammer() {
    final progress = ref.read(playerProgressProvider);
    if (progress.gems >= 50) {
      ref.read(playerProgressProvider.notifier).spendGems(50);
      _audioManager.playBooster();
      _engine!.shuffleGrid();
      setState(() {});
      HapticFeedback.heavyImpact();
    }
  }

  void _useShuffle() {
    final progress = ref.read(playerProgressProvider);
    if (progress.gems >= 75) {
      ref.read(playerProgressProvider.notifier).spendGems(75);
      _audioManager.playBooster();
      _engine!.shuffleGrid();
      setState(() {});
      HapticFeedback.mediumImpact();
    }
  }

  void _addExtraTime() {
    setState(() {
      _timeRemaining += 30;
    });
    _audioManager.playBooster();
    HapticFeedback.mediumImpact();
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
    final levelGenerator = ref.watch(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth - 64;
    final tileSize = (gridSize - 16) / level.gridSize;

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
                  padding: const EdgeInsets.all(12),
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
                      Expanded(
                        child: Text(
                          level.name.isNotEmpty
                              ? level.name
                              : 'Level ${status.currentLevel}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _useHint,
                        icon: Icon(
                          Icons.lightbulb_outline,
                          color: _currentHint != null ? Colors.yellow : AppColors.goldenRice,
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

                // Combo display
                AnimatedCombo(combo: status.combo),

                // Flexible game grid area
                Expanded(
                  child: Center(
                    child: _buildGameGrid(level, tileSize),
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
                        label: 'Hammer',
                        subtitle: '50 💎',
                        onTap: _useHammer,
                      ),
                      _BoosterButton(
                        icon: '🔀',
                        label: 'Shuffle',
                        subtitle: '75 💎',
                        onTap: _useShuffle,
                      ),
                      _BoosterButton(
                        icon: '⏱️',
                        label: '+30s',
                        subtitle: 'FREE',
                        onTap: _addExtraTime,
                      ),
                      _BoosterButton(
                        icon: '➕',
                        label: '+5',
                        subtitle: '100 💎',
                        onTap: () {
                          final progress = ref.read(playerProgressProvider);
                          if (progress.gems >= 100) {
                            ref.read(playerProgressProvider.notifier).spendGems(100);
                            final s = ref.read(gameStatusProvider);
                            ref.read(gameStatusProvider.notifier).updateScore(s.score);
                            setState(() {});
                            HapticFeedback.mediumImpact();
                          }
                        },
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

    return Stack(
      children: [
        AnimatedGameGrid(
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
        ),
      ],
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