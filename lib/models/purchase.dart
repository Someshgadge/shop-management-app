/// Purchase Entry model matching your Supabase schema
class Purchase {
  final String id;
  final String vendorName; // Your schema: vendorname
  final double amount; // Your schema: amount
  final String? billPhotoPath; // Your schema: billphotopath
  final DateTime date; // Your schema: date
  final String? category; // Your schema: category
  final String? notes; // Your schema: notes

  Purchase({
    required this.id,
    required this.vendorName,
    required this.amount,
    this.billPhotoPath,
    required this.date,
    this.category,
    this.notes,
  });

  // For backwards compatibility
  String? get billPhotoUrl => billPhotoPath;

  factory Purchase.fromSupabase(Map<String, dynamic> data) {
    return Purchase(
      id: data['id'] ?? '',
      vendorName: data['vendorname'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      billPhotoPath: data['billphotopath'],
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      category: data['category'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'vendorname': vendorName,
      'amount': amount,
      'billphotopath': billPhotoPath,
      'date': date.toIso8601String(),
      'category': category,
      'notes': notes,
    };
  }

  Purchase copyWith({
    String? id,
    String? vendorName,
    double? amount,
    String? billPhotoPath,
    DateTime? date,
    String? category,
    String? notes,
  }) {
    return Purchase(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      billPhotoPath: billPhotoPath ?? this.billPhotoPath,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
