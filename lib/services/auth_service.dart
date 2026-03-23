import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Authentication Service with Supabase - Custom Login
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user stream
  Stream<AuthState> get authStream => _supabase.auth.onAuthStateChange;

  // Get current Supabase user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Custom login using users table (username/password)
  Future<AppUser?> loginWithUsername(String username, String password) async {
    try {
      // Query users table directly
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .eq('isactive', true);

      if (response != null && response.isNotEmpty) {
        return AppUser.fromSupabase(response[0]);
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Create user (Admin/Manager only)
  Future<AppUser> createUser({
    required String username,
    required String password,
    required String name,
    required UserRole role,
    String? shopId,
  }) async {
    try {
      // Insert into users table
      AppUser appUser = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        password: password,
        name: name,
        role: role,
        shopId: shopId,
        isActive: true,
      );

      await _supabase.from('users').insert(appUser.toSupabase());

      return appUser;
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  /// Get user data from Supabase
  Future<AppUser?> getUserData(String id) async {
    try {
      final response = await _supabase.from('users').select().eq('id', id);

      if (response != null && response.isNotEmpty) {
        return AppUser.fromSupabase(response[0]);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// Get user by username
  Future<AppUser?> getUserByUsername(String username) async {
    try {
      final response =
          await _supabase.from('users').select().eq('username', username);

      if (response != null && response.isNotEmpty) {
        return AppUser.fromSupabase(response[0]);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by username: $e');
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('id', id);
  }

  /// Soft delete user
  Future<void> deleteUser(String id) async {
    await _supabase.from('users').update({'isactive': false}).eq('id', id);
  }

  /// Get all users
  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await _supabase.from('users').select().order('id',
          ascending:
              false); // Use id to avoid missing custom createddate column

      return (response as List).map((data) {
        return AppUser.fromSupabase(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  /// Get users by shop
  Future<List<AppUser>> getUsersByShop(String shopId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('shopid', shopId)
          .order('name', ascending: true);

      return (response as List).map((data) {
        return AppUser.fromSupabase(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting users by shop: $e');
      return [];
    }
  }
}
