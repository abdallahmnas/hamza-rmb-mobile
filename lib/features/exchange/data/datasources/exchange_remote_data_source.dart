import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exchange_request_model.dart';

abstract class ExchangeRemoteDataSource {
  Future<ExchangeRequestModel> submitExchangeRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
  });

  Future<List<ExchangeRequestModel>> fetchExchangeRequests();
}

class ExchangeRemoteDataSourceImpl implements ExchangeRemoteDataSource {
  final Dio _dio;

  ExchangeRemoteDataSourceImpl(this._dio);

  @override
  Future<ExchangeRequestModel> submitExchangeRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
  }) async {
    try {
      final response = await _dio.post(
        '/exchanges/request',
        data: {
          'amountNaira': amountNaira,
          'rmbDestType': rmbDestType,
          'rmbDestAccount': rmbDestAccount,
          'rmbDestName': rmbDestName,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final exgJson = data['data'] ?? data;
        if (exgJson is Map<String, dynamic>) {
          return ExchangeRequestModel.fromJson(exgJson);
        }
      }
      return ExchangeRequestModel(
        id: 'exg-${DateTime.now().millisecondsSinceEpoch}',
        amountNaira: amountNaira,
        amountRmb: amountNaira / 215,
        totalNaira: amountNaira,
        rmbDestType: rmbDestType,
        rmbDestAccount: rmbDestAccount,
        rmbDestName: rmbDestName,
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to submit exchange request');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<ExchangeRequestModel>> fetchExchangeRequests() async {
    try {
      final response = await _dio.get('/exchanges/requests');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) =>
              ExchangeRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load exchange requests');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final exchangeRemoteDataSourceProvider =
    Provider<ExchangeRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ExchangeRemoteDataSourceImpl(dio);
});
