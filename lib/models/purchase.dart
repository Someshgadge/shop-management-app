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
  final double pendingAmount; // Amount remaining to pay

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
    this.pendingAmount = 0.0,
  });

  // For backwards compatibility
  String? get billPhotoUrl => billPhotoPath;
  bool get isFullyPaid => pendingAmount <= 0;

  factory Purchase.fromSupabase(Map<String, dynamic> data) {
    final amount = (data['amount'] ?? 0).toDouble();
    final paidAmount = (data['paidamount'] ?? 0).toDouble();
    final pendingAmount = (data['pendingamount'] ?? 0).toDouble();

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
      pendingAmount: pendingAmount > 0 ? pendingAmount : (amount - paidAmount),
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
      'pendingamount':
          pendingAmount > 0 ? pendingAmount : (amount - paidAmount),
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
    double? pendingAmount,
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
      pendingAmount: pendingAmount ?? this.pendingAmount,
    );
  }
}
