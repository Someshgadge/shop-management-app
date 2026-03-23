/// Stock distribution status
enum DistributionStatus {
  pending, // PENDING
  accepted, // ACCEPTED
  rejected, // REJECTED
}

extension DistributionStatusExtension on DistributionStatus {
  String get value {
    switch (this) {
      case DistributionStatus.pending:
        return 'PENDING';
      case DistributionStatus.accepted:
        return 'ACCEPTED';
      case DistributionStatus.rejected:
        return 'REJECTED';
    }
  }

  String get displayName {
    switch (this) {
      case DistributionStatus.pending:
        return 'Pending';
      case DistributionStatus.accepted:
        return 'Accepted';
      case DistributionStatus.rejected:
        return 'Rejected';
    }
  }

  static DistributionStatus fromString(String value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED':
        return DistributionStatus.accepted;
      case 'REJECTED':
        return DistributionStatus.rejected;
      default:
        return DistributionStatus.pending;
    }
  }
}

/// Shop Distribution model matching your Supabase schema
class Distribution {
  final String id;
  final String shopName; // Your schema: shopname
  final DateTime date; // Your schema: date
  final double stockAmount; // Your schema: stockamount
  final String? biltiPhotoPath; // Your schema: biltiphotopath
  final String? productType; // Your schema: producttype
  final int? quantity; // Your schema: quantity
  final String? notes; // Your schema: notes
  final DistributionStatus status; // Your schema: status
  final String? acceptedBy; // Your schema: acceptedby
  final DateTime? acceptedDate; // Your schema: accepteddate

  Distribution({
    required this.id,
    required this.shopName,
    required this.date,
    required this.stockAmount,
    this.biltiPhotoPath,
    this.productType,
    this.quantity,
    this.notes,
    this.status = DistributionStatus.pending,
    this.acceptedBy,
    this.acceptedDate,
  });

  // For backwards compatibility
  String? get biltiPhotoUrl => biltiPhotoPath;
  String? get rejectionReason => notes;
  String? get shopId => shopName; // Using shopName as shopId
  String? get createdBy => acceptedBy;

  factory Distribution.fromSupabase(Map<String, dynamic> data) {
    return Distribution(
      id: data['id'] ?? '',
      shopName: data['shopname'] ?? '',
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      stockAmount: (data['stockamount'] ?? 0).toDouble(),
      biltiPhotoPath: data['biltiphotopath'],
      productType: data['producttype'],
      quantity: data['quantity'],
      notes: data['notes'],
      status: DistributionStatusExtension.fromString(data['status']),
      acceptedBy: data['acceptedby'],
      acceptedDate: data['accepteddate'] != null
          ? DateTime.parse(data['accepteddate'])
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'shopname': shopName,
      'date': date.toIso8601String(),
      'stockamount': stockAmount,
      'biltiphotopath': biltiPhotoPath,
      'producttype': productType,
      'quantity': quantity,
      'notes': notes,
      'status': status.value,
      'acceptedby': acceptedBy,
      'accepteddate': acceptedDate?.toIso8601String(),
    };
  }

  Distribution copyWith({
    String? id,
    String? shopName,
    DateTime? date,
    double? stockAmount,
    String? biltiPhotoPath,
    String? productType,
    int? quantity,
    String? notes,
    DistributionStatus? status,
    String? acceptedBy,
    DateTime? acceptedDate,
  }) {
    return Distribution(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      date: date ?? this.date,
      stockAmount: stockAmount ?? this.stockAmount,
      biltiPhotoPath: biltiPhotoPath ?? this.biltiPhotoPath,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedDate: acceptedDate ?? this.acceptedDate,
    );
  }
}
