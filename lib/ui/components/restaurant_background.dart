import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Animated cosmic background with stars, nebulae, and floating elements
class RestaurantBackground extends StatefulWidget {
  final Widget child;

  const RestaurantBackground({super.key, required this.child});

  @override
  State<RestaurantBackground> createState() => _RestaurantBackgroundState();
}

class _RestaurantBackgroundState extends State<RestaurantBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late AnimationController _sushiController;
  final List<Star> _stars = [];
  final List<Nebula> _nebulae = [];
  final List<FloatingSushi> _floatingSushis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Main star animation
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Nebula slow drift
    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Floating sushi movement
    _sushiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate stars
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.5,
        brightness: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 3 + 0.5,
        color: _getStarColor(),
      ));
    }

    // Generate nebulae
    for (int i = 0; i < 4; i++) {
      _nebulae.add(Nebula(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 0.4 + 0.2,
        color: _getNebulaColor(i),
        speed: _random.nextDouble() * 0.5 + 0.2,
      ));
    }

    // Generate floating sushis
    final sushiEmojis = ['🍣', '🍤', '🥑', '🥒', '🧀'];
    for (int i = 0; i < 8; i++) {
      _floatingSushis.add(FloatingSushi(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        emoji: sushiEmojis[_random.nextInt(sushiEmojis.length)],
        size: _random.nextDouble() * 20 + 20,
        speed: _random.nextDouble() * 0.5 + 0.3,
        drift: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  Color _getStarColor() {
    final colors = [
      Colors.white,
      const Color(0xFFFFD700), // Gold
      const Color(0xFFADD8E6), // Light blue
      const Color(0xFFFFB6C1), // Light pink
    ];
    return colors[_random.nextInt(colors.length)];
  }

  Color _getNebulaColor(int index) {
    final colors = [
      AppColors.neonPurple.withOpacity(0.15),
      AppColors.sakuraPink.withOpacity(0.12),
      AppColors.goldenRice.withOpacity(0.1),
      const Color(0xFF1565C0).withOpacity(0.1),
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    _sushiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2A), // Deep space blue
                Color(0xFF1B263B), // Dark blue
                Color(0xFF2C1810), // Warm dark
              ],
            ),
          ),
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

        // Stars layer
        AnimatedBuilder(
          animation: _starController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarPainter(_stars, _starController.value),
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
                  child: Opacity(
                    opacity: 0.15,
                    child: Text(
                      sushi.emoji,
                      style: TextStyle(fontSize: sushi.size),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Subtle cosmic glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                AppColors.neonPurple.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 1.5,
              colors: [
                AppColors.sakuraPink.withOpacity(0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }

  Offset _calculateSushiPosition(FloatingSushi sushi, double time) {
    final screenSize = MediaQuery.of(context).size;
    final baseX = sushi.x * screenSize.width;
    final baseY = sushi.y * screenSize.height;

    final driftX = sin(time * 2 * pi * sushi.drift + sushi.x * 10) * 30;
    final driftY = cos(time * 2 * pi * sushi.speed + sushi.y * 10) * 20;

    return Offset(
      (baseX + driftX).clamp(0, screenSize.width - 50),
      (baseY + driftY).clamp(0, screenSize.height - 50),
    );
  }
}

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

class FloatingSushi {
  final double x;
  final double y;
  final String emoji;
  final double size;
  final double speed;
  final double drift;

  FloatingSushi({
    required this.x,
    required this.y,
    required this.emoji,
    required this.size,
    required this.speed,
    required this.drift,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (sin((animationValue * star.twinkleSpeed * 2 * pi) + star.brightness * 10) + 1) / 2;
      final opacity = (star.brightness * 0.3 + twinkle * 0.7).clamp(0.3, 1.0);
      final yOffset = sin(animationValue * 2 * pi + star.x * 5) * 0.005 * size.height;

      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Glow effect for bright stars
      if (star.size > 2 && opacity > 0.7) {
        final glowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height),
          star.size * 1.5,
          glowPaint,
        );
      }

      canvas.drawCircle(
        Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height),
        star.size * (0.5 + twinkle * 0.5),
        paint,
      );
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
      final x = (nebula.x + sin(animationValue * 2 * pi * nebula.speed) * 0.1) * size.width;
      final y = (nebula.y + cos(animationValue * 2 * pi * nebula.speed * 0.7) * 0.05) * size.height;

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

/// Simple particle effect for matches
class ParticleEffect extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ParticleEffect({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.trigger) {
      _generateParticles();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ParticleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        angle: _random.nextDouble() * 2 * pi,
        speed: _random.nextDouble() * 100 + 50,
        size: _random.nextDouble() * 6 + 2,
        color: _getParticleColor(),
      ));
    }
  }

  Color _getParticleColor() {
    final colors = [
      AppColors.goldenRice,
      AppColors.sakuraPink,
      AppColors.neonPurple,
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.trigger) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _controller.value),
                size: Size.infinite,
              );
            },
          ),
        ),
      ],
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + cos(particle.angle) * distance;
      final y = center.dy + sin(particle.angle) * distance;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}