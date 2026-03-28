import 'package:flutter/material.dart';

/// Sushi Galaxy Color Palette - Light Restaurant Theme
class AppColors {
  // Primary - Light restaurant background
  static const Color restaurantCream = Color(0xFFFFF8E7);
  static const Color restaurantLight = Color(0xFFFFFAF0);
  static const Color warmWood = Color(0xFF8B6914);

  // Dark (for text)
  static const Color deepSpaceBlue = Color(0xFF2C1810);
  static const Color cosmosDark = Color(0xFF3D2317);

  // Secondary - Neon accents (space effect)
  static const Color neonPurple = Color(0xFF9C27B0);
  static const Color sakuraPink = Color(0xFFE91E63);
  static const Color goldenRice = Color(0xFFFFB300);
  static const Color warmGlow = Color(0xFFFF7043);

  // Elements (Sushi types) - more vibrant
  static const Color salmon = Color(0xFFFF6F61);
  static const Color tuna = Color(0xFFD32F2F);
  static const Color shrimp = Color(0xFFFF8A80);
  static const Color tamago = Color(0xFFFFCA28);
  static const Color avocado = Color(0xFF4CAF50);
  static const Color cucumber = Color(0xFF81C784);
  static const Color cheese = Color(0xFFFFEB3B);
  static const Color sausage = Color(0xFF795548);

  // UI
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color textPrimary = Color(0xFF2C1810);
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
}

/// App Theme
class AppTheme {
  static ThemeData get lightRestaurantTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.restaurantCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.sakuraPink,
        secondary: AppColors.neonPurple,
        tertiary: AppColors.goldenRice,
        surface: AppColors.restaurantLight,
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
          backgroundColor: AppColors.sakuraPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
        return '🦐';
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