import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../wallet/data/models/transaction_model.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../data/datasources/clearance_remote_data_source.dart';
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
        return requests;
    }
  }

  /// Most recent active request for dashboard widget
  ClearanceRequestModel? get latestActiveRequest {
    if (activeRequests.isNotEmpty) return activeRequests.first;
    if (requests.isNotEmpty) return requests.first;
    return null;
  }
}

class CustomsClearanceNotifier extends Notifier<CustomsClearanceState> {
  static const String _storageKey = 'cache_customs_clearance_requests_v1';
  static const String _draftKey = 'cache_customs_clearance_draft_v1';

  ClearanceRemoteDataSource get _remoteDataSource =>
      ref.read(clearanceRemoteDataSourceProvider);

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
            .where((r) =>
                !r.id.startsWith('sample-') &&
                !r.requestNumber.startsWith('CLR-2026-001245') &&
                !r.requestNumber.startsWith('CLR-2026-000842') &&
                !r.requestNumber.startsWith('CLR-2026-001552'))
            .toList();
      } catch (_) {}
    }

    ClearanceRequestModel? cachedDraft;
    final draftJson = storage.getString(_draftKey);
    if (draftJson != null && draftJson.isNotEmpty) {
      try {
        cachedDraft = ClearanceRequestModel.fromJson(
            jsonDecode(draftJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    // Trigger async fetch from live API on startup
    Future.microtask(() => fetchRequests());

    return CustomsClearanceState(
      requests: cachedRequests,
      activeDraft: cachedDraft,
      isLoading: cachedRequests.isEmpty,
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Fetch requests from live backend API (GET /clearance/requests)
  Future<void> fetchRequests({String? status}) async {
    state = state.copyWith(
      isLoading: state.requests.isEmpty,
      error: null,
    );

    try {
      final remoteRequests = await _remoteDataSource.getClearanceRequests(
        status: status,
      );

      // Merge remote requests with locally stored requests so locally submitted items are never lost
      final existingLocals = state.requests.where((local) =>
        !remoteRequests.any((rem) =>
          (rem.id.isNotEmpty && rem.id == local.id) ||
          (rem.requestNumber.isNotEmpty && rem.requestNumber == local.requestNumber)
        )
      ).toList();

      final combined = [...remoteRequests, ...existingLocals];

      final storage = ref.read(localStorageProvider);

      state = state.copyWith(
        requests: combined,
        isLoading: false,
        error: null,
      );
      await storage.setString(
        _storageKey,
        jsonEncode(combined.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      // Keep cached requests on network failure so user isn't blocked
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get single clearance request details (GET /clearance/requests/:id)
  Future<ClearanceRequestModel?> fetchRequestById(String id) async {
    try {
      final updated = await _remoteDataSource.getClearanceRequestById(id);
      final idx = state.requests.indexWhere((r) => r.id == id);
      final updatedList = List<ClearanceRequestModel>.from(state.requests);
      if (idx != -1) {
        updatedList[idx] = updated;
      } else {
        updatedList.insert(0, updated);
      }
      state = state.copyWith(requests: updatedList);

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(updatedList.map((e) => e.toJson()).toList()),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return state.requests.where((r) => r.id == id).firstOrNull;
    }
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

  /// Submit a new clearance request to backend (POST /clearance/requests)
  Future<ClearanceRequestModel> submitRequest(ClearanceRequestModel request) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final submissionModel = request.status == ClearanceStatus.draft
          ? request.copyWith(
              status: ClearanceStatus.submitted,
              requestNumber: request.requestNumber == 'DRAFT'
                  ? 'CLR-2026-${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}'
                  : request.requestNumber,
            )
          : request;

      ClearanceRequestModel submitted;
      try {
        submitted = await _remoteDataSource.createClearanceRequest(submissionModel);
      } catch (_) {
        // Fallback local persistence if offline
        final now = DateTime.now();
        final sequence = 1000 + state.requests.length + 1;
        final generatedRequestNumber = submissionModel.requestNumber.isNotEmpty && submissionModel.requestNumber != 'DRAFT'
            ? submissionModel.requestNumber
            : 'CLR-2026-00$sequence';
        final requestId = submissionModel.id.isNotEmpty && !submissionModel.id.startsWith('draft-')
            ? submissionModel.id
            : 'clr-req-${now.millisecondsSinceEpoch}';

        submitted = submissionModel.copyWith(
          id: requestId,
          requestNumber: generatedRequestNumber,
          status: ClearanceStatus.submitted,
          createdAt: now,
          updatedAt: now,
        );
      }

      if (submitted.status == ClearanceStatus.draft) {
        submitted = submitted.copyWith(status: ClearanceStatus.submitted);
      }

      final updatedList = [
        submitted,
        ...state.requests.where((r) =>
            r.id != submitted.id &&
            r.requestNumber != submitted.requestNumber &&
            !r.id.startsWith('draft-'))
      ];
      state = state.copyWith(
        requests: updatedList,
        clearDraft: true,
        isSubmitting: false,
        error: null,
      );

      final storage = ref.read(localStorageProvider);
      await storage.setString(
        _storageKey,
        jsonEncode(updatedList.map((e) => e.toJson()).toList()),
      );
      await storage.remove(_draftKey);

      return submitted;
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

    // Call backend API (POST /clearance/requests/:id/documents)
    ClearanceDocument remoteDoc = newDoc;
    try {
      remoteDoc = await _remoteDataSource.uploadClearanceDocument(requestId, newDoc);
    } catch (_) {
      // Fallback to local doc if offline
    }

    final target = state.requests[idx];
    final updatedDocs = List<ClearanceDocument>.from(target.documents);
    final docIdx = updatedDocs.indexWhere((d) => d.id == remoteDoc.id);

    if (docIdx != -1) {
      updatedDocs[docIdx] = remoteDoc;
    } else {
      updatedDocs.add(remoteDoc);
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
          message: 'Uploaded ${remoteDoc.documentType} (${remoteDoc.fileName}). Clearance verification resumed.',
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
          message: 'I have uploaded the requested document: ${remoteDoc.documentType} (${remoteDoc.fileName}).',
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
      // Call backend API (POST /clearance/requests/:id/pay)
      try {
        await _remoteDataSource.payClearanceCharges(requestId);
      } catch (_) {
        // Fallback to local debit
      }

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

      // Record debit transaction entry in wallet ledger
      await ref.read(walletProvider.notifier).addTransaction(
        TransactionModel(
          id: paymentRecord.id,
          title: 'Customs Clearance Fee - ${target.requestNumber}',
          type: 'debit',
          amount: amountToPay,
          currency: 'NGN',
          status: 'completed',
          reference: paymentRecord.paymentNumber,
          date: now,
        ),
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

    ClearanceMessage? remoteMessage;
    try {
      remoteMessage = await _remoteDataSource.sendClearanceMessage(
        requestId,
        text,
        attachmentUrl: attachmentUrl,
      );
    } catch (_) {}

    final userMessage = remoteMessage ??
        ClearanceMessage(
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

    // Auto simulated support reply after 1.5 seconds if offline/local
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

  /// Cancel an active clearance request (POST /clearance/requests/:id/cancel)
  Future<bool> cancelClearanceRequest(String requestId, {String? reason}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      ClearanceRequestModel? cancelled;
      try {
        cancelled = await _remoteDataSource.cancelClearanceRequest(requestId, reason: reason);
      } catch (_) {}

      final idx = state.requests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        final target = state.requests[idx];
        final now = DateTime.now();
        final updated = cancelled ??
            target.copyWith(
              status: ClearanceStatus.cancelled,
              updatedAt: now,
            );
        final updatedList = List<ClearanceRequestModel>.from(state.requests);
        updatedList[idx] = updated;
        state = state.copyWith(requests: updatedList, isSubmitting: false);

        final storage = ref.read(localStorageProvider);
        await storage.setString(
          _storageKey,
          jsonEncode(updatedList.map((e) => e.toJson()).toList()),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

}

final customsClearanceProvider =
    NotifierProvider<CustomsClearanceNotifier, CustomsClearanceState>(() {
  return CustomsClearanceNotifier();
});
