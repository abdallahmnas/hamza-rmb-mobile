import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> fetchWallet();
  Future<void> topupWallet({
    required double amount,
    required String paymentMethod,
    required String reference,
    String? imageUrl,
  });
  Future<List<TransactionModel>> fetchTransactions();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio _dio;

  WalletRemoteDataSourceImpl(this._dio);

  @override
  Future<WalletModel> fetchWallet() async {
    try {
      final response = await _dio.get<dynamic>('/wallet');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final wltJson = data['data'] ?? data;
        if (wltJson is Map<String, dynamic>) {
          return WalletModel.fromJson(wltJson);
        }
      }
      return const WalletModel(id: 'wlt-default', balance: 0.0);
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load wallet');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> topupWallet({
    required double amount,
    required String paymentMethod,
    required String reference,
    String? imageUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'amount': amount,
        'paymentMethod': paymentMethod,
        'reference': reference,
      };
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        payload['imageUrl'] = imageUrl.trim();
      }

      await _dio.post<dynamic>(
        '/wallet/topup',
        data: payload,
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Top-up failed');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      final response = await _dio.get<dynamic>('/wallet/transactions');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) =>
              TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load transactions');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final walletRemoteDataSourceProvider =
    Provider<WalletRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WalletRemoteDataSourceImpl(dio);
});
