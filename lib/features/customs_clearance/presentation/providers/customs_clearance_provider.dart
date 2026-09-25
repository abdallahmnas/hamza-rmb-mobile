import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../data/models/clearance_request_model.dart';

class CustomsClearanceState {
  final List<ClearanceRequestModel> requests;
  final ClearanceRequestModel? activeDraft;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String selectedFilter;

  const CustomsClearanceState({
    this.requests = const [],
    this.activeDraft,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.selectedFilter = 'All',
  });

  CustomsClearanceState copyWith({
    List<ClearanceRequestModel>? requests,
    ClearanceRequestModel? activeDraft,
    bool? clearDraft,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? selectedFilter,
  }) {
    return CustomsClearanceState(
      requests: requests ?? this.requests,
      activeDraft: clearDraft == true ? null : (activeDraft ?? this.activeDraft),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  /// Get active requests (in-progress, not completed or cancelled)
  List<ClearanceRequestModel> get activeRequests => requests.where((r) {
        return r.status != ClearanceStatus.completed &&
            r.status != ClearanceStatus.cancelled &&
            r.status != ClearanceStatus.draft;
      }).toList();

  /// Get completed requests
  List<ClearanceRequestModel> get completedRequests => requests
      .where((r) => r.status == ClearanceStatus.completed)
      .toList();

  /// Get cancelled requests
  List<ClearanceRequestModel> get cancelledRequests => requests
      .where((r) => r.status == ClearanceStatus.cancelled)
      .toList();

  /// Filtered requests based on selected tab
  List<ClearanceRequestModel> get filteredRequests {
    switch (selectedFilter.toLowerCase()) {
      case 'active':
        return activeRequests;
      case 'completed':
        return completedRequests;
      case 'cancelled':
        return cancelledRequests;
      case 'all':
      default:
        return requests
            .where((r) => r.status != ClearanceStatus.draft)
            .toList();
    }
  }

  /// Most recent active request for dashboard widget
  ClearanceRequestModel? get latestActiveRequest =>
      activeRequests.isNotEmpty ? activeRequests.first : null;
}

class CustomsClearanceNotifier extends Notifier<CustomsClearanceState> {
  static const String _storageKey = 'cache_customs_clearance_requests_v1';
  static const String _draftKey = 'cache_customs_clearance_draft_v1';

  @override
  CustomsClearanceState build() {
    final storage = ref.watch(localStorageProvider);

    List<ClearanceRequestModel> cachedRequests = [];
    final json = storage.getString(_storageKey);
    if (json != null && json.isNotEmpty) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        cachedRequests = list
            .map((e) => ClearanceRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (cachedRequests.isEmpty) {
      cachedRequests = _getInitialSampleRequests();
      // Persist defaults
      storage.setString(
        _storageKey,
        jsonEncode(cachedRequests.map((e) => e.toJson()).toList()),
      );
    }

    ClearanceRequestModel? cachedDraft;
    final draftJson = storage.getString(_draftKey);
    if (draftJson != null && draftJson.isNotEmpty) {
      try {
        cachedDraft = ClearanceRequestModel.fromJson(
            jsonDecode(draftJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    return CustomsClearanceState(
      requests: cachedRequests,
      activeDraft: cachedDraft,
      isLoading: false,
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Save or update the active multi-step draft
  Future<void> saveDraft(ClearanceRequestModel draft) async {
    final storage = ref.read(localStorageProvider);
    state = state.copyWith(activeDraft: draft);
    await storage.setString(_draftKey, jsonEncode(draft.toJson()));
  }

  /// Discard or remove current draft
  Future<void> clearDraft() async {
    final storage = ref.read(localStorageProvider);
    state = state.copyWith(clearDraft: true);
    await storage.remove(_draftKey);
  }

  /// Submit a new clearance request from the multi-step form
  Future<ClearanceRequestModel> submitRequest(ClearanceRequestModel request) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Simulate brief processing delay
      await Future<void>.delayed(const Duration(milliseconds: 700));

      final now = DateTime.now();
      final sequence = 1000 + state.requests.length + 1;
      final generatedRequestNumber = 'CLR-2026-00$sequence';
      final requestId = 'clr-req-${DateTime.now().millisecondsSinceEpoch}';

      final initialStatusHistory = [
        ClearanceStatusHistory(
          id: 'hist-1',
          clearanceRequestId: requestId,
          status: ClearanceStatus.submitted,
          title: 'Request Submitted',
          message:
              'Your customs clearance request has been successfully submitted and logged into our clearing queue.',
          createdAt: now,
        ),
      ];

      final initialMessages = [
        ClearanceMessage(
          id: 'msg-sys-1',
          clearanceRequestId: requestId,
          senderType: 'system',
          senderName: 'System',
          message:
              'Welcome! Your customs clearance request $generatedRequestNumber has been registered. Our logistics officer will verify your documents shortly.',
          createdAt: now,
        ),
        ClearanceMessage(
          id: 'msg-sup-1',
          clearanceRequestId: requestId,
          senderType: 'support',
          senderName: 'Clearance Desk',
          message:
              'Hello! We have received your clearance application for ${request.itemsSummary}. If you have any additional shipping manifests or duty questions, you can reply directly in this chat.',
          createdAt: now.add(const Duration(seconds: 2)),
        ),
      ];

      // Estimated provisional clearance service charge
      final initialCharges = [
        ClearanceCharge(
          id: 'chg-svc-1',
          clearanceRequestId: requestId,
          category: 'Service Charges',
          description: 'Standard Customs Brokerage & Manifest Documentation',
          amount: 85000.0,
          currency: 'NGN',
          isConfirmed: false,
          status: 'Pending',
        ),
        ClearanceCharge(
          id: 'chg-term-1',
          clearanceRequestId: requestId,
          category: 'Service Charges',
          description: 'Terminal Handling & Wharfage Documentation',
          amount: 65000.0,
          currency: 'NGN',
          isConfirmed: false,
          status: 'Pending',
        ),
      ];

      final newRequest = request.copyWith(
        id: requestId,
        requestNumber: generatedRequestNumber,
        status: ClearanceStatus.submitted,
        charges: initialCharges,
        messages: initialMessages,
        statusHistory: initialStatusHistory,
        createdAt: now,
        updatedAt: now,
      );

      final updatedList = [newRequest, ...state.requests];
      state = state.copyWith(
        requests: updatedList,
        clearDraft: true,
        isSubmitting: false,
      );

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(updatedList.map((e) => e.toJson()).toList()),
      );
      await storage.remove(_draftKey);

      return newRequest;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  /// Upload additional documents when requested by clearance team
  Future<void> uploadAdditionalDocument(
    String requestId,
    ClearanceDocument newDoc,
  ) async {
    final idx = state.requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;

    final target = state.requests[idx];
    final updatedDocs = List<ClearanceDocument>.from(target.documents);
    final docIdx = updatedDocs.indexWhere((d) => d.id == newDoc.id);

    if (docIdx != -1) {
      updatedDocs[docIdx] = newDoc;
    } else {
      updatedDocs.add(newDoc);
    }

    final hasMoreMissing = updatedDocs.any((d) => d.status == 'More information required');
    final newStatus = hasMoreMissing
        ? ClearanceStatus.additionalInfoRequired
        : ClearanceStatus.clearanceProcessing;

    final now = DateTime.now();
    final updatedHistory = List<ClearanceStatusHistory>.from(target.statusHistory)
      ..add(
        ClearanceStatusHistory(
          id: 'hist-${now.millisecondsSinceEpoch}',
          clearanceRequestId: requestId,
          status: newStatus,
          title: 'Additional Document Provided',
          message: 'Uploaded ${newDoc.documentType} (${newDoc.fileName}). Clearance verification resumed.',
          createdAt: now,
        ),
      );

    final updatedMessages = List<ClearanceMessage>.from(target.messages)
      ..add(
        ClearanceMessage(
          id: 'msg-${now.millisecondsSinceEpoch}',
          clearanceRequestId: requestId,
          senderType: 'customer',
          senderName: 'You',
          message: 'I have uploaded the requested document: ${newDoc.documentType} (${newDoc.fileName}).',
          createdAt: now,
        ),
      )
      ..add(
        ClearanceMessage(
          id: 'msg-ack-${now.millisecondsSinceEpoch}',
          clearanceRequestId: requestId,
          senderType: 'system',
          senderName: 'System',
          message: 'Document received and assigned to our clearing documentation officer.',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );

    final updatedReq = target.copyWith(
      documents: updatedDocs,
      status: newStatus,
      statusHistory: updatedHistory,
      messages: updatedMessages,
      requiredActionNote: hasMoreMissing ? target.requiredActionNote : null,
      updatedAt: now,
    );

    final updatedList = List<ClearanceRequestModel>.from(state.requests);
    updatedList[idx] = updatedReq;

    state = state.copyWith(requests: updatedList);
    final storage = ref.read(localStorageProvider);
    await storage.setString(
      _storageKey,
      jsonEncode(updatedList.map((e) => e.toJson()).toList()),
    );
  }

  /// Pay confirmed clearance charges using wallet balance
  Future<bool> payChargesWithWallet(String requestId) async {
    final idx = state.requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final target = state.requests[idx];
    final amountToPay = target.unpaidChargesAmount;
    if (amountToPay <= 0) return true;

    final wallet = ref.read(walletProvider).wallet;
    if (wallet.balance < amountToPay) {
      state = state.copyWith(
        error: 'Insufficient wallet balance. Please fund your wallet first.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final now = DateTime.now();
      final paymentSeq = target.payments.length + 1;
      final paymentRecord = ClearancePayment(
        id: 'pmt-${now.millisecondsSinceEpoch}',
        paymentNumber: 'Payment #00$paymentSeq',
        clearanceRequestId: requestId,
        description: 'Customs Duty & Clearance Terminal Settlement',
        amount: amountToPay,
        currency: 'NGN',
        status: 'Paid',
        paidAt: now,
        paymentMethod: 'Hamza NGN Wallet',
      );

      final updatedCharges = target.charges.map((c) {
        return c.copyWith(status: 'Paid', isConfirmed: true);
      }).toList();

      final updatedPayments = [...target.payments, paymentRecord];

      final nextStatus = target.deliveryPreference == 'Deliver to me'
          ? ClearanceStatus.delivery
          : ClearanceStatus.customsReleased;

      final updatedHistory = List<ClearanceStatusHistory>.from(target.statusHistory)
        ..add(
          ClearanceStatusHistory(
            id: 'hist-${now.millisecondsSinceEpoch}',
            clearanceRequestId: requestId,
            status: nextStatus,
            title: 'Clearance Payment Confirmed',
            message:
                'Payment of ₦${amountToPay.toStringAsFixed(2)} confirmed via Wallet. Terminal release order issued.',
            createdAt: now,
          ),
        );

      final updatedMessages = List<ClearanceMessage>.from(target.messages)
        ..add(
          ClearanceMessage(
            id: 'msg-pmt-${now.millisecondsSinceEpoch}',
            clearanceRequestId: requestId,
            senderType: 'system',
            senderName: 'System',
            message:
                'Payment Receipt ${paymentRecord.paymentNumber} of ₦${amountToPay.toStringAsFixed(2)} generated successfully. Status moved to ${ClearanceStatus.getLabel(nextStatus)}.',
            createdAt: now,
          ),
        );

      final updatedReq = target.copyWith(
        charges: updatedCharges,
        payments: updatedPayments,
        status: nextStatus,
        statusHistory: updatedHistory,
        messages: updatedMessages,
        updatedAt: now,
      );

      final updatedList = List<ClearanceRequestModel>.from(state.requests);
      updatedList[idx] = updatedReq;

      state = state.copyWith(requests: updatedList, isSubmitting: false);

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(updatedList.map((e) => e.toJson()).toList()),
      );

      // Trigger wallet refresh so balance updates
      ref.read(walletProvider.notifier).refresh();

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// Send message inside clearance request thread
  Future<void> sendMessage(
    String requestId,
    String text, {
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    final idx = state.requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;

    final target = state.requests[idx];
    final now = DateTime.now();

    final userMessage = ClearanceMessage(
      id: 'msg-usr-${now.millisecondsSinceEpoch}',
      clearanceRequestId: requestId,
      senderType: 'customer',
      senderName: 'You',
      message: text,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      createdAt: now,
    );

    final updatedMessages = List<ClearanceMessage>.from(target.messages)..add(userMessage);

    final updatedReq = target.copyWith(
      messages: updatedMessages,
      updatedAt: now,
    );

    final updatedList = List<ClearanceRequestModel>.from(state.requests);
    updatedList[idx] = updatedReq;

    state = state.copyWith(requests: updatedList);

    final storage = ref.read(localStorageProvider);
    await storage.setString(
      _storageKey,
      jsonEncode(updatedList.map((e) => e.toJson()).toList()),
    );

    // Auto simulated support reply after 1.5 seconds
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      final replyNow = DateTime.now();
      final supportReply = ClearanceMessage(
        id: 'msg-sup-${replyNow.millisecondsSinceEpoch}',
        clearanceRequestId: requestId,
        senderType: 'support',
        senderName: 'Clearance Desk',
        message:
            'Thank you for your update. Our port clearing officer has noted this and will keep you posted on the customs progress.',
        createdAt: replyNow,
      );

      final currentIdx = state.requests.indexWhere((r) => r.id == requestId);
      if (currentIdx != -1) {
        final currentReq = state.requests[currentIdx];
        final withReplyMessages = List<ClearanceMessage>.from(currentReq.messages)
          ..add(supportReply);

        final withReplyReq = currentReq.copyWith(
          messages: withReplyMessages,
          updatedAt: replyNow,
        );

        final finalUpdatedList = List<ClearanceRequestModel>.from(state.requests);
        finalUpdatedList[currentIdx] = withReplyReq;

        state = state.copyWith(requests: finalUpdatedList);
        storage.setString(
          _storageKey,
          jsonEncode(finalUpdatedList.map((e) => e.toJson()).toList()),
        );
      }
    });
  }

  /// Sample realistic initial data so the user can test all scenarios out-of-the-box
  static List<ClearanceRequestModel> _getInitialSampleRequests() {
    final now = DateTime.now();

    return [
      // 1. In Progress (Customs Processing) - As mentioned in spec: CLR-2026-001245
      ClearanceRequestModel(
        id: 'clr-req-1245',
        requestNumber: 'CLR-2026-001245',
        customerId: 'HZ-88912',
        shipmentType: 'Sea',
        originCountry: 'China',
        portOfEntry: 'Apapa Port',
        shipmentStatus: 'Arrived in Nigeria',
        shippingLine: 'COSCO Shipping Lines',
        billOfLadingNumber: 'COSU632819001',
        containerNumber: 'CSQU3091823',
        estimatedArrivalDate: now.subtract(const Duration(days: 3)),
        status: ClearanceStatus.clearanceProcessing,
        deliveryPreference: 'Deliver to me',
        deliveryAddress: const ClearanceDeliveryAddress(
          fullName: 'Bello Al-Hassan',
          phone: '+234 803 123 4567',
          address: 'Plot 14, Commercial Avenue, Ikeja Industrial Estate',
          city: 'Ikeja',
          state: 'Lagos State',
          instructions: 'Call driver upon arrival at main logistics gate.',
        ),
        items: const [
          ClearanceItem(
            id: 'itm-1',
            productName: 'Smart Watches & Fitness Trackers',
            description: 'Bluetooth calling, AMOLED screen, heart rate sensors',
            category: 'Electronics',
            quantity: 350,
            unit: 'pieces',
            purchaseValue: 24.50,
            currency: 'USD',
            countryOfManufacture: 'China',
            weight: 120.0,
            volume: 1.8,
            hsCode: '8517.62',
          ),
          ClearanceItem(
            id: 'itm-2',
            productName: 'Wireless Noise-Cancelling Earbuds',
            description: 'TWS earbuds with charging case and type-C cables',
            category: 'Electronics',
            quantity: 500,
            unit: 'pieces',
            purchaseValue: 12.00,
            currency: 'USD',
            countryOfManufacture: 'China',
            weight: 85.0,
            volume: 1.2,
            hsCode: '8518.30',
          ),
        ],
        documents: [
          ClearanceDocument(
            id: 'doc-1',
            documentType: 'Commercial Invoice',
            fileName: 'INV-SZ-2026-9081.pdf',
            fileUrl: 'https://example.com/invoice.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 5)),
          ),
          ClearanceDocument(
            id: 'doc-2',
            documentType: 'Packing List',
            fileName: 'PL-SZ-2026-9081.pdf',
            fileUrl: 'https://example.com/packing_list.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 5)),
          ),
          ClearanceDocument(
            id: 'doc-3',
            documentType: 'Bill of Lading',
            fileName: 'BL_COSU632819001.pdf',
            fileUrl: 'https://example.com/bl.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 4)),
          ),
          ClearanceDocument(
            id: 'doc-4',
            documentType: 'Form M',
            fileName: 'FormM-MF202609012.pdf',
            fileUrl: 'https://example.com/form_m.pdf',
            status: 'Under review',
            uploadedAt: now.subtract(const Duration(days: 3)),
          ),
        ],
        charges: const [
          ClearanceCharge(
            id: 'chg-1',
            category: 'Customs/Government Charges',
            description: 'Customs Duty & Import Surcharge Assessment (HS 8517/8518)',
            amount: 420000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Pending',
          ),
          ClearanceCharge(
            id: 'chg-2',
            category: 'Service Charges',
            description: 'Terminal Handling & Wharfage Formalities',
            amount: 95000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Pending',
          ),
          ClearanceCharge(
            id: 'chg-3',
            category: 'Service Charges',
            description: 'Hamza Agency Customs Brokerage & Clearance Execution',
            amount: 80000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Pending',
          ),
          ClearanceCharge(
            id: 'chg-4',
            category: 'Delivery',
            description: 'Container Destuffing & Ikeja Dispatch Van',
            amount: 45000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Pending',
          ),
        ],
        messages: [
          ClearanceMessage(
            id: 'msg-1',
            senderType: 'system',
            senderName: 'System',
            message: 'Your customs clearance request has moved to Customs Processing.',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          ClearanceMessage(
            id: 'msg-2',
            senderType: 'support',
            senderName: 'Clearance Desk',
            message:
                'Good day! Your COSCO container has docked at Apapa Terminal. Document examination is scheduled for tomorrow morning.',
            createdAt: now.subtract(const Duration(hours: 18)),
          ),
        ],
        statusHistory: [
          ClearanceStatusHistory(
            id: 'hist-1',
            status: ClearanceStatus.submitted,
            title: 'Request Submitted',
            message: 'Your clearance request was received and assigned to our Lagos port team.',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
          ClearanceStatusHistory(
            id: 'hist-2',
            status: ClearanceStatus.documentReview,
            title: 'Documents Review',
            message: 'Commercial invoice, packing list, and original BL validated.',
            createdAt: now.subtract(const Duration(days: 4)),
          ),
          ClearanceStatusHistory(
            id: 'hist-3',
            status: ClearanceStatus.clearanceProcessing,
            title: 'Clearance Processing',
            message: 'Your shipment is currently being processed through customs.',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),

      // 2. Action Required (Missing Document) - As described in Section 13
      ClearanceRequestModel(
        id: 'clr-req-1890',
        requestNumber: 'CLR-2026-001890',
        customerId: 'HZ-88912',
        shipmentType: 'Sea',
        originCountry: 'China',
        portOfEntry: 'Tin Can Island Port',
        shipmentStatus: 'At port/terminal',
        shippingLine: 'Maersk Line',
        billOfLadingNumber: 'MSK99201481',
        containerNumber: 'MRSU4810291',
        estimatedArrivalDate: now.subtract(const Duration(days: 1)),
        status: ClearanceStatus.additionalInfoRequired,
        requiredActionNote:
            'Please upload a clearer copy of your Commercial Invoice and the Manufacturer Packing List.',
        deliveryPreference: 'I\'ll arrange pickup/delivery myself',
        items: const [
          ClearanceItem(
            id: 'itm-3',
            productName: 'Heavy Duty Truck Filters & Brake Pads',
            description: 'Automotive replacement consumables for commercial vehicles',
            category: 'Auto Parts',
            quantity: 400,
            unit: 'sets',
            purchaseValue: 18.50,
            currency: 'USD',
            countryOfManufacture: 'China',
            weight: 450.0,
            volume: 3.5,
          ),
        ],
        documents: [
          ClearanceDocument(
            id: 'doc-5',
            documentType: 'Commercial Invoice',
            fileName: 'Scanned_Invoice_Blurry.jpg',
            fileUrl: '',
            status: 'More information required',
            note: 'Resolution is too low to read tariff description and unit values clearly.',
            uploadedAt: now.subtract(const Duration(days: 2)),
          ),
          ClearanceDocument(
            id: 'doc-6',
            documentType: 'Bill of Lading',
            fileName: 'MSK_BOL_99201481.pdf',
            fileUrl: 'https://example.com/msk.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 2)),
          ),
          ClearanceDocument(
            id: 'doc-7',
            documentType: 'Packing List',
            fileName: '',
            fileUrl: '',
            status: 'More information required',
            note: 'Packing list with gross and net weights is missing.',
            isNotAvailable: false,
            uploadedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        charges: const [
          ClearanceCharge(
            id: 'chg-5',
            category: 'Service Charges',
            description: 'Customs Clearance & Port Agent Fee',
            amount: 90000.0,
            currency: 'NGN',
            isConfirmed: false,
            status: 'Pending',
          ),
        ],
        messages: [
          ClearanceMessage(
            id: 'msg-3',
            senderType: 'system',
            senderName: 'System',
            message: 'Your clearance request requires additional documentation.',
            createdAt: now.subtract(const Duration(hours: 10)),
          ),
          ClearanceMessage(
            id: 'msg-4',
            senderType: 'support',
            senderName: 'Clearance Desk',
            message:
                'Hello! The customs documentation team flagged the commercial invoice because the serial numbers and unit prices are blurred. Please re-upload a clear PDF or scanned photo.',
            createdAt: now.subtract(const Duration(hours: 9)),
          ),
        ],
        statusHistory: [
          ClearanceStatusHistory(
            id: 'hist-4',
            status: ClearanceStatus.submitted,
            title: 'Request Submitted',
            message: 'Request received and placed into inspection queue.',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          ClearanceStatusHistory(
            id: 'hist-5',
            status: ClearanceStatus.additionalInfoRequired,
            title: 'Action Required',
            message: 'Additional information requested by customs evaluation team.',
            createdAt: now.subtract(const Duration(hours: 10)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),

      // 3. Awaiting Payment - As described in Section 14 & 15
      ClearanceRequestModel(
        id: 'clr-req-1552',
        requestNumber: 'CLR-2026-001552',
        customerId: 'HZ-88912',
        shipmentType: 'Air',
        originCountry: 'China',
        portOfEntry: 'Murtala Muhammed International Airport',
        shipmentStatus: 'At port/terminal',
        airline: 'Ethiopian Cargo',
        airWaybillNumber: '071-88492019',
        estimatedArrivalDate: now.subtract(const Duration(days: 2)),
        status: ClearanceStatus.awaitingPayment,
        deliveryPreference: 'Deliver to me',
        deliveryAddress: const ClearanceDeliveryAddress(
          fullName: 'Bello Al-Hassan',
          phone: '+234 803 123 4567',
          address: 'Block B, Suite 5, Victoria Island Plaza',
          city: 'Victoria Island',
          state: 'Lagos State',
        ),
        items: const [
          ClearanceItem(
            id: 'itm-4',
            productName: 'Solar Micro Inverters & Battery Monitors',
            description: 'Renewable energy hardware kits for domestic installations',
            category: 'Machinery & Tools',
            quantity: 25,
            unit: 'cartons',
            purchaseValue: 145.0,
            currency: 'USD',
            countryOfManufacture: 'China',
            weight: 95.0,
            volume: 0.8,
            hsCode: '8504.40',
          ),
        ],
        documents: [
          ClearanceDocument(
            id: 'doc-8',
            documentType: 'Air Waybill',
            fileName: 'AWB_07188492019.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 3)),
          ),
          ClearanceDocument(
            id: 'doc-9',
            documentType: 'Commercial Invoice',
            fileName: 'Solar_Supply_Invoice.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 3)),
          ),
        ],
        charges: const [
          ClearanceCharge(
            id: 'chg-6',
            category: 'Customs/Government Charges',
            description: 'Official Airport Cargo Duty Assessment & Import Taxes',
            amount: 185000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Awaiting Payment',
          ),
          ClearanceCharge(
            id: 'chg-7',
            category: 'Service Charges',
            description: 'NAHCO Cargo Terminal Release & Handling Fee',
            amount: 45000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Awaiting Payment',
          ),
          ClearanceCharge(
            id: 'chg-8',
            category: 'Delivery',
            description: 'Express Same-day Dispatch to Victoria Island',
            amount: 20000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Awaiting Payment',
          ),
        ],
        messages: [
          ClearanceMessage(
            id: 'msg-5',
            senderType: 'system',
            senderName: 'System',
            message: 'Customs assessment complete. Duty charge: ₦250,000.00 ready for payment.',
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
          ClearanceMessage(
            id: 'msg-6',
            senderType: 'support',
            senderName: 'Clearance Desk',
            message:
                'The customs assessment for your solar equipment at MMIA Cargo shed is complete. Once payment is made, airport gate pass will be issued immediately.',
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
        ],
        statusHistory: [
          ClearanceStatusHistory(
            id: 'hist-6',
            status: ClearanceStatus.submitted,
            title: 'Request Submitted',
            message: 'Air cargo clearance request registered.',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          ClearanceStatusHistory(
            id: 'hist-7',
            status: ClearanceStatus.customsAssessment,
            title: 'Customs Assessment Completed',
            message: 'Confirmed duty payable: ₦250,000.00.',
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
          ClearanceStatusHistory(
            id: 'hist-8',
            status: ClearanceStatus.awaitingPayment,
            title: 'Awaiting Payment',
            message: 'Payment required to initiate NAHCO gate pass release.',
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),

      // 4. Completed Request
      ClearanceRequestModel(
        id: 'clr-req-0842',
        requestNumber: 'CLR-2026-000842',
        customerId: 'HZ-88912',
        shipmentType: 'Sea',
        originCountry: 'China',
        portOfEntry: 'Lekki Deep Sea Port',
        shipmentStatus: 'Arrived in Nigeria',
        shippingLine: 'CMA CGM',
        billOfLadingNumber: 'CMA10928371',
        containerNumber: 'CMAU2910482',
        status: ClearanceStatus.completed,
        deliveryPreference: 'Deliver to me',
        deliveryAddress: const ClearanceDeliveryAddress(
          fullName: 'Bello Al-Hassan',
          phone: '+234 803 123 4567',
          address: 'Plot 14, Commercial Avenue, Ikeja Industrial Estate',
          city: 'Ikeja',
          state: 'Lagos State',
        ),
        items: const [
          ClearanceItem(
            id: 'itm-5',
            productName: 'Men\'s Casual & Athletic Footwear',
            description: 'Leather sneakers and running shoes in retail boxes',
            category: 'Fashion',
            quantity: 600,
            unit: 'pairs',
            purchaseValue: 14.0,
            currency: 'USD',
            countryOfManufacture: 'China',
            weight: 720.0,
            volume: 4.2,
          ),
        ],
        documents: [
          ClearanceDocument(
            id: 'doc-10',
            documentType: 'Bill of Lading',
            fileName: 'CMA_BL_FINAL.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 20)),
          ),
          ClearanceDocument(
            id: 'doc-11',
            documentType: 'Commercial Invoice',
            fileName: 'Footwear_Invoice.pdf',
            status: 'Accepted',
            uploadedAt: now.subtract(const Duration(days: 20)),
          ),
        ],
        charges: const [
          ClearanceCharge(
            id: 'chg-9',
            category: 'Customs/Government Charges',
            description: 'Customs Clearance Assessment & Statutory Tariffs',
            amount: 540000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Paid',
          ),
          ClearanceCharge(
            id: 'chg-10',
            category: 'Service Charges',
            description: 'Lekki Port Terminal Brokerage & Handling',
            amount: 110000.0,
            currency: 'NGN',
            isConfirmed: true,
            status: 'Paid',
          ),
        ],
        payments: [
          ClearancePayment(
            id: 'pmt-1',
            paymentNumber: 'Payment #001',
            clearanceRequestId: 'clr-req-0842',
            description: 'Lekki Port Customs & Terminal Clearance Total',
            amount: 650000.0,
            currency: 'NGN',
            status: 'Paid',
            paidAt: now.subtract(const Duration(days: 12)),
            paymentMethod: 'Hamza NGN Wallet',
          ),
        ],
        messages: [
          ClearanceMessage(
            id: 'msg-7',
            senderType: 'system',
            senderName: 'System',
            message: 'Goods cleared and delivered to client address in Ikeja, Lagos.',
            createdAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        statusHistory: [
          ClearanceStatusHistory(
            id: 'hist-9',
            status: ClearanceStatus.submitted,
            title: 'Request Submitted',
            message: 'Clearance request received.',
            createdAt: now.subtract(const Duration(days: 20)),
          ),
          ClearanceStatusHistory(
            id: 'hist-10',
            status: ClearanceStatus.customsReleased,
            title: 'Customs Released',
            message: 'Goods officially released from Lekki Port Terminal.',
            createdAt: now.subtract(const Duration(days: 11)),
          ),
          ClearanceStatusHistory(
            id: 'hist-11',
            status: ClearanceStatus.completed,
            title: 'Completed',
            message: 'Goods received in good condition by customer.',
            createdAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}

final customsClearanceProvider =
    NotifierProvider<CustomsClearanceNotifier, CustomsClearanceState>(() {
  return CustomsClearanceNotifier();
});
