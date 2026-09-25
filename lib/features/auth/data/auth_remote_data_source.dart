import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_errors.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthResponse {
  final String? token;
  final UserModel? user;
  final String message;

  const AuthResponse({
    this.token,
    this.user,
    required this.message,
  });
}

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  });

  Future<AuthResponse> resendOtp({
    required String email,
  });

  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      final data = response.data;
      String? token;
      UserModel? user;
      String message = 'Registration successful';

      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
        token = data['token']?.toString() ?? data['data']?['token']?.toString();
        final userJson = data['user'] ?? data['data']?['user'] ?? data['data'];
        if (userJson is Map<String, dynamic> && (userJson.containsKey('email') || userJson.containsKey('firstName'))) {
          user = UserModel.fromJson(userJson);
        }
      }

      return AuthResponse(token: token, user: user, message: message);
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Registration failed');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      String? token;
      UserModel? user;
      String message = 'Login successful';

      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
        token = data['token']?.toString() ?? data['data']?['token']?.toString();
        final userJson = data['user'] ?? data['data']?['user'] ?? data['data'];
        if (userJson is Map<String, dynamic> && (userJson.containsKey('email') || userJson.containsKey('firstName'))) {
          user = UserModel.fromJson(userJson);
        }
      }

      return AuthResponse(token: token, user: user, message: message);
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Login failed');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );
      final data = response.data;
      String message = 'OTP verified successfully';
      String? token;
      UserModel? user;
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
        token = data['token']?.toString() ?? data['data']?['token']?.toString();
        final userJson = data['user'] ?? data['data']?['user'] ?? data['data'];
        if (userJson is Map<String, dynamic> && (userJson.containsKey('email') || userJson.containsKey('firstName'))) {
          user = UserModel.fromJson(userJson);
        }
      }
      return AuthResponse(token: token, user: user, message: message);
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'OTP verification failed');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<AuthResponse> resendOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/resend-otp',
        data: {'email': email},
      );
      final data = response.data;
      String message = 'New OTP dispatched to email';
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
      }
      return AuthResponse(message: message);
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to resend OTP');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get<dynamic>('/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userData = data['data'] ?? data['user'] ?? data;
        if (userData is Map<String, dynamic>) {
          return UserModel.fromJson(userData);
        }
      }
      throw ApiError('Invalid user profile response');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to fetch user profile');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});
