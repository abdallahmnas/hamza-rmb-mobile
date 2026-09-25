import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/consolidation_model.dart';
import '../models/package_model.dart';

abstract class ShipmentsRemoteDataSource {
  Future<List<PackageModel>> fetchPackages();
  Future<PackageModel> submitPreAlert({
    required String originCountry,
    required String paymentOption,
    required int estimatedItems,
    String? chineseTrackingNo,
    String? supplierName,
    String? description,
    String? notes,
    List<String>? photos,
    String? courierName,
    double? declaredValueUsd,
  });
  Future<List<ConsolidationModel>> fetchConsolidations();
  Future<ConsolidationModel> createConsolidation({
    required List<String> packageIds,
    required String shippingMethod,
    required String destinationWarehouse,
    required String paymentMethod,
  });
  Future<Map<String, dynamic>> fetchTracking(String id);
}

class ShipmentsRemoteDataSourceImpl implements ShipmentsRemoteDataSource {
  final Dio _dio;

  ShipmentsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<PackageModel>> fetchPackages() async {
    try {
      final response = await _dio.get<dynamic>('/shipments/packages');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) => PackageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load packages');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<PackageModel> submitPreAlert({
    required String originCountry,
    required String paymentOption,
    required int estimatedItems,
    String? chineseTrackingNo,
    String? supplierName,
    String? description,
    String? notes,
    List<String>? photos,
    String? courierName,
    double? declaredValueUsd,
  }) async {
    try {
      final payload = <String, dynamic>{
        'originCountry': originCountry.trim(),
        'paymentOption': paymentOption.trim(),
        'estimatedItems': estimatedItems,
      };

      if (chineseTrackingNo != null && chineseTrackingNo.trim().isNotEmpty) {
        payload['chineseTrackingNo'] = chineseTrackingNo.trim();
      }
      if (supplierName != null && supplierName.trim().isNotEmpty) {
        payload['supplierName'] = supplierName.trim();
      }
      if (description != null && description.trim().isNotEmpty) {
        payload['description'] = description.trim();
      }
      if (notes != null && notes.trim().isNotEmpty) {
        payload['notes'] = notes.trim();
      }
      if (photos != null && photos.isNotEmpty) {
        payload['photos'] = photos;
      }
      if (courierName != null && courierName.trim().isNotEmpty) {
        payload['courierName'] = courierName.trim();
      }
      if (declaredValueUsd != null && declaredValueUsd > 0) {
        payload['declaredValueUsd'] = declaredValueUsd;
      }

      final endpoint = _dio.options.baseUrl.contains('/v1')
          ? '/shipments/pre-alert'
          : '/v1/shipments/pre-alert';

      final response = await _dio.post<dynamic>(
        endpoint,
        data: payload,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final pkgJson = data['data'] ?? data;
        if (pkgJson is Map<String, dynamic>) {
          return PackageModel.fromJson(pkgJson);
        }
      }
      return PackageModel(
        id: 'pkg-temp-${DateTime.now().millisecondsSinceEpoch}',
        trackingNumber: chineseTrackingNo ?? '',
        supplierName: supplierName ?? '',
        originCountry: originCountry,
        paymentOption: paymentOption,
        estimatedItems: estimatedItems,
        notes: notes,
        itemDescription: description,
        photos: photos ?? const [],
        status: 'pre_alerted',
        receivedDate: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to submit pre-alert');
    } catch (e) {
      if (e is AppError) rethrow;
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<ConsolidationModel>> fetchConsolidations() async {
    try {
      final response = await _dio.get<dynamic>('/shipments/consolidations');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) => ConsolidationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load consolidations');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ConsolidationModel> createConsolidation({
    required List<String> packageIds,
    required String shippingMethod,
    required String destinationWarehouse,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/shipments/consolidate',
        data: {
          'packageIds': packageIds,
          'shippingMethod': shippingMethod,
          'destinationWarehouse': destinationWarehouse,
          'paymentMethod': paymentMethod,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final conJson = data['data'] ?? data;
        if (conJson is Map<String, dynamic>) {
          return ConsolidationModel.fromJson(conJson);
        }
      }
      return ConsolidationModel(
        id: 'con-temp',
        consolidationId: 'CON-${DateTime.now().millisecondsSinceEpoch}',
        packageIds: packageIds,
        shippingMethod: shippingMethod,
        destinationWarehouse: destinationWarehouse,
        paymentMethod: paymentMethod,
      );
    } on DioException catch (e) {
      final serverMsg = (e.response?.data is Map)
          ? (e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString())
          : null;
      if (serverMsg != null) {
        throw NetworkError(serverMsg);
      }
      throw e.error ?? NetworkError(e.message ?? 'Failed to create consolidation');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchTracking(String id) async {
    try {
      final response = await _dio.get<dynamic>('/shipments/tracking/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['data'] as Map<String, dynamic>?) ?? data;
      }
      return {};
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to track package');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final shipmentsRemoteDataSourceProvider =
    Provider<ShipmentsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ShipmentsRemoteDataSourceImpl(dio);
});
