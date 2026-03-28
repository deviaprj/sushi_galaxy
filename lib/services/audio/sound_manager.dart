import 'package:flutter/services.dart';

/// Simple sound effects using system haptics
/// In production, replace with actual audio files
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _soundEnabled = true;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play swap sound
  Future<void> playSwap() async {
    if (!_soundEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Play match sound
  Future<void> playMatch() async {
    if (!_soundEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Play combo sound
  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Play power up sound
  Future<void> playPowerUp() async {
    if (!_soundEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  /// Play fail sound
  Future<void> playFail() async {
    if (!_soundEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Play button tap
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Play tick sound (for timer)
  Future<void> playTick() async {
    if (!_soundEnabled) return;
    await HapticFeedback.selectionClick();
  }
}