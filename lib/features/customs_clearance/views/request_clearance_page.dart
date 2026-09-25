import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../data/models/clearance_request_model.dart';
import '../presentation/providers/customs_clearance_provider.dart';

class RequestClearancePage extends ConsumerStatefulWidget {
  const RequestClearancePage({super.key});

  @override
  ConsumerState<RequestClearancePage> createState() => _RequestClearancePageState();
}

class _RequestClearancePageState extends ConsumerState<RequestClearancePage> {
  int _currentStep = 0; // 0: Shipment, 1: Goods, 2: Documents, 3: Delivery, 4: Review

  // Step 1: Shipment
  String _shipmentType = 'Sea'; // Sea, Air, Land
  String _originCountry = 'China';
  String _portOfEntry = 'Apapa Port';
  String _shipmentStatus = 'In transit';
  final TextEditingController _shippingLineController = TextEditingController();
  final TextEditingController _airlineController = TextEditingController();
  final TextEditingController _blNumberController = TextEditingController();
  final TextEditingController _awbNumberController = TextEditingController();
  final TextEditingController _containerNumberController = TextEditingController();
  DateTime? _estimatedArrivalDate;
  bool _hasMissingShipmentInfo = false;

  // Step 2: Goods (List of items)
  final List<_ProductItemFormData> _productItems = [
    _ProductItemFormData(),
  ];

  // Step 3: Documents
  final List<_DocumentUploadFormData> _documents = [
    _DocumentUploadFormData(documentType: 'Commercial Invoice', isRequired: true),
    _DocumentUploadFormData(documentType: 'Packing List', isRequired: true),
    _DocumentUploadFormData(documentType: 'Bill of Lading / Air Waybill', isRequired: true),
    _DocumentUploadFormData(documentType: 'Form M', isRequired: false),
    _DocumentUploadFormData(documentType: 'PAAR (Pre-Arrival Assessment Report)', isRequired: false),
    _DocumentUploadFormData(documentType: 'Certificate of Origin', isRequired: false),
    _DocumentUploadFormData(documentType: 'Import Permits / Product Certificates', isRequired: false),
    _DocumentUploadFormData(documentType: 'Other Supporting Documents', isRequired: false),
  ];

  // Step 4: Delivery
  String _deliveryPreference = 'Deliver to me'; // 'Deliver to me', 'I\'ll arrange pickup/delivery myself'
  final TextEditingController _deliveryNameController = TextEditingController();
  final TextEditingController _deliveryPhoneController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _deliveryCityController = TextEditingController();
  String _deliveryState = 'Lagos State';
  final TextEditingController _deliveryInstructionsController = TextEditingController();

  // Step 5: Review
  bool _isConfirmedAccurate = false;
  bool _isSavingDraft = false;

  final List<String> _countries = const [
    'China',
    'Turkey',
    'United States',
    'United Kingdom',
    'United Arab Emirates',
    'India',
    'Germany',
    'Vietnam',
    'Other',
  ];

  final List<String> _seaPorts = const [
    'Apapa Port',
    'Tin Can Island Port',
    'Lekki Deep Sea Port',
    'Onne Port (Rivers)',
    'Calabar Port',
    'Warri Port',
    'Other',
  ];

  final List<String> _airports = const [
    'Murtala Muhammed International Airport (Lagos - NAHCO/SAHCO)',
    'Nnamdi Azikiwe International Airport (Abuja)',
    'Mallam Aminu Kano International Airport (Kano)',
    'Port Harcourt International Airport',
    'Other',
  ];

  final List<String> _shipmentStatuses = const [
    'Not shipped yet',
    'In transit',
    'Arrived in Nigeria',
    'At port/terminal',
    'Already arrived but not cleared',
  ];

  final List<String> _categories = const [
    'Electronics',
    'Fashion & Apparel',
    'Auto Parts & Accessories',
    'Machinery & Tools',
    'Home & Kitchen',
    'Health & Beauty',
    'Chemicals & Raw Materials',
    'Plastics & Rubber',
    'General Cargo',
  ];

  final List<String> _units = const [
    'pieces',
    'cartons',
    'pairs',
    'sets',
    'kg',
    'rolls',
    'units',
    'meters',
  ];

  final List<String> _currencies = const ['USD', 'CNY', 'NGN', 'EUR', 'GBP'];

  final List<String> _nigerianStates = const [
    'Lagos State',
    'Abuja (FCT)',
    'Ogun State',
    'Oyo State',
    'Kano State',
    'Rivers State',
    'Delta State',
    'Anambra State',
    'Enugu State',
    'Kaduna State',
    'Edo State',
    'Other State',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill user profile info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authServiceProvider).user;
      if (user != null) {
        if (_deliveryNameController.text.isEmpty && user.fullName.isNotEmpty) {
          _deliveryNameController.text = user.fullName;
        }
        if (_deliveryPhoneController.text.isEmpty && user.phone.isNotEmpty) {
          _deliveryPhoneController.text = user.phone;
        }
      }

      // Check if draft exists
      final draft = ref.read(customsClearanceProvider).activeDraft;
      if (draft != null) {
        _restoreFromDraft(draft);
      }
    });
  }

  void _restoreFromDraft(ClearanceRequestModel draft) {
    setState(() {
      _shipmentType = draft.shipmentType;
      _originCountry = draft.originCountry;
      _portOfEntry = draft.portOfEntry;
      _shipmentStatus = draft.shipmentStatus;
      _shippingLineController.text = draft.shippingLine ?? '';
      _airlineController.text = draft.airline ?? '';
      _blNumberController.text = draft.billOfLadingNumber ?? '';
      _awbNumberController.text = draft.airWaybillNumber ?? '';
      _containerNumberController.text = draft.containerNumber ?? '';
      _estimatedArrivalDate = draft.estimatedArrivalDate;
      _hasMissingShipmentInfo = draft.hasMissingShipmentInfo;

      if (draft.items.isNotEmpty) {
        _productItems.clear();
        for (final itm in draft.items) {
          _productItems.add(_ProductItemFormData(
            name: itm.productName,
            category: itm.category,
            description: itm.description,
            quantity: itm.quantity.toString(),
            unit: itm.unit,
            purchaseValue: itm.purchaseValue.toString(),
            currency: itm.currency,
            country: itm.countryOfManufacture,
            weight: itm.weight?.toString() ?? '',
            volume: itm.volume?.toString() ?? '',
            hsCode: itm.hsCode ?? '',
          ));
        }
      }

      _deliveryPreference = draft.deliveryPreference;
      if (draft.deliveryAddress != null) {
        _deliveryNameController.text = draft.deliveryAddress!.fullName;
        _deliveryPhoneController.text = draft.deliveryAddress!.phone;
        _deliveryAddressController.text = draft.deliveryAddress!.address;
        _deliveryCityController.text = draft.deliveryAddress!.city;
        _deliveryState = draft.deliveryAddress!.state;
        _deliveryInstructionsController.text =
            draft.deliveryAddress!.instructions ?? '';
      }
    });
  }

  ClearanceRequestModel _buildCurrentDraftModel() {
    final items = _productItems.map((formItem) {
      return ClearanceItem(
        id: 'itm-${DateTime.now().microsecondsSinceEpoch}-${formItem.hashCode}',
        productName: formItem.nameController.text.trim().isNotEmpty
            ? formItem.nameController.text.trim()
            : 'Imported Cargo',
        description: formItem.descController.text.trim(),
        category: formItem.category,
        quantity: double.tryParse(formItem.qtyController.text.trim()) ?? 1.0,
        unit: formItem.unit,
        purchaseValue: double.tryParse(formItem.valueController.text.trim()) ?? 0.0,
        currency: formItem.currency,
        countryOfManufacture: formItem.country,
        weight: double.tryParse(formItem.weightController.text.trim()),
        volume: double.tryParse(formItem.volumeController.text.trim()),
        hsCode: formItem.hsCodeController.text.trim().isNotEmpty
            ? formItem.hsCodeController.text.trim()
            : null,
      );
    }).toList();

    final docs = _documents
        .where((d) => d.isUploaded || d.isNotAvailable)
        .map((d) {
      return ClearanceDocument(
        id: 'doc-${d.documentType.hashCode}',
        documentType: d.documentType,
        fileName: d.fileName ?? '',
        fileUrl: d.fileUrl ?? '',
        status: d.isNotAvailable ? 'Not Available' : 'Uploaded',
        uploadedAt: DateTime.now(),
        isNotAvailable: d.isNotAvailable,
      );
    }).toList();

    ClearanceDeliveryAddress? delAddress;
    if (_deliveryPreference == 'Deliver to me') {
      delAddress = ClearanceDeliveryAddress(
        fullName: _deliveryNameController.text.trim(),
        phone: _deliveryPhoneController.text.trim(),
        address: _deliveryAddressController.text.trim(),
        city: _deliveryCityController.text.trim(),
        state: _deliveryState,
        instructions: _deliveryInstructionsController.text.trim().isNotEmpty
            ? _deliveryInstructionsController.text.trim()
            : null,
      );
    }

    return ClearanceRequestModel(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      requestNumber: 'DRAFT',
      status: ClearanceStatus.draft,
      shipmentType: _shipmentType,
      originCountry: _originCountry,
      portOfEntry: _portOfEntry,
      shipmentStatus: _shipmentStatus,
      shippingLine: _shippingLineController.text.trim().isNotEmpty
          ? _shippingLineController.text.trim()
          : null,
      airline: _airlineController.text.trim().isNotEmpty
          ? _airlineController.text.trim()
          : null,
      billOfLadingNumber: _blNumberController.text.trim().isNotEmpty
          ? _blNumberController.text.trim()
          : null,
      airWaybillNumber: _awbNumberController.text.trim().isNotEmpty
          ? _awbNumberController.text.trim()
          : null,
      containerNumber: _containerNumberController.text.trim().isNotEmpty
          ? _containerNumberController.text.trim()
          : null,
      estimatedArrivalDate: _estimatedArrivalDate,
      hasMissingShipmentInfo: _hasMissingShipmentInfo,
      items: items,
      documents: docs,
      deliveryPreference: _deliveryPreference,
      deliveryAddress: delAddress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final draft = _buildCurrentDraftModel();
    await ref.read(customsClearanceProvider.notifier).saveDraft(draft);
    if (!mounted) return;
    setState(() => _isSavingDraft = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Clearance request saved to drafts.'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleSubmitRequest() async {
    if (!_isConfirmedAccurate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please check the confirmation box before submitting.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final requestModel = _buildCurrentDraftModel();
    final submitted = await ref
        .read(customsClearanceProvider.notifier)
        .submitRequest(requestModel);

    if (!mounted) return;
    context.pushReplacement('/customs-clearance/confirmation', extra: submitted);
  }

  @override
  void dispose() {
    _shippingLineController.dispose();
    _airlineController.dispose();
    _blNumberController.dispose();
    _awbNumberController.dispose();
    _containerNumberController.dispose();
    _deliveryNameController.dispose();
    _deliveryPhoneController.dispose();
    _deliveryAddressController.dispose();
    _deliveryCityController.dispose();
    _deliveryInstructionsController.dispose();
    for (final itm in _productItems) {
      itm.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clearanceState = ref.watch(customsClearanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.onBackground,
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: AppBarLogoTitle(
          title: 'Request Customs Clearance',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: AppColors.onBackground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: clearanceState.isSubmitting || _isSavingDraft
                ? null
                : _handleSaveDraft,
            child: _isSavingDraft
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save Draft',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress Stepper Header ─────────────────────────────────────
          _buildProgressStepper(),

          // ── Step Content ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepContent(),
            ),
          ),

          // ── Sticky Bottom Action Bar ────────────────────────────────────
          _buildBottomActionBar(clearanceState.isSubmitting),
        ],
      ),
    );
  }

  // ── Step Progress Indicator ───────────────────────────────────────────────
  Widget _buildProgressStepper() {
    final steps = ['Shipment', 'Goods', 'Documents', 'Delivery', 'Review'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = _currentStep > index;
              final isCurrent = _currentStep == index;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF059669)
                                  : (isCurrent
                                      ? AppColors.primary
                                      : const Color(0xFFE2E8F0)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: AppTypography.labelCaps.copyWith(
                                        color: isCurrent
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            steps[index],
                            style: AppTypography.labelCaps.copyWith(
                              color: isCurrent
                                  ? AppColors.primary
                                  : const Color(0xFF64748B),
                              fontWeight: isCurrent
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 14,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        color: _currentStep > index
                            ? const Color(0xFF059669)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Step Content Selector ─────────────────────────────────────────────────
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Shipment();
      case 1:
        return _buildStep2Goods();
      case 2:
        return _buildStep3Documents();
      case 3:
        return _buildStep4Delivery();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── 1. Step 1: Shipment Details ───────────────────────────────────────────
  Widget _buildStep1Shipment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Shipment Information',
          'Tell us how your goods were shipped into Nigeria.',
        ),
        const SizedBox(height: 16),

        // Shipment Type Selector (Sea, Air, Land)
        Text(
          'SHIPMENT TYPE',
          style: AppTypography.labelCaps.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeOption(
              label: 'Sea Cargo',
              typeValue: 'Sea',
              icon: Icons.directions_boat_rounded,
            ),
            const SizedBox(width: 8),
            _buildTypeOption(
              label: 'Air Freight',
              typeValue: 'Air',
              icon: Icons.flight_takeoff_rounded,
            ),
            const SizedBox(width: 8),
            _buildTypeOption(
              label: 'Land Border',
              typeValue: 'Land',
              icon: Icons.local_shipping_rounded,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Origin Country
        _buildDropdownField(
          label: 'COUNTRY OF ORIGIN',
          value: _originCountry,
          items: _countries,
          onChanged: (val) => setState(() => _originCountry = val ?? 'China'),
        ),

        const SizedBox(height: 16),

        // Port or Airport of Entry
        _buildDropdownField(
          label: _shipmentType == 'Air'
              ? 'AIRPORT / CARGO SHED OF ENTRY'
              : (_shipmentType == 'Sea' ? 'PORT OF ENTRY' : 'BORDER / INLAND PORT'),
          value: _portOfEntry,
          items: _shipmentType == 'Air'
              ? _airports
              : (_shipmentType == 'Sea' ? _seaPorts : const ['Seme Border', 'Idiroko', 'Other']),
          onChanged: (val) => setState(() => _portOfEntry = val ?? ''),
        ),

        const SizedBox(height: 16),

        // Shipment Status
        _buildDropdownField(
          label: 'CURRENT SHIPMENT STATUS',
          value: _shipmentStatus,
          items: _shipmentStatuses,
          onChanged: (val) => setState(() => _shipmentStatus = val ?? 'In transit'),
        ),

        const SizedBox(height: 20),

        // Dynamic fields based on Sea vs Air
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shipmentType == 'Sea'
                    ? 'Sea Waybill & Container Information'
                    : (_shipmentType == 'Air'
                        ? 'Air Cargo Tracking Numbers'
                        : 'Land Cargo Details'),
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              if (_shipmentType == 'Sea') ...[
                _buildTextInput(
                  controller: _shippingLineController,
                  label: 'Shipping Line / Carrier (Optional)',
                  hint: 'e.g. COSCO, Maersk, CMA CGM, PIL',
                  enabled: !_hasMissingShipmentInfo,
                ),
                const SizedBox(height: 12),
                _buildTextInput(
                  controller: _blNumberController,
                  label: 'Bill of Lading (B/L) Number',
                  hint: 'e.g. COSU632819001',
                  enabled: !_hasMissingShipmentInfo,
                ),
                const SizedBox(height: 12),
                _buildTextInput(
                  controller: _containerNumberController,
                  label: 'Container Number (Optional)',
                  hint: 'e.g. CSQU3091823',
                  enabled: !_hasMissingShipmentInfo,
                ),
              ] else if (_shipmentType == 'Air') ...[
                _buildTextInput(
                  controller: _airlineController,
                  label: 'Airline / Cargo Carrier (Optional)',
                  hint: 'e.g. Ethiopian Airlines, Qatar Cargo, Turkish',
                  enabled: !_hasMissingShipmentInfo,
                ),
                const SizedBox(height: 12),
                _buildTextInput(
                  controller: _awbNumberController,
                  label: 'Air Waybill (AWB) Number',
                  hint: 'e.g. 071-88492019',
                  enabled: !_hasMissingShipmentInfo,
                ),
              ] else ...[
                _buildTextInput(
                  controller: _blNumberController,
                  label: 'Waybill / Cross-border Manifest Number',
                  hint: 'e.g. WB-89102',
                  enabled: !_hasMissingShipmentInfo,
                ),
              ],

              const SizedBox(height: 12),

              // Estimated Arrival Date Picker
              InkWell(
                onTap: _hasMissingShipmentInfo ? null : _pickEstimatedArrivalDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ESTIMATED ARRIVAL DATE (ETA)',
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 9,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _estimatedArrivalDate != null
                                ? DateFormat('MMM dd, yyyy').format(_estimatedArrivalDate!)
                                : 'Select estimated date (Optional)',
                            style: AppTypography.bodySm.copyWith(
                              color: _estimatedArrivalDate != null
                                  ? AppColors.onBackground
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // "I don't have this information" Checkbox
              CheckboxListTile(
                value: _hasMissingShipmentInfo,
                onChanged: (val) {
                  setState(() => _hasMissingShipmentInfo = val ?? false);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text(
                  'I don\'t have full shipping or container numbers yet',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: const Color(0xFF475569),
                  ),
                ),
                subtitle: Text(
                  'You can still submit your request. Our clearing agent will identify your cargo via your commercial invoice.',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Step 2: Goods Details ──────────────────────────────────────────────
  Widget _buildStep2Goods() {
    double totalEstimatedVal = 0.0;
    for (final itm in _productItems) {
      final qty = double.tryParse(itm.qtyController.text.trim()) ?? 0.0;
      final val = double.tryParse(itm.valueController.text.trim()) ?? 0.0;
      totalEstimatedVal += (qty * val);
    }
    final primaryCurrency =
        _productItems.isNotEmpty ? _productItems.first.currency : 'USD';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Imported Goods & Products',
          'Describe the items in this shipment for customs valuation.',
        ),
        const SizedBox(height: 16),

        // Running Summary Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PRODUCTS: ${_productItems.length}',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Est. Value: $primaryCurrency ${NumberFormat('#,##0.00').format(totalEstimatedVal)}',
                    style: AppTypography.headlineMd.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 4),
                    Text(
                      'ESTIMATED ONLY',
                      style: AppTypography.labelCaps.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Note: Customs duty is evaluated on CIF value during port assessment. Final charges may differ.',
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 16),

        // Products List
        ...List.generate(_productItems.length, (index) {
          final item = _productItems[index];
          return _buildProductItemCard(item, index);
        }),

        const SizedBox(height: 14),

        // Add Another Item CTA
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _productItems.add(_ProductItemFormData());
            });
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            '+ Add Another Item',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItemCard(_ProductItemFormData item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelCaps.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Product ${index + 1}',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (_productItems.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                  onPressed: () {
                    setState(() {
                      item.dispose();
                      _productItems.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTextInput(
            controller: item.nameController,
            label: 'Product Name / Description *',
            hint: 'e.g. Men\'s Running Shoes, Lithium Inverters',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          _buildDropdownField(
            label: 'CATEGORY',
            value: item.category,
            items: _categories,
            onChanged: (val) => setState(() => item.category = val ?? 'General Cargo'),
          ),
          const SizedBox(height: 12),

          // Quantity & Unit
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildTextInput(
                  controller: item.qtyController,
                  label: 'Quantity *',
                  hint: '100',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _buildDropdownField(
                  label: 'UNIT',
                  value: item.unit,
                  items: _units,
                  onChanged: (val) => setState(() => item.unit = val ?? 'pieces'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Purchase Value & Currency
          Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildTextInput(
                  controller: item.valueController,
                  label: 'Unit Value *',
                  hint: '25.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _buildDropdownField(
                  label: 'CURRENCY',
                  value: item.currency,
                  items: _currencies,
                  onChanged: (val) => setState(() => item.currency = val ?? 'USD'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weight & Volume
          Row(
            children: [
              Expanded(
                child: _buildTextInput(
                  controller: item.weightController,
                  label: 'Est. Weight (kg)',
                  hint: 'e.g. 150',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextInput(
                  controller: item.volumeController,
                  label: 'Est. Volume (CBM)',
                  hint: 'e.g. 1.2',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTextInput(
            controller: item.hsCodeController,
            label: 'Customs Tariff HS Code (Optional)',
            hint: 'e.g. 8517.62 (if known)',
          ),
        ],
      ),
    );
  }

  // ── 3. Step 3: Documents Upload ───────────────────────────────────────────
  Widget _buildStep3Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Shipment Documents',
          'Upload available documents to expedite customs classification.',
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Don\'t worry if you don\'t have every document yet. You can tick "I don\'t have this document" and upload later.',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF92400E),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...List.generate(_documents.length, (index) {
          final doc = _documents[index];
          return _buildDocumentTile(doc);
        }),
      ],
    );
  }

  Widget _buildDocumentTile(_DocumentUploadFormData doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: doc.isUploaded
              ? const Color(0xFF10B981)
              : (doc.isNotAvailable ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                doc.isUploaded
                    ? Icons.check_circle_rounded
                    : (doc.isNotAvailable
                        ? Icons.remove_circle_outline_rounded
                        : Icons.description_outlined),
                color: doc.isUploaded
                    ? const Color(0xFF059669)
                    : (doc.isNotAvailable
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF2563EB)),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doc.documentType,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (doc.isRequired) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: AppTypography.labelCaps.copyWith(
                                color: const Color(0xFFDC2626),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (doc.isUploaded) ...[
                      const SizedBox(height: 2),
                      Text(
                        doc.fileName ?? 'Uploaded Document',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF059669),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "I don't have this document" checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: doc.isNotAvailable,
                      onChanged: (val) {
                        setState(() {
                          doc.isNotAvailable = val ?? false;
                          if (doc.isNotAvailable) {
                            doc.isUploaded = false;
                            doc.fileName = null;
                            doc.fileUrl = null;
                          }
                        });
                      },
                      activeColor: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'I don\'t have this',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Upload / Replace CTA
              if (!doc.isNotAvailable)
                Row(
                  children: [
                    if (doc.isUploaded)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: Color(0xFFEF4444)),
                        onPressed: () {
                          setState(() {
                            doc.isUploaded = false;
                            doc.fileName = null;
                            doc.fileUrl = null;
                          });
                        },
                      ),
                    ElevatedButton.icon(
                      onPressed: () => _pickAndUploadDocument(doc),
                      icon: Icon(
                        doc.isUploaded ? Icons.sync_rounded : Icons.upload_file_rounded,
                        size: 14,
                      ),
                      label: Text(
                        doc.isUploaded ? 'Replace' : 'Upload',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: doc.isUploaded
                            ? const Color(0xFFF1F5F9)
                            : AppColors.primary,
                        foregroundColor: doc.isUploaded
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadDocument(_DocumentUploadFormData doc) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Take photo of document'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Upload from phone gallery / files'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          doc.isUploaded = true;
          doc.isNotAvailable = false;
          doc.fileName = picked.name;
          doc.fileUrl = picked.path;
        });
      }
    } catch (_) {
      // Fallback simulated upload if device permissions aren't set
      setState(() {
        doc.isUploaded = true;
        doc.isNotAvailable = false;
        doc.fileName = '${doc.documentType.replaceAll(' ', '_')}.pdf';
        doc.fileUrl = 'local://sample_doc.pdf';
      });
    }
  }

  // ── 4. Step 4: Delivery Preferences ───────────────────────────────────────
  Widget _buildStep4Delivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Post-Clearance Delivery',
          'Tell us what should happen once customs releases your goods.',
        ),
        const SizedBox(height: 16),

        // Option 1: Deliver to me
        _buildDeliveryRadioOption(
          title: 'Deliver to me',
          subtitle: 'Dispatch cargo straight to your warehouse, store, or residence.',
          value: 'Deliver to me',
          icon: Icons.local_shipping_outlined,
        ),
        const SizedBox(height: 10),

        // Option 2: Self pickup
        _buildDeliveryRadioOption(
          title: 'I\'ll arrange pickup/delivery myself',
          subtitle: 'Collect directly at the port terminal or airport cargo shed gate.',
          value: 'I\'ll arrange pickup/delivery myself',
          icon: Icons.storefront_outlined,
        ),

        const SizedBox(height: 20),

        // If "Deliver to me", show address form
        if (_deliveryPreference == 'Deliver to me') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address & Contact in Nigeria',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),

                _buildTextInput(
                  controller: _deliveryNameController,
                  label: 'Full Name / Receiving Contact *',
                  hint: 'e.g. Bello Al-Hassan',
                ),
                const SizedBox(height: 12),

                _buildTextInput(
                  controller: _deliveryPhoneController,
                  label: 'Phone Number *',
                  hint: 'e.g. 0803 123 4567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                _buildTextInput(
                  controller: _deliveryAddressController,
                  label: 'Street Address *',
                  hint: 'e.g. Plot 14, Commercial Avenue, Ikeja',
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildTextInput(
                        controller: _deliveryCityController,
                        label: 'City *',
                        hint: 'e.g. Ikeja',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: _buildDropdownField(
                        label: 'STATE',
                        value: _deliveryState,
                        items: _nigerianStates,
                        onChanged: (val) => setState(() => _deliveryState = val ?? 'Lagos State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildTextInput(
                  controller: _deliveryInstructionsController,
                  label: 'Special Delivery Instructions (Optional)',
                  hint: 'e.g. Forklift required, call before dispatch',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _deliveryPreference == value;

    return GestureDetector(
      onTap: () => setState(() => _deliveryPreference = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. Step 5: Review Summary ─────────────────────────────────────────────
  Widget _buildStep5Review() {
    double totalEstimatedVal = 0.0;
    for (final itm in _productItems) {
      final qty = double.tryParse(itm.qtyController.text.trim()) ?? 0.0;
      final val = double.tryParse(itm.valueController.text.trim()) ?? 0.0;
      totalEstimatedVal += (qty * val);
    }
    final primaryCurrency =
        _productItems.isNotEmpty ? _productItems.first.currency : 'USD';
    final uploadedDocsCount = _documents.where((d) => d.isUploaded).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Review Your Request',
          'Please verify your shipment information before submission.',
        ),
        const SizedBox(height: 16),

        // Section 1: Shipment
        _buildReviewCard(
          title: 'Shipment Details',
          stepIndexToEdit: 0,
          children: [
            _buildReviewRow('Shipment Type', _shipmentType),
            _buildReviewRow('Origin Country', _originCountry),
            _buildReviewRow('Port of Entry', _portOfEntry),
            _buildReviewRow('Status', _shipmentStatus),
            if (_shipmentType == 'Sea' && _blNumberController.text.isNotEmpty)
              _buildReviewRow('B/L Number', _blNumberController.text),
            if (_shipmentType == 'Sea' && _containerNumberController.text.isNotEmpty)
              _buildReviewRow('Container', _containerNumberController.text),
            if (_shipmentType == 'Air' && _awbNumberController.text.isNotEmpty)
              _buildReviewRow('AWB Number', _awbNumberController.text),
            if (_estimatedArrivalDate != null)
              _buildReviewRow(
                  'ETA', DateFormat('MMM dd, yyyy').format(_estimatedArrivalDate!)),
          ],
        ),

        const SizedBox(height: 12),

        // Section 2: Goods
        _buildReviewCard(
          title: 'Goods & Cargo Items (${_productItems.length})',
          stepIndexToEdit: 1,
          children: [
            ..._productItems.map((item) {
              final qty = item.qtyController.text.trim();
              final name = item.nameController.text.trim().isNotEmpty
                  ? item.nameController.text.trim()
                  : 'Product Item';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '• $name (${item.category})',
                        style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$qty ${item.unit}',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildReviewRow(
              'Total Declared Value',
              '$primaryCurrency ${NumberFormat('#,##0.00').format(totalEstimatedVal)} (Est.)',
              isBold: true,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Section 3: Documents
        _buildReviewCard(
          title: 'Documents ($uploadedDocsCount Uploaded)',
          stepIndexToEdit: 2,
          children: [
            ..._documents.where((d) => d.isUploaded || d.isNotAvailable).map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      d.isUploaded ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      size: 14,
                      color: d.isUploaded ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        d.documentType,
                        style: AppTypography.bodySm.copyWith(fontSize: 11),
                      ),
                    ),
                    Text(
                      d.isUploaded ? 'Ready' : 'Not available',
                      style: AppTypography.labelCaps.copyWith(
                        color: d.isUploaded ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 12),

        // Section 4: Delivery
        _buildReviewCard(
          title: 'Delivery Preference',
          stepIndexToEdit: 3,
          children: [
            _buildReviewRow('Preference', _deliveryPreference),
            if (_deliveryPreference == 'Deliver to me') ...[
              _buildReviewRow('Recipient', _deliveryNameController.text),
              _buildReviewRow('Phone', _deliveryPhoneController.text),
              _buildReviewRow(
                  'Address', '${_deliveryAddressController.text}, ${_deliveryCityController.text}, $_deliveryState'),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Accuracy confirmation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isConfirmedAccurate
                  ? const Color(0xFF10B981)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: CheckboxListTile(
            value: _isConfirmedAccurate,
            onChanged: (val) {
              setState(() => _isConfirmedAccurate = val ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: Text(
              'I confirm that the information I have provided is accurate to the best of my knowledge.',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String title,
    required int stepIndexToEdit,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _currentStep = stepIndexToEdit),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Edit',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.onBackground,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ─────────────────────────────────────────────────────
  Widget _buildBottomActionBar(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 6,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (_currentStep < 4) {
                          setState(() => _currentStep++);
                        } else {
                          _handleSubmitRequest();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep < 4 ? 'Continue' : 'Submit Request',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentStep < 4
                                ? Icons.arrow_forward_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String label,
    required String typeValue,
    required IconData icon,
  }) {
    final isSelected = _shipmentType == typeValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _shipmentType = typeValue;
            if (typeValue == 'Air') {
              _portOfEntry = _airports.first;
            } else if (typeValue == 'Sea') {
              _portOfEntry = _seaPorts.first;
            } else {
              _portOfEntry = 'Seme Border';
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelCaps.copyWith(
            fontSize: 9,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.bodyMd.copyWith(
            fontSize: 13,
            color: enabled ? AppColors.onBackground : const Color(0xFF94A3B8),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySm.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
            ),
            filled: true,
            fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelCaps.copyWith(
            fontSize: 9,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: items.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickEstimatedArrivalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimatedArrivalDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _estimatedArrivalDate = picked);
    }
  }
}

class _ProductItemFormData {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController qtyController;
  final TextEditingController valueController;
  final TextEditingController weightController;
  final TextEditingController volumeController;
  final TextEditingController hsCodeController;
  String category;
  String unit;
  String currency;
  String country;

  _ProductItemFormData({
    String name = '',
    String description = '',
    this.category = 'General Cargo',
    String quantity = '1',
    this.unit = 'pieces',
    String purchaseValue = '',
    this.currency = 'USD',
    this.country = 'China',
    String weight = '',
    String volume = '',
    String hsCode = '',
  })  : nameController = TextEditingController(text: name),
        descController = TextEditingController(text: description),
        qtyController = TextEditingController(text: quantity),
        valueController = TextEditingController(text: purchaseValue),
        weightController = TextEditingController(text: weight),
        volumeController = TextEditingController(text: volume),
        hsCodeController = TextEditingController(text: hsCode);

  void dispose() {
    nameController.dispose();
    descController.dispose();
    qtyController.dispose();
    valueController.dispose();
    weightController.dispose();
    volumeController.dispose();
    hsCodeController.dispose();
  }
}

class _DocumentUploadFormData {
  final String documentType;
  final bool isRequired;
  bool isUploaded = false;
  bool isNotAvailable = false;
  String? fileName;
  String? fileUrl;

  _DocumentUploadFormData({
    required this.documentType,
    required this.isRequired,
  });
}
