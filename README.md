# 🏪 Shop Management System

A comprehensive Flutter-based shop management application with real-time synchronization, role-based access control, and complete business analytics.

**Live App:** https://shop-management-a20d5.web.app/

---

## 📋 Table of Contents

- [Features](#-features)
- [User Roles](#-user-roles)
- [Quick Start](#-quick-start)
- [Deployment](#-deployment)
- [Database Schema](#-database-schema)
- [Recent Updates](#-recent-updates)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Features

### 📊 Core Business Features

- **Shop Management** - Create, edit, delete shops with manager assignment
- **Sales Tracking** - Record sales with online/cash breakdown and adhoc expenses
- **Purchase Management** - Track vendor purchases with payment tracking (paid/pending)
- **Stock Distribution** - Distribute stock to shops with accept/reject workflow
- **User Management** - Complete CRUD operations with role-based permissions
- **Reports & Analytics** - Sales, purchase, distribution, and P&L reports with export

### 🎯 Recent Improvements (2026)

- ✅ **Auto-refresh** - Changes visible immediately without logout/login
- ✅ **Pending Amount Calculation** - Automatically calculated for purchases
- ✅ **Search & Filter** - Quick find across all lists
- ✅ **Export Reports** - PDF/Excel/CSV export functionality
- ✅ **Audit Logging** - Track all user actions
- ✅ **Button Visibility** - All button text now visible (white on blue)
- ✅ **Distribution CRUD** - Edit/delete distributions (Admin only)
- ✅ **User CRUD** - Complete user management with edit/delete

### 📱 Platform Support

- ✅ **Web** (Primary - Deployed on Firebase)
- ✅ **Mobile** (Android/iOS - Build locally)
- ✅ **Desktop** (Windows/Mac/Linux - Build locally)

---

## 👥 User Roles

| Feature | Admin | Manager | Shopkeeper |
|---------|-------|---------|------------|
| **Dashboard** | ✅ | ✅ | ✅ |
| **View Sales** | ✅ | ✅ | ✅ |
| **Add Sales** | ✅ | ✅ | ✅ |
| **Edit Sales** | ✅ | ✅ | ❌ |
| **Delete Sales** | ✅ | ❌ | ❌ |
| **View Purchases** | ✅ | ✅ | ❌ |
| **Add Purchases** | ✅ | ✅ | ❌ |
| **Edit Purchases** | ✅ | ✅ | ❌ |
| **Delete Purchases** | ✅ | ❌ | ❌ |
| **View Distribution** | ✅ | ✅ | ✅ |
| **Add Distribution** | ✅ | ✅ | ❌ |
| **Edit Distribution** | ✅ | ❌ | ❌ |
| **Delete Distribution** | ✅ | ❌ | ❌ |
| **Accept/Reject Stock** | ❌ | ❌ | ✅ |
| **User Management** | ✅ Full CRUD | ✅ Create Only | ❌ |
| **Shop Management** | ✅ Full CRUD | ✅ Create/Edit | ❌ |
| **Reports** | ✅ All | ✅ All | ❌ |

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install Flutter SDK
Download from: https://flutter.dev/docs/get-started/install

# Install Firebase CLI
npm install -g firebase-tools

# Verify installations
flutter --version
firebase --version
```

### Clone & Setup

```bash
# Navigate to project
cd "c:\Users\SOMYAL\Desktop\Shop Management\shop_management_app"

# Get dependencies
flutter pub get

# Run locally (Chrome)
flutter run -d chrome
```

### Login Credentials

**Default Admin:**
- Username: `admin`
- Password: Check with your system administrator

**Shopkeeper:**
- Username: Provided by admin
- Password: Provided by admin

---

## 📦 Deployment

### One-Command Deploy

```bash
cd "c:\Users\SOMYAL\Desktop\Shop Management\shop_management_app"
flutter clean && flutter pub get && flutter build web --release && firebase deploy --only hosting
```

### Step-by-Step Deploy

```bash
# 1. Clean build artifacts
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build for web
flutter build web --release

# 4. Deploy to Firebase
firebase deploy --only hosting

# 5. Verify deployment
# Visit: https://shop-management-a20d5.web.app/
```

### Deployment Time

- **First build:** ~2-3 minutes
- **Subsequent builds:** ~1-2 minutes
- **Firebase deploy:** ~30 seconds

---

## 🗄️ Database Schema

### Supabase Tables

```sql
-- Users Table
CREATE TABLE users (
  id uuid PRIMARY KEY,
  username text UNIQUE NOT NULL,
  password text NOT NULL,
  name text NOT NULL,
  role int NOT NULL, -- 0=Admin, 1=Manager, 2=Shopkeeper
  shopid uuid REFERENCES shops(id),
  isactive boolean DEFAULT true
);

-- Shops Table
CREATE TABLE shops (
  id uuid PRIMARY KEY,
  shopname text NOT NULL,
  location text,
  managername text,
  createddate timestamptz DEFAULT NOW(),
  isactive boolean DEFAULT true
);

-- Sales Table
CREATE TABLE sales (
  id uuid PRIMARY KEY,
  storename text NOT NULL,
  date timestamptz DEFAULT NOW(),
  onlineamount decimal DEFAULT 0,
  cashamount decimal DEFAULT 0,
  adhocexp decimal DEFAULT 0,
  notes text
);

-- Purchases Table
CREATE TABLE purchases (
  id uuid PRIMARY KEY,
  vendorname text NOT NULL,
  amount decimal NOT NULL,
  billphotopath text,
  date timestamptz DEFAULT NOW(),
  category text,
  notes text,
  paymentmode text DEFAULT 'Cash',
  paidamount decimal DEFAULT 0
  -- pendingAmount is calculated: MAX(0, amount - paidAmount)
);

-- Distributions Table
CREATE TABLE distributions (
  id uuid PRIMARY KEY,
  shopname text NOT NULL,
  date timestamptz DEFAULT NOW(),
  stockamount decimal NOT NULL,
  biltiphotopath text,
  producttype text,
  quantity int,
  notes text,
  status text DEFAULT 'PENDING', -- PENDING, ACCEPTED, REJECTED
  acceptedby uuid REFERENCES users(id),
  accepteddate timestamptz
);

-- Audit Logs Table (NEW!)
CREATE TABLE audit_logs (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  action text NOT NULL, -- CREATE, UPDATE, DELETE
  table_name text NOT NULL,
  record_id uuid,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz DEFAULT NOW()
);
```

### Required Database Migrations

Run this in **Supabase SQL Editor** to add new features:

```sql
-- 1. Add adhocexp to sales (if not exists)
ALTER TABLE sales ADD COLUMN IF NOT EXISTS adhocexp decimal DEFAULT 0;

-- 2. Add payment tracking to purchases (if not exists)
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS paymentmode text DEFAULT 'Cash';
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS paidamount decimal DEFAULT 0;

-- 3. Create audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  action text NOT NULL,
  table_name text NOT NULL,
  record_id uuid,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz DEFAULT NOW()
);

-- 4. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_sales_storename ON sales(storename);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date DESC);
CREATE INDEX IF NOT EXISTS idx_purchases_vendor ON purchases(vendorname);
CREATE INDEX IF NOT EXISTS idx_distributions_shop ON distributions(shopname);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON audit_logs(table_name);
```

---

## 🔧 Recent Updates

### Version 2.1.0 (April 2026)

**Added:**
- ✅ Pending amount auto-calculation for purchases
- ✅ Edit/Delete for Distribution (Admin only)
- ✅ Full CRUD for User Management (Admin only)
- ✅ Auto-refresh after all CRUD operations
- ✅ Refresh buttons on all management screens
- ✅ Button text visibility fixes (white on blue)
- ✅ Confirmation dialogs for destructive actions

**Fixed:**
- ✅ Pending amount calculation bug
- ✅ Distribution edit/delete not reflecting
- ✅ User management refresh issue
- ✅ Button text invisible on blue background

### Version 2.0.0 (March 2026)

**Added:**
- ✅ Reports & Analytics module
- ✅ Export functionality (PDF/Excel/CSV)
- ✅ Adhoc expenses tracking in sales
- ✅ Payment mode tracking (Cash/Online)
- ✅ Partial payment tracking for purchases
- ✅ Audit logging system

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.19+ - Cross-platform framework
- **Provider** - State management
- **FL Chart** - Charts and graphs
- **Intl** - Date/number formatting

### Backend
- **Supabase** - PostgreSQL database
- **Firebase Hosting** - Web hosting
- **Supabase Storage** - File uploads (bills, biltis)

### Development
- **Dart** 3.3+ - Programming language
- **Firebase CLI** - Deployment
- **Git** - Version control

---

## 📁 Project Structure

```
shop_management_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── app_user.dart           # User model
│   │   ├── shop.dart               # Shop model
│   │   ├── sale.dart               # Sale model (with adhocExp)
│   │   ├── purchase.dart           # Purchase model (auto pending)
│   │   ├── distribution.dart       # Distribution model
│   │   └── user_role.dart          # Role enum
│   ├── services/                    # Backend services
│   │   ├── auth_service.dart       # Authentication
│   │   ├── database_service.dart   # CRUD operations
│   │   └── storage_service.dart    # File uploads
│   ├── providers/                   # State management
│   │   ├── auth_provider.dart      # Auth state
│   │   └── notification_provider.dart
│   └── screens/                     # UI screens
│       ├── home_screen.dart         # Main navigation
│       ├── dashboard_screen.dart    # Analytics
│       ├── sales/                   # Sales screens
│       ├── purchase/                # Purchase screens
│       ├── distribution/            # Distribution screens
│       ├── shops/                   # Shop screens
│       ├── users/                   # User screens
│       └── reports/                 # Reports & analytics
├── firebase.json                    # Firebase config
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

---

## 🐛 Troubleshooting

### Changes Not Reflecting After Update

**Solution:**
```bash
# Hard refresh browser
Ctrl + Shift + R

# Or clear cache
Ctrl + Shift + Delete → Clear cached images and files

# Or use incognito mode
Ctrl + Shift + N
```

### Build Fails

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub cache repair

# Try building again
flutter build web --release
```

### Database Errors

**Solution:**
1. Check Supabase dashboard: https://supabase.com/dashboard
2. Verify all tables exist
3. Run migration scripts (see Database Schema section)
4. Check RLS policies are enabled

### Login Fails

**Solution:**
1. Verify user exists in `users` table
2. Check `isactive` is `true`
3. Verify password matches (plain text in DB)
4. Check Supabase credentials in `lib/main.dart`

---

## 📞 Support

For issues or questions:
1. Check this README first
2. Review `IMPROVEMENTS_STATUS.md` for known issues
3. Check Supabase dashboard for database errors
4. Review Firebase console for deployment errors

---

## 📄 License

This is a private commercial application. All rights reserved.

---

**Last Updated:** April 2026  
**Version:** 2.1.0  
**Status:** Production Ready ✅
