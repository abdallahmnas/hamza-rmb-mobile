import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/constants/app_constants.dart';
import 'package:hamza_rmb/core/services/google_maps_service.dart';

void main() {
  late Dio dio;
  late GoogleMapsServiceImpl service;

  setUp(() {
    dio = Dio();
    service = GoogleMapsServiceImpl(dio);
    AppConstants.setGoogleMapsApiKey('test_google_maps_api_key_123');
  });

  tearDown(() {
    AppConstants.setGoogleMapsApiKey('');
  });

  group('GoogleMapsServiceImpl Real API & No Mock Data Tests', () {
    test('searchPlaces returns empty list when API key is empty and does not return mock data', () async {
      AppConstants.setGoogleMapsApiKey('');

      final results = await service.searchPlaces('Abuja');

      // Crucial: Must be empty, MUST NOT return mock data or preset districts
      expect(results, isEmpty);
    });

    test('searchPlaces makes real API call with query and parses PlaceSuggestion', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.path,
              'https://maps.googleapis.com/maps/api/place/autocomplete/json',
            );
            expect(options.queryParameters['input'], 'Wuse');
            expect(options.queryParameters['key'], 'test_google_maps_api_key_123');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'OK',
                  'predictions': [
                    {
                      'place_id': 'place_real_wuse_1',
                      'description': 'Wuse 2, Abuja, Nigeria',
                      'structured_formatting': {
                        'main_text': 'Wuse 2',
                        'secondary_text': 'Abuja, Nigeria',
                      },
                    },
                    {
                      'place_id': 'place_real_wuse_zone_5',
                      'description': 'Wuse Zone 5, Abuja, Nigeria',
                      'structured_formatting': {
                        'main_text': 'Wuse Zone 5',
                        'secondary_text': 'Abuja, Nigeria',
                      },
                    }
                  ],
                },
              ),
            );
          },
        ),
      );

      final results = await service.searchPlaces('Wuse');

      expect(results.length, 2);
      expect(results[0].placeId, 'place_real_wuse_1');
      expect(results[0].mainText, 'Wuse 2');
      expect(results[0].description, 'Wuse 2, Abuja, Nigeria');
      expect(results[1].placeId, 'place_real_wuse_zone_5');
      expect(results[1].mainText, 'Wuse Zone 5');
    });

    test('searchPlaces returns empty list on ZERO_RESULTS without mock fallback', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'ZERO_RESULTS',
                  'predictions': [],
                },
              ),
            );
          },
        ),
      );

      final results = await service.searchPlaces('NonExistentAddressQuery12345');

      expect(results, isEmpty);
    });

    test('getPlaceDetails makes real API call and returns LocationModel with exact coordinates', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.path,
              'https://maps.googleapis.com/maps/api/place/details/json',
            );
            expect(options.queryParameters['place_id'], 'place_wuse_123');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'OK',
                  'result': {
                    'name': 'Wuse Mall',
                    'formatted_address': 'Plot 400, Aminu Kano Crescent, Wuse 2, Abuja, Nigeria',
                    'geometry': {
                      'location': {
                        'lat': 9.0725,
                        'lng': 7.4780,
                      },
                    },
                    'address_components': [
                      {
                        'long_name': 'Abuja',
                        'types': ['locality'],
                      },
                      {
                        'long_name': 'Federal Capital Territory',
                        'types': ['administrative_area_level_1'],
                      },
                      {
                        'long_name': 'Nigeria',
                        'types': ['country'],
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final details = await service.getPlaceDetails('place_wuse_123');

      expect(details, isNotNull);
      expect(details!.latitude, 9.0725);
      expect(details.longitude, 7.4780);
      expect(details.name, 'Wuse Mall');
      expect(details.address, 'Plot 400, Aminu Kano Crescent, Wuse 2, Abuja, Nigeria');
      expect(details.city, 'Abuja');
      expect(details.state, 'Federal Capital Territory');
      expect(details.country, 'Nigeria');
    });

    test('reverseGeocode makes real API call and returns formatted geocoded address', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, 'https://maps.googleapis.com/maps/api/geocode/json');
            expect(options.queryParameters['latlng'], '9.0765,7.3986');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'OK',
                  'results': [
                    {
                      'place_id': 'place_geo_cbd_1',
                      'formatted_address': 'Shehu Shagari Way, Central Business District, Abuja, Nigeria',
                      'address_components': [
                        {
                          'long_name': 'Abuja',
                          'types': ['locality'],
                        },
                      ],
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final location = await service.reverseGeocode(9.0765, 7.3986);

      expect(location.address, 'Shehu Shagari Way, Central Business District, Abuja, Nigeria');
      expect(location.placeId, 'place_geo_cbd_1');
      expect(location.latitude, 9.0765);
      expect(location.longitude, 7.3986);
      expect(location.city, 'Abuja');
    });
  });
}
