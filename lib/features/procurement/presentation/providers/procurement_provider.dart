import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/procurement_remote_data_source.dart';
import '../../data/models/procurement_request_model.dart';

class ProcurementState {
  final List<ProcurementRequestModel> requests;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ProcurementState({
    this.requests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ProcurementState copyWith({
    List<ProcurementRequestModel>? requests,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ProcurementState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ProcurementNotifier extends Notifier<ProcurementState> {
  static const String _storageKey = 'cache_procurements';

  @override
  ProcurementState build() {
    final storage = ref.watch(localStorageProvider);
    List<ProcurementRequestModel> cached = [];
    final json = storage.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        cached = list
            .map((e) =>
                ProcurementRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return ProcurementState(requests: cached, isLoading: cached.isEmpty);
  }

  Future<void> fetchRequests({bool isUserInitiated = false}) async {
    state = state.copyWith(isLoading: state.requests.isEmpty && !isUserInitiated);
    try {
      final remote = ref.read(procurementRemoteDataSourceProvider);
      final fresh = await remote.fetchRequests();
      final storage = ref.read(localStorageProvider);
      await storage.setString(
          _storageKey, jsonEncode(fresh.map((e) => e.toJson()).toList()));
      state = state.copyWith(requests: fresh, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitRequest({
    required String productUrl,
    required int quantity,
    required String specifications,
    String? notes,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(procurementRemoteDataSourceProvider);
      final newReq = await remote.submitRequest(
        productUrl: productUrl,
        quantity: quantity,
        specifications: specifications,
        notes: notes,
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

  Future<bool> approveQuote(String id) async {
    try {
      final remote = ref.read(procurementRemoteDataSourceProvider);
      await remote.approveQuote(id);
      await fetchRequests(isUserInitiated: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final procurementProvider =
    NotifierProvider<ProcurementNotifier, ProcurementState>(() {
  return ProcurementNotifier();
});
