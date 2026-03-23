# Quick Start Guide

## Prerequisites

1. **Install Flutter**: Download from https://docs.flutter.dev/get-started/install
2. **Install Git**: For version control
3. **Code Editor**: VS Code or Android Studio

## Installation (5 minutes)

### 1. Open Project
```bash
cd "shop_management_app"
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase (Quick)

**Option A: Use FlutterFire CLI** (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

**Option B: Manual Setup**
- Follow `FIREBASE_SETUP.md` for detailed instructions
- Or skip for now and test locally

### 4. Run the App

**For Chrome (Web):**
```bash
flutter run -d chrome
```

**For Android Emulator:**
```bash
flutter run
```

**For Connected Device:**
```bash
flutter devices  # List devices
flutter run      # Run on selected device
```

## First Login

Use default admin credentials:
- **Email**: `admin@shop.com`
- **Password**: `admin123`

> Note: You'll need to create this user in Firebase Authentication first, or modify the code to auto-create on first run.

## Testing Features

### As Admin:
1. ✅ Go to Shop Management → Add a shop
2. ✅ Go to User Management → Create manager and shopkeeper users
3. ✅ View Dashboard with analytics
4. ✅ Edit/Delete any entries

### As Manager:
1. ✅ Add sales entries
2. ✅ Add purchase entries with bill photos
3. ✅ Create stock distributions
4. ✅ Manage users (not delete)

### As Shopkeeper:
1. ✅ Add sales entries
2. ✅ View stock distributions
3. ✅ Accept/Reject stock

## Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Web App
```bash
flutter build web --release
```
Output: `build/web/`

### Deploy Web to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (first time only)
firebase init hosting

# Deploy
flutter build web --release
firebase deploy
```

## Common Issues

### "No devices found"
- For web: Install Chrome browser
- For Android: Start Android emulator or connect device

### "Pub get failed"
```bash
flutter clean
flutter pub get
```

### "FirebaseException"
- Ensure Firebase is configured
- Check `firebase_options.dart` has correct values

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Project Structure Overview

```
shop_management_app/
├── lib/
│   ├── main.dart              # App entry
│   ├── models/                # Data classes
│   ├── services/              # Firebase logic
│   ├── providers/             # State management
│   └── screens/               # UI pages
├── web/                       # Web files
├── android/                   # Android files
├── pubspec.yaml              # Dependencies
└── README.md                 # Full docs
```

## Next Steps

1. **Customize Branding**: Update app name, colors, logo
2. **Add Real Users**: Create actual user accounts in Firebase
3. **Configure Security**: Add Firestore and Storage rules
4. **Deploy**: Build and deploy to production

## Getting Help

- **README.md**: Full documentation
- **FIREBASE_SETUP.md**: Firebase configuration guide
- **Flutter Docs**: https://docs.flutter.dev

## Quick Commands

```bash
flutter run              # Run app
flutter pub get          # Install packages
flutter clean            # Clean build
flutter build apk        # Build Android
flutter build web        # Build web
flutter doctor           # Check setup
```

---

**Ready to start? Run:** `flutter run -d chrome`
