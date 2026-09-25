import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

    if (_apiKey.isEmpty) {
      debugPrint('[GoogleMapsService] Places API Key is not configured. Real API call skipped.');
      return [];
    }

    try {
      final lat = latitude ?? AppConstants.defaultLatitude;
      final lng = longitude ?? AppConstants.defaultLongitude;

      final response = await _dio.get<dynamic>(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': cleanQuery,
          'key': _apiKey,
          'location': '$lat,$lng',
          'radius': 50000,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = data['status']?.toString();
        if (status == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => PlaceSuggestion.fromJson(p as Map<String, dynamic>))
              .toList();
        } else if (status == 'ZERO_RESULTS') {
          return [];
        } else {
          final errorMsg = data['error_message']?.toString();
          debugPrint(
            '[GoogleMapsService] Autocomplete API status: $status${errorMsg != null ? " ($errorMsg)" : ""}',
          );
        }
      }
    } catch (e) {
      debugPrint('[GoogleMapsService] searchPlaces network error: $e');
    }

    return [];
  }

  @override
  Future<LocationModel?> getPlaceDetails(
    String placeId, {
    String? fallbackDescription,
  }) async {
    if (placeId.isEmpty) return null;

    if (_apiKey.isEmpty) {
      debugPrint('[GoogleMapsService] Places API Key is not configured. Place details skipped.');
      return null;
    }

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

        final lat = (loc?['lat'] as num?)?.toDouble();
        final lng = (loc?['lng'] as num?)?.toDouble();

        if (lat == null || lng == null) return null;

        final address = result['formatted_address']?.toString() ??
            fallbackDescription ??
            '';
        final name = result['name']?.toString();

        String? city;
        String? state;
        String? country;
        final components = result['address_components'] as List<dynamic>? ?? [];
        for (final comp in components) {
          if (comp is Map<String, dynamic>) {
            final types = (comp['types'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];
            if (types.contains('locality') ||
                types.contains('administrative_area_level_2')) {
              city ??= comp['long_name']?.toString();
            }
            if (types.contains('administrative_area_level_1')) {
              state = comp['long_name']?.toString();
            }
            if (types.contains('country')) {
              country = comp['long_name']?.toString();
            }
          }
        }

        return LocationModel(
          address: address,
          latitude: lat,
          longitude: lng,
          placeId: placeId,
          name: name,
          city: city,
          state: state,
          country: country,
        );
      } else if (data is Map<String, dynamic>) {
        final status = data['status']?.toString();
        final errorMsg = data['error_message']?.toString();
        debugPrint(
          '[GoogleMapsService] Place details API status: $status${errorMsg != null ? " ($errorMsg)" : ""}',
        );
      }
    } catch (e) {
      debugPrint('[GoogleMapsService] getPlaceDetails network error: $e');
    }

    return null;
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

            String? city;
            String? state;
            String? country;
            final components = first['address_components'] as List<dynamic>? ?? [];
            for (final comp in components) {
              if (comp is Map<String, dynamic>) {
                final types = (comp['types'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [];
                if (types.contains('locality') ||
                    types.contains('administrative_area_level_2')) {
                  city ??= comp['long_name']?.toString();
                }
                if (types.contains('administrative_area_level_1')) {
                  state = comp['long_name']?.toString();
                }
                if (types.contains('country')) {
                  country = comp['long_name']?.toString();
                }
              }
            }

            return LocationModel(
              address: formatted,
              latitude: latitude,
              longitude: longitude,
              placeId: placeId,
              city: city,
              state: state,
              country: country,
            );
          }
        }
      } catch (e) {
        debugPrint('[GoogleMapsService] reverseGeocode network error: $e');
      }
    }

    return LocationModel(
      address: 'Pinpoint (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
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
    // Apply standard road network factor (1.25x)
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
}

final googleMapsServiceProvider = Provider<GoogleMapsService>((ref) {
  final dio = ref.watch(dioProvider);
  return GoogleMapsServiceImpl(dio);
});
