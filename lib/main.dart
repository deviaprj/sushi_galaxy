import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style - warm terracotta theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.cosmosDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: SushiGalaxyApp()));
}

class SushiGalaxyApp extends StatelessWidget {
  const SushiGalaxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sushi Galaxy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightRestaurantTheme,
      home: const SplashScreen(),
    );
  }
}

/// Enhanced splash screen with warm terracotta animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textController.forward();
    _loadApp();
  }

  Future<void> _loadApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Warm space gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0F2E),
                  Color(0xFF2D1B4E),
                  AppColors.cosmosDark,
                ],
              ),
            ),
          ),

          // Animated glow effects - warm terracotta tones
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (context, child) {
              return Stack(
                children: [
                  // Terracotta glow (top left)
                  Positioned(
                    top: 80,
                    left: 40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.terracotta
                                .withOpacity(_glowOpacity.value * 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Golden glow (bottom right)
                  Positioned(
                    bottom: 120,
                    right: 40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldenRice
                                .withOpacity(_glowOpacity.value * 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with warm glow
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.terracotta
                                  .withOpacity(_glowOpacity.value * 0.6),
                              blurRadius: 45,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: AppColors.goldenRice
                                  .withOpacity(_glowOpacity.value * 0.3),
                              blurRadius: 65,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🍣',
                            style: TextStyle(fontSize: 95),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 45),

                // Title with warm terracotta gradient
                FadeTransition(
                  opacity: _textOpacity,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.terracottaLight,
                        AppColors.terracotta,
                        AppColors.goldenRice,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'SUSHI GALAXY',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: AppColors.terracotta,
                            blurRadius: 25,
                          ),
                          Shadow(
                            color: AppColors.goldenRice,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 70),

                // Loading indicator with terracotta theme
                FadeTransition(
                  opacity: _textOpacity,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.terracotta.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                      backgroundColor:
                          AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}