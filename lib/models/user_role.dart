/// User roles in the system
enum UserRole {
  admin, // 0 - Main User - Full access
  manager, // 1 - Supply Manager - No delete
  shopkeeper, // 2 - End User - Sales + Stock accept/reject
}

extension UserRoleExtension on UserRole {
  int get value {
    switch (this) {
      case UserRole.admin:
        return 0;
      case UserRole.manager:
        return 1;
      case UserRole.shopkeeper:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.shopkeeper:
        return 'Shopkeeper';
    }
  }

  static UserRole fromInt(int value) {
    switch (value) {
      case 0:
        return UserRole.admin;
      case 1:
        return UserRole.manager;
      case 2:
        return UserRole.shopkeeper;
      default:
        return UserRole.shopkeeper;
    }
  }
}
