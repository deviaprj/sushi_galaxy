import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_widgets.dart';
import 'package:sushi_galaxy/ui/components/game_components.dart';
import 'package:sushi_galaxy/ui/components/restaurant_background.dart';
import 'package:sushi_galaxy/services/audio/sound_manager.dart';
import 'package:sushi_galaxy/ui/screens/level_complete_screen.dart';
import 'package:sushi_galaxy/ui/screens/level_fail_screen.dart';

/// Game Screen - Main gameplay
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameEngine _engine;
  Set<GridPosition> _matchedPositions = {};
  bool _isProcessing = false;
  Timer? _gameTimer;
  int _timeRemaining = 0;
  bool _isPaused = false;

  // Drag gesture variables
  Offset? _dragStart;
  GridPosition? _dragStartPosition;

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
    super.dispose();
  }

  void _initGame() {
    if (!mounted) return;

    Future.microtask(() {
      if (!mounted) return;

      final progress = ref.read(playerProgressProvider);
      final currentLevel = progress.currentLevel;
      final levelGenerator = ref.read(levelGeneratorProvider);
      final level = levelGenerator.generate(levelNumber: currentLevel);

      _engine = GameEngine(config: GridConfig(rows: level.gridSize, cols: level.gridSize));
      _engine.initGrid();

      // Set time based on level difficulty
      _timeRemaining = _getTimeForLevel(currentLevel);

      ref.read(gameStatusProvider.notifier).startLevel(
            currentLevel,
            level.moveLimit,
          );
      ref.read(livesProvider.notifier).useLife();

      if (mounted) {
        setState(() {});
        _startTimer();
      }
    });
  }

  int _getTimeForLevel(int level) {
    // Start with 2 minutes, decrease gradually
    if (level <= 10) return 120; // 2 minutes for tutorial
    if (level <= 30) return 90; // 1.5 min
    if (level <= 50) return 60; // 1 min
    return 45; // 45 seconds for harder levels
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
          // Play tick sound when time is low
          if (_timeRemaining <= 10 && _timeRemaining > 0) {
            SoundManager().playTick();
          }
        });
      } else {
        // Time's up!
        timer.cancel();
        _onTimeUp();
      }
    });
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

  /// Handle swap between two adjacent cells (called from drag gesture)
  void _onTileTap(GridPosition position) async {
    if (_isProcessing) return;

    // Need a starting position from the drag gesture
    if (_dragStartPosition == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Check if adjacent
    final rowDiff = (_dragStartPosition!.row - position.row).abs();
    final colDiff = (_dragStartPosition!.col - position.col).abs();
    final isAdjacent = rowDiff + colDiff == 1;

    if (isAdjacent) {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final result = await _engine.processTurn(_dragStartPosition!, position);

      if (result.scoreGained > 0) {
        // Valid move - update score
        final status = ref.read(gameStatusProvider);
        ref.read(gameStatusProvider.notifier).updateScore(
              status.score + result.scoreGained,
            );
        ref.read(gameStatusProvider.notifier).decrementMoves();

        // Play match sound
        if (result.matches.length > 1) {
          SoundManager().playCombo();
        } else {
          SoundManager().playMatch();
        }

        // Show matched positions with animation
        setState(() {
          _matchedPositions = result.matches
              .expand((m) => m.positions)
              .toSet();
        });

        // Strong haptic for match
        HapticFeedback.heavyImpact();

        // Wait for animation
        await Future.delayed(const Duration(milliseconds: 400));

        setState(() {
          _matchedPositions = {};
        });
      }
    }

    setState(() {
      _dragStartPosition = null;
      _isProcessing = false;
    });

    // Check win/lose conditions
    _checkGameEnd();
  }

  /// Called when user starts dragging a tile
  void _handleDragStart(GridPosition position, DragStartDetails details) {
    _dragStart = details.localPosition;
    _dragStartPosition = position;
  }

  /// Handle tap on tile (for hints only)
  void _onTileTapOnly(GridPosition position) {
    // Tap can still be used for hints
  }

  void _handleDragEnd(GridPosition position, DragEndDetails details) async {
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    // Check minimum swipe threshold (lower = more sensitive)
    if (dx.abs() < 100 && dy.abs() < 100) return;

    // Determine direction based on velocity
    GridPosition? targetPos;

    if (dx.abs() > dy.abs()) {
      // Horizontal drag
      if (dx > 0 && _dragStartPosition!.col < _engine.config.cols - 1) {
        targetPos = GridPosition(_dragStartPosition!.row, _dragStartPosition!.col + 1);
      } else if (dx < 0 && _dragStartPosition!.col > 0) {
        targetPos = GridPosition(_dragStartPosition!.row, _dragStartPosition!.col - 1);
      }
    } else {
      // Vertical drag
      if (dy > 0 && _dragStartPosition!.row < _engine.config.rows - 1) {
        targetPos = GridPosition(_dragStartPosition!.row + 1, _dragStartPosition!.col);
      } else if (dy < 0 && _dragStartPosition!.row > 0) {
        targetPos = GridPosition(_dragStartPosition!.row - 1, _dragStartPosition!.col);
      }
    }

    if (targetPos != null) {
      _onTileTap(targetPos);
    }

    _dragStart = null;
    _dragStartPosition = null;
  }

  void _checkGameEnd() {
    final status = ref.read(gameStatusProvider);
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);

    // Win - score >= target
    if (status.score >= level.targetScore) {
      _gameTimer?.cancel();
      ref.read(gameStatusProvider.notifier).completeLevel();
      _showLevelComplete();
      return;
    }

    // Lose - no moves left or time up
    if (status.movesRemaining <= 0) {
      _gameTimer?.cancel();
      ref.read(gameStatusProvider.notifier).failLevel();
      _showLevelFail();
      return;
    }

    // Check for valid moves
    if (!_engine.hasValidMoves()) {
      _engine.shuffleGrid();
      setState(() {});
    }
  }

  void _showLevelComplete() {
    SoundManager().playSuccess();
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
    SoundManager().playFail();
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
    final levelGenerator = ref.read(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: ref.read(gameStatusProvider).currentLevel);
    final timeForLevel = _getTimeForLevel(ref.read(gameStatusProvider).currentLevel);
    final timeBonus = _timeRemaining / timeForLevel; // 0 to 1

    // Base score percentage
    final scoreRatio = score / target;

    // Calculate stars based on score + time + combos
    // 1 star: Complete the level (any score >= target)
    // 2 stars: Score >= 120% target OR (>= 100% with time bonus > 50%)
    // 3 stars: Score >= 150% target OR (>= 120% with time bonus > 30%)

    if (scoreRatio >= 1.5 || (scoreRatio >= 1.2 && timeBonus > 0.3)) {
      return 3;
    } else if (scoreRatio >= 1.2 || (scoreRatio >= 1.0 && timeBonus > 0.5)) {
      return 2;
    }
    return 1;
  }

  void _useHint() {
    // Hint would shuffle or highlight - for now just shuffle
    _engine.shuffleGrid();
    setState(() {});
    HapticFeedback.lightImpact();
  }

  void _useHammer() {
    // Hammer: destroys a specific tile (cost gems)
    final progress = ref.read(playerProgressProvider);
    if (progress.gems >= 50) {
      ref.read(playerProgressProvider.notifier).spendGems(50);
      // For now, just shuffle the board
      _engine.shuffleGrid();
      setState(() {});
      HapticFeedback.heavyImpact();
    }
  }

  void _useShuffle() {
    // Shuffle: randomizes the board
    final progress = ref.read(playerProgressProvider);
    if (progress.gems >= 75) {
      ref.read(playerProgressProvider.notifier).spendGems(75);
      _engine.shuffleGrid();
      setState(() {});
      HapticFeedback.mediumImpact();
    }
  }

  void _addExtraMoves() {
    // +5 Moves: adds 5 more moves
    final progress = ref.read(playerProgressProvider);
    if (progress.gems >= 100) {
      ref.read(playerProgressProvider.notifier).spendGems(100);
      final status = ref.read(gameStatusProvider);
      ref.read(gameStatusProvider.notifier).updateScore(status.score);
      // Would need to add a method to add moves
      setState(() {});
      HapticFeedback.mediumImpact();
    }
  }

  void _addExtraTime() {
    // +30 seconds (could be from ad)
    setState(() {
      _timeRemaining += 30;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(gameStatusProvider);
    final levelGenerator = ref.watch(levelGeneratorProvider);
    final level = levelGenerator.generate(levelNumber: status.currentLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth - 64;
    final tileSize = (gridSize - 16) / level.gridSize;

    return Scaffold(
      body: RestaurantBackground(
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _gameTimer?.cancel();
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
                      icon: const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.goldenRice,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _timeRemaining <= 10 ? AppColors.error.withOpacity(0.3) : AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _timeRemaining <= 10 ? AppColors.error : AppColors.sakuraPink,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: AppColors.sakuraPink, size: 20),
                    const SizedBox(width: 8),
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

              const SizedBox(height: 16),

              // Score display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedScore(
                  score: status.score,
                  targetScore: level.targetScore,
                ),
              ),

              const SizedBox(height: 16),

              // Moves and combo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MovesIndicator(moves: status.movesRemaining),
                ],
              ),

              const SizedBox(height: 8),

              // Combo display
              AnimatedCombo(combo: status.combo),

              const Spacer(),

              // Game grid with drag gesture
              _buildGameGrid(level, tileSize),

              const Spacer(),

              // Boosters
              Padding(
                padding: const EdgeInsets.all(24),
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
                      onTap: _addExtraMoves,
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
    return GestureDetector(
      onPanUpdate: (details) {
        // Track drag for simple swap
      },
      onPanEnd: (details) {
        // Not using grid-level drag, tiles handle their own
      },
      child: AnimatedGameGrid(
        grid: _engine.grid,
        tileSize: tileSize.clamp(36, 56),
        matchedPositions: _matchedPositions,
        onTileTap: _onTileTapOnly,
        onTileSwipe: _handleDragEnd,
      ),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonPurple.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}