import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_deposit_model.dart';
import '../../data/models/wallet_model.dart';

class WalletState {
  final WalletModel wallet;
  final List<TransactionModel> transactions;
  final List<WalletDepositModel> deposits;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const WalletState({
    this.wallet = const WalletModel(id: 'wlt-default'),
    this.transactions = const [],
    this.deposits = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    List<WalletDepositModel>? deposits,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      deposits: deposits ?? this.deposits,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  static const String _walletKey = 'cache_wallet';
  static const String _txKey = 'cache_transactions';
  static const String _depositKey = 'cache_deposits';

  @override
  WalletState build() {
    final storage = ref.watch(localStorageProvider);

    WalletModel wallet = const WalletModel(id: 'wlt-default');
    List<TransactionModel> txs = [];
    List<WalletDepositModel> deposits = [];

    final wJson = storage.getString(_walletKey);
    if (wJson != null) {
      try {
        wallet =
            WalletModel.fromJson(jsonDecode(wJson) as Map<String, dynamic>);
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

    final dJson = storage.getString(_depositKey);
    if (dJson != null) {
      try {
        final list = jsonDecode(dJson) as List<dynamic>;
        deposits = list
            .map((e) =>
                WalletDepositModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Auto-fetch fresh wallet data on initialization
    Future.microtask(() {
      fetchWalletAndTransactions();
    });

    return WalletState(
      wallet: wallet,
      transactions: txs,
      deposits: deposits,
      isLoading: txs.isEmpty && wallet.balance == 0 && deposits.isEmpty,
    );
  }

  Future<void> fetchWalletAndTransactions({bool isUserInitiated = false}) async {
    state = state.copyWith(
      isRefreshing: true,
      isLoading: state.transactions.isEmpty &&
          state.deposits.isEmpty &&
          !isUserInitiated,
    );

    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);

      WalletModel freshWallet = state.wallet;
      try {
        freshWallet = await remote.fetchWallet();
        await storage.setString(_walletKey, jsonEncode(freshWallet.toJson()));
      } catch (_) {}

      List<TransactionModel> freshTxs = state.transactions;
      try {
        freshTxs = await remote.fetchTransactions();
        await storage.setString(
            _txKey, jsonEncode(freshTxs.map((t) => t.toJson()).toList()));
      } catch (_) {}

      List<WalletDepositModel> freshDeposits = state.deposits;
      try {
        freshDeposits = await remote.fetchDeposits();
        await storage.setString(_depositKey,
            jsonEncode(freshDeposits.map((d) => d.toJson()).toList()));
      } catch (_) {}

      state = state.copyWith(
        wallet: freshWallet,
        transactions: freshTxs,
        deposits: freshDeposits,
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

  Future<void> fetchWallet() async {
    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);
      final freshWallet = await remote.fetchWallet();
      await storage.setString(_walletKey, jsonEncode(freshWallet.toJson()));
      state = state.copyWith(wallet: freshWallet);
    } catch (_) {}
  }

  Future<void> fetchDeposits({bool isUserInitiated = false}) async {
    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);
      final freshDeposits = await remote.fetchDeposits();

      await storage.setString(_depositKey,
          jsonEncode(freshDeposits.map((d) => d.toJson()).toList()));

      state = state.copyWith(
        deposits: freshDeposits,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> topup({
    required double amount,
    required String paymentMethod,
    required String reference,
    String? imageUrl,
  }) async {
    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      await remote.topupWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        reference: reference,
        imageUrl: imageUrl,
      );
      await fetchWalletAndTransactions(isUserInitiated: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<WalletDepositModel?> deposit({
    required double amount,
    required String senderName,
    required String sessionId,
    File? receiptFile,
    Uint8List? receiptBytes,
    String? receiptFileName,
  }) async {
    try {
      final remote = ref.read(walletRemoteDataSourceProvider);
      final depositRecord = await remote.depositWallet(
        amount: amount,
        senderName: senderName,
        sessionId: sessionId,
        receiptFile: receiptFile,
        receiptBytes: receiptBytes,
        receiptFileName: receiptFileName,
      );
      await fetchWalletAndTransactions(isUserInitiated: true);
      return depositRecord;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> refresh() => fetchWalletAndTransactions(isUserInitiated: true);
}


final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});
