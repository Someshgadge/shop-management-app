# Firebase Setup Guide

Follow these steps to configure Firebase for your Shop Management App.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `Shop Management` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, click on "Authentication" in left sidebar
2. Click "Get started"
3. Click on "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

## Step 3: Create Firestore Database

1. Click on "Firestore Database" in left sidebar
2. Click "Create database"
3. Select "Start in test mode" (we'll add security rules later)
4. Choose a location (select closest to your users)
5. Click "Enable"

## Step 4: Enable Storage

1. Click on "Storage" in left sidebar
2. Click "Get started"
3. Click "Next" (start in test mode)
4. Choose same location as Firestore
5. Click "Done"

## Step 5: Add Android App

1. In Firebase Console, click project overview (gear icon → Project settings)
2. Scroll to "Your apps" section
3. Click Android icon
4. Enter package name: `com.shopmanagement.shop_management_app`
5. App nickname: `Shop Management Android`
6. Click "Register app"
7. Download `google-services.json`
8. Place it in: `shop_management_app/android/app/google-services.json`

## Step 6: Add Web App

1. In same "Your apps" section
2. Click Web icon (</>)
3. App nickname: `Shop Management Web`
4. Click "Register app"
5. Copy the Firebase configuration
6. Update `lib/firebase_options.dart` with your values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_FROM_FIREBASE',
  appId: 'YOUR_APP_ID_FROM_FIREBASE',
  messagingSenderId: 'YOUR_SENDER_ID_FROM_FIREBASE',
  projectId: 'YOUR_PROJECT_ID_FROM_FIREBASE',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

## Step 7: Create Admin User

### Option A: Through the App (Recommended)

1. Run the app
2. The first user created will be admin by default in code
3. Or manually update the user role in Firestore

### Option B: Through Firebase Console

1. Go to Authentication → Users
2. Click "Add user"
3. Email: `admin@shop.com`
4. Password: `admin123`
5. Click "Add user"
6. Go to Firestore Database
7. Create a new collection: `users`
8. Add document with ID = user's UID (from Authentication)
9. Add fields:
   - `email`: "admin@shop.com"
   - `name`: "Admin"
   - `role`: "admin"
   - `created_at`: (timestamp)
   - `is_active`: true

## Step 8: Add Security Rules

### Firestore Rules

1. Go to Firestore Database → Rules
2. Copy content from `firestore.rules`
3. Paste and click "Publish"

### Storage Rules

1. Go to Storage → Rules
2. Copy content from `storage.rules`
3. Paste and click "Publish"

## Step 9: Create Sample Data

### Create a Shop

1. Go to Firestore Database
2. Create collection: `shops`
3. Add document with auto-ID
4. Fields:
   - `name`: "Main Shop"
   - `address`: "123 Main Street"
   - `contact_person`: "John Doe"
   - `phone`: "+1234567890"
   - `created_by`: [admin user ID]
   - `created_at`: (timestamp)
   - `is_active`: true

### Create Manager User

1. Go to Authentication → Users → Add user
2. Email: `manager@shop.com`
3. Password: `manager123`
4. Go to Firestore → users collection
5. Add document with same UID
6. Fields:
   - `email`: "manager@shop.com"
   - `name`: "Manager"
   - `role`: "manager"
   - `created_by`: [admin user ID]
   - `created_at`: (timestamp)
   - `is_active`: true

### Create Shopkeeper User

1. Go to Authentication → Users → Add user
2. Email: `shop@shop.com`
3. Password: `shop123`
4. Go to Firestore → users collection
5. Add document with same UID
6. Fields:
   - `email`: "shop@shop.com"
   - `name`: "Shop Keeper"
   - `role`: "shopkeeper"
   - `shop_id`: [shop document ID from above]
   - `created_by`: [manager user ID]
   - `created_at`: (timestamp)
   - `is_active`: true

## Step 10: Test the App

1. Run the app: `flutter run`
2. Login with admin credentials
3. Create shops, users, and test all features

## Troubleshooting

### "No module found" error
- Make sure you ran `flutter pub get`
- Check that all Firebase packages are in `pubspec.yaml`

### "FirebaseException" errors
- Verify `google-services.json` is in correct location
- Check Firebase options are correctly configured
- Ensure Firestore and Storage are enabled

### Permission denied errors
- Check security rules are published
- Verify user roles in Firestore

## Default Test Credentials

After setup, you can test with:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@shop.com | admin123 |
| Manager | manager@shop.com | manager123 |
| Shopkeeper | shop@shop.com | shop123 |

## Next Steps

1. Build Android APK: `flutter build apk --release`
2. Build for Web: `flutter build web --release`
3. Deploy web to Firebase Hosting
4. Distribute APK to users

For Firebase Hosting deployment:
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
flutter build web --release
firebase deploy
```
