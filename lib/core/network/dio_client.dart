import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../errors/app_errors.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add headers, auth tokens, etc. here
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              error: NetworkError('Connection timed out'),
            ),
          );
        }

        if (e.response != null) {
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              error: ApiError(
                e.response?.data?['message']?.toString() ?? 'API Error occurred',
                statusCode: e.response?.statusCode,
              ),
            ),
          );
        }

        return handler.next(
          DioException(
            requestOptions: e.requestOptions,
            error: NetworkError(e.message ?? 'Unknown network error'),
          ),
        );
      },
    ),
  );

  return dio;
});
