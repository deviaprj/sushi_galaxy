import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Centralized audio manager for sound effects and background music.
/// Music adapts to remaining time - calm during gameplay, urgent when time is low.
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isMusicPlaying = false;
  double _musicVolume = 0.3;
  String _currentMusic = '';

  /// Initialize audio players
  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.setVolume(1.0);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  // === Sound Effects ===

  Future<void> playSwap() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/swap.wav'));
  }

  Future<void> playMatch() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/match.wav'));
  }

  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/combo.wav'));
  }

  Future<void> playInvalid() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/invalid.wav'));
  }

  Future<void> playVictory() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/victory.wav'));
  }

  Future<void> playFail() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/fail.wav'));
  }

  Future<void> playLevelComplete() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/level_complete.wav'));
  }

  Future<void> playHint() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/hint.wav'));
  }

  Future<void> playTick() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/tick.wav'));
  }

  Future<void> playBooster() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/booster.wav'));
  }

  // === Background Music ===

  /// Start calm ambient music for normal gameplay
  Future<void> playCalmMusic() async {
    if (!_musicEnabled) return;
    if (_currentMusic == 'calm' && _isMusicPlaying) return;

    await _musicPlayer.stop();
    _currentMusic = 'calm';
    _musicVolume = 0.25;
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.play(AssetSource('audio/music/ambient_calm.wav'));
    _isMusicPlaying = true;
  }

  /// Switch to urgent music when time is running low (last 30 seconds)
  Future<void> playUrgentMusic() async {
    if (!_musicEnabled) return;
    if (_currentMusic == 'urgent' && _isMusicPlaying) return;

    await _musicPlayer.stop();
    _currentMusic = 'urgent';
    _musicVolume = 0.35;
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.play(AssetSource('audio/music/ambient_urgent.wav'));
    _isMusicPlaying = true;
  }

  /// Gradually increase music intensity based on time remaining
  /// timeRatio: 1.0 = full time, 0.0 = no time left
  Future<void> updateMusicIntensity(double timeRatio) async {
    if (!_musicEnabled || !_isMusicPlaying) return;

    // Ramp up volume and switch to urgent as time decreases
    if (timeRatio <= 0.25 && _currentMusic != 'urgent') {
      await playUrgentMusic();
    } else if (timeRatio > 0.35 && _currentMusic != 'calm') {
      await playCalmMusic();
    }

    // Adjust volume based on time pressure
    final targetVolume = timeRatio > 0.5 ? 0.20 : (timeRatio > 0.25 ? 0.30 : 0.40);
    if ((_musicVolume - targetVolume).abs() > 0.05) {
      _musicVolume = targetVolume;
      await _musicPlayer.setVolume(_musicVolume);
    }
  }

  /// Stop all background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
    _currentMusic = '';
  }

  /// Pause music (for pause screen)
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  /// Resume music
  Future<void> resumeMusic() async {
    if (_isMusicPlaying) {
      await _musicPlayer.resume();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}