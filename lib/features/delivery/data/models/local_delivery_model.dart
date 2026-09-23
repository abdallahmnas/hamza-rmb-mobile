class LocalDeliveryModel {
  final String id;
  final String consolidationId;
  final String deliveryAddress;
  final String recipientName;
  final String recipientPhone;
  final String pickupPin;
  final String status;
  final String? driverName;
  final String? driverPhone;
  final double deliveryFee;
  final String? vehicleType;
  final String? itemPhotoUrl;
  final DateTime createdAt;

  const LocalDeliveryModel({
    required this.id,
    required this.consolidationId,
    required this.deliveryAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.pickupPin,
    this.status = 'pending',
    this.driverName,
    this.driverPhone,
    this.deliveryFee = 0.0,
    this.vehicleType,
    this.itemPhotoUrl,
    required this.createdAt,
  });

  factory LocalDeliveryModel.fromJson(Map<String, dynamic> json) {
    return LocalDeliveryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      consolidationId: json['consolidationId']?.toString() ??
          json['packageId']?.toString() ??
          '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      recipientPhone: json['recipientPhone']?.toString() ?? '',
      pickupPin: json['pickupPin']?.toString() ??
          json['pin']?.toString() ??
          '----',
      status: json['status']?.toString() ?? 'pending',
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ??
          (json['fee'] as num?)?.toDouble() ??
          0.0,
      vehicleType: json['vehicleType']?.toString() ?? json['vehicle']?.toString(),
      itemPhotoUrl: json['itemPhotoUrl']?.toString() ?? json['photoUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consolidationId': consolidationId,
        'deliveryAddress': deliveryAddress,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'pickupPin': pickupPin,
        'status': status,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'deliveryFee': deliveryFee,
        'vehicleType': vehicleType,
        'itemPhotoUrl': itemPhotoUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
