import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/data/models/delivery_vehicle_model.dart';
import '../models/local_delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<LocalDeliveryModel> requestDelivery({
    required String pickupAddress,
    String pickupCity = 'Lagos',
    String pickupContactName = 'Warehouse Admin',
    String pickupPhone = '+2348090219021',
    String pickupEmail = 'pickup@logistics.com',
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    String dropoffCity = 'Lagos',
    required String dropoffContactName,
    required String dropoffPhone,
    String dropoffEmail = 'customer@example.com',
    required double dropoffLat,
    required double dropoffLng,
    required String customerEmail,
    required String customerPhone,
    required String packageDescription,
    List<String> imageUrls = const [],
    required String vehicleId,
    required String vehicleType,
    required double distanceKm,
    String paymentMethod = 'wallet',
    String? consolidationId,
  });

  Future<List<LocalDeliveryModel>> fetchDeliveries();

  Future<List<DeliveryVehicleModel>> fetchVehicles();
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio _dio;

  DeliveryRemoteDataSourceImpl(this._dio);

  @override
  Future<LocalDeliveryModel> requestDelivery({
    required String pickupAddress,
    String pickupCity = 'Lagos',
    String pickupContactName = 'Warehouse Admin',
    String pickupPhone = '+2348090219021',
    String pickupEmail = 'pickup@logistics.com',
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    String dropoffCity = 'Lagos',
    required String dropoffContactName,
    required String dropoffPhone,
    String dropoffEmail = 'customer@example.com',
    required double dropoffLat,
    required double dropoffLng,
    required String customerEmail,
    required String customerPhone,
    required String packageDescription,
    List<String> imageUrls = const [],
    required String vehicleId,
    required String vehicleType,
    required double distanceKm,
    String paymentMethod = 'wallet',
    String? consolidationId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'pickupAddress': pickupAddress,
        'pickupCity': pickupCity.isNotEmpty ? pickupCity : 'Lagos',
        'pickupContactName': pickupContactName.isNotEmpty ? pickupContactName : 'Warehouse Admin',
        'pickupPhone': pickupPhone.isNotEmpty ? pickupPhone : '+2348090219021',
        'pickupEmail': pickupEmail.isNotEmpty ? pickupEmail : 'pickup@logistics.com',
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffAddress': dropoffAddress,
        'dropoffCity': dropoffCity.isNotEmpty ? dropoffCity : 'Lagos',
        'dropoffContactName': dropoffContactName,
        'dropoffPhone': dropoffPhone,
        'dropoffEmail': dropoffEmail.isNotEmpty ? dropoffEmail : customerEmail,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'packageDescription': packageDescription,
        'imageUrls': imageUrls,
        'vehicleId': vehicleId,
        'vehicleType': vehicleType,
        'distanceKm': distanceKm,
        'paymentMethod': paymentMethod, // 'wallet'
        if (consolidationId != null && consolidationId.isNotEmpty)
          'consolidationId': consolidationId,
      };

      final response = await _dio.post<dynamic>('/delivery/request', data: payload);
      final data = response.data;

      if (data is Map) {
        final delJson = data['data'] ?? data['delivery'] ?? data;
        if (delJson is Map) {
          return LocalDeliveryModel.fromJson(Map<String, dynamic>.from(delJson));
        }
      }

      return LocalDeliveryModel(
        id: 'del-${DateTime.now().millisecondsSinceEpoch}',
        consolidationId: consolidationId ?? '',
        pickupAddress: pickupAddress,
        pickupCity: pickupCity,
        pickupContactName: pickupContactName,
        pickupPhone: pickupPhone,
        pickupEmail: pickupEmail,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffAddress: dropoffAddress,
        dropoffCity: dropoffCity,
        dropoffContactName: dropoffContactName,
        dropoffPhone: dropoffPhone,
        dropoffEmail: dropoffEmail,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        packageDescription: packageDescription,
        imageUrls: imageUrls,
        vehicleId: vehicleId,
        vehicleType: vehicleType,
        distanceKm: distanceKm,
        paymentMethod: paymentMethod,
        pickupPin: '${(1000 + (DateTime.now().millisecond % 9000))}',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      final resData = e.response?.data;
      String? errorMessage;
      if (resData is Map) {
        errorMessage = resData['message']?.toString() ?? resData['error']?.toString();
      } else if (resData is String && resData.isNotEmpty) {
        errorMessage = resData;
      }
      throw e.error ?? NetworkError(errorMessage ?? e.message ?? 'Failed to request local delivery');
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
      if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['deliveries'] is List) {
          list = data['deliveries'] as List;
        } else if (data['items'] is List) {
          list = data['items'] as List;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => LocalDeliveryModel.fromJson(Map<String, dynamic>.from(e)))
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
      if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['vehicles'] is List) {
          list = data['vehicles'] as List;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => DeliveryVehicleModel.fromJson(Map<String, dynamic>.from(e)))
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
