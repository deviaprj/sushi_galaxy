# Sushi Galaxy — Deployment Guide

## Google Play Store

### 1. Pre-requisites
- Google Play Developer account ($25 one-time)
- App icon (1024x1024 PNG)
- Screenshots (Phone: 1080x1920, Tablet: 720x1280)
- Privacy Policy URL
- Feature Graphic (1024x500)

### 2. Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 3. App Store Listing

| Field | Value |
|-------|-------|
| Title | Sushi Galaxy |
| Short Description | Match & Feast in Space! |
| Full Description | See ASO_STRATEGY.md |
| Category | Games > Puzzle |
| Content Rating | Everyone |
| Tags | match3, puzzle, sushi, casual, game |

### 4. Upload to Play Console
1. Create new app
2. Upload APK
3. Fill Store Listing
4. Complete Content Rating
5. Set Pricing & Distribution
6. Submit for review

---

## Apple App Store

### 1. Pre-requisites
- Apple Developer account ($99/year)
- App Store screenshots (multiple sizes)
- App Preview video (optional, 30s)
- Privacy Policy URL

### 2. Build iOS

```bash
# Only on macOS
flutter build ios --release --no-codesign
```

### 3. Upload
- Use Xcode or Transporter app
- Or use EAS: `eas build -p ios`

---

## EAS Build (Recommended)

### Install EAS CLI
```bash
npm install -g eas-cli
```

### Configure
```bash
eas configure
```

### Build Commands

```bash
# Android
eas build -p android

# iOS (requires Apple credentials)
eas build -p ios
```

---

## Firebase Setup (Optional)

### 1. Create Project
- Go to Firebase Console
- Add Android + iOS apps

### 2. Download Configs
- `google-services.json` → `android/app/`
- `GoogleService-Info.plist` → `ios/Runner/`

### 3. Enable Features
- Firebase Auth (anonymous + Google)
- Firestore (user data, leaderboards)
- Analytics (events tracking)
- Remote Config (dynamic tuning)

---

## Post-Launch Checklist

- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Check Store reviews
- [ ] Track analytics (DAU, retention, revenue)
- [ ] A/B test offers
- [ ] Plan content updates

---

## Important Links

- Play Console: play.google.com/console
- Apple App Store Connect: appstoreconnect.apple.com
- Firebase Console: console.firebase.google.com
- Google Mobile Ads: apps.admob.com