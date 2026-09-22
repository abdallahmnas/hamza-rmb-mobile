import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/exchange_remote_data_source.dart';
import '../../data/models/exchange_request_model.dart';

class ExchangeState {
  final List<ExchangeRequestModel> requests;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ExchangeState({
    this.requests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ExchangeState copyWith({
    List<ExchangeRequestModel>? requests,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ExchangeState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ExchangeNotifier extends Notifier<ExchangeState> {
  static const String _storageKey = 'cache_exchanges';

  @override
  ExchangeState build() {
    final storage = ref.watch(localStorageProvider);
    List<ExchangeRequestModel> cached = [];
    final json = storage.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        cached = list
            .map((e) => ExchangeRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return ExchangeState(requests: cached, isLoading: cached.isEmpty);
  }

  Future<void> fetchRequests({bool isUserInitiated = false}) async {
    state = state.copyWith(isLoading: state.requests.isEmpty && !isUserInitiated);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final fresh = await remote.fetchExchangeRequests();
      final storage = ref.read(localStorageProvider);
      await storage.setString(
          _storageKey, jsonEncode(fresh.map((e) => e.toJson()).toList()));
      state = state.copyWith(requests: fresh, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final newReq = await remote.submitExchangeRequest(
        amountNaira: amountNaira,
        rmbDestType: rmbDestType,
        rmbDestAccount: rmbDestAccount,
        rmbDestName: rmbDestName,
      );
      state = state.copyWith(
        requests: [newReq, ...state.requests],
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createExchangeRequest({
    required String fromCurrency,
    required String toCurrency,
    required double fromAmount,
    required double toAmount,
    required String receivingPlatform,
    required Map<String, dynamic> recipientDetails,
  }) async {
    return submitRequest(
      amountNaira: fromAmount,
      rmbDestType: receivingPlatform,
      rmbDestAccount: recipientDetails['account_id']?.toString() ?? '',
      rmbDestName: recipientDetails['beneficiary_name']?.toString() ?? '',
    );
  }
}


final exchangeProvider =
    NotifierProvider<ExchangeNotifier, ExchangeState>(() {
  return ExchangeNotifier();
});
