import 'package:flutter/material.dart';

/// Sushi Galaxy Color Palette - Warm Terracotta Space Theme
class AppColors {
  // Primary - Warm terracotta and restaurant tones
  static const Color terracotta = Color(0xFFE07A5F);
  static const Color terracottaDark = Color(0xFFC4603F);
  static const Color terracottaLight = Color(0xFFF2A68D);
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

  // Elements (Sushi types) - distinct high-contrast palette
  static const Color salmon = Color(0xFFFF5722);     // Deep orange-red
  static const Color tuna = Color(0xFFD32F2F);        // Rich crimson
  static const Color shrimp = Color(0xFFFF9800);      // Bright orange
  static const Color tamago = Color(0xFFFFEB3B);      // Bright yellow
  static const Color avocado = Color(0xFF4CAF50);     // Rich green
  static const Color cucumber = Color(0xFF00BCD4);    // Teal/cyan
  static const Color cheese = Color(0xFFFFC107);      // Amber gold
  static const Color sausage = Color(0xFF9C27B0);     // Purple

  // UI
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x40000000);
  static const Color textPrimary = Color(0xFFFFF8E1);
  static const Color textSecondary = Color(0xFFB0A090);
  static const Color textAccent = Color(0xFFE07A5F);
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
    Color(0xFFE07A5F),
    Color(0xFFF06292),
    Color(0xFFBB86FC),
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
        return const Color(0xFFBF360C);
      case SushiType.tuna:
        return const Color(0xFFB71C1C);
      case SushiType.shrimp:
        return const Color(0xFFE65100);
      case SushiType.tamago:
        return const Color(0xFFF9A825);
      case SushiType.avocado:
        return const Color(0xFF2E7D32);
      case SushiType.cucumber:
        return const Color(0xFF00838F);
      case SushiType.cheese:
        return const Color(0xFFFF8F00);
      case SushiType.sausage:
        return const Color(0xFF6A1B9A);
    }
  }

  /// Lighter shade for highlights
  Color get lightColor {
    switch (this) {
      case SushiType.salmon:
        return const Color(0xFFFFAB91);
      case SushiType.tuna:
        return const Color(0xFFEF9A9A);
      case SushiType.shrimp:
        return const Color(0xFFFFCC80);
      case SushiType.tamago:
        return const Color(0xFFFFF9C4);
      case SushiType.avocado:
        return const Color(0xFFA5D6A7);
      case SushiType.cucumber:
        return const Color(0xFFB2EBF2);
      case SushiType.cheese:
        return const Color(0xFFFFE082);
      case SushiType.sausage:
        return const Color(0xFFCE93D8);
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