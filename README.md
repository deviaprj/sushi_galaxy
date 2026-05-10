# Sushi Galaxy

A delicious match-3 puzzle game set in space! 🍣🌌

## Features

- **Match-3 Gameplay**: Swap and match sushi pieces to create delicious combinations
- **8 Unique Sushi Types**: Salmon, Tuna, Shrimp, Tamago, Avocado, Cucumber, Cheese, and Sausage
- **50+ Levels**: Progress through increasingly challenging levels
- **Power-ups**: Create special power-ups with 4+, 5+, and 6+ matches
- **Combo System**: Chain reactions for massive scores
- **Lives System**: Strategic gameplay with recharge mechanics
- **Dark Space Theme**: Beautiful neon aesthetic inspired by space and sushi
- **Visual Effects**: Stunning cosmic background, particle effects, and glassmorphism UI
- **Smooth Animations**: 60 FPS with custom painters for stars, nebulae, and floating elements

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart 3.5+
- Android SDK 35+ / iOS (for building)

### Installation

```bash
# Clone the repository
cd sushi_galaxy

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --no-codesign

# Web
flutter build web
```

### Install on Device via ADB

Automatically install the APK on your connected Android device (auto-uninstalls old version):

```bash
# Make script executable
chmod +x scripts/install-app.sh

# Install APK (default package: com.sushigalaxy.game)
./scripts/install-app.sh build/app.apk

# Install with custom package name
./scripts/install-app.sh build/app.apk com.myapp.package
```

The script will:
1. Detect connected Android device
2. Check if app is already installed
3. Automatically uninstall old version (if exists)
4. Install new APK (preserving user data with `-r` flag)
5. Report success/failure

**Requirements**:
- ADB (Android SDK Platform Tools) in PATH
- USB debugging enabled on device
- Device authorized (accept RSA prompt)

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── core/
│   ├── engine/                  # Game engine (matching, gravity)
│   ├── generators/              # Level generation
│   └── store/                  # State management (Riverpod)
├── ui/
│   ├── components/              # Reusable widgets
│   ├── screens/                 # App screens
│   └── theme/                   # Colors & styling
├── config/
│   └── levels/                  # Level data (JSON)
└── services/                    # Firebase, Ads, IAP
```

## Technology Stack

- **Framework**: Flutter 3.24+
- **State Management**: Riverpod
- **Game Engine**: Custom (no Flame for simplicity)
- **Animations**: flutter_animate
- **Monetization**: google_mobile_ads, in_app_purchase
- **Backend**: Firebase (Auth, Firestore, Analytics)

## Game Mechanics

### Matching
- Match 3+ identical sushi to clear them
- Match 4: Creates directional bomb 💣
- Match 5: Creates row/column eraser ⚡
- Match 6+: Creates super bomb 🌟

### Scoring
- Base points per sushi type
- Combo multiplier for chain reactions
- Special power-ups for big scores

### Lives
- Max 5 lives
- 30 minutes per recharge
- Watch ads or use gems to restore

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License

---

*Made with 🍣 and Flutter*