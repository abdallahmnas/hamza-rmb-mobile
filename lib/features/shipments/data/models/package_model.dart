class PackageModel {
  final String id;
  final String trackingId;
  final String trackingNumber;
  final String customerId;
  final String customerName;
  final String courierName;
  final String supplierName;
  final String originCountry;
  final String paymentOption;
  final String paymentStatus;
  final int estimatedItems;
  final String? notes;
  final double declaredValueUsd;
  final double weightKg;
  final double cbm;
  final String status;
  final String? itemDescription;
  final List<String> photos;
  final DateTime? receivedDate;
  final DateTime? preAlertDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PackageModel({
    required this.id,
    this.trackingId = '',
    required this.trackingNumber,
    this.customerId = '',
    this.customerName = '',
    this.courierName = '',
    this.supplierName = '',
    this.originCountry = '',
    this.paymentOption = '',
    this.paymentStatus = 'unpaid',
    this.estimatedItems = 1,
    this.notes,
    this.declaredValueUsd = 0.0,
    this.weightKg = 0.0,
    this.cbm = 0.0,
    this.status = 'pre_alerted',
    this.itemDescription,
    this.photos = const [],
    this.receivedDate,
    this.preAlertDate,
    this.createdAt,
    this.updatedAt,
  });

  String get courier => courierName.isNotEmpty ? courierName : (supplierName.isNotEmpty ? supplierName : 'Express Cargo');
  String get chineseTrackingNo => trackingNumber;
  String get displayTracking => trackingId.isNotEmpty ? trackingId : (trackingNumber.isNotEmpty ? trackingNumber : id);
  String get description =>
      (itemDescription != null && itemDescription!.isNotEmpty)
          ? itemDescription!
          : (supplierName.isNotEmpty ? '$supplierName Package' : 'General Parcel');
  double get weight => weightKg;
  double get declaredValue => declaredValueUsd;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      trackingId: json['trackingId']?.toString() ?? '',
      trackingNumber: json['chineseTrackingNo']?.toString() ??
          json['trackingNumber']?.toString() ??
          json['trackingNo']?.toString() ??
          json['trackingId']?.toString() ??
          '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      courierName: json['courierName']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      originCountry: json['originCountry']?.toString() ?? '',
      paymentOption: json['paymentOption']?.toString() ??
          json['paymentMethod']?.toString() ??
          '',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      estimatedItems: (json['estimatedItems'] as num?)?.toInt() ?? 1,
      notes: json['notes']?.toString(),
      declaredValueUsd: (json['declaredValueUsd'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      cbm: (json['cbm'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pre_alerted',
      itemDescription: json['description']?.toString() ??
          json['itemDescription']?.toString(),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      receivedDate: json['receivedDate'] != null
          ? DateTime.tryParse(json['receivedDate'].toString())
          : null,
      preAlertDate: json['preAlertDate'] != null
          ? DateTime.tryParse(json['preAlertDate'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trackingId': trackingId,
        'trackingNumber': trackingNumber,
        'chineseTrackingNo': trackingNumber,
        'customerId': customerId,
        'customerName': customerName,
        'courierName': courierName,
        'supplierName': supplierName,
        'originCountry': originCountry,
        'paymentOption': paymentOption,
        'paymentStatus': paymentStatus,
        'estimatedItems': estimatedItems,
        'notes': notes,
        'declaredValueUsd': declaredValueUsd,
        'description': itemDescription,
        'weightKg': weightKg,
        'cbm': cbm,
        'status': status,
        'photos': photos,
        'receivedDate': receivedDate?.toIso8601String(),
        'preAlertDate': preAlertDate?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
