class ConsolidationModel {
  final String id;
  final String consolidationId;
  final String customerId;
  final String shippingMethod;
  final String destinationWarehouse;
  final String paymentMethod;
  final double totalWeightKg;
  final double totalCbm;
  final double shippingFee;
  final String status;
  final List<String> packageIds;

  const ConsolidationModel({
    required this.id,
    required this.consolidationId,
    this.customerId = '',
    this.shippingMethod = 'air',
    this.destinationWarehouse = 'lagos',
    this.paymentMethod = 'wallet',
    this.totalWeightKg = 0.0,
    this.totalCbm = 0.0,
    this.shippingFee = 0.0,
    this.status = 'ready_to_batch',
    this.packageIds = const [],
  });

  factory ConsolidationModel.fromJson(Map<String, dynamic> json) {
    return ConsolidationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      consolidationId:
          json['consolidationId']?.toString() ?? json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      shippingMethod: json['shippingMethod']?.toString() ?? 'air',
      destinationWarehouse: json['destinationWarehouse']?.toString() ?? 'lagos',
      paymentMethod: json['paymentMethod']?.toString() ?? 'wallet',
      totalWeightKg: (json['totalWeightKg'] as num?)?.toDouble() ?? 0.0,
      totalCbm: (json['totalCbm'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ready_to_batch',
      packageIds: (json['packageIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consolidationId': consolidationId,
        'customerId': customerId,
        'shippingMethod': shippingMethod,
        'destinationWarehouse': destinationWarehouse,
        'paymentMethod': paymentMethod,
        'totalWeightKg': totalWeightKg,
        'totalCbm': totalCbm,
        'shippingFee': shippingFee,
        'status': status,
        'packageIds': packageIds,
      };
}
