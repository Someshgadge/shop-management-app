# Shop Management App - Supabase Version

## ✅ What Changed

Your app has been **converted from Firebase to Supabase**!

### Benefits of Supabase:
- ✅ **PostgreSQL** database (SQL instead of NoSQL)
- ✅ **More generous** free tier
- ✅ **Self-hosting** option available
- ✅ **Built-in** Row Level Security
- ✅ **Real-time** subscriptions included
- ✅ **Open source**

---

## 🚀 Quick Start (3 Steps)

### Step 1: Create Supabase Project (5 minutes)

1. Go to https://supabase.com
2. Sign up with GitHub
3. Create new project:
   - Name: `shop-management`
   - Password: (save it!)
   - Region: Choose closest to you

### Step 2: Copy Credentials & Update Code

1. In Supabase: **Settings** → **API**
2. Copy **Project URL** and **anon key**
3. Open `lib/main.dart`
4. Replace:
   ```dart
   url: 'YOUR_SUPABASE_URL',
   anonKey: 'YOUR_SUPABASE_ANON_KEY',
   ```

### Step 3: Run SQL in Supabase

1. In Supabase: **SQL Editor** → **New query**
2. Copy SQL from `SUPABASE_SETUP.md`
3. Click **Run**

---

## 📋 Full Setup Instructions

See **`SUPABASE_SETUP.md`** for detailed step-by-step guide.

---

## 🎯 Run the App

```bash
# Install dependencies (already done)
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android (if you have Android Studio)
flutter run
```

---

## 📁 Project Files

| File | Purpose |
|------|---------|
| `README.md` | Complete documentation |
| `SUPABASE_SETUP.md` | **Start here!** Setup guide |
| `lib/main.dart` | App entry + Supabase config |
| `lib/models/` | Data models |
| `lib/services/` | Supabase services |
| `lib/screens/` | UI screens |

---

## 🔑 Default Login

After creating admin user in Supabase:

- **Email**: `admin@shop.com`
- **Password**: `admin123`

---

## 📊 Database Schema

The SQL creates these tables:
- `users` - App users with roles
- `shops` - Shop information
- `sales` - Sales entries
- `purchases` - Purchase records
- `distributions` - Stock distribution
- `notifications` - In-app notifications

---

## 🎨 Features

### Admin (Main User)
- ✅ Everything (full access)
- ✅ Add/edit/delete any data
- ✅ Manage users & shops
- ✅ Notifications to Director

### Manager (Supply Manager)
- ✅ Add sales & purchases
- ✅ Manage distribution
- ✅ Add shops & users
- ❌ Cannot delete

### Shopkeeper (End User)
- ✅ Add sales only
- ✅ Accept/reject stock
- ❌ No delete/edit
- ❌ No purchases

---

## 🔧 Supabase Setup Checklist

- [ ] Create Supabase account
- [ ] Create new project
- [ ] Copy URL and anon key
- [ ] Update `lib/main.dart`
- [ ] Run database SQL schema
- [ ] Create storage buckets (bills, biltis)
- [ ] Run RLS policies SQL
- [ ] Create admin user
- [ ] Run the app!

---

## 🐛 Troubleshooting

**"Invalid API key"**
→ Check credentials in `main.dart`

**"Table does not exist"**
→ Run the SQL schema in Supabase

**"Permission denied"**
→ Check RLS policies are set up

**Login fails**
→ Verify admin user exists in Supabase

---

## 📞 Need Help?

1. Check `SUPABASE_SETUP.md` for detailed guide
2. Supabase Docs: https://supabase.com/docs
3. Flutter Docs: https://docs.flutter.dev

---

**Ready to start?** Open `SUPABASE_SETUP.md` and follow Step 1!
