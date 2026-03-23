/// Shop model matching your Supabase schema
class Shop {
  final String id;
  final String shopName; // Your schema: shopname
  final String? location; // Your schema: location
  final String? managerName; // Your schema: managername
  final DateTime createdDate; // Your schema: createddate
  final bool isActive; // Your schema: isactive

  Shop({
    required this.id,
    required this.shopName,
    this.location,
    this.managerName,
    required this.createdDate,
    this.isActive = true,
  });

  // For backwards compatibility with screens
  String get name => shopName;
  String? get address => location;
  String? get contactPerson => managerName;
  String? get phone => null; // Not in your schema

  factory Shop.fromSupabase(Map<String, dynamic> data) {
    return Shop(
      id: data['id'] ?? '',
      shopName: data['shopname'] ?? '',
      location: data['location'],
      managerName: data['managername'],
      createdDate: data['createddate'] != null
          ? DateTime.parse(data['createddate'])
          : DateTime.now(),
      isActive: data['isactive'] ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'shopname': shopName,
      'location': location,
      'managername': managerName,
      'createddate': createdDate.toIso8601String(),
      'isactive': isActive,
    };
  }

  Shop copyWith({
    String? id,
    String? shopName,
    String? location,
    String? managerName,
    DateTime? createdDate,
    bool? isActive,
  }) {
    return Shop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      managerName: managerName ?? this.managerName,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
