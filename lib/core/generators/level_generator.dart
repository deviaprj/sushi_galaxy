import 'dart:math';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Level objective types
enum ObjectiveType {
  score,
  collect,
  clearBlockers,
  dropIngredients,
  fillZones,
  destroyInOrder,
}

/// Difficulty parameters for level generation
class DifficultyParams {
  final double targetWinRate;
  final int moveLimit;
  final int targetScore;
  final int gridSize;
  final int sushiTypeCount; // Fewer types = easier matches

  const DifficultyParams({
    this.targetWinRate = 0.7,
    this.moveLimit = 20,
    this.targetScore = 1000,
    this.gridSize = 8,
    this.sushiTypeCount = 8,
  });
}

/// Level configuration
class Level {
  final int number;
  final int moveLimit;
  final int targetScore;
  final ObjectiveType objectiveType;
  final Map<SushiType, int>? collectTargets;
  final int gridSize;
  final int difficulty;
  final String name;
  final bool isEvent;
  final int sushiTypeCount;
  final int comboTier;

  const Level({
    required this.number,
    required this.moveLimit,
    required this.targetScore,
    required this.objectiveType,
    this.collectTargets,
    this.gridSize = 8,
    this.difficulty = 1,
    this.name = '',
    this.isEvent = false,
    this.sushiTypeCount = 8,
    this.comboTier = 0,
  });

  Level copyWith({
    int? number,
    int? moveLimit,
    int? targetScore,
    ObjectiveType? objectiveType,
    Map<SushiType, int>? collectTargets,
    int? gridSize,
    int? difficulty,
    String? name,
    bool? isEvent,
    int? sushiTypeCount,
    int? comboTier,
  }) {
    return Level(
      number: number ?? this.number,
      moveLimit: moveLimit ?? this.moveLimit,
      targetScore: targetScore ?? this.targetScore,
      objectiveType: objectiveType ?? this.objectiveType,
      collectTargets: collectTargets ?? this.collectTargets,
      gridSize: gridSize ?? this.gridSize,
      difficulty: difficulty ?? this.difficulty,
      name: name ?? this.name,
      isEvent: isEvent ?? this.isEvent,
      sushiTypeCount: sushiTypeCount ?? this.sushiTypeCount,
      comboTier: comboTier ?? this.comboTier,
    );
  }
}

/// Level generator with progressive difficulty
class LevelGenerator {
  final Random _random = Random();

  Level generate({
    required int levelNumber,
    DifficultyParams? params,
  }) {
    final difficultyParams = params ?? _getDifficultyForLevel(levelNumber);
    final objectiveType = ObjectiveType.values[
        (levelNumber ~/ 5) % ObjectiveType.values.length];
    final name = _generateLevelName(levelNumber);

    return Level(
      number: levelNumber,
      moveLimit: difficultyParams.moveLimit,
      targetScore: difficultyParams.targetScore,
      objectiveType: objectiveType,
      collectTargets: objectiveType == ObjectiveType.collect
          ? _generateCollectTargets(levelNumber)
          : null,
      gridSize: difficultyParams.gridSize,
      difficulty: _calculateDifficulty(levelNumber),
      name: name,
      sushiTypeCount: difficultyParams.sushiTypeCount,
      comboTier: _comboTierForLevel(levelNumber),
    );
  }

  int _comboTierForLevel(int level) {
    if (level < 5) return 0;
    if (level < 10) return 1;
    if (level < 15) return 2;
    if (level < 20) return 3;
    if (level < 30) return 4;
    if (level < 40) return 5;
    if (level < 50) return 6;
    return 7;
  }

  /// Progressive difficulty: fewer sushi types early, more moves, smaller grids
  DifficultyParams _getDifficultyForLevel(int level) {
    if (level <= 5) {
      // Tutorial - very easy: only 5 sushi types, small grid, many moves
      return const DifficultyParams(
        targetWinRate: 0.98,
        moveLimit: 30,
        targetScore: 300,
        gridSize: 6,
        sushiTypeCount: 5,
      );
    } else if (level <= 10) {
      // Easy: 6 types
      return const DifficultyParams(
        targetWinRate: 0.95,
        moveLimit: 28,
        targetScore: 500,
        gridSize: 6,
        sushiTypeCount: 6,
      );
    } else if (level <= 20) {
      // Easy-medium: 6 types, 7x7 grid
      return const DifficultyParams(
        targetWinRate: 0.90,
        moveLimit: 25,
        targetScore: 800,
        gridSize: 7,
        sushiTypeCount: 6,
      );
    } else if (level <= 35) {
      // Medium: 7 types
      return const DifficultyParams(
        targetWinRate: 0.85,
        moveLimit: 23,
        targetScore: 1200,
        gridSize: 7,
        sushiTypeCount: 7,
      );
    } else if (level <= 60) {
      // Medium-hard: 7 types, 8x8 grid
      return const DifficultyParams(
        targetWinRate: 0.75,
        moveLimit: 22,
        targetScore: 1600,
        gridSize: 8,
        sushiTypeCount: 7,
      );
    } else if (level <= 100) {
      // Hard: all 8 types
      return const DifficultyParams(
        targetWinRate: 0.65,
        moveLimit: 20,
        targetScore: 2200,
        gridSize: 8,
        sushiTypeCount: 8,
      );
    } else {
      // Expert - procedural difficulty
      return DifficultyParams(
        targetWinRate: 0.50,
        moveLimit: 16 + _random.nextInt(6),
        targetScore: 2500 + (level - 100) * 50,
        gridSize: 8 + ((level - 100) ~/ 50).clamp(0, 2),
        sushiTypeCount: 8,
      );
    }
  }

  int _calculateDifficulty(int level) {
    if (level <= 5) return 1;
    if (level <= 10) return 2;
    if (level <= 20) return 3;
    if (level <= 35) return 4;
    if (level <= 60) return 5;
    if (level <= 100) return 6;
    return 7;
  }

  String _generateLevelName(int level) {
    final names = [
      'First Roll',
      'California Dream',
      'Spicy Tuna',
      'Dragon Roll',
      'Rainbow Garden',
      'Ocean Wave',
      'Samurai Plate',
      "Chef's Special",
      'Midnight Sushi',
      'Galaxy Feast',
    ];

    if (level <= 10) {
      return 'Training Level $level';
    } else if (level <= 100) {
      return names[(level - 11) ~/ 10 % names.length];
    } else {
      return 'Cosmic Level $level';
    }
  }

  Map<SushiType, int>? _generateCollectTargets(int level) {
    final targetCount = 10 + (level ~/ 10) * 5;
    final sushiType = SushiType.values[level % SushiType.values.length];
    return {sushiType: targetCount};
  }

  ValidationResult validate(Level level) {
    return const ValidationResult(
      isValid: true,
      estimatedWinRate: 0.7,
      issues: [],
    );
  }

  Level balance(Level level, double targetWinRate) {
    return level.copyWith(
      moveLimit: level.moveLimit + ((targetWinRate - 0.7) * 10).round(),
    );
  }
}

class ValidationResult {
  final bool isValid;
  final double estimatedWinRate;
  final List<String> issues;

  const ValidationResult({
    required this.isValid,
    required this.estimatedWinRate,
    required this.issues,
  });
}