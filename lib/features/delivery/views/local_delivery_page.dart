import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/google_maps_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../../home/data/models/delivery_vehicle_model.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';
import '../../shipments/data/models/package_model.dart';
import '../../shipments/data/models/consolidation_model.dart';
import '../data/models/local_delivery_model.dart';
import '../data/models/location_model.dart';
import '../presentation/providers/delivery_provider.dart';
import 'location_picker_page.dart';

class LocalDeliveryPage extends ConsumerStatefulWidget {
  const LocalDeliveryPage({super.key});

  @override
  ConsumerState<LocalDeliveryPage> createState() => _LocalDeliveryPageState();
}

class _LocalDeliveryPageState extends ConsumerState<LocalDeliveryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityStateController = TextEditingController(text: 'Abuja, Nigeria');
  final _notesController = TextEditingController();

  LocationModel? _pickupLocation;
  LocationModel? _deliveryLocation;

  String? _selectedConsolidationId;
  String? _selectedVehicleId;
  File? _localImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize default pickup location in Abuja Central Hub
    _pickupLocation = const LocationModel(
      address: 'Plot 1024, Shehu Shagari Way, Central Business District, Abuja, Nigeria',
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      name: 'Hamza RMB Logistics Hub (Abuja)',
      city: 'Abuja',
      state: 'FCT',
      country: 'Nigeria',
    );

    Future.microtask(() {
      ref.read(deliveryProvider.notifier).fetchAll();
      ref.read(shipmentsProvider.notifier).fetchAll();
      ref.read(systemMetadataProvider.notifier).refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _addressController.dispose();
    _cityStateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPickupLocation() async {
    final result = await Navigator.of(context).push<LocationModel>(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          title: 'Select Pickup / Origin Location',
          initialLocation: _pickupLocation,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _pickupLocation = result;
      });
    }
  }

  Future<void> _pickDeliveryLocation() async {
    final result = await Navigator.of(context).push<LocationModel>(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          title: 'Select Destination / Delivery Location',
          initialLocation: _deliveryLocation,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _deliveryLocation = result;
        _addressController.text = result.address;
        if (result.city != null && result.state != null) {
          _cityStateController.text = '${result.city}, ${result.state}';
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _localImageFile = file;
        });
        await ref.read(deliveryProvider.notifier).uploadPhoto(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _localImageFile = null;
    });
    ref.read(deliveryProvider.notifier).clearUploadedPhoto();
  }

  double _getCalculatedDistanceKm() {
    if (_pickupLocation == null || _deliveryLocation == null) {
      return 5.0; // Default baseline 5km if destination not yet selected
    }
    return GoogleMapsService.calculateDistanceKmStatic(
      _pickupLocation!,
      _deliveryLocation!,
    );
  }

  double _calculateVehicleFare(DeliveryVehicleModel vehicle) {
    final distanceKm = _getCalculatedDistanceKm();
    return vehicle.baseFare + (distanceKm * vehicle.perKmRate);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deliveryLocation == null && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery location on Google Maps'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedConsolidationId == null || _selectedConsolidationId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a consignment/package to deliver'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final deliveryDest = _deliveryLocation?.address ?? _addressController.text.trim();
    final pickupSource = _pickupLocation?.address ?? 'Hamza RMB Abuja Hub';
    final fullAddress = '$deliveryDest [Pickup: $pickupSource]';

    final result = await ref.read(deliveryProvider.notifier).scheduleDelivery(
          consolidationId: _selectedConsolidationId!,
          deliveryAddress: fullAddress,
          recipientName: _recipientNameController.text.trim(),
          recipientPhone: _recipientPhoneController.text.trim(),
          deliveryVehicleId: _selectedVehicleId,
        );

    if (result != null && mounted) {
      _showSuccessDialog(result);
      _recipientNameController.clear();
      _recipientPhoneController.clear();
      _addressController.clear();
      _notesController.clear();
      setState(() {
        _deliveryLocation = null;
        _localImageFile = null;
      });
    } else if (mounted) {
      final err = ref.read(deliveryProvider).error ?? 'Failed to schedule delivery';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(LocalDeliveryModel delivery) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dispatch Scheduled!',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your doorstep delivery request is registered. Give this 4-digit pickup PIN to the driver upon arrival.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Pickup PIN card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'SECURITY PICKUP PIN',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: delivery.pickupPin.split('').map((char) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 46,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF38BDF8),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: AppTypography.headlineLg.copyWith(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: delivery.pickupPin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PIN copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          color: Color(0xFF38BDF8),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to Copy PIN',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _tabController.animateTo(1);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'View Deliveries',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final shipmentsState = ref.watch(shipmentsProvider);
    final metaState = ref.watch(systemMetadataProvider);

    // Combine available vehicles from delivery state and system metadata
    final vehicles = deliveryState.vehicles.isNotEmpty
        ? deliveryState.vehicles
        : metaState.vehicles.isNotEmpty
            ? metaState.vehicles
            : _getFallbackVehicles();

    // Set default vehicle if unselected
    if (_selectedVehicleId == null && vehicles.isNotEmpty) {
      _selectedVehicleId = vehicles.first.id;
    }

    final arrivedPackages = shipmentsState.packages;
    final consolidations = shipmentsState.consolidations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppBarLogoTitle(
          title: 'Doorstep Local Delivery',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
          unselectedLabelStyle:
              AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            const Tab(text: 'Request Dispatch'),
            Tab(
              text: 'My Deliveries (${deliveryState.deliveries.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestDispatchTab(
            vehicles: vehicles,
            arrivedPackages: arrivedPackages,
            consolidations: consolidations,
            deliveryState: deliveryState,
          ),
          _buildMyDeliveriesTab(deliveryState),
        ],
      ),
    );
  }

  Widget _buildRequestDispatchTab({
    required List<DeliveryVehicleModel> vehicles,
    required List<PackageModel> arrivedPackages,
    required List<ConsolidationModel> consolidations,
    required DeliveryState deliveryState,
  }) {
    final selectedVehicle = vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => vehicles.isNotEmpty ? vehicles.first : _getFallbackVehicles().first,
    );

    final distanceKm = _getCalculatedDistanceKm();
    final eta = GoogleMapsService.estimateTravelTimeStatic(distanceKm);
    final distanceFee = distanceKm * selectedVehicle.perKmRate;
    final totalFare = selectedVehicle.baseFare + distanceFee;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(deliveryProvider.notifier).fetchAll(isUserInitiated: true);
        await ref.read(shipmentsProvider.notifier).fetchAll(isUserInitiated: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF38BDF8),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doorstep Map Dispatch',
                            style: AppTypography.bodyLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Select pickup & destination locations on Google Maps with live distance & rate calculation.',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 1. Google Maps Route Selection ────────────────────────────────
              _buildSectionTitle('1. Route & Map Locations', Icons.map_outlined),
              const SizedBox(height: 10),

              // Pickup Card
              _buildLocationCard(
                title: 'SOURCE / PICKUP LOCATION',
                icon: Icons.storefront_outlined,
                location: _pickupLocation,
                onTap: _pickPickupLocation,
                isPickup: true,
              ),

              const SizedBox(height: 10),

              // Destination Card
              _buildLocationCard(
                title: 'DESTINATION / DELIVERY ADDRESS',
                icon: Icons.pin_drop_rounded,
                location: _deliveryLocation,
                onTap: _pickDeliveryLocation,
                isPickup: false,
              ),

              // Route & Distance Summary banner if destination is selected
              if (_deliveryLocation != null) ...[
                const SizedBox(height: 12),
                _buildRouteSummaryCard(distanceKm: distanceKm, eta: eta),
              ],

              const SizedBox(height: 20),

              // ── 2. Select Consignment / Package ──────────────────────────────
              _buildSectionTitle('2. Select Consignment or Package', Icons.inventory_2_outlined),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedConsolidationId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                    hintText: 'Choose arrived batch, waybill or parcel',
                  ),
                  items: [
                    if (arrivedPackages.isEmpty && consolidations.isEmpty)
                      const DropdownMenuItem(
                        value: 'HZ-CON-ABUJA-DEFAULT',
                        child: Text('HZ-CON-90218 (Abuja Hub - 8.5 kg)'),
                      ),
                    ...arrivedPackages.map((pkg) {
                      final title = pkg.trackingNumber.isNotEmpty
                          ? '${pkg.trackingNumber} (${pkg.weightKg > 0 ? "${pkg.weightKg}kg" : "Arrived"})'
                          : 'Package ${pkg.id}';
                      return DropdownMenuItem<String>(
                        value: pkg.trackingNumber.isNotEmpty ? pkg.trackingNumber : pkg.id,
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(fontSize: 13),
                        ),
                      );
                    }),
                    ...consolidations.map((con) {
                      final title = con.consolidationId.isNotEmpty
                          ? '${con.consolidationId} (${con.shippingMethod.toUpperCase()} - Arrived)'
                          : 'Consolidation ${con.id}';
                      return DropdownMenuItem<String>(
                        value: con.consolidationId.isNotEmpty ? con.consolidationId : con.id,
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(fontSize: 13),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedConsolidationId = val;
                    });
                  },
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please select a consignment' : null,
                ),
              ),

              const SizedBox(height: 20),

              // ── 3. Recipient Information ─────────────────────────────────────
              _buildSectionTitle('3. Recipient Information', Icons.person_outline_rounded),
              const SizedBox(height: 8),

              AppTextField(
                controller: _recipientNameController,
                labelText: 'Recipient Full Name',
                hintText: 'e.g. Babatunde Lawal',
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter recipient name' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _recipientPhoneController,
                labelText: 'Contact Phone Number',
                hintText: '+234 801 234 5678',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _notesController,
                labelText: 'Delivery Instructions / House Landmark',
                hintText: 'e.g. Opposite Central Mosque, Black Gate, call on arrival',
                maxLines: 2,
                prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              ),

              const SizedBox(height: 20),

              // ── 4. Vehicle Fleet Selection ──────────────────────────────────
              _buildSectionTitle('4. Choose Dispatch Vehicle', Icons.directions_car_filled_outlined),
              const SizedBox(height: 8),

              Column(
                children: vehicles.map((vehicle) {
                  final isSelected = vehicle.id == _selectedVehicleId;
                  final vehicleFare = _calculateVehicleFare(vehicle);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVehicleId = vehicle.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.secondary.withValues(alpha: 0.15)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getVehicleIcon(vehicle.type),
                              color: isSelected ? AppColors.secondary : const Color(0xFF64748B),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      vehicle.name,
                                      style: AppTypography.bodyMd.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Max ${vehicle.maxWeightKg.toStringAsFixed(0)}kg',
                                        style: AppTypography.labelCaps.copyWith(
                                          fontSize: 9,
                                          color: const Color(0xFF334155),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle.description,
                                  style: AppTypography.bodySm.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₦${vehicleFare.toStringAsFixed(0)}',
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '₦${vehicle.baseFare.toStringAsFixed(0)} + ₦${vehicle.perKmRate.toStringAsFixed(0)}/km',
                                style: AppTypography.bodySm.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── 5. Optional Photo Attachment (Camera / Gallery) ──────────────
              _buildSectionTitle('5. Item Photo / Landmark (Optional)', Icons.camera_alt_outlined),
              const SizedBox(height: 8),

              _buildImageUploadCard(deliveryState),

              const SizedBox(height: 24),

              // ── 6. Pricing Summary Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Fare (${selectedVehicle.name})',
                          style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          '₦${selectedVehicle.baseFare.toStringAsFixed(2)}',
                          style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distance (${distanceKm.toStringAsFixed(1)} km × ₦${selectedVehicle.perKmRate.toStringAsFixed(0)}/km)',
                          style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          '₦${distanceFee.toStringAsFixed(2)}',
                          style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4-Digit Pickup PIN Protection',
                          style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          'FREE',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total',
                          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '₦${totalFare.toStringAsFixed(2)}',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              AppButton.primary(
                text: deliveryState.isSubmitting
                    ? 'Scheduling Dispatch...'
                    : 'Confirm Doorstep Delivery (₦${totalFare.toStringAsFixed(0)})',
                isLoading: deliveryState.isSubmitting,
                onPressed: deliveryState.isSubmitting ? null : _handleSubmit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(DeliveryState state) {
    if (_localImageFile != null || state.uploadedPhotoUrl != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _localImageFile != null
                  ? Image.file(
                      _localImageFile!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: state.uploadedPhotoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo Attached',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.isUploadingPhoto
                        ? 'Uploading to cloud...'
                        : 'Uploaded & ready for driver reference',
                    style: AppTypography.bodySm.copyWith(
                      color: state.isUploadingPhoto
                          ? AppColors.secondary
                          : const Color(0xFF16A34A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (state.isUploadingPhoto)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: _removePhoto,
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            color: Color(0xFF94A3B8),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload waypoint photo or landmark description',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('From Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyDeliveriesTab(DeliveryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = state.deliveries;

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(deliveryProvider.notifier).fetchAll(isUserInitiated: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF94A3B8),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Local Deliveries Yet',
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you schedule doorstep delivery for your arrived parcels, your active dispatches and 4-digit pickup PINs will appear here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Schedule Delivery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(deliveryProvider.notifier).fetchAll(isUserInitiated: true);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildDeliveryCard(item);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(LocalDeliveryModel item) {
    final statusLower = item.status.toLowerCase();
    Color badgeColor;
    Color badgeBg;
    String statusLabel;

    if (statusLower == 'delivered' || statusLower == 'completed') {
      badgeColor = const Color(0xFF16A34A);
      badgeBg = const Color(0xFFDCFCE7);
      statusLabel = 'DELIVERED';
    } else if (statusLower == 'dispatched' || statusLower == 'in_transit') {
      badgeColor = const Color(0xFF0284C7);
      badgeBg = const Color(0xFFE0F2FE);
      statusLabel = 'EN ROUTE';
    } else {
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFEF3C7);
      statusLabel = 'PENDING DISPATCH';
    }

    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.consolidationId,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTypography.labelCaps.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<LocationModel?>(
                        builder: (context) => LocationPickerPage(
                          title: 'Delivery Destination',
                          initialLocation: LocationModel(
                            address: item.deliveryAddress,
                            latitude: AppConstants.defaultLatitude,
                            longitude: AppConstants.defaultLongitude,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.deliveryAddress,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF334155),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.recipientName} (${item.recipientPhone})',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 4-Digit Pickup PIN Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.key_rounded,
                            color: Color(0xFF38BDF8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PICKUP PIN:',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item.pickupPin,
                        style: AppTypography.bodyLg.copyWith(
                          color: const Color(0xFF38BDF8),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required IconData icon,
    required LocationModel? location,
    required VoidCallback onTap,
    required bool isPickup,
  }) {
    final hasLocation = location != null && location.address.isNotEmpty;
    final accentColor = isPickup ? const Color(0xFF10B981) : AppColors.primary;
    final badgeBg = isPickup ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasLocation ? accentColor.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: hasLocation ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: accentColor, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasLocation
                            ? const Color(0xFFF1F5F9)
                            : accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 13,
                            color: hasLocation ? const Color(0xFF475569) : accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasLocation ? 'Change' : 'Select on Map',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: hasLocation ? const Color(0xFF475569) : accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (hasLocation) ...[
                  Text(
                    location.shortTitle,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location.address,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '📍 ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                          style: AppTypography.labelCaps.copyWith(
                            fontSize: 9.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (location.city != null && location.city!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            location.city!,
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 9.5,
                              color: const Color(0xFF0369A1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.add_location_alt_outlined, color: Color(0xFF94A3B8), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPickup
                              ? 'Tap to choose pickup depot / origin address'
                              : 'Tap to pick destination on Google Map or search address',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSummaryCard({required double distanceKm, required String eta}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: Color(0xFF38BDF8),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESTIMATED TRANSIT ROUTE',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      eta,
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'urban road distance calculated',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motorbike':
      case 'bike':
        return Icons.two_wheeler_rounded;
      case 'van':
      case 'bus':
        return Icons.airport_shuttle_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      default:
        return Icons.delivery_dining_rounded;
    }
  }

  List<DeliveryVehicleModel> _getFallbackVehicles() {
    return const [
      DeliveryVehicleModel(
        id: 'vh-001',
        name: 'Express Motorbike',
        type: 'motorbike',
        description: 'Fastest for light parcels up to 15kg.',
        baseFare: 1000,
        perKmRate: 150,
        maxWeightKg: 15,
        imageUrl: '',
      ),
      DeliveryVehicleModel(
        id: 'vh-002',
        name: 'Doorstep Cargo Van',
        type: 'van',
        description: 'Ideal for medium cargo boxes up to 150kg.',
        baseFare: 4500,
        perKmRate: 350,
        maxWeightKg: 150,
        imageUrl: '',
      ),
    ];
  }
}
