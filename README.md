# Shop Management Application - Supabase Version

A comprehensive Flutter-based shop management system with real-time synchronization across Android and Web platforms, powered by **Supabase**.

## Features

### User Roles & Permissions

| Feature | Admin | Manager | Shopkeeper |
|---------|-------|---------|------------|
| View Dashboard | ✅ | ✅ | ✅ |
| Add Sales | ✅ | ✅ | ✅ |
| Edit Sales | ✅ | ✅ | ❌ |
| Delete Sales | ✅ | ❌ | ❌ |
| Add Purchases | ✅ | ✅ | ❌ |
| Manage Distribution | ✅ | ✅ | View Only |
| Accept/Reject Stock | ✅ | ✅ | ✅ |
| Add Shops | ✅ | ✅ | ❌ |
| Edit Shops | ✅ | ✅ | ❌ |
| Delete Shops | ✅ | ❌ | ❌ |
| Manage Users | ✅ | ✅ | ❌ |
| Delete Users | ✅ | ❌ | ❌ |

### Core Modules

1. **Sales Entry** - Store name, date, online/cash amounts
2. **Purchase Entry** - Vendor, amount, bill photo upload
3. **Shop Distribution** - Stock allocation with accept/reject workflow
4. **Dashboard** - Date-wise, Month-wise, YTD, Shop-wise reports
5. **User Management** - Create users with roles (Manager+)
6. **Shop Management** - Add/edit shops (Admin/Manager)
7. **Notifications** - Real-time alerts for all actions

## Tech Stack

- **Frontend**: Flutter 3.x (Dart)
- **Platforms**: Android, Web
- **Backend**: Supabase
  - Auth: Supabase Authentication
  - Database: PostgreSQL with real-time subscriptions
  - Storage: Supabase Storage (for photos)
- **State Management**: Provider

## Setup Instructions

### Step 1: Install Dependencies

```bash
cd shop_management_app
flutter pub get
```

### Step 2: Create Supabase Project

1. Go to https://supabase.com
2. Click "New Project"
3. Enter project details:
   - **Name**: Shop Management
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to your users
4. Click "Create new project"

### Step 3: Get Supabase Credentials

1. In your Supabase project dashboard
2. Go to **Settings** → **API**
3. Copy:
   - **Project URL**
   - **anon/public key**

### Step 4: Update Flutter App

Open `lib/main.dart` and update:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Example:
```dart
await Supabase.initialize(
  url: 'https://abcdefghijklmnop.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

### Step 5: Set Up Database Tables

Go to Supabase **SQL Editor** and run these commands:

```sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create users table
create table users (
  id uuid primary key references auth.users on delete cascade,
  email text unique not null,
  name text not null,
  role text not null check (role in ('admin', 'manager', 'shopkeeper')),
  shop_id uuid references shops(id),
  created_by uuid references users(id),
  created_at timestamptz default now(),
  is_active boolean default true
);

-- Create shops table
create table shops (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text,
  contact_person text,
  phone text,
  created_by uuid references users(id),
  created_at timestamptz default now(),
  is_active boolean default true
);

-- Create sales table
create table sales (
  id uuid primary key default uuid_generate_v4(),
  store_name text not null,
  date date not null,
  online_amount numeric default 0,
  cash_amount numeric default 0,
  shop_id uuid references shops(id),
  created_by uuid references users(id),
  created_at timestamptz default now(),
  last_modified_by uuid references users(id),
  last_modified_at timestamptz
);

-- Create purchases table
create table purchases (
  id uuid primary key default uuid_generate_v4(),
  vendor_name text not null,
  amount numeric default 0,
  bill_photo_url text,
  shop_id uuid references shops(id),
  created_by uuid references users(id),
  created_at timestamptz default now(),
  last_modified_by uuid references users(id),
  last_modified_at timestamptz
);

-- Create distributions table
create table distributions (
  id uuid primary key default uuid_generate_v4(),
  shop_id uuid references shops(id) not null,
  date date not null,
  stock_amount numeric default 0,
  bilti_photo_url text,
  created_by uuid references users(id),
  created_at timestamptz default now(),
  status text default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  responded_by uuid references users(id),
  responded_at timestamptz,
  rejection_reason text
);

-- Create notifications table
create table notifications (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  message text not null,
  type text not null,
  recipient_id uuid references users(id),
  sender_id uuid references users(id),
  related_doc_id uuid,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- Create indexes for better performance
create index idx_users_shop_id on users(shop_id);
create index idx_sales_shop_id on sales(shop_id);
create index idx_sales_date on sales(date);
create index idx_purchases_shop_id on purchases(shop_id);
create index idx_distributions_shop_id on distributions(shop_id);
create index idx_notifications_recipient on notifications(recipient_id);
create index idx_notifications_is_read on notifications(is_read);

-- Enable Row Level Security (RLS)
alter table users enable row level security;
alter table shops enable row level security;
alter table sales enable row level security;
alter table purchases enable row level security;
alter table distributions enable row level security;
alter table notifications enable row level security;
```

### Step 6: Create Storage Buckets

In Supabase dashboard, go to **Storage** and create these buckets:

1. **bills** - For purchase bill photos
2. **biltis** - For distribution bilti photos

Make them **public** so images can be viewed.

### Step 7: Set Up RLS Policies

Run these SQL commands in Supabase SQL Editor:

```sql
-- Users policies
create policy "Users can view all users"
  on users for select
  using (true);

create policy "Admins can insert users"
  on users for insert
  with check (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Admins can update users"
  on users for update
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Shops policies
create policy "Authenticated users can view shops"
  on shops for select
  using (auth.role() = 'authenticated');

create policy "Admins and managers can insert shops"
  on shops for insert
  with check (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

create policy "Admins and managers can update shops"
  on shops for update
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

-- Sales policies
create policy "Authenticated users can view sales"
  on sales for select
  using (auth.role() = 'authenticated');

create policy "Authenticated users can insert sales"
  on sales for insert
  with check (auth.role() = 'authenticated');

create policy "Admins and managers can update sales"
  on sales for update
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

create policy "Admins can delete sales"
  on sales for delete
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Purchases policies
create policy "Admins and managers can view purchases"
  on purchases for select
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

create policy "Admins and managers can insert purchases"
  on purchases for insert
  with check (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

create policy "Admins can update purchases"
  on purchases for update
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Admins can delete purchases"
  on purchases for delete
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Distributions policies
create policy "Authenticated users can view distributions"
  on distributions for select
  using (auth.role() = 'authenticated');

create policy "Admins and managers can insert distributions"
  on distributions for insert
  with check (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

create policy "Shopkeepers can update their distributions"
  on distributions for update
  using (
    exists (
      select 1 from users u
      where u.id = auth.uid() 
      and u.shop_id = distributions.shop_id
    )
    or exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'manager')
    )
  );

-- Notifications policies
create policy "Users can view their notifications"
  on notifications for select
  using (
    recipient_id = auth.uid()
    or exists (
      select 1 from users where id = auth.uid() and role = 'admin'
    )
  );

create policy "Authenticated users can insert notifications"
  on notifications for insert
  with check (auth.role() = 'authenticated');

create policy "Users can update their notifications"
  on notifications for update
  using (recipient_id = auth.uid());
```

### Step 8: Create Admin User

1. Go to Supabase **Authentication** → **Users**
2. Click "Add user" → "Create new user"
3. Enter:
   - **Email**: `admin@shop.com`
   - **Password**: `admin123`
   - **Auto Confirm User**: ✅ (check this)
4. Click "Create user"

5. Now go to **SQL Editor** and run:

```sql
-- Insert admin user record
insert into users (id, email, name, role, created_at, is_active)
values (
  'USER_ID_FROM_AUTH', -- Replace with the actual user ID from Authentication
  'admin@shop.com',
  'Admin',
  'admin',
  now(),
  true
);
```

### Step 9: Run the App

```bash
# For web
flutter run -d chrome

# For Android
flutter run
```

### Step 10: Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Web:**
```bash
flutter build web --release
```

## Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@shop.com | admin123 |

## Project Structure

```
lib/
├── main.dart                 # App entry + Supabase init
├── models/                   # Data models
│   ├── app_user.dart
│   ├── shop.dart
│   ├── sale.dart
│   ├── purchase.dart
│   ├── distribution.dart
│   └── notification.dart
├── services/                 # Supabase services
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── notification_provider.dart
└── screens/                  # UI screens
    ├── auth/
    ├── sales/
    ├── purchase/
    ├── distribution/
    ├── dashboard/
    ├── users/
    └── shops/
```

## Key Differences from Firebase

| Feature | Firebase | Supabase |
|---------|----------|----------|
| Database | Firestore (NoSQL) | PostgreSQL (SQL) |
| Auth | Firebase Auth | Supabase Auth |
| Real-time | Built-in | Streams |
| Storage | Firebase Storage | Supabase Storage |
| Pricing | Pay-as-you-go | More generous free tier |
| Self-hosting | No | Yes |

## Troubleshooting

### "Invalid API key"
- Check your Supabase URL and anon key in `main.dart`

### "Table does not exist"
- Run the SQL commands in Supabase SQL Editor

### "Permission denied"
- Check RLS policies are set up correctly
- Verify user has correct role in users table

### Real-time not working
- Ensure streams are properly set up
- Check RLS policies allow read access

## Support

For issues or questions, check:
- Supabase Docs: https://supabase.com/docs
- Flutter Docs: https://docs.flutter.dev

## License

Proprietary - All rights reserved
