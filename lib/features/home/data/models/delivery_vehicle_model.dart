class DeliveryVehicleModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final double baseFare;
  final double perKmRate;
  final double maxWeightKg;
  final String imageUrl;
  final bool isActive;

  const DeliveryVehicleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.maxWeightKg,
    required this.imageUrl,
    this.isActive = true,
  });

  factory DeliveryVehicleModel.fromJson(Map<String, dynamic> json) {
    return DeliveryVehicleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? 0.0,
      maxWeightKg: (json['maxWeightKg'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'baseFare': baseFare,
        'perKmRate': perKmRate,
        'maxWeightKg': maxWeightKg,
        'imageUrl': imageUrl,
        'isActive': isActive,
      };
}
