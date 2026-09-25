import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/auth/auth_service.dart';
import 'package:hamza_rmb/core/errors/app_errors.dart';
import 'package:hamza_rmb/core/network/dio_client.dart';
import 'package:hamza_rmb/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalStorage Session and Cache Clearing', () {
    test('clearCache removes only keys with cache_ prefix', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'secret_token_123',
        'auth_user': '{"id":"usr-1"}',
        'onboarding_completed': 'true',
        'cache_wallet': '{"balance":5000}',
        'cache_rates': '{"rate":205}',
      });

      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.clearCache();

      expect(storage.getString('auth_token'), 'secret_token_123');
      expect(storage.getString('auth_user'), '{"id":"usr-1"}');
      expect(storage.getString('onboarding_completed'), 'true');
      expect(storage.getString('cache_wallet'), isNull);
      expect(storage.getString('cache_rates'), isNull);
    });

    test('clearSessionAndCache removes session and cache while preserving onboarding', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'secret_token_123',
        'auth_user': '{"id":"usr-1"}',
        'onboarding_completed': 'true',
        'cache_wallet': '{"balance":5000}',
        'cache_transactions': '[{"id":"tx-1"}]',
        'cache_customs_clearance_requests_v1': '[]',
      });

      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.clearSessionAndCache();

      expect(storage.getString('auth_token'), isNull);
      expect(storage.getString('auth_user'), isNull);
      expect(storage.getString('cache_wallet'), isNull);
      expect(storage.getString('cache_transactions'), isNull);
      expect(storage.getString('cache_customs_clearance_requests_v1'), isNull);
      expect(storage.getString('onboarding_completed'), 'true');
    });
  });

  group('Dio 401 Interceptor', () {
    test('clears login session and cache on 401 API response', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'expired_jwt_token',
        'auth_user': '{"id":"usr-99","email":"user@example.com"}',
        'onboarding_completed': 'true',
        'cache_wallet': '{"balance":9999}',
        'cache_packages': '[{"id":"pkg-1"}]',
      });

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Verify initial auth state
      expect(container.read(authServiceProvider).isLoggedIn, isTrue);
      expect(container.read(authServiceProvider).token, 'expired_jwt_token');

      final dio = container.read(dioProvider);

      // Simulate a server 401 response via httpClientAdapter
      dio.httpClientAdapter = Mock401Adapter();

      try {
        await dio.get<dynamic>('/test-protected-endpoint');
        fail('Should have thrown DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
        expect(e.error, isA<UnauthorizedError>());
      }

      // Verify that login session is cleared in AuthService
      final authState = container.read(authServiceProvider);
      expect(authState.isLoggedIn, isFalse);
      expect(authState.token, isNull);
      expect(authState.user, isNull);

      // Verify that session and cache are cleared in LocalStorage
      final storage = container.read(localStorageProvider);
      expect(storage.getString('auth_token'), isNull);
      expect(storage.getString('auth_user'), isNull);
      expect(storage.getString('cache_wallet'), isNull);
      expect(storage.getString('cache_packages'), isNull);

      // Verify that onboarding_completed is preserved
      expect(storage.getString('onboarding_completed'), 'true');
    });
  });
}

class Mock401Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message": "Token has expired"}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

