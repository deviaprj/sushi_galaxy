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
flutter build appbundle --release   # Build Android release bundle (beta)
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
- `lib/services/ads/rewarded_ad_service.dart` - Rewarded ads + chained rewarded sequence API
- `lib/services/notifications/local_notification_service.dart` - Local notifications (full lives reminder)

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
- **AAB release location**: `build/app/outputs/bundle/release/app-release.aab`
- **Audio files**: Generated WAV files in `assets/audio/sfx/` and `assets/audio/music/`
- **SVG assets**: 8 neigloo-style sushi SVGs in `assets/images/sushis/`
- **GameEngine is nullable**: `_engine` is `GameEngine?` with `_isInitialized` flag; show loading until ready

## Beta Release Readiness

### Must Have Before Beta (P0)
- Stabiliser tous les flows rewarded ads (succès/échec/interruption/réseau lent).
- Valider anti-exploit "no lives" sur tous les écrans de relance.
- Confirmer recharge des vies (app ouverte, fond, relance) + cohérence timers.
- Vérifier notifications locales "vies pleines" (permission Android 13+, déclenchement unique).
- Corriger toute erreur audio bloquante Android (`MEDIA_ERROR_UNKNOWN`) et fallback propre.
- Produire un build `--release` signé et installable en canal bêta fermé.

### Should Have Before Beta (P1)
- Instrumentation analytics minimale (events gameplay + monétisation).
- Revue balancing économie (gems, boosters, difficulté).
- Revalidation UI petites résolutions (overflow, lisibilité, zones tactiles).
- Tutoriel onboarding court pour nouveaux joueurs.

### Exit Criteria
- Aucun crash bloquant sur un parcours de jeu complet.
- Données joueur persistées correctement après redémarrage.
- Ads/IAP fonctionnels en sandbox, sans faille évidente d'abus.
- Analyse statique et tests passants.

## Known Issues / Operational Notes
- `flutter pub get` peut échouer avec un bug advisories cache.
- Contournement actuel:
```bash
rm -f /home/geekai/.pub-cache/hosted/pub.dev/.cache/*-advisories.json
/home/geekai/flutter/bin/flutter pub get --offline
```
- Le device peut refuser une installation APK avec `INSTALL_FAILED_USER_RESTRICTED` si l'utilisateur annule la confirmation Android.