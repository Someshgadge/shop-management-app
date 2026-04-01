/// Sales Entry model matching your Supabase schema
class Sale {
  final String id;
  final String storeName; // Your schema: storename
  final DateTime date; // Your schema: date
  final double onlineAmount; // Your schema: onlineamount
  final double cashAmount; // Your schema: cashamount
  final double adhocExp; // Adhoc expenses (milk, sugar, etc.)
  final String? notes; // Your schema: notes

  Sale({
    required this.id,
    required this.storeName,
    required this.date,
    required this.onlineAmount,
    required this.cashAmount,
    this.adhocExp = 0.0,
    this.notes,
  });

  double get totalAmount => onlineAmount + cashAmount;
  double get netTotal => onlineAmount + cashAmount - adhocExp;

  factory Sale.fromSupabase(Map<String, dynamic> data) {
    return Sale(
      id: data['id'] ?? '',
      storeName: data['storename'] ?? '',
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      onlineAmount: (data['onlineamount'] ?? 0).toDouble(),
      cashAmount: (data['cashamount'] ?? 0).toDouble(),
      adhocExp: (data['adhocexp'] ?? 0).toDouble(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'storename': storeName,
      'date': date.toIso8601String(),
      'onlineamount': onlineAmount,
      'cashamount': cashAmount,
      'adhocexp': adhocExp,
      'notes': notes,
    };
  }

  Sale copyWith({
    String? id,
    String? storeName,
    DateTime? date,
    double? onlineAmount,
    double? cashAmount,
    double? adhocExp,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      date: date ?? this.date,
      onlineAmount: onlineAmount ?? this.onlineAmount,
      cashAmount: cashAmount ?? this.cashAmount,
      adhocExp: adhocExp ?? this.adhocExp,
      notes: notes ?? this.notes,
    );
  }
}
