import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Authentication Provider for state management with Supabase
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  UserRole? get currentRole => _currentUser?.role;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isManager => _currentUser?.role == UserRole.manager;
  bool get isShopkeeper => _currentUser?.role == UserRole.shopkeeper;

  /// Sign in with username and password
  Future<bool> signIn(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 Attempting login for username: $username');

      _currentUser = await _authService.loginWithUsername(username, password);

      if (_currentUser == null) {
        _error = 'Invalid username or password';
        debugPrint('❌ Login failed: Invalid credentials');
        return false;
      }

      debugPrint('✅ Login successful for: ${_currentUser!.username}');
      debugPrint('   Role: ${_currentUser!.role.displayName}');
      debugPrint('   User ID: ${_currentUser!.id}');

      return true;
    } catch (e) {
      _error = 'Login error: $e';
      debugPrint('❌ Login exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    debugPrint('🚪 Signing out user: ${_currentUser?.username}');
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Create user (Admin/Manager only)
  Future<AppUser?> createUser({
    required String username,
    required String password,
    required String name,
    required UserRole role,
    String? shopId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppUser user = await _authService.createUser(
        username: username,
        password: password,
        name: name,
        role: role,
        shopId: shopId,
      );
      return user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh current user data
  Future<void> refreshUserData() async {
    if (_currentUser != null) {
      _currentUser = await _authService.getUserData(_currentUser!.id);
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
