import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';
import '../models/wallet_deposit_model.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> fetchWallet();
  Future<void> topupWallet({
    required double amount,
    required String paymentMethod,
    required String reference,
    String? imageUrl,
  });
  Future<WalletDepositModel> depositWallet({
    required double amount,
    required String senderName,
    required String sessionId,
    File? receiptFile,
    Uint8List? receiptBytes,
    String? receiptFileName,
  });
  Future<List<TransactionModel>> fetchTransactions();
  Future<List<WalletDepositModel>> fetchDeposits();
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
        final candidate = data['data'] ?? data['wallet'] ?? data;
        final wltJson = (candidate is Map<String, dynamic> && candidate['wallet'] is Map<String, dynamic>)
            ? candidate['wallet'] as Map<String, dynamic>
            : (candidate is Map<String, dynamic> ? candidate : null);
        if (wltJson != null) {
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
  Future<WalletDepositModel> depositWallet({
    required double amount,
    required String senderName,
    required String sessionId,
    File? receiptFile,
    Uint8List? receiptBytes,
    String? receiptFileName,
  }) async {
    try {
      MultipartFile multipartReceipt;
      if (receiptFile != null) {
        final fileName = receiptFileName ??
            receiptFile.path.split(Platform.pathSeparator).last;
        multipartReceipt = await MultipartFile.fromFile(
          receiptFile.path,
          filename: fileName,
        );
      } else if (receiptBytes != null) {
        multipartReceipt = MultipartFile.fromBytes(
          receiptBytes,
          filename: receiptFileName ?? 'receipt.jpg',
        );
      } else {
        throw ValidationError('Receipt file is required');
      }

      final formData = FormData.fromMap({
        'amount': amount % 1 == 0 ? amount.toInt() : amount,
        'senderName': senderName.trim(),
        'sessionId': sessionId.trim(),
        'receipt': multipartReceipt,
      });

      final endpoint = _dio.options.baseUrl.contains('/v1')
          ? '/wallet/deposit'
          : '/v1/wallet/deposit';

      final response = await _dio.post<dynamic>(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] ?? data;
        if (payload is Map<String, dynamic>) {
          return WalletDepositModel.fromJson(payload);
        }
      }
      throw NetworkError('Invalid deposit response format');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Wallet deposit failed');
    } catch (e) {
      if (e is AppError) rethrow;
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

  @override
  Future<List<WalletDepositModel>> fetchDeposits() async {
    try {
      final endpoint = _dio.options.baseUrl.contains('/v1')
          ? '/wallet/deposits'
          : '/v1/wallet/deposits';

      final response = await _dio.get<dynamic>(endpoint);
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List<dynamic>) {
        list = data;
      }
      return list
          .map((item) =>
              WalletDepositModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load deposit requests');
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
