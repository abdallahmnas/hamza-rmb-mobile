import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/media_upload_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../home/data/models/delivery_vehicle_model.dart';
import '../../data/datasources/delivery_remote_data_source.dart';
import '../../data/models/local_delivery_model.dart';

class DeliveryState {
  final List<LocalDeliveryModel> deliveries;
  final List<DeliveryVehicleModel> vehicles;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final String? uploadedPhotoUrl;
  final String? error;
  final LocalDeliveryModel? lastCreatedDelivery;

  const DeliveryState({
    this.deliveries = const [],
    this.vehicles = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.uploadedPhotoUrl,
    this.error,
    this.lastCreatedDelivery,
  });

  DeliveryState copyWith({
    List<LocalDeliveryModel>? deliveries,
    List<DeliveryVehicleModel>? vehicles,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    String? uploadedPhotoUrl,
    bool clearPhoto = false,
    String? error,
    LocalDeliveryModel? lastCreatedDelivery,
  }) {
    return DeliveryState(
      deliveries: deliveries ?? this.deliveries,
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      uploadedPhotoUrl:
          clearPhoto ? null : (uploadedPhotoUrl ?? this.uploadedPhotoUrl),
      error: error,
      lastCreatedDelivery: lastCreatedDelivery ?? this.lastCreatedDelivery,
    );
  }
}

class DeliveryNotifier extends Notifier<DeliveryState> {
  static const String _storageKey = 'cache_local_deliveries';
  static const String _vehiclesStorageKey = 'cache_delivery_vehicles';

  @override
  DeliveryState build() {
    final storage = ref.watch(localStorageProvider);
    List<LocalDeliveryModel> cached = [];
    final json = storage.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        cached = list
            .map((e) => LocalDeliveryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    List<DeliveryVehicleModel> cachedVehicles = [];
    final vJson = storage.getString(_vehiclesStorageKey);
    if (vJson != null) {
      try {
        final list = jsonDecode(vJson) as List<dynamic>;
        cachedVehicles = list
            .map((e) => DeliveryVehicleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    Future.microtask(() => fetchAll());

    return DeliveryState(
      deliveries: cached,
      vehicles: cachedVehicles,
      isLoading: cached.isEmpty,
    );
  }

  Future<void> fetchAll({bool isUserInitiated = false}) async {
    state = state.copyWith(
      isLoading: state.deliveries.isEmpty && !isUserInitiated,
      error: null,
    );
    try {
      final remote = ref.read(deliveryRemoteDataSourceProvider);
      final results = await Future.wait([
        remote.fetchDeliveries().catchError((_) => state.deliveries),
        remote.fetchVehicles().catchError((_) => state.vehicles),
      ]);

      final freshDeliveries = results[0] as List<LocalDeliveryModel>;
      final freshVehicles = results[1] as List<DeliveryVehicleModel>;

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(freshDeliveries.map((e) => e.toJson()).toList()),
      );
      if (freshVehicles.isNotEmpty) {
        await storage.setString(
          _vehiclesStorageKey,
          jsonEncode(freshVehicles.map((e) => e.toJson()).toList()),
        );
      }

      state = state.copyWith(
        deliveries: freshDeliveries,
        vehicles: freshVehicles,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> uploadPhoto(File imageFile) async {
    state = state.copyWith(isUploadingPhoto: true, error: null);
    try {
      final uploader = ref.read(mediaUploadServiceProvider);
      final url = await uploader.uploadImage(imageFile);
      state = state.copyWith(
        isUploadingPhoto: false,
        uploadedPhotoUrl: url,
        error: null,
      );
      return url;
    } catch (e) {
      state = state.copyWith(isUploadingPhoto: false, error: e.toString());
      return null;
    }
  }

  void clearUploadedPhoto() {
    state = state.copyWith(clearPhoto: true);
  }

  Future<LocalDeliveryModel?> scheduleDelivery({
    required String pickupAddress,
    String pickupCity = 'Lagos',
    String pickupContactName = 'Warehouse Admin',
    String pickupPhone = '+2348090219021',
    String pickupEmail = 'pickup@logistics.com',
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    String dropoffCity = 'Lagos',
    required String dropoffContactName,
    required String dropoffPhone,
    String dropoffEmail = 'customer@example.com',
    required double dropoffLat,
    required double dropoffLng,
    required String customerEmail,
    required String customerPhone,
    required String packageDescription,
    List<String>? imageUrls,
    required String vehicleId,
    required String vehicleType,
    required double distanceKm,
    String paymentMethod = 'wallet',
    String? consolidationId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(deliveryRemoteDataSourceProvider);
      final List<String> finalImages = [
        if (imageUrls != null) ...imageUrls,
        if (imageUrls == null && state.uploadedPhotoUrl != null && state.uploadedPhotoUrl!.isNotEmpty)
          state.uploadedPhotoUrl!,
      ];

      final delivery = await remote.requestDelivery(
        pickupAddress: pickupAddress,
        pickupCity: pickupCity,
        pickupContactName: pickupContactName,
        pickupPhone: pickupPhone,
        pickupEmail: pickupEmail,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffAddress: dropoffAddress,
        dropoffCity: dropoffCity,
        dropoffContactName: dropoffContactName,
        dropoffPhone: dropoffPhone,
        dropoffEmail: dropoffEmail,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        packageDescription: packageDescription,
        imageUrls: finalImages,
        vehicleId: vehicleId,
        vehicleType: vehicleType,
        distanceKm: distanceKm,
        paymentMethod: paymentMethod,
        consolidationId: consolidationId,
      );

      final updatedList = [delivery, ...state.deliveries];
      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(updatedList.map((e) => e.toJson()).toList()),
      );

      state = state.copyWith(
        deliveries: updatedList,
        lastCreatedDelivery: delivery,
        isSubmitting: false,
        clearPhoto: true,
        error: null,
      );
      return delivery;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final deliveryProvider =
    NotifierProvider<DeliveryNotifier, DeliveryState>(() {
  return DeliveryNotifier();
});
