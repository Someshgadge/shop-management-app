import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Supabase Database Service - Matching your schema
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ==================== SHOPS ====================

  /// Get all shops stream
  Stream<List<Shop>> getAllShops() {
    return _supabase
        .from('shops')
        .stream(primaryKey: ['id'])
        .eq('isactive', true)
        .order('id', ascending: false)
        .map((snapshot) {
          return snapshot.map((data) => Shop.fromSupabase(data)).toList();
        });
  }

  /// Get shop by ID
  Future<Shop?> getShop(String id) async {
    try {
      final response =
          await _supabase.from('shops').select().eq('id', id).single();

      if (response != null) {
        return Shop.fromSupabase(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting shop: $e');
      return null;
    }
  }

  /// Create shop
  Future<String> createShop(Shop shop) async {
    try {
      final response = await _supabase
          .from('shops')
          .insert(shop.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating shop: $e');
      rethrow;
    }
  }

  /// Update shop
  Future<void> updateShop(String id, Map<String, dynamic> data) async {
    await _supabase.from('shops').update(data).eq('id', id);
  }

  /// Delete shop (Admin only) - Soft delete
  Future<void> deleteShop(String id) async {
    await _supabase.from('shops').update({'isactive': false}).eq('id', id);
  }

  // ==================== SALES ====================

  /// Get all sales stream
  Stream<List<Sale>> getAllSales() {
    return _supabase
        .from('sales')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((snapshot) {
          return snapshot.map((data) => Sale.fromSupabase(data)).toList();
        });
  }

  /// Get sales by date range
  Stream<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async* {
    final response = await _supabase
        .from('sales')
        .select()
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false);

    yield (response as List).map((data) => Sale.fromSupabase(data)).toList();
  }

  /// Get all sales in date range (stream version for filtering)
  Stream<List<Sale>> getAllSalesInDateRange(DateTime start, DateTime end) {
    return _supabase
        .from('sales')
        .stream(primaryKey: ['id'])
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false)
        .map((snapshot) {
          return snapshot.map((data) => Sale.fromSupabase(data)).toList();
        });
  }

  /// Create sale
  Future<String> createSale(Sale sale) async {
    try {
      final response = await _supabase
          .from('sales')
          .insert(sale.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating sale: $e');
      rethrow;
    }
  }

  /// Update sale
  Future<void> updateSale(String id, Map<String, dynamic> data) async {
    await _supabase.from('sales').update(data).eq('id', id);
  }

  /// Delete sale (Admin only)
  Future<void> deleteSale(String id) async {
    await _supabase.from('sales').delete().eq('id', id);
  }

  // ==================== PURCHASES ====================

  /// Get all purchases stream
  Stream<List<Purchase>> getAllPurchases() {
    return _supabase
        .from('purchases')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((snapshot) {
          return snapshot.map((data) => Purchase.fromSupabase(data)).toList();
        });
  }

  /// Create purchase
  Future<String> createPurchase(Purchase purchase) async {
    try {
      final response = await _supabase
          .from('purchases')
          .insert(purchase.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating purchase: $e');
      rethrow;
    }
  }

  /// Update purchase
  Future<void> updatePurchase(String id, Map<String, dynamic> data) async {
    await _supabase.from('purchases').update(data).eq('id', id);
  }

  /// Delete purchase (Admin only)
  Future<void> deletePurchase(String id) async {
    await _supabase.from('purchases').delete().eq('id', id);
  }

  // ==================== DISTRIBUTIONS ====================

  /// Get all distributions stream
  Stream<List<Distribution>> getAllDistributions() {
    return _supabase
        .from('distributions')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((snapshot) {
          return snapshot
              .map((data) => Distribution.fromSupabase(data))
              .toList();
        });
  }

  /// Get pending distributions
  Stream<List<Distribution>> getPendingDistributions() {
    return _supabase
        .from('distributions')
        .stream(primaryKey: ['id'])
        .eq('status', 'PENDING')
        .order('date', ascending: false)
        .map((snapshot) {
          return snapshot
              .map((data) => Distribution.fromSupabase(data))
              .toList();
        });
  }

  /// Create distribution
  Future<String> createDistribution(Distribution distribution) async {
    try {
      final response = await _supabase
          .from('distributions')
          .insert(distribution.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating distribution: $e');
      rethrow;
    }
  }

  /// Update distribution (accept/reject stock)
  Future<void> updateDistribution(String id, Map<String, dynamic> data) async {
    await _supabase.from('distributions').update(data).eq('id', id);
  }

  /// Delete distribution (Admin only)
  Future<void> deleteDistribution(String id) async {
    await _supabase.from('distributions').delete().eq('id', id);
  }

  // ==================== DASHBOARD DATA ====================

  /// Get total sales amount for date range
  Future<double> getTotalSalesAmount(DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('onlineamount, cashamount')
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      double total = 0;
      for (var row in response) {
        total += (row['onlineamount'] ?? 0).toDouble();
        total += (row['cashamount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total sales: $e');
      return 0;
    }
  }

  /// Get sales grouped by date
  Future<Map<String, double>> getSalesByDate(
      DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('date, onlineamount, cashamount')
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      Map<String, double> salesByDate = {};
      for (var row in response) {
        DateTime date = DateTime.parse(row['date']);
        String dateKey = '${date.day}/${date.month}/${date.year}';
        double amount = (row['onlineamount'] ?? 0).toDouble() +
            (row['cashamount'] ?? 0).toDouble();

        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + amount;
      }
      return salesByDate;
    } catch (e) {
      debugPrint('Error getting sales by date: $e');
      return {};
    }
  }

  /// Get sales grouped by month
  Future<Map<String, double>> getSalesByMonth(int year) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('date, onlineamount, cashamount')
          .gte('date', DateTime(year, 1, 1).toIso8601String())
          .lte('date', DateTime(year, 12, 31, 23, 59, 59).toIso8601String());

      Map<String, double> salesByMonth = {};
      for (var row in response) {
        DateTime date = DateTime.parse(row['date']);
        String month = '${date.month}';
        double amount = (row['onlineamount'] ?? 0).toDouble() +
            (row['cashamount'] ?? 0).toDouble();

        salesByMonth[month] = (salesByMonth[month] ?? 0) + amount;
      }
      return salesByMonth;
    } catch (e) {
      debugPrint('Error getting sales by month: $e');
      return {};
    }
  }

  /// Get shop-wise sales (returns empty since your schema doesn't have shop_id in sales)
  Future<Map<String, double>> getSalesByShop(
      DateTime start, DateTime end) async {
    return {};
  }

  // ==================== SHOP-WISE SALES ====================

  /// Get sales for a specific shop (by shop name) with date range filter
  /// Uses case-insensitive comparison with trimming
  Stream<List<Sale>> getSalesByShopName(
      String shopName, DateTime start, DateTime end) {
    final normalizedShopName = shopName.trim().toLowerCase();

    return _supabase
        .from('sales')
        .stream(primaryKey: ['id'])
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false)
        .map((snapshot) {
          // Filter by shop name (case-insensitive)
          return snapshot
              .where((data) =>
                  (data['storename'] ?? '').toString().trim().toLowerCase() ==
                  normalizedShopName)
              .map((data) => Sale.fromSupabase(data))
              .toList();
        });
  }

  /// Get total sales amount for a specific shop with date range filter
  Future<double> getTotalSalesAmountForShop(
      String shopName, DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('onlineamount, cashamount')
          .eq('storename', shopName)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      double total = 0;
      for (var row in response) {
        total += (row['onlineamount'] ?? 0).toDouble();
        total += (row['cashamount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total sales for shop: $e');
      return 0;
    }
  }

  /// Get sales grouped by date for a specific shop
  Future<Map<String, double>> getSalesByDateForShop(
      String shopName, DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('date, onlineamount, cashamount')
          .eq('storename', shopName)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      Map<String, double> salesByDate = {};
      for (var row in response) {
        DateTime date = DateTime.parse(row['date']);
        String dateKey = '${date.day}/${date.month}/${date.year}';
        double amount = (row['onlineamount'] ?? 0).toDouble() +
            (row['cashamount'] ?? 0).toDouble();

        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + amount;
      }
      return salesByDate;
    } catch (e) {
      debugPrint('Error getting sales by date for shop: $e');
      return {};
    }
  }

  /// Get sales grouped by month for a specific shop
  Future<Map<String, double>> getSalesByMonthForShop(
      String shopName, int year) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('date, onlineamount, cashamount')
          .eq('storename', shopName)
          .gte('date', DateTime(year, 1, 1).toIso8601String())
          .lte('date', DateTime(year, 12, 31, 23, 59, 59).toIso8601String());

      Map<String, double> salesByMonth = {};
      for (var row in response) {
        DateTime date = DateTime.parse(row['date']);
        String month = '${date.month}';
        double amount = (row['onlineamount'] ?? 0).toDouble() +
            (row['cashamount'] ?? 0).toDouble();

        salesByMonth[month] = (salesByMonth[month] ?? 0) + amount;
      }
      return salesByMonth;
    } catch (e) {
      debugPrint('Error getting sales by month for shop: $e');
      return {};
    }
  }

  /// Get daily sales summary for all shops (today)
  Future<Map<String, double>> getDailySalesSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final response = await _supabase
          .from('sales')
          .select('storename, onlineamount, cashamount')
          .gte('date', startOfDay.toIso8601String())
          .lt('date', endOfDay.toIso8601String());

      Map<String, double> shopSales = {};
      for (var row in response) {
        String shopName = row['storename'] ?? 'Unknown';
        double amount = (row['onlineamount'] ?? 0).toDouble() +
            (row['cashamount'] ?? 0).toDouble();
        shopSales[shopName] = (shopSales[shopName] ?? 0) + amount;
      }
      return shopSales;
    } catch (e) {
      debugPrint('Error getting daily sales summary: $e');
      return {};
    }
  }

  // ==================== USERS ====================

  /// Get all users stream
  Stream<List<AppUser>> getAllUsers() {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((snapshot) {
          return snapshot.map((data) => AppUser.fromSupabase(data)).toList();
        });
  }

  /// Get user by ID
  Future<AppUser?> getUser(String id) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', id).single();

      if (response != null) {
        return AppUser.fromSupabase(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Create user
  Future<String> createUser(AppUser user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  /// Update user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('id', id);
  }

  /// Delete user (Admin only) - Soft delete by deactivating
  Future<void> deleteUser(String id) async {
    await _supabase.from('users').update({'isactive': false}).eq('id', id);
  }

  /// Get users by role
  Stream<List<AppUser>> getUsersByRole(UserRole role) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('role', role.value)
        .order('name', ascending: true)
        .map((snapshot) {
          return snapshot.map((data) => AppUser.fromSupabase(data)).toList();
        });
  }

  /// Get shopkeepers without assigned shop
  Stream<List<AppUser>> getUnassignedShopkeepers() {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('role', UserRole.shopkeeper.value)
        .order('name', ascending: true)
        .map((snapshot) {
          // Filter in code for null shopid
          return snapshot
              .where((data) => data['shopid'] == null)
              .map((data) => AppUser.fromSupabase(data))
              .toList();
        });
  }
}
