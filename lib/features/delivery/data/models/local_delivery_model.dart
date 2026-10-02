class LocalDeliveryModel {
  final String id;
  final String consolidationId;
  final String pickupAddress;
  final String pickupCity;
  final String pickupContactName;
  final String pickupPhone;
  final String pickupEmail;
  final double? pickupLat;
  final double? pickupLng;
  final String dropoffAddress;
  final String dropoffCity;
  final String dropoffContactName;
  final String dropoffPhone;
  final String dropoffEmail;
  final double? dropoffLat;
  final double? dropoffLng;
  final String customerEmail;
  final String customerPhone;
  final String packageDescription;
  final List<String> imageUrls;
  final String? vehicleId;
  final String? vehicleType;
  final double distanceKm;
  final String paymentMethod;
  final String pickupPin;
  final String status;
  final String? driverName;
  final String? driverPhone;
  final double deliveryFee;
  final String? _deliveryAddress;
  final String? _recipientName;
  final String? _recipientPhone;
  final String? _itemPhotoUrl;
  final DateTime createdAt;

  const LocalDeliveryModel({
    required this.id,
    this.consolidationId = '',
    this.pickupAddress = '',
    this.pickupCity = '',
    this.pickupContactName = '',
    this.pickupPhone = '',
    this.pickupEmail = '',
    this.pickupLat,
    this.pickupLng,
    this.dropoffAddress = '',
    this.dropoffCity = '',
    this.dropoffContactName = '',
    this.dropoffPhone = '',
    this.dropoffEmail = '',
    this.dropoffLat,
    this.dropoffLng,
    this.customerEmail = '',
    this.customerPhone = '',
    this.packageDescription = '',
    this.imageUrls = const [],
    this.vehicleId,
    this.vehicleType,
    this.distanceKm = 0.0,
    this.paymentMethod = 'wallet',
    required this.pickupPin,
    this.status = 'pending',
    this.driverName,
    this.driverPhone,
    this.deliveryFee = 0.0,
    String? deliveryAddress,
    String? recipientName,
    String? recipientPhone,
    String? itemPhotoUrl,
    required this.createdAt,
  })  : _deliveryAddress = deliveryAddress,
        _recipientName = recipientName,
        _recipientPhone = recipientPhone,
        _itemPhotoUrl = itemPhotoUrl;

  String get deliveryAddress =>
      dropoffAddress.isNotEmpty ? dropoffAddress : (_deliveryAddress ?? '');
  String get recipientName =>
      dropoffContactName.isNotEmpty ? dropoffContactName : (_recipientName ?? '');
  String get recipientPhone =>
      dropoffPhone.isNotEmpty ? dropoffPhone : (_recipientPhone ?? '');
  String? get itemPhotoUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : _itemPhotoUrl;

  factory LocalDeliveryModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['imageUrls'] is List) {
      images = (json['imageUrls'] as List).map((e) => e.toString()).toList();
    } else if (json['itemPhotoUrl'] != null && json['itemPhotoUrl'].toString().isNotEmpty) {
      images = [json['itemPhotoUrl'].toString()];
    } else if (json['photoUrl'] != null && json['photoUrl'].toString().isNotEmpty) {
      images = [json['photoUrl'].toString()];
    }

    final dropoffAddr = json['dropoffAddress']?.toString() ??
        json['deliveryAddress']?.toString() ??
        '';
    final dropoffContact = json['dropoffContactName']?.toString() ??
        json['recipientName']?.toString() ??
        '';
    final dropoffPh = json['dropoffPhone']?.toString() ??
        json['recipientPhone']?.toString() ??
        '';

    return LocalDeliveryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      consolidationId: json['consolidationId']?.toString() ??
          json['packageId']?.toString() ??
          '',
      pickupAddress: json['pickupAddress']?.toString() ?? '',
      pickupCity: json['pickupCity']?.toString() ?? '',
      pickupContactName: json['pickupContactName']?.toString() ?? '',
      pickupPhone: json['pickupPhone']?.toString() ?? '',
      pickupEmail: json['pickupEmail']?.toString() ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffAddress: dropoffAddr,
      dropoffCity: json['dropoffCity']?.toString() ?? '',
      dropoffContactName: dropoffContact,
      dropoffPhone: dropoffPh,
      dropoffEmail: json['dropoffEmail']?.toString() ?? '',
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      packageDescription: json['packageDescription']?.toString() ?? '',
      imageUrls: images,
      vehicleId: json['vehicleId']?.toString() ?? json['deliveryVehicleId']?.toString(),
      vehicleType: json['vehicleType']?.toString() ?? json['vehicle']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'wallet',
      pickupPin: json['pickupPin']?.toString() ??
          json['pin']?.toString() ??
          '----',
      status: json['status']?.toString() ?? 'pending',
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ??
          (json['fare'] as num?)?.toDouble() ??
          (json['fee'] as num?)?.toDouble() ??
          0.0,
      deliveryAddress: dropoffAddr,
      recipientName: dropoffContact,
      recipientPhone: dropoffPh,
      itemPhotoUrl: images.isNotEmpty ? images.first : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consolidationId': consolidationId,
        'pickupAddress': pickupAddress,
        'pickupCity': pickupCity,
        'pickupContactName': pickupContactName,
        'pickupPhone': pickupPhone,
        'pickupEmail': pickupEmail,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffAddress': dropoffAddress,
        'dropoffCity': dropoffCity,
        'dropoffContactName': dropoffContactName,
        'dropoffPhone': dropoffPhone,
        'dropoffEmail': dropoffEmail,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'packageDescription': packageDescription,
        'imageUrls': imageUrls,
        'vehicleId': vehicleId,
        'vehicleType': vehicleType,
        'distanceKm': distanceKm,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'pickupPin': pickupPin,
        'status': status,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'deliveryFee': deliveryFee,
        'itemPhotoUrl': itemPhotoUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
