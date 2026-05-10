import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Enhanced cosmic background with warm terracotta nebulae, golden stars,
/// and floating sushi - creating a warm space-restaurant atmosphere
class CosmicBackground extends StatefulWidget {
  final Widget child;
  final bool enableShootingStars;
  final bool enableAurora;

  const CosmicBackground({
    super.key,
    required this.child,
    this.enableShootingStars = true,
    this.enableAurora = true,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late AnimationController _shootingStarController;
  late AnimationController _auroraController;
  late AnimationController _sushiController;
  late AnimationController _glowController;

  final List<Star> _stars = [];
  final List<Nebula> _nebulae = [];
  final List<ShootingStar> _shootingStars = [];
  final List<FloatingSushi> _floatingSushis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _spawnShootingStar();
          _shootingStarController.forward(from: 0);
        }
      });
    _shootingStarController.forward();

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _sushiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Generate 180 stars for richer sky
    for (int i = 0; i < 180; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.5,
        brightness: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 3 + 0.5,
        color: _getStarColor(),
      ));
    }

    // Generate warm nebulae (terracotta/pink/gold tones)
    _nebulae.addAll([
      Nebula(x: 0.2, y: 0.3, radius: 0.35, color: AppColors.terracotta.withOpacity(0.12), speed: 0.15),
      Nebula(x: 0.75, y: 0.2, radius: 0.3, color: AppColors.neonPurple.withOpacity(0.10), speed: 0.2),
      Nebula(x: 0.5, y: 0.7, radius: 0.25, color: AppColors.goldenRice.withOpacity(0.08), speed: 0.25),
      Nebula(x: 0.85, y: 0.65, radius: 0.2, color: AppColors.sakuraPink.withOpacity(0.10), speed: 0.18),
      Nebula(x: 0.15, y: 0.8, radius: 0.3, color: AppColors.warmGlow.withOpacity(0.07), speed: 0.22),
      Nebula(x: 0.6, y: 0.45, radius: 0.22, color: AppColors.terracottaLight.withOpacity(0.06), speed: 0.3),
    ]);

    // Generate shooting stars
    for (int i = 0; i < 3; i++) {
      _shootingStars.add(ShootingStar(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.5,
        angle: _random.nextDouble() * 0.3 + 0.15,
        speed: _random.nextDouble() * 0.5 + 0.5,
        length: _random.nextDouble() * 80 + 40,
      ));
    }

    // Generate floating sushis
    final sushiEmojis = ['🍣', '🍤', '🥑', '🥒', '🧀', '🍙', '🍥', '🐟', '🍚', '🥢'];
    for (int i = 0; i < 14; i++) {
      _floatingSushis.add(FloatingSushi(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        emoji: sushiEmojis[_random.nextInt(sushiEmojis.length)],
        size: _random.nextDouble() * 22 + 16,
        speed: _random.nextDouble() * 0.4 + 0.2,
        drift: _random.nextDouble() * 0.4 + 0.15,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: _random.nextDouble() * 0.5 - 0.25,
      ));
    }
  }

  void _spawnShootingStar() {
    if (_shootingStars.isNotEmpty) {
      _shootingStars[_random.nextInt(_shootingStars.length)].reset();
    }
  }

  Color _getStarColor() {
    final colors = [
      Colors.white,
      const Color(0xFFFFD700), // Gold
      const Color(0xFFF06292), // Warm pink
      const Color(0xFFFFB74D), // Warm orange
      const Color(0xFFBB86FC), // Soft purple
      const Color(0xFFE07A5F), // Terracotta
      const Color(0xFFFFCCBC), // Warm light
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    _shootingStarController.dispose();
    _auroraController.dispose();
    _sushiController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Deep space gradient base - warm undertones
          _buildGradientBase(),

          // Aurora borealis effect (warm tones)
          if (widget.enableAurora)
            AnimatedBuilder(
              animation: _auroraController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AuroraPainter(_auroraController.value),
                  size: Size.infinite,
                );
              },
            ),

          // Nebula layers
          AnimatedBuilder(
            animation: _nebulaController,
            builder: (context, child) {
              return CustomPaint(
                painter: NebulaPainter(_nebulae, _nebulaController.value),
                size: Size.infinite,
              );
            },
          ),

          // Stars layer with parallax
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(_stars, _starController.value),
                size: Size.infinite,
              );
            },
          ),

          // Shooting stars
          if (widget.enableShootingStars)
            AnimatedBuilder(
              animation: _shootingStarController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ShootingStarPainter(
                    _shootingStars,
                    _shootingStarController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

          // Floating sushi elements
          AnimatedBuilder(
            animation: _sushiController,
            builder: (context, child) {
              return Stack(
                children: _floatingSushis.map((sushi) {
                  final offset = _calculateSushiPosition(sushi, _sushiController.value);
                  return Positioned(
                    left: offset.dx,
                    top: offset.dy,
                    child: Transform.rotate(
                      angle: sushi.rotation + sushi.rotationSpeed * sin(_sushiController.value * 2 * pi),
                      child: Opacity(
                        opacity: 0.10,
                        child: Text(
                          sushi.emoji,
                          style: TextStyle(fontSize: sushi.size),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Cosmic glow overlays - warm terracotta tones
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return _buildCosmicGlows(_glowController.value);
            },
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }

  Widget _buildGradientBase() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0F2E), // Deep space purple
            Color(0xFF2D1B4E), // Nebula purple
            Color(0xFF1E1028), // Dark warm
            Color(0xFF0D0716), // Near black
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
    );
  }

  Widget _buildCosmicGlows(double animValue) {
    final glowIntensity = 0.5 + animValue * 0.5;
    return Stack(
      children: [
        // Top right warm purple glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.8,
              colors: [
                AppColors.neonPurple.withOpacity(0.08 * glowIntensity),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Bottom left terracotta glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 1.8,
              colors: [
                AppColors.terracotta.withOpacity(0.10 * glowIntensity),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Center golden glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 2.0,
              colors: [
                AppColors.goldenRice.withOpacity(0.04 * glowIntensity),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Top center pink glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                AppColors.sakuraPink.withOpacity(0.06 * glowIntensity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Offset _calculateSushiPosition(FloatingSushi sushi, double time) {
    final screenSize = MediaQuery.of(context).size;
    final baseX = sushi.x * screenSize.width;
    final baseY = sushi.y * screenSize.height;

    final driftX = sin(time * 2 * pi * sushi.drift + sushi.x * 10) * 40;
    final driftY = cos(time * 2 * pi * sushi.speed + sushi.y * 10) * 25;

    return Offset(
      (baseX + driftX).clamp(0, screenSize.width - 60),
      (baseY + driftY).clamp(0, screenSize.height - 60),
    );
  }
}

// Data classes
class Star {
  final double x;
  final double y;
  final double size;
  final double brightness;
  final double twinkleSpeed;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.color,
  });
}

class Nebula {
  final double x;
  final double y;
  final double radius;
  final Color color;
  final double speed;

  Nebula({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
  });
}

class ShootingStar {
  double x;
  double y;
  final double angle;
  final double speed;
  final double length;

  ShootingStar({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.length,
  });

  void reset() {
    x = Random().nextDouble();
    y = Random().nextDouble() * 0.5;
  }
}

class FloatingSushi {
  final double x;
  final double y;
  final String emoji;
  final double size;
  final double speed;
  final double drift;
  final double rotation;
  final double rotationSpeed;

  FloatingSushi({
    required this.x,
    required this.y,
    required this.emoji,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
  });
}

// Custom painters with warm terracotta palette
class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (sin((animationValue * star.twinkleSpeed * 2 * pi) + star.brightness * 10) + 1) / 2;
      final opacity = (star.brightness * 0.3 + twinkle * 0.7).clamp(0.3, 1.0);
      final yOffset = sin(animationValue * 2 * pi + star.x * 5) * 0.003 * size.height;

      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Enhanced glow effect for bright stars
      if (star.size > 2 && opacity > 0.7) {
        // Outer warm glow
        final outerGlowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(
          Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height),
          star.size * 2.5,
          outerGlowPaint,
        );
        // Inner glow
        final innerGlowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height),
          star.size * 1.5,
          innerGlowPaint,
        );
      }

      // Star core with cross spikes for bright stars
      final center = Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height);
      final coreSize = star.size * (0.4 + twinkle * 0.6);

      canvas.drawCircle(center, coreSize, paint);

      // Add cross spikes for the brightest stars
      if (star.size > 2.0 && opacity > 0.8) {
        final spikePaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.4)
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round;
        final spikeLength = coreSize * 2.5;
        canvas.drawLine(
          Offset(center.dx - spikeLength, center.dy),
          Offset(center.dx + spikeLength, center.dy),
          spikePaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - spikeLength),
          Offset(center.dx, center.dy + spikeLength),
          spikePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => true;
}

class NebulaPainter extends CustomPainter {
  final List<Nebula> nebulae;
  final double animationValue;

  NebulaPainter(this.nebulae, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final nebula in nebulae) {
      final x = (nebula.x + sin(animationValue * 2 * pi * nebula.speed) * 0.08) * size.width;
      final y = (nebula.y + cos(animationValue * 2 * pi * nebula.speed * 0.7) * 0.04) * size.height;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            nebula.color,
            nebula.color.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: nebula.radius * size.width,
          ),
        );

      canvas.drawCircle(
        Offset(x, y),
        nebula.radius * size.width,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) => true;
}

class ShootingStarPainter extends CustomPainter {
  final List<ShootingStar> shootingStars;
  final double animationValue;

  ShootingStarPainter(this.shootingStars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in shootingStars) {
      if (animationValue > 0.1) continue;

      final progress = (animationValue * 10) % 1;
      if (progress > 0.8) continue;

      final startX = (star.x - progress * star.angle) * size.width;
      final startY = (star.y - progress * star.speed * 0.3) * size.height;
      final endX = startX + star.length * star.angle;
      final endY = startY + star.length * star.speed * 0.3;

      final opacity = (1 - progress * 1.2).clamp(0.0, 1.0);

      // Warm-toned shooting star trail
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.goldenRice.withOpacity(0),
            Colors.white.withOpacity(opacity * 0.6),
            AppColors.terracottaLight.withOpacity(opacity),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromPoints(
          Offset(startX, startY),
          Offset(endX, endY),
        ))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // Glow
      final glowPaint = Paint()
        ..color = AppColors.goldenRice.withOpacity(opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + star.length * 0.2, startY + star.length * 0.1),
        glowPaint..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(ShootingStarPainter oldDelegate) => true;
}

class AuroraPainter extends CustomPainter {
  final double animationValue;

  AuroraPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Warm aurora colors (terracotta, gold, pink)
    final colors = [
      AppColors.terracotta.withOpacity(0.06),
      AppColors.sakuraPink.withOpacity(0.04),
      AppColors.goldenRice.withOpacity(0.03),
      AppColors.neonPurple.withOpacity(0.04),
    ];

    for (int i = 0; i < colors.length; i++) {
      final path = Path();
      final baseY = size.height * (0.12 + i * 0.07);

      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += size.width / 60) {
        final y = baseY +
            sin(x * 0.008 + animationValue * 2 * pi + i) * 35 +
            sin(x * 0.015 - animationValue * 1.5 * pi + i * 0.5) * 25;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors[i],
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, baseY - 50, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) => true;
}