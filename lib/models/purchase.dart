/// Purchase Entry model matching your Supabase schema
class Purchase {
  final String id;
  final String vendorName; // Your schema: vendorname
  final double amount; // Your schema: amount
  final String? billPhotoPath; // Your schema: billphotopath
  final DateTime date; // Your schema: date
  final String? category; // Your schema: category
  final String? notes; // Your schema: notes
  final String paymentMode; // 'Cash' or 'Online'
  final double paidAmount; // Amount already paid

  Purchase({
    required this.id,
    required this.vendorName,
    required this.amount,
    this.billPhotoPath,
    required this.date,
    this.category,
    this.notes,
    this.paymentMode = 'Cash',
    this.paidAmount = 0.0,
  });

  // For backwards compatibility
  String? get billPhotoUrl => billPhotoPath;

  // Calculate pending amount automatically
  double get pendingAmount {
    final calculated = amount - paidAmount;
    return calculated > 0 ? calculated : 0.0;
  }

  bool get isFullyPaid =>
      pendingAmount < 0.01; // Allow small floating point errors

  factory Purchase.fromSupabase(Map<String, dynamic> data) {
    final amount = (data['amount'] ?? 0).toDouble();
    final paidAmount = (data['paidamount'] ?? 0).toDouble();

    return Purchase(
      id: data['id'] ?? '',
      vendorName: data['vendorname'] ?? '',
      amount: amount,
      billPhotoPath: data['billphotopath'],
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      category: data['category'],
      notes: data['notes'],
      paymentMode: data['paymentmode'] ?? 'Cash',
      paidAmount: paidAmount,
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
      'paymentmode': paymentMode,
      'paidamount': paidAmount,
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
    String? paymentMode,
    double? paidAmount,
  }) {
    return Purchase(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      billPhotoPath: billPhotoPath ?? this.billPhotoPath,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      paymentMode: paymentMode ?? this.paymentMode,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
