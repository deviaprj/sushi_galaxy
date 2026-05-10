import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';

// Game State
enum GameState {
  idle,
  playing,
  paused,
  levelComplete,
  levelFailed,
}

/// Current game state
class GameStatus {
  final GameState state;
  final int currentLevel;
  final int movesRemaining;
  final int score;
  final int combo;
  final bool isLoading;

  const GameStatus({
    this.state = GameState.idle,
    this.currentLevel = 1,
    this.movesRemaining = 20,
    this.score = 0,
    this.combo = 0,
    this.isLoading = false,
  });

  GameStatus copyWith({
    GameState? state,
    int? currentLevel,
    int? movesRemaining,
    int? score,
    int? combo,
    bool? isLoading,
  }) {
    return GameStatus(
      state: state ?? this.state,
      currentLevel: currentLevel ?? this.currentLevel,
      movesRemaining: movesRemaining ?? this.movesRemaining,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Game Status Provider
final gameStatusProvider =
    StateNotifierProvider<GameStatusNotifier, GameStatus>((ref) {
  return GameStatusNotifier();
});

class GameStatusNotifier extends StateNotifier<GameStatus> {
  GameStatusNotifier() : super(const GameStatus());

  void startLevel(int levelNumber, int moveLimit) {
    state = GameStatus(
      state: GameState.playing,
      currentLevel: levelNumber,
      movesRemaining: moveLimit,
      score: 0,
      combo: 0,
    );
  }

  void updateScore(int score) {
    state = state.copyWith(score: score);
  }

  void decrementMoves() {
    state = state.copyWith(movesRemaining: state.movesRemaining - 1);
  }

  void incrementCombo() {
    state = state.copyWith(combo: state.combo + 1);
  }

  void resetCombo() {
    state = state.copyWith(combo: 0);
  }

  void completeLevel() {
    state = state.copyWith(state: GameState.levelComplete);
  }

  void failLevel() {
    state = state.copyWith(state: GameState.levelFailed);
  }

  void reset() {
    state = const GameStatus();
  }
}

// Game Engine Provider
final gameEngineProvider = Provider<GameEngine>((ref) {
  return GameEngine();
});

// Level Generator Provider
final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

// Current Level Provider
final currentLevelProvider = Provider<Level>((ref) {
  final generator = ref.watch(levelGeneratorProvider);
  final status = ref.watch(gameStatusProvider);
  return generator.generate(levelNumber: status.currentLevel);
});

// Player Progress
class PlayerProgress {
  final int currentLevel;
  final int totalStars;
  final int gems;
  final int highScore;
  final List<int> completedLevels;
  final int currentStreak;
  final DateTime? lastPlayedAt;

  const PlayerProgress({
    this.currentLevel = 1,
    this.totalStars = 0,
    this.gems = 100,
    this.highScore = 0,
    this.completedLevels = const [],
    this.currentStreak = 0,
    this.lastPlayedAt,
  });

  PlayerProgress copyWith({
    int? currentLevel,
    int? totalStars,
    int? gems,
    int? highScore,
    List<int>? completedLevels,
    int? currentStreak,
    DateTime? lastPlayedAt,
  }) {
    return PlayerProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      totalStars: totalStars ?? this.totalStars,
      gems: gems ?? this.gems,
      highScore: highScore ?? this.highScore,
      completedLevels: completedLevels ?? this.completedLevels,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}

final playerProgressProvider =
    StateNotifierProvider<PlayerProgressNotifier, PlayerProgress>((ref) {
  return PlayerProgressNotifier();
});

class PlayerProgressNotifier extends StateNotifier<PlayerProgress> {
  PlayerProgressNotifier() : super(const PlayerProgress());

  void addGems(int amount) {
    state = state.copyWith(gems: state.gems + amount);
  }

  void spendGems(int amount) {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
    }
  }

  void completeLevel(int level, int score, int stars) {
    final completed = List<int>.from(state.completedLevels);
    if (!completed.contains(level)) {
      completed.add(level);
    }

    state = state.copyWith(
      currentLevel: level + 1,
      totalStars: state.totalStars + stars,
      completedLevels: completed,
      highScore: score > state.highScore ? score : state.highScore,
      lastPlayedAt: DateTime.now(),
    );
  }

  void updateStreak() {
    final now = DateTime.now();
    final lastPlayed = state.lastPlayedAt;

    if (lastPlayed != null) {
      final daysDiff = now.difference(lastPlayed).inDays;
      if (daysDiff == 1) {
        state = state.copyWith(currentStreak: state.currentStreak + 1);
      } else if (daysDiff > 1) {
        state = state.copyWith(currentStreak: 1);
      }
    } else {
      state = state.copyWith(currentStreak: 1);
    }
  }
}

// Lives System
class LivesSystem {
  final int currentLives;
  final int maxLives;
  final int rechargeMinutes;
  final DateTime? lastRechargeAt;

  const LivesSystem({
    this.currentLives = 5,
    this.maxLives = 5,
    this.rechargeMinutes = 30,
    this.lastRechargeAt,
  });

  LivesSystem copyWith({
    int? currentLives,
    int? maxLives,
    int? rechargeMinutes,
    DateTime? lastRechargeAt,
  }) {
    return LivesSystem(
      currentLives: currentLives ?? this.currentLives,
      maxLives: maxLives ?? this.maxLives,
      rechargeMinutes: rechargeMinutes ?? this.rechargeMinutes,
      lastRechargeAt: lastRechargeAt ?? this.lastRechargeAt,
    );
  }

  bool get canPlay => currentLives > 0;

  Duration? get timeUntilNextLife {
    if (currentLives >= maxLives) return null;
    if (lastRechargeAt == null) return Duration.zero;

    final elapsed = DateTime.now().difference(lastRechargeAt!);
    final rechargeTime = Duration(minutes: rechargeMinutes);
    final remaining = rechargeTime - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}

final livesProvider = StateNotifierProvider<LivesNotifier, LivesSystem>((ref) {
  return LivesNotifier();
});

class LivesNotifier extends StateNotifier<LivesSystem> {
  LivesNotifier() : super(const LivesSystem());

  void useLife() {
    if (state.currentLives > 0) {
      state = state.copyWith(
        currentLives: state.currentLives - 1,
        lastRechargeAt: DateTime.now(),
      );
    }
  }

  void addLife() {
    if (state.currentLives < state.maxLives) {
      state = state.copyWith(
        currentLives: state.currentLives + 1,
        lastRechargeAt: DateTime.now(),
      );
    }
  }

  void refillLives() {
    state = state.copyWith(
      currentLives: state.maxLives,
      lastRechargeAt: DateTime.now(),
    );
  }

  void tick() {
    // Called every minute to check for recharge
    final timeUntil = state.timeUntilNextLife;
    if (timeUntil != null && timeUntil.inMinutes <= 0) {
      addLife();
    }
  }
}

// Settings
class AppSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool notificationsEnabled;

  const AppSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  void toggleMusic() {
    state = state.copyWith(musicEnabled: !state.musicEnabled);
  }

  void toggleHaptics() {
    state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }
}