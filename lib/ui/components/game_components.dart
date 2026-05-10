import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';

/// Neigloo-style sushi tile with 3D depth, inner shadows, and glass highlights
class AnimatedSushiTile extends StatefulWidget {
  final SushiElement element;
  final double size;
  final bool isMatched;
  final bool isFalling;
  final bool isSelected;
  final bool isHinted;
  final int row;
  final int col;
  final Function(int row, int col)? onDragStart;
  final Function(int row, int col, double dx, double dy)? onDragEnd;

  const AnimatedSushiTile({
    super.key,
    required this.element,
    this.size = 48,
    this.isMatched = false,
    this.isFalling = false,
    this.isSelected = false,
    this.isHinted = false,
    required this.row,
    required this.col,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<AnimatedSushiTile> createState() => _AnimatedSushiTileState();
}

class _AnimatedSushiTileState extends State<AnimatedSushiTile>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _hintController;
  late Animation<double> _hintScaleAnimation;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hintScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.20), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.20, end: 1.0), weight: 0.5),
    ]).animate(CurvedAnimation(parent: _hintController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedSushiTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHinted && !oldWidget.isHinted) {
      _hintController.repeat();
    } else if (!widget.isHinted && oldWidget.isHinted) {
      _hintController.stop();
      _hintController.value = 0;
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  String _getSushiAsset() {
    return 'assets/images/sushis/${widget.element.type.name}.svg';
  }

  @override
  Widget build(BuildContext context) {
    final tileSize = widget.size;
    final type = widget.element.type;

    Widget tile = GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
          _dragOffset = Offset.zero;
        });
        widget.onDragStart?.call(widget.row, widget.col);
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        widget.onDragEnd?.call(widget.row, widget.col, velocity.dx, velocity.dy);
        setState(() {
          _isDragging = false;
          _dragOffset = Offset.zero;
        });
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: tileSize,
          height: tileSize,
          decoration: _buildTileDecoration(type, tileSize),
          child: Stack(
            children: [
              // Inner shadow at top (neumorphic concavity)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tileSize * 0.25),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                      Colors.white.withOpacity(0.08),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Main sushi graphic
              Center(
                child: _buildSushiGraphic(),
              ),

              // Glass highlight reflection
              Positioned(
                top: tileSize * 0.06,
                left: tileSize * 0.12,
                child: Container(
                  width: tileSize * 0.4,
                  height: tileSize * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tileSize * 0.08),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom rim light
              Positioned(
                bottom: tileSize * 0.04,
                left: tileSize * 0.1,
                right: tileSize * 0.1,
                child: Container(
                  height: tileSize * 0.04,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tileSize * 0.02),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        type.lightColor.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isMatched) {
      tile = tile
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.5, 1.5),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.5, 1.5),
            end: const Offset(0, 0),
            duration: 250.ms,
            curve: Curves.easeIn,
          )
          .fadeOut(duration: 200.ms);
    }

    if (widget.isFalling) {
      tile = tile
          .animate()
          .slideY(
            begin: -1,
            end: 0,
            duration: 350.ms,
            curve: Curves.bounceOut,
          )
          .fadeIn(duration: 100.ms);
    }

    // Hint animation: use AnimationController for reliable pulsing
    if (widget.isHinted) {
      tile = AnimatedBuilder(
        animation: _hintScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hintScaleAnimation.value,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            tile,
            // Very visible golden overlay with arrow indicator
            IgnorePointer(
              child: Container(
                width: tileSize + 4,
                height: tileSize + 4,
                decoration: BoxDecoration(
                  color: AppColors.goldenRice.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(tileSize * 0.28),
                  border: Border.all(
                    color: Colors.white,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldenRice.withOpacity(0.9),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white.withOpacity(0.8),
                    size: tileSize * 0.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(child: tile);
  }

  BoxDecoration _buildTileDecoration(SushiType type, double tileSize) {
    final borderRadius = tileSize * 0.25;

    // Neigloo style: combination of neumorphic shadows and glass-like highlights
    return BoxDecoration(
      // 3-layer gradient background
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          type.lightColor.withOpacity(0.95),
          type.color.withOpacity(0.85),
          type.darkColor.withOpacity(0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: widget.isHinted
            ? AppColors.goldenRice
            : (widget.isSelected
                ? Colors.white.withOpacity(0.9)
                : type.lightColor.withOpacity(0.4)),
        width: widget.isHinted ? 3.0 : (widget.isSelected ? 2.5 : 1.0),
      ),
      boxShadow: [
        // Top-left inner highlight (neumorphic light)
        BoxShadow(
          color: Colors.white.withOpacity(_isDragging ? 0.3 : 0.2),
          blurRadius: tileSize * 0.15,
          offset: Offset(-tileSize * 0.05, -tileSize * 0.05),
        ),
        // Bottom-right shadow (neumorphic dark)
        BoxShadow(
          color: type.darkColor.withOpacity(0.7),
          blurRadius: tileSize * 0.2,
          offset: Offset(tileSize * 0.05, tileSize * 0.08),
        ),
        // Main ambient glow
        BoxShadow(
          color: type.color.withOpacity(
            widget.isMatched ? 0.9 : (_isDragging ? 0.7 : 0.4),
          ),
          blurRadius: widget.isMatched ? 25 : (_isDragging ? 15 : 8),
          spreadRadius: widget.isMatched ? 4 : (_isDragging ? 2 : 0),
        ),
        // Outer atmospheric glow (subtle)
        BoxShadow(
          color: type.color.withOpacity(0.12),
          blurRadius: tileSize * 0.6,
          spreadRadius: tileSize * 0.15,
        ),
        // Selection glow
        if (widget.isSelected)
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        // Hint glow (3D pulsing effect)
        if (widget.isHinted)
          BoxShadow(
            color: AppColors.goldenRice,
            blurRadius: 22,
            spreadRadius: 6,
          ),
        if (widget.isHinted)
          BoxShadow(
            color: AppColors.goldenRice.withOpacity(0.5),
            blurRadius: 35,
            spreadRadius: 10,
          ),
      ],
    );
  }

  Widget _buildSushiGraphic() {
    try {
      return SvgPicture.asset(
        _getSushiAsset(),
        width: widget.size * 0.72,
        height: widget.size * 0.72,
        fit: BoxFit.contain,
        colorFilter: null,
      );
    } catch (e) {
      // Fallback to emoji with 3D shadow
      return Stack(
        children: [
          // Shadow layer
          Text(
            widget.element.type.emoji,
            style: TextStyle(
              fontSize: widget.size * 0.65,
              color: widget.element.type.darkColor.withOpacity(0.5),
            ),
          ),
          // Main emoji
          Text(
            widget.element.type.emoji,
            style: TextStyle(
              fontSize: widget.size * 0.65,
              color: widget.element.type.color,
            ),
          ),
        ],
      );
    }
  }
}

/// Enhanced game grid with neumorphic border and warm space theme
class AnimatedGameGrid extends StatelessWidget {
  final List<List<SushiElement>> grid;
  final double tileSize;
  final Set<GridPosition> matchedPositions;
  final Set<GridPosition>? hintPositions;
  final GridPosition? selectedPosition;
  final Function(int row, int col)? onDragStart;
  final Function(int row, int col, double dx, double dy)? onDragEnd;

  const AnimatedGameGrid({
    super.key,
    required this.grid,
    this.tileSize = 48,
    this.matchedPositions = const {},
    this.hintPositions,
    this.selectedPosition,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.restaurantLight.withOpacity(0.12),
              AppColors.nebulaPurple.withOpacity(0.25),
              AppColors.cosmosDark.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.terracotta.withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            // Inner glow
            BoxShadow(
              color: AppColors.terracotta.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: -5,
            ),
            // Outer shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
            // Top highlight (neumorphic)
            BoxShadow(
              color: AppColors.neonPurple.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: grid.asMap().entries.map((rowEntry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: rowEntry.value.asMap().entries.map((colEntry) {
                  final position = GridPosition(rowEntry.key, colEntry.key);
                  final isMatched = matchedPositions.contains(position);
                  final isSelected = selectedPosition == position;
                  final isHinted = hintPositions?.contains(position) ?? false;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedSushiTile(
                      element: colEntry.value,
                      size: tileSize,
                      isMatched: isMatched,
                      isSelected: isSelected,
                      isHinted: isHinted,
                      row: rowEntry.key,
                      col: colEntry.key,
                      onDragStart: onDragStart,
                      onDragEnd: onDragEnd,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Enhanced animated score counter with warm theme
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
    final isComplete = score >= targetScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.nebulaPurple.withOpacity(0.5),
            AppColors.deepSpaceBlue.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withOpacity(0.6)
              : AppColors.terracotta.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isComplete
                ? AppColors.success.withOpacity(0.25)
                : AppColors.terracotta.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                isHighlighted: isComplete,
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
                color: AppColors.terracotta,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.textSecondary.withOpacity(0.15),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 10,
                width: MediaQuery.of(context).size.width * progress * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: isComplete
                        ? [AppColors.success, AppColors.mintGreen]
                        : [AppColors.terracotta, AppColors.sakuraPink],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isComplete ? AppColors.success : AppColors.terracotta)
                          .withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
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
  final bool isHighlighted;

  const _ScoreItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isHighlighted ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? AppColors.success : color,
              ),
              child: Text('$value'),
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

/// Enhanced combo display with fire and warm glow effects
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
      AppColors.terracotta,
      AppColors.sakuraPink,
      AppColors.warmGlow,
    ];
    final color = colors[(combo - 2) % colors.length];
    final multiplier = combo >= 5 ? 4 : (combo >= 4 ? 3 : 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 35,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${combo}x',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'COMBO x$multiplier!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          const Text('🔥', style: TextStyle(fontSize: 24)),
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
        .fadeIn(duration: 200.ms)
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.3),
        );
  }
}

/// Enhanced moves indicator with warm theme
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
    final isLow = moves <= 5;
    final isCritical = moves <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.nebulaPurple.withOpacity(0.5),
            AppColors.deepSpaceBlue.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCritical
              ? AppColors.error.withOpacity(0.8)
              : (isLow
                  ? AppColors.warning.withOpacity(0.6)
                  : AppColors.terracotta.withOpacity(0.3)),
          width: isCritical ? 2 : 1.5,
        ),
        boxShadow: [
          if (isCritical)
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            color: isCritical
                ? AppColors.error
                : (isLow ? AppColors.warning : AppColors.terracotta),
            size: 24,
          ),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isCritical ? 26 : 24,
              fontWeight: FontWeight.bold,
              color: isCritical
                  ? AppColors.error
                  : (isLow ? AppColors.warning : AppColors.textPrimary),
            ),
            child: Text('$moves'),
          ),
          const SizedBox(width: 6),
          Text(
            'moves',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate(target: isCritical ? 1 : 0)
        .shake(hz: 3, duration: 400.ms)
        .tint(color: AppColors.error.withOpacity(0.1 * (isCritical ? 1 : 0)));
  }
}