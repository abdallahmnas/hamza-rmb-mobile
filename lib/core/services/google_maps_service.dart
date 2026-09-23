import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../../features/delivery/data/models/location_model.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final struct = json['structured_formatting'] as Map<String, dynamic>?;
    return PlaceSuggestion(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mainText: struct?['main_text']?.toString() ??
          json['description']?.toString() ??
          '',
      secondaryText: struct?['secondary_text']?.toString() ?? '',
    );
  }
}

abstract class GoogleMapsService {
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
  });

  Future<LocationModel?> getPlaceDetails(
    String placeId, {
    String? fallbackDescription,
  });

  Future<LocationModel> reverseGeocode(double latitude, double longitude);

  double calculateDistanceKm(LocationModel origin, LocationModel destination);

  String estimateTravelTime(double distanceKm);

  static double calculateDistanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    if (lat1 == 0 && lng1 == 0) return 0.0;
    if (lat2 == 0 && lng2 == 0) return 0.0;

    const double earthRadiusKm = 6371.0;
    final double dLat = _degToRad(lat2 - lat1);
    final double dLng = _degToRad(lng2 - lng1);

    final double radLat1 = _degToRad(lat1);
    final double radLat2 = _degToRad(lat2);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(radLat1) * math.cos(radLat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final double directDistance = earthRadiusKm * c;
    return directDistance * 1.25;
  }

  static double calculateDistanceKmStatic(LocationModel origin, LocationModel destination) {
    return calculateDistanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  static String estimateTravelTimeStatic(double distanceKm) {
    if (distanceKm <= 0.5) return '5 - 10 mins';
    if (distanceKm <= 5.0) return '15 - 25 mins';
    if (distanceKm <= 15.0) return '30 - 45 mins';
    if (distanceKm <= 35.0) return '45 - 70 mins';
    final hours = (distanceKm / 40.0).toStringAsFixed(1);
    return '~$hours hrs';
  }

  static double _degToRad(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}

class GoogleMapsServiceImpl implements GoogleMapsService {
  final Dio _dio;

  GoogleMapsServiceImpl(this._dio);

  String get _apiKey => AppConstants.googleMapsApiKey;

  @override
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    if (_apiKey.isNotEmpty) {
      try {
        final lat = latitude ?? AppConstants.defaultLatitude;
        final lng = longitude ?? AppConstants.defaultLongitude;

        final response = await _dio.get<dynamic>(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': cleanQuery,
            'key': _apiKey,
            'components': 'country:ng',
            'location': '$lat,$lng',
            'radius': 50000,
          },
        );

        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => PlaceSuggestion.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Fallback to local suggestions if network/API fails
      }
    }

    // Smart Nigerian & Abuja fallback suggestions
    return _getLocalSuggestions(cleanQuery);
  }

  @override
  Future<LocationModel?> getPlaceDetails(
    String placeId, {
    String? fallbackDescription,
  }) async {
    if (_apiKey.isNotEmpty && placeId.isNotEmpty && !placeId.startsWith('local_')) {
      try {
        final response = await _dio.get<dynamic>(
          'https://maps.googleapis.com/maps/api/place/details/json',
          queryParameters: {
            'place_id': placeId,
            'fields': 'formatted_address,geometry,name,address_components',
            'key': _apiKey,
          },
        );

        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final geom = result['geometry'] as Map<String, dynamic>?;
          final loc = geom?['location'] as Map<String, dynamic>?;

          final lat = (loc?['lat'] as num?)?.toDouble() ?? AppConstants.defaultLatitude;
          final lng = (loc?['lng'] as num?)?.toDouble() ?? AppConstants.defaultLongitude;
          final address = result['formatted_address']?.toString() ??
              fallbackDescription ??
              '';
          final name = result['name']?.toString();

          return LocationModel(
            address: address,
            latitude: lat,
            longitude: lng,
            placeId: placeId,
            name: name,
          );
        }
      } catch (_) {
        // Fallback below
      }
    }

    // Fallback for local suggestions or when API is unreachable
    final local = _findLocalPlace(placeId, fallbackDescription);
    if (local != null) return local;

    return LocationModel(
      address: fallbackDescription ?? 'Abuja, Federal Capital Territory, Nigeria',
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      placeId: placeId,
    );
  }

  @override
  Future<LocationModel> reverseGeocode(double latitude, double longitude) async {
    if (_apiKey.isNotEmpty) {
      try {
        final response = await _dio.get<dynamic>(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '$latitude,$longitude',
            'key': _apiKey,
          },
        );

        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>? ?? [];
          if (results.isNotEmpty) {
            final first = results.first as Map<String, dynamic>;
            final formatted = first['formatted_address']?.toString() ?? '';
            final placeId = first['place_id']?.toString();

            return LocationModel(
              address: formatted,
              latitude: latitude,
              longitude: longitude,
              placeId: placeId,
            );
          }
        }
      } catch (_) {
        // Fallback to local coordinate label
      }
    }

    // Local approximate label based on coordinates
    final label = _approximateLocationName(latitude, longitude);
    return LocationModel(
      address: label,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  double calculateDistanceKm(LocationModel origin, LocationModel destination) {
    if (origin.latitude == 0 && origin.longitude == 0) return 0.0;
    if (destination.latitude == 0 && destination.longitude == 0) return 0.0;

    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(destination.latitude - origin.latitude);
    final double dLng = _degreesToRadians(destination.longitude - origin.longitude);

    final double lat1 = _degreesToRadians(origin.latitude);
    final double lat2 = _degreesToRadians(destination.latitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final double directDistance = earthRadiusKm * c;
    // Apply standard urban road network factor (1.25x)
    return directDistance * 1.25;
  }

  @override
  String estimateTravelTime(double distanceKm) {
    if (distanceKm <= 0.5) return '5 - 10 mins';
    if (distanceKm <= 5.0) return '15 - 25 mins';
    if (distanceKm <= 15.0) return '30 - 45 mins';
    if (distanceKm <= 35.0) return '45 - 70 mins';
    final hours = (distanceKm / 40.0).toStringAsFixed(1);
    return '~$hours hrs';
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  // ── Local Fallback Database for Resilient Offline / Demo Operations ───────
  static final List<LocationModel> _presetLocations = [
    const LocationModel(
      placeId: 'local_abj_cbd',
      name: 'Central Business District (CBD)',
      address: 'Central Business District, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0765,
      longitude: 7.3986,
    ),
    const LocationModel(
      placeId: 'local_abj_maitama',
      name: 'Maitama District',
      address: 'Maitama, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0882,
      longitude: 7.4934,
    ),
    const LocationModel(
      placeId: 'local_abj_wuse2',
      name: 'Wuse 2 District',
      address: 'Wuse 2, Aminu Kano Crescent, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0723,
      longitude: 7.4764,
    ),
    const LocationModel(
      placeId: 'local_abj_gwarimpa',
      name: 'Gwarinpa Estate',
      address: 'Gwarinpa Estate, 3rd Avenue, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.1108,
      longitude: 7.4116,
    ),
    const LocationModel(
      placeId: 'local_abj_asokoro',
      name: 'Asokoro District',
      address: 'Asokoro, Yakubu Gowon Crescent, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0435,
      longitude: 7.5244,
    ),
    const LocationModel(
      placeId: 'local_abj_jabi',
      name: 'Jabi Lake Mall & District',
      address: 'Jabi District, Alex Ekwueme Way, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0772,
      longitude: 7.4246,
    ),
    const LocationModel(
      placeId: 'local_abj_garki',
      name: 'Garki Area 11',
      address: 'Garki Area 11, Ahmadu Bello Way, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0345,
      longitude: 7.4892,
    ),
    const LocationModel(
      placeId: 'local_abj_airport',
      name: 'Nnamdi Azikiwe International Airport (ABV)',
      address: 'Airport Road, Abuja, FCT, Nigeria',
      city: 'Abuja',
      state: 'FCT',
      latitude: 9.0065,
      longitude: 7.2631,
    ),
    const LocationModel(
      placeId: 'local_lag_ikeja',
      name: 'Ikeja Central Hub',
      address: 'Allen Avenue, Ikeja, Lagos State, Nigeria',
      city: 'Ikeja',
      state: 'Lagos',
      latitude: 6.6018,
      longitude: 3.3515,
    ),
    const LocationModel(
      placeId: 'local_lag_lekki',
      name: 'Lekki Phase 1',
      address: 'Admiralty Way, Lekki Phase 1, Lagos State, Nigeria',
      city: 'Lekki',
      state: 'Lagos',
      latitude: 6.4474,
      longitude: 3.4723,
    ),
    const LocationModel(
      placeId: 'local_lag_vi',
      name: 'Victoria Island Business Hub',
      address: 'Adeola Odeku Street, Victoria Island, Lagos State, Nigeria',
      city: 'Victoria Island',
      state: 'Lagos',
      latitude: 6.4281,
      longitude: 3.4219,
    ),
    const LocationModel(
      placeId: 'local_kano_gwarzo',
      name: 'Hamza RMB Kano Hub',
      address: 'No. 08 Gwarzo Road Beside Shopwell, Gwale, Kano State, Nigeria',
      city: 'Kano',
      state: 'Kano',
      latitude: 11.9899,
      longitude: 8.5204,
    ),
  ];

  List<PlaceSuggestion> _getLocalSuggestions(String query) {
    final lower = query.toLowerCase();
    final matches = _presetLocations.where((loc) {
      return loc.name!.toLowerCase().contains(lower) ||
          loc.address.toLowerCase().contains(lower) ||
          (loc.city?.toLowerCase().contains(lower) ?? false);
    }).toList();

    if (matches.isNotEmpty) {
      return matches
          .map((loc) => PlaceSuggestion(
                placeId: loc.placeId ?? 'local_${loc.name}',
                description: loc.address,
                mainText: loc.name ?? loc.address,
                secondaryText: '${loc.city ?? ""}, ${loc.state ?? "Nigeria"}',
              ))
          .toList();
    }

    // If no direct matches, return general Abuja districts
    return _presetLocations
        .take(5)
        .map((loc) => PlaceSuggestion(
              placeId: loc.placeId ?? 'local_${loc.name}',
              description: loc.address,
              mainText: loc.name ?? loc.address,
              secondaryText: '${loc.city ?? ""}, ${loc.state ?? "Nigeria"}',
            ))
        .toList();
  }

  LocationModel? _findLocalPlace(String placeId, String? description) {
    try {
      return _presetLocations.firstWhere(
        (loc) =>
            loc.placeId == placeId ||
            (description != null && loc.address == description),
      );
    } catch (_) {
      return null;
    }
  }

  String _approximateLocationName(double lat, double lng) {
    // Check if near Abuja
    if ((lat - 9.07).abs() < 0.25 && (lng - 7.45).abs() < 0.25) {
      return 'Selected Location, Abuja, FCT, Nigeria';
    }
    // Check if near Lagos
    if ((lat - 6.52).abs() < 0.35 && (lng - 3.37).abs() < 0.35) {
      return 'Selected Location, Lagos State, Nigeria';
    }
    // Check if near Kano
    if ((lat - 12.00).abs() < 0.25 && (lng - 8.52).abs() < 0.25) {
      return 'Selected Location, Kano State, Nigeria';
    }
    return 'Pinpoint Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}), Nigeria';
  }
}

final googleMapsServiceProvider = Provider<GoogleMapsService>((ref) {
  final dio = ref.watch(dioProvider);
  return GoogleMapsServiceImpl(dio);
});
