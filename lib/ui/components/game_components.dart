import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';

/// Animated sushi tile with effects
class AnimatedSushiTile extends StatefulWidget {
  final SushiElement element;
  final double size;
  final bool isMatched;
  final bool isFalling;
  final VoidCallback? onTap;
  final Function(DragEndDetails)? onSwipe;

  const AnimatedSushiTile({
    super.key,
    required this.element,
    this.size = 48,
    this.isMatched = false,
    this.isFalling = false,
    this.onTap,
    this.onSwipe,
  });

  @override
  State<AnimatedSushiTile> createState() => _AnimatedSushiTileState();
}

class _AnimatedSushiTileState extends State<AnimatedSushiTile> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    Widget tile = GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        // Determine swipe direction
        if (details.velocity.pixelsPerSecond.dx.abs() > 100 ||
            details.velocity.pixelsPerSecond.dy.abs() > 100) {
          widget.onSwipe?.call(details);
        }
        setState(() {
          _dragOffset = Offset.zero;
        });
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.element.type.color.withOpacity(0.8),
                widget.element.type.color.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.element.type.color,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.element.type.color.withOpacity(
                  widget.isMatched ? 0.8 : 0.4,
                ),
                blurRadius: widget.isMatched ? 25 : 8,
                spreadRadius: widget.isMatched ? 4 : 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.element.type.emoji,
              style: TextStyle(
                fontSize: widget.size * 0.75,
              ),
            ),
          ),
        ),
      ),
    );

    // Add animations based on state
    if (widget.isMatched) {
      tile = tile
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.4, 1.4),
            duration: 150.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.4, 1.4),
            end: const Offset(0, 0),
            duration: 200.ms,
          )
          .fadeOut(duration: 200.ms);
    }

    if (widget.isFalling) {
      tile = tile.animate().slideY(
            begin: -1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOut,
          );
    }

    return tile;
  }
}

/// Animated game grid with transitions
class AnimatedGameGrid extends StatelessWidget {
  final List<List<SushiElement>> grid;
  final double tileSize;
  final Set<GridPosition> matchedPositions;
  final Function(GridPosition)? onTileTap;
  final Function(GridPosition, DragEndDetails)? onTileSwipe;

  const AnimatedGameGrid({
    super.key,
    required this.grid,
    this.tileSize = 48,
    this.matchedPositions = const {},
    this.onTileTap,
    this.onTileSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.restaurantLight.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warmWood.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGlow.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: grid.asMap().entries.map((rowEntry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: rowEntry.value.asMap().entries.map((colEntry) {
                final position = GridPosition(rowEntry.key, colEntry.key);
                final isMatched = matchedPositions.contains(position);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedSushiTile(
                    element: colEntry.value,
                    size: tileSize,
                    isMatched: isMatched,
                    onTap: () => onTileTap?.call(position),
                    onSwipe: (details) => onTileSwipe?.call(position, details),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Animated score counter
class AnimatedScore extends StatelessWidget {
  final int score;
  final int targetScore;

  const AnimatedScore({
    super.key,
    required this.score,
    required this.targetScore,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / targetScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.restaurantLight,
            AppColors.restaurantLight.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmWood.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGlow.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScoreItem(
                icon: '⭐',
                value: score,
                label: 'Score',
                color: AppColors.goldenRice,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              _ScoreItem(
                icon: '🎯',
                value: targetScore,
                label: 'Target',
                color: AppColors.sakuraPink,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1 ? AppColors.success : AppColors.sakuraPink,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String icon;
  final int value;
  final String label;
  final Color color;

  const _ScoreItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Animated combo counter
class AnimatedCombo extends StatelessWidget {
  final int combo;

  const AnimatedCombo({
    super.key,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    final colors = [
      AppColors.goldenRice,
      AppColors.sakuraPink,
      AppColors.neonPurple,
    ];
    final color = colors[(combo - 2) % colors.length];
    final multiplier = combo >= 5 ? 4 : (combo >= 4 ? 3 : 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${combo}x',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'COMBO x$multiplier!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          const Text('🔥', style: TextStyle(fontSize: 18)),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }
}

/// Progress bar for moves
class MovesIndicator extends StatelessWidget {
  final int moves;
  final int maxMoves;

  const MovesIndicator({
    super.key,
    required this.moves,
    this.maxMoves = 25,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (moves / maxMoves).clamp(0.0, 1.0);
    final isLow = moves <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.restaurantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warmWood.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            color: isLow ? AppColors.warning : AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$moves',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLow ? AppColors.warning : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'moves',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate(target: isLow ? 1 : 0).shake(hz: 2, duration: 500.ms);
  }
}