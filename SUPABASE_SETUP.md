# Supabase Setup Guide for Shop Management App

Follow these steps to set up your Supabase backend.

## Step 1: Create Supabase Account

1. Go to https://supabase.com
2. Click "Start your project" or "Sign In"
3. Sign up with GitHub (recommended) or email

## Step 2: Create New Project

1. Click **"New Project"**
2. Fill in:
   - **Name**: `shop-management`
   - **Database Password**: Choose a strong password (save it!)
   - **Region**: Select closest to you (e.g., Asia South for India)
3. Click **"Create new project"**

Wait 2-3 minutes for setup to complete.

## Step 3: Get Your Credentials

1. Click **Settings** (bottom left gear icon)
2. Click **API**
3. Copy these two values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGciOi...` (long string)

## Step 4: Update Your Flutter App

Open `lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

With your actual credentials:

```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

## Step 5: Set Up Database Tables

1. In Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click **"New query"**
3. Copy and paste the SQL from Step 6 below
4. Click **"Run"**

## Step 6: Database Schema SQL

Copy this entire SQL script and run it in Supabase SQL Editor:

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

-- Create indexes
create index idx_users_shop_id on users(shop_id);
create index idx_sales_shop_id on sales(shop_id);
create index idx_sales_date on sales(date);
create index idx_purchases_shop_id on purchases(shop_id);
create index idx_distributions_shop_id on distributions(shop_id);
create index idx_notifications_recipient on notifications(recipient_id);
```

## Step 7: Create Storage Buckets

1. Click **Storage** (left sidebar)
2. Click **"New bucket"**
3. Create these buckets:

**Bucket 1:**
- Name: `bills`
- Public: ✅ Yes
- File size limit: leave empty
- Click **"Create bucket"**

**Bucket 2:**
- Name: `biltis`
- Public: ✅ Yes
- Click **"Create bucket"**

## Step 8: Set Up Security (RLS Policies)

1. Go back to **SQL Editor**
2. Create new query
3. Paste the RLS policies SQL (see below)
4. Click **"Run"**

## Step 9: RLS Policies SQL

```sql
-- Users policies
create policy "Users can view all users" on users for select using (true);

create policy "Admins can insert users" on users for insert
  with check (exists (select 1 from users where id = auth.uid() and role = 'admin'));

create policy "Admins can update users" on users for update
  using (exists (select 1 from users where id = auth.uid() and role = 'admin'));

-- Shops policies
create policy "Authenticated users can view shops" on shops for select
  using (auth.role() = 'authenticated');

create policy "Admins and managers can insert shops" on shops for insert
  with check (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

create policy "Admins and managers can update shops" on shops for update
  using (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

-- Sales policies
create policy "Authenticated users can view sales" on sales for select
  using (auth.role() = 'authenticated');

create policy "Authenticated users can insert sales" on sales for insert
  with check (auth.role() = 'authenticated');

create policy "Admins and managers can update sales" on sales for update
  using (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

create policy "Admins can delete sales" on sales for delete
  using (exists (select 1 from users where id = auth.uid() and role = 'admin'));

-- Purchases policies
create policy "Admins and managers can view purchases" on purchases for select
  using (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

create policy "Admins and managers can insert purchases" on purchases for insert
  with check (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

create policy "Admins can update purchases" on purchases for update
  using (exists (select 1 from users where id = auth.uid() and role = 'admin'));

create policy "Admins can delete purchases" on purchases for delete
  using (exists (select 1 from users where id = auth.uid() and role = 'admin'));

-- Distributions policies
create policy "Authenticated users can view distributions" on distributions for select
  using (auth.role() = 'authenticated');

create policy "Admins and managers can insert distributions" on distributions for insert
  with check (exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager')));

create policy "Shopkeepers can update their distributions" on distributions for update
  using (
    exists (select 1 from users u where u.id = auth.uid() and u.shop_id = distributions.shop_id)
    or exists (select 1 from users where id = auth.uid() and role in ('admin', 'manager'))
  );

-- Notifications policies
create policy "Users can view their notifications" on notifications for select
  using (recipient_id = auth.uid() or exists (select 1 from users where id = auth.uid() and role = 'admin'));

create policy "Authenticated users can insert notifications" on notifications for insert
  with check (auth.role() = 'authenticated');

create policy "Users can update their notifications" on notifications for update
  using (recipient_id = auth.uid());

-- Storage policies for bills bucket
create policy "Authenticated users can view bills" on storage.objects for select
  using (bucket_id = 'bills' and auth.role() = 'authenticated');

create policy "Admins and managers can upload bills" on storage.objects for insert
  with check (bucket_id = 'bills' and exists (
    select 1 from users where id = auth.uid() and role in ('admin', 'manager')
  ));

-- Storage policies for biltis bucket
create policy "Authenticated users can view biltis" on storage.objects for select
  using (bucket_id = 'biltis' and auth.role() = 'authenticated');

create policy "Admins and managers can upload biltis" on storage.objects for insert
  with check (bucket_id = 'biltis' and exists (
    select 1 from users where id = auth.uid() and role in ('admin', 'manager')
  ));
```

## Step 10: Create Admin User

### Option A: Through Supabase Dashboard

1. Go to **Authentication** → **Users**
2. Click **"Add user"** → **"Create new user"**
3. Enter:
   - **Email**: `admin@shop.com`
   - **Password**: `admin123`
   - **Auto Confirm User**: ✅ Check this box
4. Click **"Create user"**
5. Copy the **User ID** (UUID format)

6. Go to **SQL Editor** and run:

```sql
-- Replace 'YOUR_USER_ID_HERE' with the actual UUID from step 5
insert into users (id, email, name, role, created_at, is_active)
values (
  'YOUR_USER_ID_HERE',
  'admin@shop.com',
  'Admin',
  'admin',
  now(),
  true
);
```

### Option B: Through the App (After First Run)

Once you run the app, you can create users through the User Management screen (logged in as admin).

## Step 11: Test Your Setup

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Login with:**
   - Email: `admin@shop.com`
   - Password: `admin123`

3. **Test features:**
   - Add a shop
   - Create a manager user
   - Create a shopkeeper user
   - Add sales entries
   - View dashboard

## Troubleshooting

### "Invalid API key"
- Check your URL and anon key in `main.dart`
- Make sure there are no extra spaces

### "Table does not exist"
- Run the SQL schema again
- Check table names are correct

### "Permission denied"
- Make sure RLS policies are set up
- Check user has correct role in users table

### Login fails
- Verify admin user exists in Authentication → Users
- Check users table has matching record

## Next Steps

1. ✅ Create additional users (Manager, Shopkeepers)
2. ✅ Add shops
3. ✅ Test sales entries
4. ✅ Test purchase entries
5. ✅ Test distribution workflow
6. ✅ Build for production

## Quick Reference

| Component | Location |
|-----------|----------|
| Supabase Dashboard | https://app.supabase.com |
| Project URL | Settings → API |
| Anon Key | Settings → API |
| SQL Editor | SQL Editor |
| Storage | Storage |
| Users | Authentication → Users |
| RLS Policies | Authentication → Policies |

---

**Need help?** Check https://supabase.com/docs or the app README.md
