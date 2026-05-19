import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';
import 'package:sushi_galaxy/core/generators/level_generator.dart';
import 'package:sushi_galaxy/core/store/auth_providers.dart';

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

  void startLevel(int levelNumber, int moveLimit, {int initialScore = 0}) {
    state = GameStatus(
      state: GameState.playing,
      currentLevel: levelNumber,
      movesRemaining: moveLimit,
      score: initialScore,
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

  void setCombo(int combo) {
    state = state.copyWith(combo: combo);
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
  final int hammerBoosters;
  final int shuffleBoosters;
  final int highScore;
  final List<int> completedLevels;
  final int currentStreak;
  final DateTime? lastPlayedAt;
  final int storedTimeSeconds; // time bonus stored from ads/events/shop

  const PlayerProgress({
    this.currentLevel = 1,
    this.totalStars = 0,
    this.gems = 100,
    this.hammerBoosters = 0,
    this.shuffleBoosters = 0,
    this.highScore = 0,
    this.completedLevels = const [],
    this.currentStreak = 0,
    this.lastPlayedAt,
    this.storedTimeSeconds = 0,
  });

  PlayerProgress copyWith({
    int? currentLevel,
    int? totalStars,
    int? gems,
    int? hammerBoosters,
    int? shuffleBoosters,
    int? highScore,
    List<int>? completedLevels,
    int? currentStreak,
    DateTime? lastPlayedAt,
    int? storedTimeSeconds,
  }) {
    return PlayerProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      totalStars: totalStars ?? this.totalStars,
      gems: gems ?? this.gems,
      hammerBoosters: hammerBoosters ?? this.hammerBoosters,
      shuffleBoosters: shuffleBoosters ?? this.shuffleBoosters,
      highScore: highScore ?? this.highScore,
      completedLevels: completedLevels ?? this.completedLevels,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      storedTimeSeconds: storedTimeSeconds ?? this.storedTimeSeconds,
    );
  }
}

final playerProgressProvider =
    StateNotifierProvider<PlayerProgressNotifier, PlayerProgress>((ref) {
  final notifier = PlayerProgressNotifier(ref);
  ref.listen(authSessionProvider.select((state) => state.session?.storageKey),
      (_, __) {
    notifier.reload();
  });
  return notifier;
});

class PlayerProgressNotifier extends StateNotifier<PlayerProgress> {
  PlayerProgressNotifier(this._ref) : super(const PlayerProgress()) {
    _load();
  }

  final Ref _ref;

  static const _keyLevel = 'pp_level';
  static const _keyStars = 'pp_stars';
  static const _keyGems = 'pp_gems';
  static const _keyHammerBoosters = 'pp_hammer_boosters';
  static const _keyShuffleBoosters = 'pp_shuffle_boosters';
  static const _keyHighScore = 'pp_highscore';
  static const _keyStreak = 'pp_streak';
  static const _keyCompleted = 'pp_completed';
  static const _keyStoredTime = 'pp_stored_time';

  String _scopedKey(String key, String prefix) => '${prefix}_$key';

  String get _currentPrefix =>
      _ref.read(authSessionProvider).session?.storageKey ?? 'local_guest';

  Future<void> reload() async {
    await _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _currentPrefix;
    final completedRaw =
        prefs.getStringList(_scopedKey(_keyCompleted, prefix)) ?? [];
    final completed = completedRaw.map(int.parse).toList();
    state = PlayerProgress(
      currentLevel: prefs.getInt(_scopedKey(_keyLevel, prefix)) ?? 1,
      totalStars: prefs.getInt(_scopedKey(_keyStars, prefix)) ?? 0,
      gems: prefs.getInt(_scopedKey(_keyGems, prefix)) ?? 100,
      hammerBoosters:
        prefs.getInt(_scopedKey(_keyHammerBoosters, prefix)) ?? 0,
      shuffleBoosters:
        prefs.getInt(_scopedKey(_keyShuffleBoosters, prefix)) ?? 0,
      highScore: prefs.getInt(_scopedKey(_keyHighScore, prefix)) ?? 0,
      completedLevels: completed,
      currentStreak: prefs.getInt(_scopedKey(_keyStreak, prefix)) ?? 0,
      storedTimeSeconds: prefs.getInt(_scopedKey(_keyStoredTime, prefix)) ?? 0,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _currentPrefix;
    await prefs.setInt(_scopedKey(_keyLevel, prefix), state.currentLevel);
    await prefs.setInt(_scopedKey(_keyStars, prefix), state.totalStars);
    await prefs.setInt(_scopedKey(_keyGems, prefix), state.gems);
    await prefs.setInt(
      _scopedKey(_keyHammerBoosters, prefix),
      state.hammerBoosters,
    );
    await prefs.setInt(
      _scopedKey(_keyShuffleBoosters, prefix),
      state.shuffleBoosters,
    );
    await prefs.setInt(_scopedKey(_keyHighScore, prefix), state.highScore);
    await prefs.setInt(_scopedKey(_keyStreak, prefix), state.currentStreak);
    await prefs.setStringList(
      _scopedKey(_keyCompleted, prefix),
      state.completedLevels.map((e) => e.toString()).toList(),
    );
    await prefs.setInt(
      _scopedKey(_keyStoredTime, prefix),
      state.storedTimeSeconds,
    );
  }

  void addGems(int amount) {
    state = state.copyWith(gems: state.gems + amount);
    _save();
  }

  void spendGems(int amount) {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
      _save();
    }
  }

  void addStoredTime(int seconds) {
    state = state.copyWith(storedTimeSeconds: state.storedTimeSeconds + seconds);
    _save();
  }

  void addHammerBoosters(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(hammerBoosters: state.hammerBoosters + amount);
    _save();
  }

  void addShuffleBoosters(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(shuffleBoosters: state.shuffleBoosters + amount);
    _save();
  }

  bool useHammerBooster() {
    if (state.hammerBoosters <= 0) return false;
    state = state.copyWith(hammerBoosters: state.hammerBoosters - 1);
    _save();
    return true;
  }

  bool useShuffleBooster() {
    if (state.shuffleBoosters <= 0) return false;
    state = state.copyWith(shuffleBoosters: state.shuffleBoosters - 1);
    _save();
    return true;
  }

  bool useStoredTime(int seconds) {
    if (state.storedTimeSeconds >= seconds) {
      state = state.copyWith(storedTimeSeconds: state.storedTimeSeconds - seconds);
      _save();
      return true;
    }
    return false;
  }

  bool completeLevel(int level, int score, int stars) {
    // Mise à jour du streak journalier AVANT d'écraser lastPlayedAt
    updateStreak();

    final oldTotal = state.totalStars;
    final newTotal = oldTotal + stars;
    final milestoneReached = newTotal ~/ 50 > oldTotal ~/ 50;

    final completed = List<int>.from(state.completedLevels);
    if (!completed.contains(level)) {
      completed.add(level);
    }

    state = state.copyWith(
      currentLevel: level + 1,
      totalStars: newTotal,
      gems: milestoneReached ? state.gems + 50 : state.gems,
      completedLevels: completed,
      highScore: score > state.highScore ? score : state.highScore,
      lastPlayedAt: DateTime.now(),
    );
    _save();
    return milestoneReached;
  }

  /// Record a replay completion without affecting progression economy.
  ///
  /// Use this when the player replays an already unlocked level:
  /// - do NOT add stars
  /// - do NOT grant milestone gems
  /// - do NOT advance currentLevel
  /// - keep high score and completion flags up to date
  void completeReplayLevel(int level, int score) {
    updateStreak();

    final completed = List<int>.from(state.completedLevels);
    if (!completed.contains(level)) {
      completed.add(level);
    }

    state = state.copyWith(
      completedLevels: completed,
      highScore: score > state.highScore ? score : state.highScore,
      lastPlayedAt: DateTime.now(),
    );
    _save();
  }

  /// Reset all progression values to start a fresh run.
  Future<void> resetProgress() async {
    state = const PlayerProgress();
    await _save();
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
    _save();
  }
}

// Lives System
class LivesSystem {
  final int currentLives;
  final int maxLives;
  final int rechargeMinutes;
  final DateTime? lastRechargeAt;

  const LivesSystem({
    this.currentLives = 3,
    this.maxLives = 3,
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
  final notifier = LivesNotifier(ref);
  ref.listen(authSessionProvider.select((state) => state.session?.storageKey),
      (_, __) {
    notifier.reload();
  });
  return notifier;
});

class LivesNotifier extends StateNotifier<LivesSystem> {
  LivesNotifier(this._ref) : super(const LivesSystem()) {
    _load();
  }

  final Ref _ref;

  static const _keyLives = 'lives_current';
  static const _keyMax = 'lives_max';
  static const _keyLastRecharge = 'lives_recharge';

  String _scopedKey(String key, String prefix) => '${prefix}_$key';

  String get _currentPrefix =>
      _ref.read(authSessionProvider).session?.storageKey ?? 'local_guest';

  Future<void> reload() async {
    await _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _currentPrefix;
    final lastRechargeMs = prefs.getInt(_scopedKey(_keyLastRecharge, prefix));
    state = LivesSystem(
      currentLives: prefs.getInt(_scopedKey(_keyLives, prefix)) ?? 3,
      maxLives: prefs.getInt(_scopedKey(_keyMax, prefix)) ?? 3,
      lastRechargeAt: lastRechargeMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastRechargeMs)
          : null,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _currentPrefix;
    await prefs.setInt(_scopedKey(_keyLives, prefix), state.currentLives);
    await prefs.setInt(_scopedKey(_keyMax, prefix), state.maxLives);
    if (state.lastRechargeAt != null) {
      await prefs.setInt(
        _scopedKey(_keyLastRecharge, prefix),
        state.lastRechargeAt!.millisecondsSinceEpoch,
      );
    }
  }

  void useLife() {
    if (state.currentLives > 0) {
      state = state.copyWith(
        currentLives: state.currentLives - 1,
        lastRechargeAt: DateTime.now(),
      );
      _save();
    }
  }

  void addLife() {
    if (state.currentLives < state.maxLives) {
      state = state.copyWith(
        currentLives: state.currentLives + 1,
        lastRechargeAt: DateTime.now(),
      );
      _save();
    }
  }

  void refillLives() {
    state = state.copyWith(
      currentLives: state.maxLives,
      lastRechargeAt: DateTime.now(),
    );
    _save();
  }

  void tick() {
    final timeUntil = state.timeUntilNextLife;
    if (timeUntil != null && timeUntil.inMinutes <= 0) {
      addLife();
    }
  }

  Future<void> resetLives() async {
    state = const LivesSystem();
    await _save();
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