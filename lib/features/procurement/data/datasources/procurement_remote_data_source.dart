import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/procurement_request_model.dart';

abstract class ProcurementRemoteDataSource {
  Future<ProcurementRequestModel> submitRequest({
    required String productUrl,
    required int quantity,
    required String specifications,
    String? notes,
  });

  Future<List<ProcurementRequestModel>> fetchRequests();

  Future<void> approveQuote(String id);
}

class ProcurementRemoteDataSourceImpl implements ProcurementRemoteDataSource {
  final Dio _dio;

  ProcurementRemoteDataSourceImpl(this._dio);

  @override
  Future<ProcurementRequestModel> submitRequest({
    required String productUrl,
    required int quantity,
    required String specifications,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/procurements/request',
        data: {
          'productUrl': productUrl,
          'quantity': quantity,
          'specifications': specifications,
          if (notes != null) 'notes': notes,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final procJson = data['data'] ?? data;
        if (procJson is Map<String, dynamic>) {
          return ProcurementRequestModel.fromJson(procJson);
        }
      }
      return ProcurementRequestModel(
        id: 'proc-${DateTime.now().millisecondsSinceEpoch}',
        productUrl: productUrl,
        quantity: quantity,
        specifications: specifications,
        notes: notes,
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to submit procurement request');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<ProcurementRequestModel>> fetchRequests() async {
    try {
      final response = await _dio.get('/procurements/requests');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) =>
              ProcurementRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load procurement requests');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> approveQuote(String id) async {
    try {
      await _dio.post('/procurements/requests/$id/approve');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to approve quote');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final procurementRemoteDataSourceProvider =
    Provider<ProcurementRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProcurementRemoteDataSourceImpl(dio);
});
