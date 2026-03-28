import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Simple audio manager using system sounds
/// In production, replace with actual audio files
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
  }

  /// Play a system haptic feedback as sound substitute
  /// In production, this would play actual sound files
  Future<void> playSound(SoundEffect effect) async {
    if (!_soundEnabled) return;

    // Use haptic feedback as audio substitute
    switch (effect) {
      case SoundEffect.match:
        await HapticFeedback.lightImpact();
        break;
      case SoundEffect.combo:
        await HapticFeedback.mediumImpact();
        break;
      case SoundEffect.powerUp:
        await HapticFeedback.heavyImpact();
        break;
      case SoundEffect.levelComplete:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        break;
      case SoundEffect.levelFail:
        await HapticFeedback.lightImpact();
        break;
      case SoundEffect.buttonTap:
        await HapticFeedback.selectionClick();
        break;
      case SoundEffect.buy:
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Background music placeholder
  /// In production, implement with actual music files
  Future<void> playMusic() async {
    if (!_musicEnabled) return;
    // TODO: Implement actual music playback
  }

  void stopMusic() {
    // TODO: Stop music playback
  }
}

enum SoundEffect {
  match,
  combo,
  powerUp,
  levelComplete,
  levelFail,
  buttonTap,
  buy,
}