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
}
