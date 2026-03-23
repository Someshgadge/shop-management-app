import 'user_role.dart';

/// User model matching your Supabase schema
class AppUser {
  final String id;
  final String username; // Your schema uses username
  final String password; // Stored in your schema
  final String name;
  final UserRole role; // Your schema uses int (0, 1, 2)
  final String? shopId;
  final bool isActive;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.shopId,
    this.isActive = true,
  });

  // For backwards compatibility
  String get email => username;

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      name: data['name'] ?? '',
      role: UserRoleExtension.fromInt(data['role'] ?? 2),
      shopId: data['shopid'],
      isActive: data['isactive'] ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'role': role.value,
      'shopid': shopId,
      'isactive': isActive,
    };
  }

  AppUser copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    UserRole? role,
    String? shopId,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      isActive: isActive ?? this.isActive,
    );
  }
}
