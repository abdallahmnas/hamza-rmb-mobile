import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/banner_model.dart';
import '../models/delivery_vehicle_model.dart';
import '../models/exchange_rate_model.dart';
import '../models/system_settings_model.dart';

abstract class PublicMetadataRemoteDataSource {
  Future<List<BannerModel>> fetchBanners();
  Future<SystemSettingsModel> fetchSettings();
  Future<List<DeliveryVehicleModel>> fetchDeliveryVehicles();
  Future<ExchangeRateModel> fetchExchangeRate();
}

class PublicMetadataRemoteDataSourceImpl implements PublicMetadataRemoteDataSource {
  final Dio _dio;

  PublicMetadataRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get<dynamic>('/banners');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      final parsed = list
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .where((b) => b.isActive)
          .toList();
      return parsed.isNotEmpty ? parsed : BannerModel.defaultBanners;
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to fetch banners');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<SystemSettingsModel> fetchSettings() async {
    try {
      final response = await _dio.get<dynamic>('/settings');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final settingsJson = data['data'] ?? data;
        if (settingsJson is Map<String, dynamic>) {
          return SystemSettingsModel.fromJson(settingsJson);
        }
      }
      return const SystemSettingsModel();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to fetch settings');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<DeliveryVehicleModel>> fetchDeliveryVehicles() async {
    try {
      final response = await _dio.get<dynamic>('/delivery/vehicles');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) => DeliveryVehicleModel.fromJson(item as Map<String, dynamic>))
          .where((v) => v.isActive)
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to fetch delivery vehicles');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ExchangeRateModel> fetchExchangeRate() async {
    try {
      final response = await _dio.get<dynamic>('/exchanges/rate');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rateJson = data['data'] ?? data;
        if (rateJson is Map<String, dynamic>) {
          return ExchangeRateModel.fromJson(rateJson);
        }
      }
      return const ExchangeRateModel();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to fetch exchange rate');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final publicMetadataRemoteDataSourceProvider =
    Provider<PublicMetadataRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PublicMetadataRemoteDataSourceImpl(dio);
});
