# CLAUDE.md - Sushi Galaxy

## Project Overview
Sushi Galaxy is a Flutter match-3 puzzle game with a warm terracotta space-restaurant theme. The game features neigloo-style tiles (neumorphic + glass), adaptive difficulty, auto-hint system, and dynamic audio.

## Build Commands
```bash
flutter pub get                     # Install dependencies
flutter analyze --no-fatal-infos   # Static analysis
flutter test                        # Run all tests (34 tests)
flutter test test/unit/             # Unit tests only
flutter test test/widgets/          # Widget tests only
flutter build apk --debug           # Build Android APK
flutter run -d android              # Run on connected device
```

## Architecture

### Key Files
- `lib/core/engine/game_engine.dart` - Match-3 game engine (swap, detect, gravity, hints)
- `lib/core/generators/level_generator.dart` - Level generation with progressive difficulty
- `lib/core/store/game_providers.dart` - Riverpod state management (GameStatus, PlayerProgress, Lives, Settings)
- `lib/ui/screens/game_screen.dart` - Main gameplay screen with timer, hint, audio
- `lib/ui/components/game_components.dart` - AnimatedSushiTile, AnimatedGameGrid, AnimatedScore, AnimatedCombo
- `lib/ui/theme/app_theme.dart` - AppColors palette, SushiType enum with color extensions
- `lib/ui/components/effects/cosmic_background.dart` - Animated space background
- `lib/ui/components/effects/glassmorphism.dart` - Glass container effects
- `lib/ui/components/effects/particle_effects.dart` - Match/confetti particles
- `lib/services/audio/audio_manager.dart` - Sound effects and adaptive background music

### Game Engine
- `GridConfig(rows, cols, sushiTypeCount)` - Fewer sushi types = easier matches
- `GameEngine.initGrid()` - Creates grid with only active sushi types, no initial matches
- `GameEngine.getHint()` - Returns best swap hint (used by auto-hint system)
- `Level.sushiTypeCount` - Difficulty scaling: levels 1-5 use 5 types, up to 8 for levels 61+

### Auto-Hint System
- 10s base delay, +5s every 5 levels (level 1-5: 10s, level 6-10: 15s, etc.)
- Persistent until player makes a move
- Visible golden overlay + star icon + pulsing AnimationController scale
- `_hintDelaySeconds = 10 + (currentLevel ~/ 5) * 5`

### Audio System
- `AudioManager` singleton: playSwap, playMatch, playCombo, playInvalid, playVictory, playFail, playLevelComplete, playHint, playTick, playBooster
- Adaptive background music: `playCalmMusic()` → `playUrgentMusic()` when timeRatio <= 0.25
- `updateMusicIntensity(timeRatio)` adjusts volume and switches tracks

### Tile Colors (High Contrast)
- salmon: #FF5722, tuna: #D32F2F, shrimp: #FF9800, tamago: #FFEB3B
- avocado: #4CAF50, cucumber: #00BCD4, cheese: #FFC107, sausage: #9C27B0
- Each has darkColor/lightColor extensions for 3-layer gradient rendering

## Important Notes
- **Device**: Connected Android device at `6db039ac` (Android 15)
- **Flutter path**: `/home/geekai/flutter/bin/flutter`
- **APK location**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Audio files**: Generated WAV files in `assets/audio/sfx/` and `assets/audio/music/`
- **SVG assets**: 8 neigloo-style sushi SVGs in `assets/images/sushis/`
- **GameEngine is nullable**: `_engine` is `GameEngine?` with `_isInitialized` flag; show loading until ready