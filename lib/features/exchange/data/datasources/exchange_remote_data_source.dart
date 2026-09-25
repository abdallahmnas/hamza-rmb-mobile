import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exchange_request_model.dart';
import '../models/saved_account_model.dart';

abstract class ExchangeRemoteDataSource {
  Future<List<SavedAccountModel>> fetchSavedAccounts();

  Future<SavedAccountModel> createSavedAccount({
    required String platform,
    required String accountNumber,
    required String accountName,
    required String label,
    required String barcodeUrl,
    bool isDefault = false,
  });

  Future<ExchangeRequestModel> createExchangeRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
    required String rmbDestQrCode,
    required String receivingBarcodeUrl,
    required String nairaReceiptUrl,
    bool saveAccount = false,
  });

  Future<List<ExchangeRequestModel>> fetchExchangeRequests();
}

class ExchangeRemoteDataSourceImpl implements ExchangeRemoteDataSource {
  final Dio _dio;

  ExchangeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SavedAccountModel>> fetchSavedAccounts() async {
    try {
      final response = await _dio.get<dynamic>('/exchanges/saved-accounts');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) =>
              SavedAccountModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load saved accounts');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<SavedAccountModel> createSavedAccount({
    required String platform,
    required String accountNumber,
    required String accountName,
    required String label,
    required String barcodeUrl,
    bool isDefault = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/exchanges/saved-accounts',
        data: {
          'platform': platform,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'label': label,
          'barcodeUrl': barcodeUrl,
          'isDefault': isDefault,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final itemJson = data['data'] ?? data;
        if (itemJson is Map<String, dynamic>) {
          return SavedAccountModel.fromJson(itemJson);
        }
      }
      return SavedAccountModel(
        id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
        platform: platform,
        accountNumber: accountNumber,
        accountName: accountName,
        label: label,
        barcodeUrl: barcodeUrl,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to create saved account');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ExchangeRequestModel> createExchangeRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
    required String rmbDestQrCode,
    required String receivingBarcodeUrl,
    required String nairaReceiptUrl,
    bool saveAccount = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/exchanges',
        data: {
          'amountNaira': amountNaira,
          'rmbDestType': rmbDestType,
          'rmbDestAccount': rmbDestAccount,
          'rmbDestName': rmbDestName,
          'rmbDestQrCode': rmbDestQrCode,
          'receivingBarcodeUrl': receivingBarcodeUrl,
          'nairaReceiptUrl': nairaReceiptUrl,
          'saveAccount': saveAccount,
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
        amountRmb: amountNaira / 225,
        totalNaira: amountNaira + 5000,
        exchangeRate: 225,
        platformFee: 5000,
        status: 'receipt_uploaded',
        rmbDestType: rmbDestType,
        rmbDestAccount: rmbDestAccount,
        rmbDestName: rmbDestName,
        rmbDestQrCode: rmbDestQrCode,
        receivingBarcodeUrl: receivingBarcodeUrl,
        nairaReceiptUrl: nairaReceiptUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
      Response<dynamic> response;
      try {
        response = await _dio.get<dynamic>('/exchanges');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get<dynamic>('/exchanges/requests');
        } else {
          rethrow;
        }
      }
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
