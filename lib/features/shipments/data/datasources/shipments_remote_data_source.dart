import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/consolidation_model.dart';
import '../models/package_model.dart';

abstract class ShipmentsRemoteDataSource {
  Future<List<PackageModel>> fetchPackages();
  Future<PackageModel> submitPreAlert({
    required String trackingNumber,
    required String courierName,
    required double declaredValueUsd,
    String? itemDescription,
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
      final response = await _dio.get('/shipments/packages');
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
    required String trackingNumber,
    required String courierName,
    required double declaredValueUsd,
    String? itemDescription,
  }) async {
    try {
      final response = await _dio.post(
        '/shipments/pre-alert',
        data: {
          'trackingNumber': trackingNumber,
          'courierName': courierName,
          'declaredValueUsd': declaredValueUsd,
          if (itemDescription != null) 'itemDescription': itemDescription,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final pkgJson = data['data'] ?? data;
        if (pkgJson is Map<String, dynamic>) {
          return PackageModel.fromJson(pkgJson);
        }
      }
      return PackageModel(
        id: 'pkg-temp',
        trackingNumber: trackingNumber,
        courierName: courierName,
        declaredValueUsd: declaredValueUsd,
        status: 'pre_alert_submitted',
        receivedDate: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to submit pre-alert');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<ConsolidationModel>> fetchConsolidations() async {
    try {
      final response = await _dio.get('/shipments/consolidations');
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
      final response = await _dio.post(
        '/shipments/consolidations',
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
      throw e.error ?? NetworkError(e.message ?? 'Failed to create consolidation');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchTracking(String id) async {
    try {
      final response = await _dio.get('/shipments/tracking/$id');
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
