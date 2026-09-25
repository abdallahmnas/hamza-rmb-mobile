import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_service.dart';
import '../constants/app_constants.dart';
import '../errors/app_errors.dart';
import '../storage/local_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(localStorageProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Read auth token from LocalStorage
        final token = storage.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;

        // Whenever an API call detects status 401, clear login session and cache.
        if (statusCode == 401) {
          try {
            await ref.read(authServiceProvider.notifier).clearSessionAndCache();
          } catch (_) {
            // Silently swallow errors during session clearing
          }
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: NetworkError('Unable to connect to server. Please check your internet connection.'),
            ),
          );
        }

        if (e.response != null) {
          final data = e.response?.data;
          String errorMessage = statusCode == 401
              ? 'Session expired. Please log in again.'
              : 'An error occurred';
          if (data is Map<String, dynamic>) {
            errorMessage = data['message']?.toString() ??
                data['error']?.toString() ??
                (statusCode == 401
                    ? 'Session expired. Please log in again.'
                    : 'Request failed with status code ${e.response?.statusCode}');
          } else if (data is String && data.isNotEmpty) {
            errorMessage = data;
          }

          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: statusCode == 401
                  ? UnauthorizedError(errorMessage)
                  : ApiError(
                      errorMessage,
                      statusCode: statusCode,
                    ),
            ),
          );
        }

        return handler.next(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            error: NetworkError(e.message ?? 'Unknown network error'),
          ),
        );
      },
    ),
  );

  return dio;
});
