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
    String? qrCodeUrl,
    String? receiptUrl,
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
    String? qrCodeUrl,
    String? receiptUrl,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/exchanges/request',
        data: {
          'amountNaira': amountNaira,
          'rmbDestType': rmbDestType,
          'rmbDestAccount': rmbDestAccount,
          'rmbDestName': rmbDestName,
          if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) 'qrCodeUrl': qrCodeUrl,
          if (receiptUrl != null && receiptUrl.isNotEmpty) 'receiptUrl': receiptUrl,
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
        qrCodeUrl: qrCodeUrl,
        receiptUrl: receiptUrl,
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
      final response = await _dio.get<dynamic>('/exchanges/requests');
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
