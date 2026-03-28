import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Animated restaurant background with space elements
class RestaurantBackground extends StatefulWidget {
  final Widget child;

  const RestaurantBackground({super.key, required this.child});

  @override
  State<RestaurantBackground> createState() => _RestaurantBackgroundState();
}

class _RestaurantBackgroundState extends State<RestaurantBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate floating elements (like lanterns, stars)
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        brightness: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 2 + 1,
        isPink: _random.nextBool(),
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
    return Stack(
      children: [
        // Base gradient - warm restaurant interior
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8E7), // Cream
                Color(0xFFFFE0B2), // Light orange
                Color(0xFFFFCC80), // Warm
              ],
            ),
          ),
        ),
        // Floating decorative elements
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: FloatingElementsPainter(_stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Subtle warm glow overlay
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                AppColors.warmGlow.withOpacity(0.1),
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
                AppColors.goldenRice.withOpacity(0.08),
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
}

class Star {
  final double x;
  final double y;
  final double size;
  final double brightness;
  final double twinkleSpeed;
  final bool isPink;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.isPink,
  });
}

class FloatingElementsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  FloatingElementsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (sin((animationValue * star.twinkleSpeed * 2 * 3.14159) + star.brightness * 10) + 1) / 2;
      final opacity = (star.brightness * 0.3 + twinkle * 0.7).clamp(0.2, 0.8);
      final yOffset = sin(animationValue * 2 * 3.14159 + star.x * 5) * 0.01 * size.height;

      final color = star.isPink
          ? AppColors.sakuraPink.withOpacity(opacity)
          : AppColors.goldenRice.withOpacity(opacity);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, (star.y * size.height + yOffset) % size.height),
        star.size * (0.5 + twinkle * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FloatingElementsPainter oldDelegate) => true;
}