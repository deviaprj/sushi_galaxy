import 'package:flutter/material.dart';

/// Sushi Galaxy Color Palette - Electric Galaxy Blue Theme
class AppColors {
  // Primary - Electric galaxy blue tones
  static const Color terracotta = Color(0xFF00A9FF);
  static const Color terracottaDark = Color(0xFF0074D6);
  static const Color terracottaLight = Color(0xFF6EDBFF);
  static const Color warmCream = Color(0xFFFFF3E0);
  static const Color warmBeige = Color(0xFFFFE0B2);
  static const Color restaurantLight = Color(0xFFFFFAF0);
  static const Color warmWood = Color(0xFF8B6914);
  static const Color warmWoodDark = Color(0xFF5D4410);

  // Dark backgrounds - deep space with warm undertones
  static const Color deepSpaceBlue = Color(0xFF1A0F2E);
  static const Color cosmosDark = Color(0xFF0D0716);
  static const Color nebulaPurple = Color(0xFF2D1B4E);
  static const Color midnightWarm = Color(0xFF1E1028);

  // Neon accents (space effect) - warmer palette
  static const Color neonPurple = Color(0xFFBB86FC);
  static const Color sakuraPink = Color(0xFFF06292);
  static const Color goldenRice = Color(0xFFFFB74D);
  static const Color warmGlow = Color(0xFFFF7043);
  static const Color mintGreen = Color(0xFF66BB6A);
  static const Color cosmicBlue = Color(0xFF5C6BC0);

  // Elements (Sushi types) - maximally distinct palette (each ~45° apart on hue wheel)
  static const Color salmon = Color(0xFFFF4081);      // Hot pink/magenta (was orange-red)
  static const Color tuna = Color(0xFF1565C0);        // Deep cobalt blue (was crimson) - tuna sashimi
  static const Color shrimp = Color(0xFFFF6D00);      // Vivid amber-orange
  static const Color tamago = Color(0xFFFFD600);      // Bright canary yellow (egg)
  static const Color avocado = Color(0xFF00C853);     // Vivid lime-green
  static const Color cucumber = Color(0xFF00B0FF);    // Sky cyan-blue
  static const Color cheese = Color(0xFF8D6E63);      // Caramel brown (clearly distinct from orange shrimp)
  static const Color sausage = Color(0xFF7C4DFF);     // Vivid violet-purple

  // UI
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x40000000);
  static const Color textPrimary = Color(0xFFFFF8E1);
  static const Color textSecondary = Color(0xFFB0A090);
  static const Color textAccent = Color(0xFF00A9FF);
  static const Color success = Color(0xFF66BB6A);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);

  // Gradients
  static const List<Color> warmSpaceGradient = [
    Color(0xFF1A0F2E),
    Color(0xFF2D1B4E),
    Color(0xFF1E1028),
    Color(0xFF0D0716),
  ];

  static const List<Color> terracottaGradient = [
    Color(0xFF6EDBFF),
    Color(0xFF00A9FF),
    Color(0xFF3B6CFF),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];
}

/// App Theme - Warm Terracotta Space Restaurant
class AppTheme {
  static ThemeData get lightRestaurantTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepSpaceBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.terracotta,
        secondary: AppColors.neonPurple,
        tertiary: AppColors.goldenRice,
        surface: AppColors.nebulaPurple,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Sushi Element Types
enum SushiType {
  salmon,
  tuna,
  shrimp,
  tamago,
  avocado,
  cucumber,
  cheese,
  sausage,
}

extension SushiTypeExtension on SushiType {
  Color get color {
    switch (this) {
      case SushiType.salmon:
        return AppColors.salmon;
      case SushiType.tuna:
        return AppColors.tuna;
      case SushiType.shrimp:
        return AppColors.shrimp;
      case SushiType.tamago:
        return AppColors.tamago;
      case SushiType.avocado:
        return AppColors.avocado;
      case SushiType.cucumber:
        return AppColors.cucumber;
      case SushiType.cheese:
        return AppColors.cheese;
      case SushiType.sausage:
        return AppColors.sausage;
    }
  }

  String get emoji {
    switch (this) {
      case SushiType.salmon:
        return '🍣';
      case SushiType.tuna:
        return '🐟';
      case SushiType.shrimp:
        return '🍤';
      case SushiType.tamago:
        return '🥚';
      case SushiType.avocado:
        return '🥑';
      case SushiType.cucumber:
        return '🥒';
      case SushiType.cheese:
        return '🧀';
      case SushiType.sausage:
        return '🌭';
    }
  }

  /// Darker shade for 3D depth
  Color get darkColor {
    switch (this) {
      case SushiType.salmon:
        return const Color(0xFFC51162); // deep pink
      case SushiType.tuna:
        return const Color(0xFF0D47A1); // navy blue
      case SushiType.shrimp:
        return const Color(0xFFE65100); // deep orange
      case SushiType.tamago:
        return const Color(0xFFF9A825); // amber
      case SushiType.avocado:
        return const Color(0xFF00701A); // dark green
      case SushiType.cucumber:
        return const Color(0xFF0081CB); // deep sky blue
      case SushiType.cheese:
        return const Color(0xFF5D4037); // deep caramel brown
      case SushiType.sausage:
        return const Color(0xFF4527A0); // deep violet
    }
  }

  /// Lighter shade for highlights
  Color get lightColor {
    switch (this) {
      case SushiType.salmon:
        return const Color(0xFFFF80AB); // light pink
      case SushiType.tuna:
        return const Color(0xFF5E92F3); // light blue
      case SushiType.shrimp:
        return const Color(0xFFFFAB40); // light amber
      case SushiType.tamago:
        return const Color(0xFFFFF176); // light yellow
      case SushiType.avocado:
        return const Color(0xFF69F0AE); // light lime
      case SushiType.cucumber:
        return const Color(0xFF80D8FF); // light sky blue
      case SushiType.cheese:
        return const Color(0xFFD7CCC8); // light beige-caramel
      case SushiType.sausage:
        return const Color(0xFFB388FF); // light violet
    }
  }

  int get score {
    switch (this) {
      case SushiType.salmon:
        return 10;
      case SushiType.tuna:
        return 10;
      case SushiType.shrimp:
        return 10;
      case SushiType.tamago:
        return 10;
      case SushiType.avocado:
        return 15;
      case SushiType.cucumber:
        return 15;
      case SushiType.cheese:
        return 20;
      case SushiType.sausage:
        return 25;
    }
  }
}