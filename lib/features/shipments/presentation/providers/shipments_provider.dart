import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/shipments_remote_data_source.dart';
import '../../data/models/consolidation_model.dart';
import '../../data/models/package_model.dart';

class ShipmentsState {
  final List<PackageModel> packages;
  final List<ConsolidationModel> consolidations;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const ShipmentsState({
    this.packages = const [],
    this.consolidations = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  ShipmentsState copyWith({
    List<PackageModel>? packages,
    List<ConsolidationModel>? consolidations,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return ShipmentsState(
      packages: packages ?? this.packages,
      consolidations: consolidations ?? this.consolidations,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

class ShipmentsNotifier extends Notifier<ShipmentsState> {
  static const String _packagesKey = 'cache_packages';
  static const String _consolidationsKey = 'cache_consolidations';

  @override
  ShipmentsState build() {
    final storage = ref.watch(localStorageProvider);

    List<PackageModel> packages = [];
    List<ConsolidationModel> consolidations = [];

    final pkgJson = storage.getString(_packagesKey);
    if (pkgJson != null) {
      try {
        final list = jsonDecode(pkgJson) as List<dynamic>;
        packages = list
            .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final conJson = storage.getString(_consolidationsKey);
    if (conJson != null) {
      try {
        final list = jsonDecode(conJson) as List<dynamic>;
        consolidations = list
            .map((e) => ConsolidationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return ShipmentsState(
      packages: packages,
      consolidations: consolidations,
      isLoading: packages.isEmpty,
    );
  }

  Future<void> fetchAll({bool isUserInitiated = false}) async {
    state = state.copyWith(
      isRefreshing: true,
      isLoading: state.packages.isEmpty && !isUserInitiated,
    );

    try {
      final remoteSource = ref.read(shipmentsRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);

      final results = await Future.wait([
        remoteSource.fetchPackages().catchError((_) => state.packages),
        remoteSource.fetchConsolidations().catchError((_) => state.consolidations),
      ]);

      final freshPackages = results[0] as List<PackageModel>;
      final freshConsolidations = results[1] as List<ConsolidationModel>;

      await storage.setString(
          _packagesKey, jsonEncode(freshPackages.map((p) => p.toJson()).toList()));
      await storage.setString(_consolidationsKey,
          jsonEncode(freshConsolidations.map((c) => c.toJson()).toList()));

      state = state.copyWith(
        packages: freshPackages,
        consolidations: freshConsolidations,
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

  Future<bool> submitPreAlert({
    required String chineseTrackingNo,
    required String courierName,
    required double declaredValueUsd,
    required String description,
  }) async {
    try {
      final remoteSource = ref.read(shipmentsRemoteDataSourceProvider);
      final newPkg = await remoteSource.submitPreAlert(
        chineseTrackingNo: chineseTrackingNo,
        courierName: courierName,
        declaredValueUsd: declaredValueUsd,
        description: description,
      );
      state = state.copyWith(
        packages: [newPkg, ...state.packages],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> createConsolidation({
    required List<String> packageIds,
    required String shippingMethod,
    required String destinationWarehouse,
    required String paymentMethod,
  }) async {
    try {
      final remoteSource = ref.read(shipmentsRemoteDataSourceProvider);
      final newCon = await remoteSource.createConsolidation(
        packageIds: packageIds,
        shippingMethod: shippingMethod,
        destinationWarehouse: destinationWarehouse,
        paymentMethod: paymentMethod,
      );
      state = state.copyWith(
        consolidations: [newCon, ...state.consolidations],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => fetchAll(isUserInitiated: true);
}


final shipmentsProvider =
    NotifierProvider<ShipmentsNotifier, ShipmentsState>(() {
  return ShipmentsNotifier();
});
