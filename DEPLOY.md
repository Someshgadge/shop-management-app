# Deploy to Firebase - Quick Guide

## Prerequisites
Make sure you have:
- ✅ Firebase CLI installed (`npm install -g firebase-tools`)
- ✅ Flutter SDK installed
- ✅ You're logged into Firebase (`firebase login`)

## Deployment Steps

### Option 1: Quick Deploy (Recommended)

Run these commands in sequence:

```bash
# 1. Navigate to project
cd "c:\Users\SOMYAL\Desktop\Shop Management\shop_management_app"

# 2. Clean previous builds
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Build for web
flutter build web --release

# 5. Deploy to Firebase
firebase deploy --only hosting

# OR deploy everything (hosting + firestore rules + storage rules)
firebase deploy
```

### Option 2: One-Line Deploy

```bash
flutter clean && flutter pub get && flutter build web --release && firebase deploy --only hosting
```

## Verify Deployment

After deployment, visit:
- **Production**: https://shop-management-a20d5.web.app/
- **Preview** (if using hosting channels): Check Firebase Console

## Check Deployment Status

```bash
# View recent deployments
firebase hosting:channel:list

# Open Firebase Console
firebase open hosting:site
```

## Troubleshooting

### Error: Firebase CLI not found
```bash
npm install -g firebase-tools
```

### Error: Not logged in
```bash
firebase login
```

### Build fails
```bash
# Clear cache
flutter clean
flutter pub cache repair

# Rebuild
flutter build web --release
```

### Want to preview before deploying
```bash
# Serve locally
firebase serve

# Or use Flutter's web server
flutter run -d chrome
```

## Latest Changes Being Deployed

✅ Shopkeeper Portal with 2 options (Add Sale, Stock Received)
✅ Modern UI/UX with gradients and beautiful design
✅ Store name dropdown with add new store feature
✅ Accept/Reject stock functionality
✅ Improved button colors and text visibility
✅ Fixed overflow issues
✅ Modern input fields with rounded corners

---

**Ready to deploy?** Run the commands in Option 1 above! 🚀
