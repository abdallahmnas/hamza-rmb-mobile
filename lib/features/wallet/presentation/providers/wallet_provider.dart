import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';

class WalletState {
  final WalletModel wallet;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const WalletState({
    this.wallet = const WalletModel(id: 'wlt-default'),
    this.transactions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  static const String _walletKey = 'cache_wallet';
  static const String _txKey = 'cache_transactions';

  @override
  WalletState build() {
    final storage = ref.watch(localStorageProvider);

    WalletModel wallet = const WalletModel(id: 'wlt-default');
    List<TransactionModel> txs = [];

    final wJson = storage.getString(_walletKey);
    if (wJson != null) {
      try {
        wallet = WalletModel.fromJson(jsonDecode(wJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    final txJson = storage.getString(_txKey);
    if (txJson != null) {
      try {
        final list = jsonDecode(txJson) as List<dynamic>;
        txs = list
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return WalletState(
      wallet: wallet,
      transactions: txs,
      isLoading: txs.isEmpty && wallet.balance == 0,
    );
  }

  Future<void> fetchWalletAndTransactions({bool isUserInitiated = false}) async {
    state = state.copyWith(
      isRefreshing: true,
      isLoading: state.transactions.isEmpty && !isUserInitiated,
    );

    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);

      final results = await Future.wait([
        remote.fetchWallet().catchError((_) => state.wallet),
        remote.fetchTransactions().catchError((_) => state.transactions),
      ]);

      final freshWallet = results[0] as WalletModel;
      final freshTxs = results[1] as List<TransactionModel>;

      await storage.setString(_walletKey, jsonEncode(freshWallet.toJson()));
      await storage.setString(
          _txKey, jsonEncode(freshTxs.map((t) => t.toJson()).toList()));

      state = state.copyWith(
        wallet: freshWallet,
        transactions: freshTxs,
        isLoading: false,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> topup({
    required double amount,
    required String paymentMethod,
    required String reference,
  }) async {
    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      await remote.topupWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        reference: reference,
      );
      await fetchWalletAndTransactions(isUserInitiated: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => fetchWalletAndTransactions(isUserInitiated: true);
}


final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});
