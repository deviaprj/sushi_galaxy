import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';

/// Sushi tile widget for the game grid
class SushiTile extends StatelessWidget {
  final SushiElement element;
  final double size;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback? onTap;

  const SushiTile({
    super.key,
    required this.element,
    this.size = 48,
    this.isSelected = false,
    this.isMatched = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: element.type.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.goldenRice
                : element.type.color.withOpacity(0.5),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isMatched
              ? [
                  BoxShadow(
                    color: element.type.color.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            element.type.emoji,
            style: TextStyle(
              fontSize: size * 0.5,
            ),
          ),
        ),
      ),
    ).animate(target: isMatched ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
        );
  }
}

/// Game board grid
class GameGrid extends StatelessWidget {
  final List<List<SushiElement>> grid;
  final double tileSize;
  final GridPosition? selectedPosition;
  final Set<GridPosition> matchedPositions;
  final Function(GridPosition)? onTileTap;

  const GameGrid({
    super.key,
    required this.grid,
    this.tileSize = 48,
    this.selectedPosition,
    this.matchedPositions = const {},
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: grid.asMap().entries.map((rowEntry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: rowEntry.value.asMap().entries.map((colEntry) {
              final position = GridPosition(rowEntry.key, colEntry.key);
              final isSelected = selectedPosition == position;
              final isMatched = matchedPositions.contains(position);

              return Padding(
                padding: const EdgeInsets.all(2),
                child: SushiTile(
                  element: colEntry.value,
                  size: tileSize,
                  isSelected: isSelected,
                  isMatched: isMatched,
                  onTap: () => onTileTap?.call(position),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

/// Score display widget
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int targetScore;
  final int movesRemaining;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.targetScore,
    required this.movesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: '⭐',
            value: '$score',
            label: 'Score',
          ),
          _StatItem(
            icon: '🎯',
            value: '$targetScore',
            label: 'Target',
          ),
          _StatItem(
            icon: '👆',
            value: '$movesRemaining',
            label: 'Moves',
            color: movesRemaining <= 5 ? AppColors.warning : null,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$icon $value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
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

/// Combo display
class ComboDisplay extends StatelessWidget {
  final int combo;

  const ComboDisplay({
    super.key,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sakuraPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${combo}x COMBO! 🔥',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().scale(
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}

/// Lives indicator
class LivesIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;
  final String? timeText;

  const LivesIndicator({
    super.key,
    required this.lives,
    this.maxLives = 5,
    this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxLives, (index) {
          final isFilled = index < lives;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.favorite : Icons.favorite_border,
              color: isFilled ? AppColors.sakuraPink : AppColors.textSecondary,
              size: 24,
            ),
          );
        }),
        if (timeText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              timeText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Gem counter
class GemCounter extends StatelessWidget {
  final int gems;

  const GemCounter({
    super.key,
    required this.gems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neonPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonPurple),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$gems',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Star rating display
class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? AppColors.goldenRice : AppColors.textSecondary,
            size: 32,
          ),
        ).animate(delay: Duration(milliseconds: 300 * index)).scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            );
      }),
    );
  }
}