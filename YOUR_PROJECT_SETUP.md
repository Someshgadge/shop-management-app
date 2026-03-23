# Quick Start Guide - Your Supabase Project

## ✅ Your Supabase Project is Already Configured!

Your app is now connected to your Supabase project:

- **Project URL**: https://zkeowotvloszyjrdkwac.supabase.co
- **Project Name**: nano

---

## 📋 Your Current Database Schema

Your Supabase project already has these tables:

1. **users** - User accounts (username, password, role)
2. **shops** - Shop information
3. **sales** - Sales entries (storename, onlineamount, cashamount)
4. **purchases** - Purchase records (vendorname, amount, billphotopath)
5. **distributions** - Stock distribution (shopname, stockamount, status)
6. **notifications** - System notifications

---

## 🚀 Step 1: Create Admin User

You need to add an admin user to your `users` table.

### Option 1: Through Supabase Dashboard

1. Go to your Supabase project: https://app.supabase.com/project/zkeowotvloszyjrdkwac
2. Click **Table Editor** (left sidebar)
3. Click **users** table
4. Click **Insert** → **New Row**
5. Fill in:
   - **id**: `admin` (or any unique ID)
   - **username**: `admin`
   - **password**: `admin123`
   - **name**: `Administrator`
   - **role**: `0` (0 = Admin, 1 = Manager, 2 = Shopkeeper)
   - **shopid**: (leave empty for admin)
   - **isactive**: `true`
6. Click **Save**

### Option 2: Using SQL Editor

1. Go to **SQL Editor** in Supabase
2. Run this query:

```sql
INSERT INTO users (id, username, password, name, role, isactive)
VALUES ('admin-001', 'admin', 'admin123', 'Administrator', 0, true);
```

---

## 🎯 Step 2: Run the App

```bash
# Navigate to project
cd "C:\Users\SOMYAL\Desktop\Shop Management\shop_management_app"

# Make sure dependencies are installed
flutter pub get

# Run on Chrome
flutter run -d chrome
```

---

## 🔑 Step 3: Login

Use the admin credentials you just created:

- **Username**: `admin`
- **Password**: `admin123`

---

## 📊 User Roles

| Role Value | Name | Permissions |
|------------|------|-------------|
| 0 | Admin | Full access - add/edit/delete everything |
| 1 | Manager | Add sales, purchases, distribution. No delete. |
| 2 | Shopkeeper | Add sales only. Accept/reject stock. |

---

## 🗄️ Your Database Tables

### users
```
- id (text, PK)
- username (text, unique)
- password (text)
- name (text)
- role (integer: 0=admin, 1=manager, 2=shopkeeper)
- shopid (text)
- isactive (boolean)
```

### shops
```
- id (text, PK)
- shopname (text)
- location (text)
- managername (text)
- createddate (timestamp)
- isactive (boolean)
```

### sales
```
- id (text, PK)
- storename (text)
- date (timestamp)
- onlineamount (numeric)
- cashamount (numeric)
- notes (text)
```

### purchases
```
- id (text, PK)
- vendorname (text)
- amount (numeric)
- billphotopath (text)
- date (timestamp)
- category (text)
- notes (text)
```

### distributions
```
- id (text, PK)
- shopname (text)
- date (timestamp)
- stockamount (numeric)
- biltiphotopath (text)
- producttype (text)
- quantity (integer)
- notes (text)
- status (text: PENDING/ACCEPTED/REJECTED)
- acceptedby (text)
- accepteddate (timestamp)
```

### notifications
```
- id (text, PK)
- title (text)
- message (text)
- date (timestamp)
- isread (boolean)
- relatedentityid (text)
- entitytype (text)
```

---

## 📝 Create Sample Data

### Add a Shop

In Supabase Table Editor → shops → Insert:

```
id: shop-001
shopname: Main Store
location: Mumbai
managername: John Doe
createddate: (auto)
isactive: true
```

### Create Manager User

In users table:

```
id: manager-001
username: manager
password: manager123
name: Store Manager
role: 1
shopid: shop-001
isactive: true
```

### Create Shopkeeper User

In users table:

```
id: shopkeeper-001
username: shopkeeper
password: shop123
name: Shop Keeper
role: 2
shopid: shop-001
isactive: true
```

---

## 🎨 Test the App

### As Admin:
1. ✅ Login with `admin` / `admin123`
2. ✅ Go to User Management → Create users
3. ✅ Go to Shop Management → Add shops
4. ✅ View Dashboard → See analytics

### As Manager:
1. ✅ Login with `manager` / `manager123`
2. ✅ Add sales entries
3. ✅ Add purchase entries
4. ✅ Create distributions

### As Shopkeeper:
1. ✅ Login with `shopkeeper` / `shop123`
2. ✅ Add sales
3. ✅ View distributions
4. ✅ Accept/Reject stock

---

## 📦 Storage Buckets

Make sure you have these storage buckets created in Supabase:

1. **bills** - For purchase bill photos
2. **biltis** - For distribution bilti photos

### To Create Buckets:

1. Go to **Storage** in Supabase
2. Click **New bucket**
3. Name: `bills`
4. Public: ✅ Yes
5. Click **Create**
6. Repeat for `biltis`

---

## 🔧 Troubleshooting

### "Invalid username or password"
- Check user exists in `users` table
- Verify username and password are correct
- Check `isactive` is `true`

### "Table does not exist"
- Your tables are already created
- Check table names match exactly (lowercase)

### "Permission denied"
- Check RLS policies if enabled
- For now, you can disable RLS for testing

### Images not uploading
- Create storage buckets: `bills` and `biltis`
- Make buckets public

---

## 📱 Build for Production

### Android APK
```bash
flutter build apk --release
```

### Web
```bash
flutter build web --release
```

---

## 🎯 What's Working

✅ Login with username/password
✅ Sales entry (add, view)
✅ Purchase entry with photos
✅ Distribution with accept/reject
✅ Shop management
✅ User management
✅ Dashboard with reports
✅ Notifications
✅ Real-time updates

---

## 📞 Need Help?

Check your Supabase dashboard:
https://app.supabase.com/project/zkeowotvloszyjrdkwac

---

**Ready to start?** Run `flutter run -d chrome` and login with `admin` / `admin123`!
