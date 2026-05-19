# Sushi Galaxy - Remaining Tasks

## Next Session

### 1. Improve tile switch/swipe sound effect
- Current `swap.wav` is a simple generated tone
- Need a proper "switch" or "click-clack" sound effect for tile swaps
- Consider using ffmpeg to generate a short percussive sound with two quick tones (click then clack)

### 2. Fix audio file playback errors on device
- `match.wav` throws `AudioPlayerException` with `MEDIA_ERROR_UNKNOWN` on Android
- Other SFX files may have similar issues
- Generated WAV files via ffmpeg may not be properly formatted for Android's MediaPlayer
- Investigate: try different WAV formats (PCM 16-bit, correct sample rate, mono vs stereo)
- Consider generating audio with `sox` instead of `ffmpeg` for better compatibility

### 3. Fix SVG filter warnings on device
- Logs show: `unhandled element <filter/>; Picture key: Svg loader`
- SVG sushi assets use `feDropShadow` / `feGaussianBlur` filters not supported by Flutter's SVG renderer
- Consider: pre-render SVGs to PNGs at build time, or simplify SVGs to remove filter elements

### 4. Persistence layer
- Player progress resets on app restart
- Need to save: completed levels, stars earned, lives remaining, gems, settings
- Options: SharedPreferences, Hive, or SQLite via sqflite
- Should also persist lives recharge timer state

### 5. Polish & UX improvements
- Add level transition animations between screens
- Improve booster UX (visual feedback when activating)
- Add settings screen (sound/music toggle, notifications)
- Add tutorial/onboarding for first-time players
- Add daily reward system

## Completed (2026-05-10)
- Graphics overhaul (terracotta space theme, neigloo tiles, cosmic background)
- Difficulty scaling (5→8 sushi types across levels)
- High-contrast tile colors
- Auto-hint system (10s base + 5s per 5 levels, golden overlay + star icon)
- Sound effects (10 SFX files)
- Adaptive background music (calm → urgent)
- Layout fix (removed bottom stripe band)
- Hint visibility fix (AnimationController + golden overlay)