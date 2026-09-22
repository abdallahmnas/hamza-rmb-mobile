import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/public_metadata_remote_data_source.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/delivery_vehicle_model.dart';
import '../../data/models/exchange_rate_model.dart';
import '../../data/models/system_settings_model.dart';

class SystemMetadataState {
  final SystemSettingsModel settings;
  final List<BannerModel> banners;
  final List<DeliveryVehicleModel> vehicles;
  final ExchangeRateModel exchangeRate;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const SystemMetadataState({
    this.settings = const SystemSettingsModel(),
    this.banners = const [],
    this.vehicles = const [],
    this.exchangeRate = const ExchangeRateModel(),
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  SystemMetadataState copyWith({
    SystemSettingsModel? settings,
    List<BannerModel>? banners,
    List<DeliveryVehicleModel>? vehicles,
    ExchangeRateModel? exchangeRate,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return SystemMetadataState(
      settings: settings ?? this.settings,
      banners: banners ?? this.banners,
      vehicles: vehicles ?? this.vehicles,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

class SystemMetadataNotifier extends Notifier<SystemMetadataState> {
  static const String _settingsKey = 'cache_settings';
  static const String _bannersKey = 'cache_banners';
  static const String _vehiclesKey = 'cache_vehicles';
  static const String _ratesKey = 'cache_rates';

  @override
  SystemMetadataState build() {
    final storage = ref.watch(localStorageProvider);

    // 1. Restore from cache immediately
    SystemSettingsModel settings = const SystemSettingsModel();
    List<BannerModel> banners = [];
    List<DeliveryVehicleModel> vehicles = [];
    ExchangeRateModel rates = const ExchangeRateModel();

    final settingsJson = storage.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        settings = SystemSettingsModel.fromJson(
            jsonDecode(settingsJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    final bannersJson = storage.getString(_bannersKey);
    if (bannersJson != null) {
      try {
        final list = jsonDecode(bannersJson) as List<dynamic>;
        banners = list
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final vehiclesJson = storage.getString(_vehiclesKey);
    if (vehiclesJson != null) {
      try {
        final list = jsonDecode(vehiclesJson) as List<dynamic>;
        vehicles = list
            .map((e) => DeliveryVehicleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final ratesJson = storage.getString(_ratesKey);
    if (ratesJson != null) {
      try {
        rates = ExchangeRateModel.fromJson(
            jsonDecode(ratesJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    return SystemMetadataState(
      settings: settings,
      banners: banners,
      vehicles: vehicles,
      exchangeRate: rates,
      isLoading: banners.isEmpty,
    );
  }

  /// Refresh all public metadata in background without blocking cached display
  Future<void> refreshAll({bool isUserInitiated = false}) async {
    state = state.copyWith(
      isRefreshing: true,
      isLoading: state.banners.isEmpty && !isUserInitiated,
    );

    try {
      final remoteSource = ref.read(publicMetadataRemoteDataSourceProvider);
      final storage = ref.read(localStorageProvider);

      final results = await Future.wait([
        remoteSource.fetchSettings().catchError((_) => state.settings),
        remoteSource.fetchBanners().catchError((_) => state.banners),
        remoteSource.fetchDeliveryVehicles().catchError((_) => state.vehicles),
        remoteSource.fetchExchangeRate().catchError((_) => state.exchangeRate),
      ]);

      final newSettings = results[0] as SystemSettingsModel;
      final newBanners = results[1] as List<BannerModel>;
      final newVehicles = results[2] as List<DeliveryVehicleModel>;
      final newRates = results[3] as ExchangeRateModel;

      // Persist fresh data to local storage
      await storage.setString(_settingsKey, jsonEncode(newSettings.toJson()));
      await storage.setString(
          _bannersKey, jsonEncode(newBanners.map((b) => b.toJson()).toList()));
      await storage.setString(_vehiclesKey,
          jsonEncode(newVehicles.map((v) => v.toJson()).toList()));
      await storage.setString(_ratesKey, jsonEncode(newRates.toJson()));

      state = state.copyWith(
        settings: newSettings,
        banners: newBanners.isNotEmpty ? newBanners : state.banners,
        vehicles: newVehicles.isNotEmpty ? newVehicles : state.vehicles,
        exchangeRate: newRates,
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
}

final systemMetadataProvider =
    NotifierProvider<SystemMetadataNotifier, SystemMetadataState>(() {
  return SystemMetadataNotifier();
});
