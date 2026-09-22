class ProcurementRequestModel {
  final String id;
  final String customerId;
  final String productUrl;
  final int quantity;
  final String specifications;
  final String? notes;
  final double productCostRmb;
  final double serviceFeeRmb;
  final double totalCostRmb;
  final double exchangeRateUsed;
  final double totalCostNaira;
  final String status;

  const ProcurementRequestModel({
    required this.id,
    this.customerId = '',
    required this.productUrl,
    this.quantity = 1,
    this.specifications = '',
    this.notes,
    this.productCostRmb = 0.0,
    this.serviceFeeRmb = 0.0,
    this.totalCostRmb = 0.0,
    this.exchangeRateUsed = 215.0,
    this.totalCostNaira = 0.0,
    this.status = 'pending_quote',
  });

  factory ProcurementRequestModel.fromJson(Map<String, dynamic> json) {
    return ProcurementRequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      productUrl: json['productUrl']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      specifications: json['specifications']?.toString() ?? '',
      notes: json['notes']?.toString(),
      productCostRmb: (json['productCostRmb'] as num?)?.toDouble() ?? 0.0,
      serviceFeeRmb: (json['serviceFeeRmb'] as num?)?.toDouble() ?? 0.0,
      totalCostRmb: (json['totalCostRmb'] as num?)?.toDouble() ?? 0.0,
      exchangeRateUsed: (json['exchangeRateUsed'] as num?)?.toDouble() ?? 215.0,
      totalCostNaira: (json['totalCostNaira'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending_quote',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'productUrl': productUrl,
        'quantity': quantity,
        'specifications': specifications,
        'notes': notes,
        'productCostRmb': productCostRmb,
        'serviceFeeRmb': serviceFeeRmb,
        'totalCostRmb': totalCostRmb,
        'exchangeRateUsed': exchangeRateUsed,
        'totalCostNaira': totalCostNaira,
        'status': status,
      };
}
