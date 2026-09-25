import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/exchange_remote_data_source.dart';
import '../../data/models/exchange_request_model.dart';
import '../../data/models/saved_account_model.dart';

class ExchangeState {
  final List<ExchangeRequestModel> requests;
  final List<SavedAccountModel> savedAccounts;
  final SavedAccountModel? selectedSavedAccount;
  final bool isLoading;
  final bool isLoadingAccounts;
  final bool isSubmitting;
  final String? error;

  const ExchangeState({
    this.requests = const [],
    this.savedAccounts = const [],
    this.selectedSavedAccount,
    this.isLoading = false,
    this.isLoadingAccounts = false,
    this.isSubmitting = false,
    this.error,
  });

  ExchangeState copyWith({
    List<ExchangeRequestModel>? requests,
    List<SavedAccountModel>? savedAccounts,
    SavedAccountModel? selectedSavedAccount,
    bool clearSelectedSavedAccount = false,
    bool? isLoading,
    bool? isLoadingAccounts,
    bool? isSubmitting,
    String? error,
  }) {
    return ExchangeState(
      requests: requests ?? this.requests,
      savedAccounts: savedAccounts ?? this.savedAccounts,
      selectedSavedAccount: clearSelectedSavedAccount
          ? null
          : (selectedSavedAccount ?? this.selectedSavedAccount),
      isLoading: isLoading ?? this.isLoading,
      isLoadingAccounts: isLoadingAccounts ?? this.isLoadingAccounts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ExchangeNotifier extends Notifier<ExchangeState> {
  static const String _storageKeyRequests = 'cache_exchanges';
  static const String _storageKeyAccounts = 'cache_exchange_saved_accounts';

  @override
  ExchangeState build() {
    final storage = ref.watch(localStorageProvider);
    List<ExchangeRequestModel> cachedRequests = [];
    final jsonRequests = storage.getString(_storageKeyRequests);
    if (jsonRequests != null) {
      try {
        final list = jsonDecode(jsonRequests) as List<dynamic>;
        cachedRequests = list
            .map((e) =>
                ExchangeRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    List<SavedAccountModel> cachedAccounts = [];
    final jsonAccounts = storage.getString(_storageKeyAccounts);
    if (jsonAccounts != null) {
      try {
        final list = jsonDecode(jsonAccounts) as List<dynamic>;
        cachedAccounts = list
            .map((e) =>
                SavedAccountModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    SavedAccountModel? defaultAccount;
    if (cachedAccounts.isNotEmpty) {
      defaultAccount = cachedAccounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => cachedAccounts.first,
      );
    }

    return ExchangeState(
      requests: cachedRequests,
      savedAccounts: cachedAccounts,
      selectedSavedAccount: defaultAccount,
      isLoading: cachedRequests.isEmpty,
      isLoadingAccounts: cachedAccounts.isEmpty,
    );
  }

  Future<void> fetchRequests({bool isUserInitiated = false}) async {
    state = state.copyWith(
        isLoading: state.requests.isEmpty && !isUserInitiated);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final fresh = await remote.fetchExchangeRequests();
      final storage = ref.read(localStorageProvider);
      await storage.setString(
          _storageKeyRequests,
          jsonEncode(fresh.map((e) => e.toJson()).toList()));
      state = state.copyWith(requests: fresh, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchSavedAccounts({bool isUserInitiated = false}) async {
    state = state.copyWith(
        isLoadingAccounts: state.savedAccounts.isEmpty && !isUserInitiated);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final fresh = await remote.fetchSavedAccounts();
      final storage = ref.read(localStorageProvider);
      await storage.setString(
          _storageKeyAccounts,
          jsonEncode(fresh.map((e) => e.toJson()).toList()));

      SavedAccountModel? selected = state.selectedSavedAccount;
      if (selected != null) {
        final selectedId = selected.id;
        final match = fresh.where((a) => a.id == selectedId).firstOrNull;
        if (match != null) {
          selected = match;
        } else if (fresh.isNotEmpty) {
          selected = fresh.firstWhere((a) => a.isDefault, orElse: () => fresh.first);
        }
      } else if (fresh.isNotEmpty) {
        selected = fresh.firstWhere((a) => a.isDefault, orElse: () => fresh.first);
      }

      state = state.copyWith(
        savedAccounts: fresh,
        selectedSavedAccount: selected,
        isLoadingAccounts: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingAccounts: false, error: e.toString());
    }
  }

  void selectSavedAccount(SavedAccountModel? account) {
    if (account == null) {
      state = state.copyWith(clearSelectedSavedAccount: true);
    } else {
      state = state.copyWith(selectedSavedAccount: account);
    }
  }

  Future<SavedAccountModel?> createSavedAccount({
    required String platform,
    required String accountNumber,
    required String accountName,
    required String label,
    required String barcodeUrl,
    bool isDefault = false,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final newAcc = await remote.createSavedAccount(
        platform: platform,
        accountNumber: accountNumber,
        accountName: accountName,
        label: label,
        barcodeUrl: barcodeUrl,
        isDefault: isDefault,
      );

      final updatedAccounts = [newAcc, ...state.savedAccounts];
      state = state.copyWith(
        savedAccounts: updatedAccounts,
        selectedSavedAccount: newAcc,
        isSubmitting: false,
      );

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKeyAccounts,
        jsonEncode(updatedAccounts.map((e) => e.toJson()).toList()),
      );

      return newAcc;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<ExchangeRequestModel?> createExchangeRequest({
    required double amountNaira,
    required String rmbDestType,
    required String rmbDestAccount,
    required String rmbDestName,
    required String rmbDestQrCode,
    required String receivingBarcodeUrl,
    required String nairaReceiptUrl,
    bool saveAccount = false,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(exchangeRemoteDataSourceProvider);
      final newReq = await remote.createExchangeRequest(
        amountNaira: amountNaira,
        rmbDestType: rmbDestType,
        rmbDestAccount: rmbDestAccount,
        rmbDestName: rmbDestName,
        rmbDestQrCode: rmbDestQrCode,
        receivingBarcodeUrl: receivingBarcodeUrl,
        nairaReceiptUrl: nairaReceiptUrl,
        saveAccount: saveAccount,
      );

      final updatedRequests = [newReq, ...state.requests];
      state = state.copyWith(
        requests: updatedRequests,
        isSubmitting: false,
      );

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKeyRequests,
        jsonEncode(updatedRequests.map((e) => e.toJson()).toList()),
      );

      // If user saved account, refresh saved accounts
      if (saveAccount) {
        fetchSavedAccounts(isUserInitiated: true);
      }

      return newReq;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchRequests(isUserInitiated: true),
      fetchSavedAccounts(isUserInitiated: true),
    ]);
  }
}

final exchangeProvider =
    NotifierProvider<ExchangeNotifier, ExchangeState>(() {
  return ExchangeNotifier();
});
