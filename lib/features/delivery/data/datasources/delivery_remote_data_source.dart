import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/data/models/delivery_vehicle_model.dart';
import '../models/local_delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<LocalDeliveryModel> requestDelivery({
    required String consolidationId,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
    String? deliveryVehicleId,
    String? itemPhotoUrl,
  });

  Future<List<LocalDeliveryModel>> fetchDeliveries();

  Future<List<DeliveryVehicleModel>> fetchVehicles();
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio _dio;

  DeliveryRemoteDataSourceImpl(this._dio);

  @override
  Future<LocalDeliveryModel> requestDelivery({
    required String consolidationId,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
    String? deliveryVehicleId,
    String? itemPhotoUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'consolidationId': consolidationId,
        'deliveryAddress': deliveryAddress,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        if (deliveryVehicleId != null && deliveryVehicleId.isNotEmpty)
          'deliveryVehicleId': deliveryVehicleId,
        if (itemPhotoUrl != null && itemPhotoUrl.isNotEmpty)
          'itemPhotoUrl': itemPhotoUrl,
      };

      final response = await _dio.post<dynamic>('/delivery/request', data: payload);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final delJson = data['data'] ?? data;
        if (delJson is Map<String, dynamic>) {
          return LocalDeliveryModel.fromJson(delJson);
        }
      }

      return LocalDeliveryModel(
        id: 'del-${DateTime.now().millisecondsSinceEpoch}',
        consolidationId: consolidationId,
        deliveryAddress: deliveryAddress,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        pickupPin: '${(1000 + (DateTime.now().millisecond % 9000))}',
        status: 'pending',
        itemPhotoUrl: itemPhotoUrl,
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to request local delivery');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<LocalDeliveryModel>> fetchDeliveries() async {
    try {
      final response = await _dio.get<dynamic>('/delivery/deliveries');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((e) => LocalDeliveryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load local deliveries');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<DeliveryVehicleModel>> fetchVehicles() async {
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
          .map((e) => DeliveryVehicleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load vehicles');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final deliveryRemoteDataSourceProvider =
    Provider<DeliveryRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DeliveryRemoteDataSourceImpl(dio);
});
