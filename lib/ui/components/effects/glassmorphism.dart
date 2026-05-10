import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Glassmorphism container with blur and frost effect - warm terracotta theme
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(opacity * 0.5),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(22),
              border: Border.all(
                color: borderColor ?? AppColors.terracotta.withOpacity(0.25),
                width: borderWidth,
              ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: AppColors.terracotta.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Neon glow button with warm terracotta color
class NeonButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.glowColor = AppColors.terracotta,
    this.glowIntensity = 0.8,
    this.padding,
    this.borderRadius,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: widget.glowIntensity * 0.5,
      end: widget.glowIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: _isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.glowColor.withOpacity(0.8),
                  widget.glowColor.withOpacity(0.6),
                ],
              ),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.6),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 40 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Glowing text effect with warm colors
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;

  const GlowText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = AppColors.terracotta,
    this.glowRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

    return Stack(
      children: [
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = glowRadius
              ..color = glowColor.withOpacity(0.5)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
          ),
        ),
        Text(text, style: textStyle),
      ],
    );
  }
}

/// Animated gradient border with warm terracotta colors
class GradientBorder extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color> gradientColors;
  final Duration animationDuration;

  const GradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = 18.0,
    this.gradientColors = const [AppColors.terracotta, AppColors.sakuraPink, AppColors.goldenRice],
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: SweepGradient(
          colors: [...gradientColors, gradientColors.first],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          color: AppColors.deepSpaceBlue,
        ),
        child: child,
      ),
    );
  }
}

/// Pulsing glow indicator with warm theme
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.terracotta,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.3 * _animation.value),
                blurRadius: 20 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Screen shake effect wrapper
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final Duration duration;
  final double intensity;
  final VoidCallback? onComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shake = false,
    this.duration = const Duration(milliseconds: 500),
    this.intensity = 10.0,
    this.onComplete,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = sin(_animation.value * pi * 8);
        return Transform.translate(
          offset: Offset(sineValue * widget.intensity * (1 - _animation.value), 0),
          child: widget.child,
        );
      },
    );
  }
}