class LocationModel {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? name;
  final String? city;
  final String? state;
  final String? country;

  const LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.name,
    this.city,
    this.state,
    this.country,
  });

  /// Default Abuja, Nigeria location model
  factory LocationModel.defaultAbuja() {
    return const LocationModel(
      address: 'Central Business District, Abuja, FCT, Nigeria',
      latitude: 9.0765,
      longitude: 7.3986,
      name: 'Abuja CBD',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      country: 'Nigeria',
    );
  }

  bool get isEmpty => address.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Short display title (e.g., street name or place name)
  String get shortTitle {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    final parts = address.split(',');
    if (parts.isNotEmpty) return parts.first.trim();
    return address;
  }

  /// Subtitle description (e.g., city, state)
  String get subtitle {
    final parts = address.split(',');
    if (parts.length > 1) {
      return parts.sublist(1).join(',').trim();
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  LocationModel copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    String? name,
    String? city,
    String? state,
    String? country,
  }) {
    return LocationModel(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address']?.toString() ??
          json['formatted_address']?.toString() ??
          json['name']?.toString() ??
          '',
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          0.0,
      placeId: json['placeId']?.toString() ?? json['place_id']?.toString(),
      name: json['name']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'placeId': placeId,
        'name': name,
        'city': city,
        'state': state,
        'country': country,
      };

  @override
  String toString() =>
      'LocationModel(address: $address, lat: $latitude, lng: $longitude, placeId: $placeId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => address.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
