class PackageModel {
  final String id;
  final String trackingNumber;
  final String customerId;
  final String customerName;
  final String courierName;
  final double declaredValueUsd;
  final double weightKg;
  final double cbm;
  final String status;
  final List<String> photos;
  final DateTime? receivedDate;

  const PackageModel({
    required this.id,
    required this.trackingNumber,
    this.customerId = '',
    this.customerName = '',
    this.courierName = '',
    this.declaredValueUsd = 0.0,
    this.weightKg = 0.0,
    this.cbm = 0.0,
    this.status = 'pending',
    this.photos = const [],
    this.receivedDate,
  });

  String get courier => courierName;
  String get description =>
      courierName.isNotEmpty ? '$courierName Package' : 'General Parcel';
  double get weight => weightKg;
  double get declaredValue => declaredValueUsd;


  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      courierName: json['courierName']?.toString() ?? '',
      declaredValueUsd: (json['declaredValueUsd'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      cbm: (json['cbm'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'received_cn',
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      receivedDate: json['receivedDate'] != null
          ? DateTime.tryParse(json['receivedDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trackingNumber': trackingNumber,
        'customerId': customerId,
        'customerName': customerName,
        'courierName': courierName,
        'declaredValueUsd': declaredValueUsd,
        'weightKg': weightKg,
        'cbm': cbm,
        'status': status,
        'photos': photos,
        'receivedDate': receivedDate?.toIso8601String(),
      };
}
