import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Enhanced particle system for match effects - warm terracotta palette
class MatchParticles extends StatefulWidget {
  final List<Offset> positions;
  final Color baseColor;
  final bool isActive;
  final VoidCallback? onComplete;

  const MatchParticles({
    super.key,
    required this.positions,
    required this.baseColor,
    this.isActive = false,
    this.onComplete,
  });

  @override
  State<MatchParticles> createState() => _MatchParticlesState();
}

class _MatchParticlesState extends State<MatchParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(MatchParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    final colors = [
      widget.baseColor,
      AppColors.goldenRice,
      AppColors.terracottaLight,
      Colors.white,
      widget.baseColor.withOpacity(0.7),
    ];

    for (final position in widget.positions) {
      for (int i = 0; i < 15; i++) {
        _particles.add(_Particle(
          position: position,
          velocity: Offset(
            _random.nextDouble() * 300 - 150,
            _random.nextDouble() * 300 - 150,
          ),
          size: _random.nextDouble() * 8 + 4,
          color: colors[_random.nextInt(colors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: _random.nextDouble() * 10 - 5,
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final time = progress;
      final gravity = 200 * time * time;
      final x = particle.position.dx + particle.velocity.dx * time;
      final y = particle.position.dy + particle.velocity.dy * time + gravity;
      final opacity = (1 - time).clamp(0.0, 1.0);
      final currentSize = particle.size * (1 - time * 0.5);
      final currentRotation = particle.rotation + particle.rotationSpeed * time;

      if (opacity <= 0 || currentSize <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      // Draw sparkle shape
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = i * pi / 2;
        final length = i % 2 == 0 ? currentSize : currentSize * 0.5;
        path.lineTo(cos(angle) * length, sin(angle) * length);
      }
      path.close();

      canvas.drawPath(path, paint);

      // Warm glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentSize * 0.5);
      canvas.drawPath(path, glowPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

/// Confetti effect for victory - warm colors
class ConfettiEffect extends StatefulWidget {
  final bool isActive;
  final int particleCount;
  final VoidCallback? onComplete;

  const ConfettiEffect({
    super.key,
    this.isActive = false,
    this.particleCount = 100,
    this.onComplete,
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateConfetti();
      _controller.forward(from: 0);
    }
  }

  void _generateConfetti() {
    _particles.clear();
    // Warm terracotta palette confetti colors
    final colors = [
      AppColors.terracotta,
      AppColors.sakuraPink,
      AppColors.goldenRice,
      AppColors.success,
      Colors.white,
      AppColors.terracottaLight,
      AppColors.neonPurple,
      const Color(0xFFFF8A65),
    ];

    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble() * screenSize.width,
        y: -_random.nextDouble() * 200,
        velocityX: _random.nextDouble() * 100 - 50,
        velocityY: _random.nextDouble() * 200 + 100,
        size: _random.nextDouble() * 10 + 5,
        color: colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: _random.nextDouble() * 10 - 5,
        shape: _random.nextInt(3),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final int shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress;
    final gravity = 400 * time * time;

    for (final particle in particles) {
      final x = particle.x + particle.velocityX * time;
      final y = particle.y + particle.velocityY * time + gravity;
      final opacity = (1 - time * 0.5).clamp(0.0, 1.0);
      final rotation = particle.rotation + particle.rotationSpeed * time;

      if (y > size.height + 50 || opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (particle.shape) {
        case 0: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, particle.size * 0.5, paint);
          break;
        case 2: // Star
          final path = Path();
          for (int i = 0; i < 5; i++) {
            final angle = i * 2 * pi / 5 - pi / 2;
            final outer = particle.size * 0.5;
            final inner = particle.size * 0.2;
            if (i == 0) {
              path.moveTo(cos(angle) * outer, sin(angle) * outer);
            } else {
              path.lineTo(cos(angle) * outer, sin(angle) * outer);
            }
            final innerAngle = angle + pi / 5;
            path.lineTo(cos(innerAngle) * inner, sin(innerAngle) * inner);
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Sparkle trail effect for power-ups - warm golden color
class SparkleTrail extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Color color;
  final bool isActive;
  final VoidCallback? onComplete;

  const SparkleTrail({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.color,
    this.isActive = false,
    this.onComplete,
  });

  @override
  State<SparkleTrail> createState() => _SparkleTrailState();
}

class _SparkleTrailState extends State<SparkleTrail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SparkleTrail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateSparkles();
      _controller.forward(from: 0);
    }
  }

  void _generateSparkles() {
    _sparkles.clear();
    final dx = widget.endPosition.dx - widget.startPosition.dx;
    final dy = widget.endPosition.dy - widget.startPosition.dy;

    for (int i = 0; i < 30; i++) {
      final t = _random.nextDouble();
      final baseX = widget.startPosition.dx + dx * t;
      final baseY = widget.startPosition.dy + dy * t;
      _sparkles.add(_Sparkle(
        x: baseX,
        y: baseY,
        offsetX: (_random.nextDouble() - 0.5) * 40,
        offsetY: (_random.nextDouble() - 0.5) * 40,
        size: _random.nextDouble() * 6 + 2,
        delay: _random.nextDouble() * 0.3,
        color: widget.color,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || _sparkles.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SparklePainter(_sparkles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Sparkle {
  final double x;
  final double y;
  final double offsetX;
  final double offsetY;
  final double size;
  final double delay;
  final Color color;

  _Sparkle({
    required this.x,
    required this.y,
    required this.offsetX,
    required this.offsetY,
    required this.size,
    required this.delay,
    required this.color,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double progress;

  _SparklePainter(this.sparkles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final adjustedProgress = ((progress - sparkle.delay) / (1 - sparkle.delay)).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final x = sparkle.x + sparkle.offsetX * adjustedProgress;
      final y = sparkle.y + sparkle.offsetY * adjustedProgress;
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);
      final currentSize = sparkle.size * (1 - adjustedProgress);

      if (opacity <= 0 || currentSize <= 0) continue;

      final paint = Paint()
        ..color = sparkle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), currentSize, paint);

      // Warm glow
      final glowPaint = Paint()
        ..color = sparkle.color.withOpacity(opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentSize);
      canvas.drawCircle(Offset(x, y), currentSize * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}