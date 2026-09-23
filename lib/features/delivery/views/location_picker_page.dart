import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/google_maps_service.dart';
import '../data/models/location_model.dart';

enum LocationPickerType { pickup, delivery }

class LocationPickerPage extends ConsumerStatefulWidget {
  final String title;
  final LocationPickerType type;
  final LocationModel? initialLocation;

  const LocationPickerPage({
    super.key,
    this.title = 'Select Location',
    this.type = LocationPickerType.delivery,
    this.initialLocation,
  });

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late LatLng _currentCameraCenter;
  LocationModel? _selectedLocation;
  bool _isGeocoding = false;
  bool _isSearching = false;
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounceTimer;

  // Track whether map is currently being dragged
  bool _isMapMoving = false;

  @override
  void initState() {
    super.initState();

    // Default to Abuja, Nigeria unless initial location is provided
    if (widget.initialLocation != null &&
        widget.initialLocation!.latitude != 0 &&
        widget.initialLocation!.longitude != 0) {
      _currentCameraCenter = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedLocation = widget.initialLocation;
      _searchController.text = widget.initialLocation!.address;
    } else {
      _currentCameraCenter = const LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      );
      _selectedLocation = LocationModel.defaultAbuja();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isSearching = true);
      try {
        final results = await ref.read(googleMapsServiceProvider).searchPlaces(
              query,
              latitude: _currentCameraCenter.latitude,
              longitude: _currentCameraCenter.longitude,
            );
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
      _isGeocoding = true;
      _searchController.text = suggestion.description;
    });

    try {
      final loc = await ref.read(googleMapsServiceProvider).getPlaceDetails(
            suggestion.placeId,
            fallbackDescription: suggestion.description,
          );

      if (loc != null && mounted) {
        setState(() {
          _selectedLocation = loc;
          _currentCameraCenter = LatLng(loc.latitude, loc.longitude);
          _isGeocoding = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentCameraCenter,
              zoom: 16.5,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _onCameraIdle() async {
    if (!mounted) return;
    setState(() {
      _isMapMoving = false;
      _isGeocoding = true;
    });

    try {
      final reverse = await ref.read(googleMapsServiceProvider).reverseGeocode(
            _currentCameraCenter.latitude,
            _currentCameraCenter.longitude,
          );

      if (mounted) {
        setState(() {
          _selectedLocation = reverse;
          _isGeocoding = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  void _centerOn(LatLng target, {double zoom = 15.5}) {
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
      _currentCameraCenter = target;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or search a valid location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).pop(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.type == LocationPickerType.pickup;
    final themeColor = isPickup ? const Color(0xFF10B981) : AppColors.primary;
    final titleText = isPickup ? 'Select Pickup Location' : 'Select Delivery Location';
    final tagText = isPickup ? 'PICKUP / SOURCE' : 'DELIVERY DESTINATION';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title.isNotEmpty ? widget.title : titleText,
          style: AppTypography.headlineMd.copyWith(fontSize: 17),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text(
              'Done',
              style: AppTypography.bodyMd.copyWith(
                color: themeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── 1. Interactive Google Map ────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCameraCenter,
              zoom: 15.0,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: (position) {
              _currentCameraCenter = position.target;
              if (!_isMapMoving) {
                setState(() {
                  _isMapMoving = true;
                });
              }
            },
            onCameraIdle: _onCameraIdle,
            onTap: (latLng) {
              _centerOn(latLng);
            },
          ),

          // ── 2. Fixed Center Pin Marker ──────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 38.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                transform: Matrix4.translationValues(
                  0,
                  _isMapMoving ? -14 : 0,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location pin badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPickup
                                ? Icons.storefront_rounded
                                : Icons.location_on_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tagText,
                            style: AppTypography.labelCaps.copyWith(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Pointer Icon
                    Icon(
                      Icons.location_pin,
                      size: 44,
                      color: themeColor,
                    ),
                    // Pin shadow dot
                    Container(
                      width: 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Top Search & Filter Bar ──────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Input Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Search address, district or landmark...',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _suggestions = [];
                                });
                              },
                            )
                          : _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                // Suggestions Autocomplete Dropdown List
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: themeColor,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            item.mainText,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: item.secondaryText.isNotEmpty
                              ? Text(
                                  item.secondaryText,
                                  style: AppTypography.bodySm.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _selectSuggestion(item),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── 4. Quick City Preset Chips ──────────────────────────────
          Positioned(
            top: 76,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CityChip(
                    label: '📍 Abuja (Default)',
                    isSelected: (_currentCameraCenter.latitude - 9.0765).abs() < 0.05,
                    onTap: () => _centerOn(
                      const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CityChip(
                    label: '🏢 Maitama',
                    isSelected: false,
                    onTap: () => _centerOn(const LatLng(9.0882, 7.4934)),
                  ),
                  const SizedBox(width: 8),
                  _CityChip(
                    label: '🛍️ Wuse 2',
                    isSelected: false,
                    onTap: () => _centerOn(const LatLng(9.0723, 7.4764)),
                  ),
                  const SizedBox(width: 8),
                  _CityChip(
                    label: '🌊 Jabi',
                    isSelected: false,
                    onTap: () => _centerOn(const LatLng(9.0772, 7.4246)),
                  ),
                  const SizedBox(width: 8),
                  _CityChip(
                    label: '🏙️ Lagos Island',
                    isSelected: false,
                    onTap: () => _centerOn(const LatLng(6.4549, 3.4246)),
                  ),
                  const SizedBox(width: 8),
                  _CityChip(
                    label: '🏛️ Kano Hub',
                    isSelected: false,
                    onTap: () => _centerOn(const LatLng(11.9899, 8.5204)),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Map Control Floating Actions ─────────────────────────
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_abuja',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 4,
                  onPressed: () => _centerOn(
                    const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
                  ),
                  tooltip: 'Center on Abuja',
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 4,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 4,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove, size: 20),
                ),
              ],
            ),
          ),

          // ── 6. Bottom Selected Location Card & Confirm Button ────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tagText,
                          style: AppTypography.labelCaps.copyWith(
                            color: themeColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_isGeocoding)
                        Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Resolving address...',
                              style: AppTypography.bodySm.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '${_currentCameraCenter.latitude.toStringAsFixed(4)}, ${_currentCameraCenter.longitude.toStringAsFixed(4)}',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location Title
                  Text(
                    _selectedLocation?.shortTitle ?? 'Pinpoint Location',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Full Address Text
                  Text(
                    _selectedLocation?.address ??
                        'Central Business District, Abuja, Nigeria',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Location Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPickup
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPickup
                                ? 'Confirm Pickup Location'
                                : 'Confirm Delivery Location',
                            style: AppTypography.bodyMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}
