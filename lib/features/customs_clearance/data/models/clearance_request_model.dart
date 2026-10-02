/// Status constants for Customs Clearance Requests.
class ClearanceStatus {
  static const String draft = 'DRAFT';
  static const String submitted = 'SUBMITTED';
  static const String documentReview = 'DOCUMENT_REVIEW';
  static const String additionalInfoRequired = 'ADDITIONAL_INFORMATION_REQUIRED';
  static const String clearanceProcessing = 'CLEARANCE_PROCESSING';
  static const String customsAssessment = 'CUSTOMS_ASSESSMENT';
  static const String inspection = 'INSPECTION';
  static const String awaitingPayment = 'AWAITING_PAYMENT';
  static const String customsReleased = 'CUSTOMS_RELEASED';
  static const String delivery = 'DELIVERY';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
  static const String onHold = 'ON_HOLD';

  static String getLabel(String status) {
    switch (status) {
      case draft:
        return 'Draft';
      case submitted:
        return 'Request Submitted';
      case documentReview:
        return 'Reviewing Documents';
      case additionalInfoRequired:
        return 'Action Required';
      case clearanceProcessing:
        return 'Customs Processing';
      case customsAssessment:
        return 'Customs Assessment';
      case inspection:
        return 'Inspection';
      case awaitingPayment:
        return 'Awaiting Payment';
      case customsReleased:
        return 'Customs Released';
      case delivery:
        return 'Out for Delivery';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      case onHold:
        return 'On Hold';
      default:
        return status;
    }
  }

  static String getDescription(String status) {
    switch (status) {
      case draft:
        return 'Your request has been saved as a draft.';
      case submitted:
        return 'Your request has been submitted and received.';
      case documentReview:
        return 'Your documents are being reviewed by our clearing specialists.';
      case additionalInfoRequired:
        return 'We need additional information or documents from you.';
      case clearanceProcessing:
        return 'Your shipment is currently being processed through customs.';
      case customsAssessment:
        return 'Your shipment is undergoing customs assessment.';
      case inspection:
        return 'Your shipment is undergoing the required terminal inspection process.';
      case awaitingPayment:
        return 'Payment is required before the next clearance stage can proceed.';
      case customsReleased:
        return 'Your goods have been officially released from customs.';
      case delivery:
        return 'Your goods are being prepared and dispatched for delivery.';
      case completed:
        return 'Your customs clearance request has been successfully completed.';
      case cancelled:
        return 'This clearance request has been cancelled.';
      case onHold:
        return 'This request is temporarily on hold pending customs verification.';
      default:
        return '';
    }
  }

  /// Maps status to one of the 7 main timeline progress steps (0 to 6)
  static int getTimelineStep(String status) {
    switch (status) {
      case draft:
      case submitted:
        return 0; // Request Submitted
      case documentReview:
      case additionalInfoRequired:
        return 1; // Documents Review
      case clearanceProcessing:
      case inspection:
        return 2; // Clearance Processing
      case customsAssessment:
      case awaitingPayment:
        return 3; // Customs Assessment
      case customsReleased:
        return 4; // Customs Release
      case delivery:
        return 5; // Delivery
      case completed:
        return 6; // Completed
      default:
        return 0;
    }
  }
}

/// Delivery address details for clearance release dispatch
class ClearanceDeliveryAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String? instructions;

  const ClearanceDeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    this.instructions,
  });

  factory ClearanceDeliveryAddress.fromJson(dynamic json) {
    if (json is String) {
      return ClearanceDeliveryAddress(
        fullName: '',
        phone: '',
        address: json,
        city: '',
        state: '',
      );
    }
    if (json is Map<String, dynamic>) {
      return ClearanceDeliveryAddress(
        fullName: json['fullName'] as String? ?? json['recipientName'] as String? ?? '',
        phone: json['phone'] as String? ?? json['recipientPhone'] as String? ?? '',
        address: json['address'] as String? ?? json['deliveryAddress'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        instructions: json['instructions'] as String? ?? json['deliveryInstructions'] as String?,
      );
    }
    return const ClearanceDeliveryAddress(
      fullName: '',
      phone: '',
      address: '',
      city: '',
      state: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'instructions': instructions,
      };
}

/// Individual product item within a clearance request
class ClearanceItem {
  final String id;
  final String clearanceRequestId;
  final String productName;
  final String description;
  final String category;
  final double quantity;
  final String unit;
  final double purchaseValue;
  final String currency;
  final String countryOfManufacture;
  final double? weight;
  final double? volume;
  final String? hsCode;

  const ClearanceItem({
    required this.id,
    this.clearanceRequestId = '',
    required this.productName,
    this.description = '',
    this.category = 'General Goods',
    this.quantity = 1,
    this.unit = 'pieces',
    this.purchaseValue = 0.0,
    this.currency = 'USD',
    this.countryOfManufacture = 'China',
    this.weight,
    this.volume,
    this.hsCode,
  });

  ClearanceItem copyWith({
    String? id,
    String? clearanceRequestId,
    String? productName,
    String? description,
    String? category,
    double? quantity,
    String? unit,
    double? purchaseValue,
    String? currency,
    String? countryOfManufacture,
    double? weight,
    double? volume,
    String? hsCode,
  }) {
    return ClearanceItem(
      id: id ?? this.id,
      clearanceRequestId: clearanceRequestId ?? this.clearanceRequestId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      currency: currency ?? this.currency,
      countryOfManufacture: countryOfManufacture ?? this.countryOfManufacture,
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
      hsCode: hsCode ?? this.hsCode,
    );
  }

  static double _parseNum(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) {
      final sanitized = val.replaceAll(',', '').replaceAll('\$', '').replaceAll('¥', '').trim();
      return double.tryParse(sanitized) ?? defaultVal;
    }
    return defaultVal;
  }

  factory ClearanceItem.fromJson(Map<String, dynamic> json) {
    return ClearanceItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clearanceRequestId: json['clearanceRequestId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['name']?.toString() ?? json['item']?.toString() ?? 'Item',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General Goods',
      quantity: _parseNum(json['quantity'], 1.0),
      unit: json['unit']?.toString() ?? 'pieces',
      purchaseValue: _parseNum(
        json['purchaseValue'] ?? json['value'] ?? json['price'] ?? json['unitPrice'],
        0.0,
      ),
      currency: json['currency']?.toString() ?? 'USD',
      countryOfManufacture: json['countryOfManufacture']?.toString() ?? 'China',
      weight: json['weight'] != null ? _parseNum(json['weight']) : null,
      volume: json['volume'] != null ? _parseNum(json['volume']) : null,
      hsCode: json['hsCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clearanceRequestId': clearanceRequestId,
        'productName': productName,
        'description': description,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'purchaseValue': purchaseValue,
        'currency': currency,
        'countryOfManufacture': countryOfManufacture,
        'weight': weight,
        'volume': volume,
        'hsCode': hsCode,
      };
}

/// Document uploaded for customs clearance
class ClearanceDocument {
  final String id;
  final String clearanceRequestId;
  final String documentType;
  final String fileName;
  final String fileUrl;
  final String status; // Uploaded, Under review, Accepted, More information required
  final DateTime uploadedAt;
  final bool isNotAvailable;
  final String? note;

  const ClearanceDocument({
    required this.id,
    this.clearanceRequestId = '',
    required this.documentType,
    this.fileName = '',
    this.fileUrl = '',
    this.status = 'Uploaded',
    required this.uploadedAt,
    this.isNotAvailable = false,
    this.note,
  });

  ClearanceDocument copyWith({
    String? id,
    String? clearanceRequestId,
    String? documentType,
    String? fileName,
    String? fileUrl,
    String? status,
    DateTime? uploadedAt,
    bool? isNotAvailable,
    String? note,
  }) {
    return ClearanceDocument(
      id: id ?? this.id,
      clearanceRequestId: clearanceRequestId ?? this.clearanceRequestId,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isNotAvailable: isNotAvailable ?? this.isNotAvailable,
      note: note ?? this.note,
    );
  }

  factory ClearanceDocument.fromJson(Map<String, dynamic> json) {
    return ClearanceDocument(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clearanceRequestId: json['clearanceRequestId']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? json['type']?.toString() ?? 'Document',
      fileName: json['fileName']?.toString() ?? json['name']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? json['url']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Uploaded',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isNotAvailable: json['isNotAvailable'] == true ||
          json['isMissingNoted'] == true ||
          json['isNotAvailable']?.toString() == 'true',
      note: json['note']?.toString() ?? json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clearanceRequestId': clearanceRequestId,
        'documentType': documentType,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'status': status,
        'uploadedAt': uploadedAt.toIso8601String(),
        'isNotAvailable': isNotAvailable,
        'note': note,
      };
}

/// Itemized government or clearing service fee
class ClearanceCharge {
  final String id;
  final String clearanceRequestId;
  final String category; // 'Customs/Government Charges', 'Service Charges', 'Delivery', 'Other'
  final String description;
  final double amount;
  final String currency;
  final bool isConfirmed; // Estimated vs Confirmed
  final String status; // 'Pending', 'Awaiting Payment', 'Paid', 'Waived'

  const ClearanceCharge({
    required this.id,
    this.clearanceRequestId = '',
    required this.category,
    required this.description,
    required this.amount,
    this.currency = 'NGN',
    this.isConfirmed = false,
    this.status = 'Pending',
  });

  ClearanceCharge copyWith({
    String? id,
    String? clearanceRequestId,
    String? category,
    String? description,
    double? amount,
    String? currency,
    bool? isConfirmed,
    String? status,
  }) {
    return ClearanceCharge(
      id: id ?? this.id,
      clearanceRequestId: clearanceRequestId ?? this.clearanceRequestId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
    );
  }

  static double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final sanitized = val.replaceAll(',', '').replaceAll('₦', '').replaceAll('\$', '').trim();
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  factory ClearanceCharge.fromJson(Map<String, dynamic> json) {
    return ClearanceCharge(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clearanceRequestId: json['clearanceRequestId']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Service Charges',
      description: json['description']?.toString() ?? json['title']?.toString() ?? '',
      amount: _parseAmount(json['amount'] ?? json['fee']),
      currency: json['currency']?.toString() ?? 'NGN',
      isConfirmed: json['isConfirmed'] == true || json['isConfirmed']?.toString() == 'true',
      status: json['status']?.toString() ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clearanceRequestId': clearanceRequestId,
        'category': category,
        'description': description,
        'amount': amount,
        'currency': currency,
        'isConfirmed': isConfirmed,
        'status': status,
      };
}

/// Payment record for clearance charges
class ClearancePayment {
  final String id;
  final String paymentNumber;
  final String clearanceRequestId;
  final String description;
  final double amount;
  final String currency;
  final String status; // 'Paid', 'Payment processing', 'Failed', 'Refunded'
  final DateTime paidAt;
  final String paymentMethod;

  const ClearancePayment({
    required this.id,
    required this.paymentNumber,
    this.clearanceRequestId = '',
    required this.description,
    required this.amount,
    this.currency = 'NGN',
    this.status = 'Paid',
    required this.paidAt,
    this.paymentMethod = 'Wallet Balance',
  });

  static double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final sanitized = val.replaceAll(',', '').replaceAll('₦', '').replaceAll('\$', '').trim();
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  factory ClearancePayment.fromJson(Map<String, dynamic> json) {
    return ClearancePayment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      paymentNumber: json['paymentNumber']?.toString() ?? json['reference']?.toString() ?? 'Payment #001',
      clearanceRequestId: json['clearanceRequestId']?.toString() ?? '',
      description: json['description']?.toString() ?? json['title']?.toString() ?? '',
      amount: _parseAmount(json['amount'] ?? json['value']),
      currency: json['currency']?.toString() ?? 'NGN',
      status: json['status']?.toString() ?? 'Paid',
      paidAt: json['paidAt'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['paidAt'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'Wallet Balance',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'paymentNumber': paymentNumber,
        'clearanceRequestId': clearanceRequestId,
        'description': description,
        'amount': amount,
        'currency': currency,
        'status': status,
        'paidAt': paidAt.toIso8601String(),
        'paymentMethod': paymentMethod,
      };
}

/// In-request message or status update
class ClearanceMessage {
  final String id;
  final String clearanceRequestId;
  final String senderType; // 'customer', 'support', 'system'
  final String senderName;
  final String message;
  final String? attachmentUrl;
  final String? attachmentName;
  final DateTime createdAt;

  const ClearanceMessage({
    required this.id,
    this.clearanceRequestId = '',
    required this.senderType,
    required this.senderName,
    required this.message,
    this.attachmentUrl,
    this.attachmentName,
    required this.createdAt,
  });

  factory ClearanceMessage.fromJson(Map<String, dynamic> json) {
    return ClearanceMessage(
      id: json['id'] as String? ?? '',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'system',
      senderName: json['senderName'] as String? ?? 'System',
      message: json['message'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clearanceRequestId': clearanceRequestId,
        'senderType': senderType,
        'senderName': senderName,
        'message': message,
        'attachmentUrl': attachmentUrl,
        'attachmentName': attachmentName,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Audit history of status changes
class ClearanceStatusHistory {
  final String id;
  final String clearanceRequestId;
  final String status;
  final String title;
  final String message;
  final DateTime createdAt;

  const ClearanceStatusHistory({
    required this.id,
    this.clearanceRequestId = '',
    required this.status,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory ClearanceStatusHistory.fromJson(Map<String, dynamic> json) {
    return ClearanceStatusHistory(
      id: json['id'] as String? ?? '',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clearanceRequestId': clearanceRequestId,
        'status': status,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Main Customer Customs Clearance Request Model
class ClearanceRequestModel {
  final String id;
  final String requestNumber;
  final String customerId;
  final String shipmentType; // Sea, Air, Land
  final String originCountry;
  final String portOfEntry;
  final String shipmentStatus;
  final String? shippingLine;
  final String? airline;
  final String? billOfLadingNumber;
  final String? airWaybillNumber;
  final String? containerNumber;
  final DateTime? estimatedArrivalDate;
  final bool hasMissingShipmentInfo;

  final String status;
  final String deliveryPreference; // 'Deliver to me', 'I\'ll arrange pickup/delivery myself'
  final ClearanceDeliveryAddress? deliveryAddress;

  final List<ClearanceItem> items;
  final List<ClearanceDocument> documents;
  final List<ClearanceCharge> charges;
  final List<ClearancePayment> payments;
  final List<ClearanceMessage> messages;
  final List<ClearanceStatusHistory> statusHistory;

  final int? totalProductsCount;
  final double? totalValueUsd;
  final String? goodsDescription;

  final String? requiredActionNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClearanceRequestModel({
    required this.id,
    required this.requestNumber,
    this.customerId = '',
    this.shipmentType = 'Sea',
    this.originCountry = 'China',
    this.portOfEntry = 'Apapa Port',
    this.shipmentStatus = 'In transit',
    this.shippingLine,
    this.airline,
    this.billOfLadingNumber,
    this.airWaybillNumber,
    this.containerNumber,
    this.estimatedArrivalDate,
    this.hasMissingShipmentInfo = false,
    this.status = ClearanceStatus.submitted,
    this.deliveryPreference = 'Deliver to me',
    this.deliveryAddress,
    this.items = const [],
    this.documents = const [],
    this.charges = const [],
    this.payments = const [],
    this.messages = const [],
    this.statusHistory = const [],
    this.totalProductsCount,
    this.totalValueUsd,
    this.goodsDescription,
    this.requiredActionNote,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total declared value across all products
  double get totalValue {
    if (items.isNotEmpty) {
      return items.fold(0.0, (sum, item) => sum + (item.purchaseValue * item.quantity));
    }
    return totalValueUsd ?? 0.0;
  }

  /// Primary currency used in goods items
  String get primaryCurrency =>
      items.isNotEmpty ? items.first.currency : 'USD';

  /// Total goods quantity count
  double get totalQuantity {
    if (items.isNotEmpty) {
      return items.fold(0.0, (sum, item) => sum + item.quantity);
    }
    return (totalProductsCount ?? 0).toDouble();
  }

  /// Total weight if available
  double get totalWeight =>
      items.fold(0.0, (sum, item) => sum + (item.weight ?? 0.0));

  /// Total confirmed or estimated charges amount
  double get totalChargesAmount =>
      charges.fold(0.0, (sum, charge) => sum + charge.amount);

  /// Outstanding charges amount requiring payment
  double get unpaidChargesAmount => charges
      .where((c) => c.status != 'Paid' && c.status != 'Waived')
      .fold(0.0, (sum, charge) => sum + charge.amount);

  /// Check if all charges are confirmed
  bool get areChargesConfirmed =>
      charges.isNotEmpty && charges.every((c) => c.isConfirmed);

  /// Check if action is required from customer
  bool get isActionRequired =>
      status == ClearanceStatus.additionalInfoRequired ||
      documents.any((d) => d.status == 'More information required');

  /// Brief description of products for list views
  String get itemsSummary {
    if (items.isNotEmpty) {
      if (items.length == 1) return items.first.productName;
      return '${items.first.productName} + ${items.length - 1} more items';
    }
    if (goodsDescription != null && goodsDescription!.trim().isNotEmpty) {
      return goodsDescription!.trim();
    }
    if (totalProductsCount != null && totalProductsCount! > 0) {
      return '$totalProductsCount item(s) consignment';
    }
    return 'General Cargo';
  }

  ClearanceRequestModel copyWith({
    String? id,
    String? requestNumber,
    String? customerId,
    String? shipmentType,
    String? originCountry,
    String? portOfEntry,
    String? shipmentStatus,
    String? shippingLine,
    String? airline,
    String? billOfLadingNumber,
    String? airWaybillNumber,
    String? containerNumber,
    DateTime? estimatedArrivalDate,
    bool? hasMissingShipmentInfo,
    String? status,
    String? deliveryPreference,
    ClearanceDeliveryAddress? deliveryAddress,
    List<ClearanceItem>? items,
    List<ClearanceDocument>? documents,
    List<ClearanceCharge>? charges,
    List<ClearancePayment>? payments,
    List<ClearanceMessage>? messages,
    List<ClearanceStatusHistory>? statusHistory,
    int? totalProductsCount,
    double? totalValueUsd,
    String? goodsDescription,
    String? requiredActionNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClearanceRequestModel(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      customerId: customerId ?? this.customerId,
      shipmentType: shipmentType ?? this.shipmentType,
      originCountry: originCountry ?? this.originCountry,
      portOfEntry: portOfEntry ?? this.portOfEntry,
      shipmentStatus: shipmentStatus ?? this.shipmentStatus,
      shippingLine: shippingLine ?? this.shippingLine,
      airline: airline ?? this.airline,
      billOfLadingNumber: billOfLadingNumber ?? this.billOfLadingNumber,
      airWaybillNumber: airWaybillNumber ?? this.airWaybillNumber,
      containerNumber: containerNumber ?? this.containerNumber,
      estimatedArrivalDate: estimatedArrivalDate ?? this.estimatedArrivalDate,
      hasMissingShipmentInfo:
          hasMissingShipmentInfo ?? this.hasMissingShipmentInfo,
      status: status ?? this.status,
      deliveryPreference: deliveryPreference ?? this.deliveryPreference,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      documents: documents ?? this.documents,
      charges: charges ?? this.charges,
      payments: payments ?? this.payments,
      messages: messages ?? this.messages,
      statusHistory: statusHistory ?? this.statusHistory,
      totalProductsCount: totalProductsCount ?? this.totalProductsCount,
      totalValueUsd: totalValueUsd ?? this.totalValueUsd,
      goodsDescription: goodsDescription ?? this.goodsDescription,
      requiredActionNote: requiredActionNote ?? this.requiredActionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ClearanceRequestModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final rawReqNum = json['requestNumber']?.toString() ??
        json['trackingNumber']?.toString() ??
        json['reference']?.toString() ??
        json['request_number']?.toString() ??
        json['clearanceNumber']?.toString() ??
        (rawId.isNotEmpty ? 'CLR-$rawId' : 'CLR-REQUEST');

    final rawStatus = (json['status']?.toString() ?? ClearanceStatus.submitted).toUpperCase();

    final rawCreatedAt = json['createdAt'] ?? json['created_at'] ?? json['date'];
    final rawUpdatedAt = json['updatedAt'] ?? json['updated_at'] ?? rawCreatedAt;

    final parsedItems = json['items'] is List
        ? (json['items'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearanceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearanceItem>[];

    final parsedDocs = json['documents'] is List
        ? (json['documents'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearanceDocument.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearanceDocument>[];

    final parsedCharges = json['charges'] is List
        ? (json['charges'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearanceCharge.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearanceCharge>[];

    final parsedPayments = json['payments'] is List
        ? (json['payments'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearancePayment.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearancePayment>[];

    final parsedMessages = json['messages'] is List
        ? (json['messages'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearanceMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearanceMessage>[];

    final parsedHistory = json['statusHistory'] is List
        ? (json['statusHistory'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => ClearanceStatusHistory.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ClearanceStatusHistory>[];

    ClearanceDeliveryAddress? parsedAddress;
    if (json['deliveryAddress'] != null) {
      parsedAddress = ClearanceDeliveryAddress.fromJson(json['deliveryAddress']);
    }

    final totalCount = (json['totalProductsCount'] as num?)?.toInt() ??
        (json['itemsCount'] as num?)?.toInt() ??
        (parsedItems.isNotEmpty ? parsedItems.length : null);

    final totalVal = (json['totalValueUsd'] as num?)?.toDouble() ??
        (json['totalValue'] as num?)?.toDouble();

    final desc = json['goodsDescription']?.toString() ??
        json['description']?.toString() ??
        json['itemsSummary']?.toString();

    return ClearanceRequestModel(
      id: rawId,
      requestNumber: rawReqNum,
      customerId: json['customerId']?.toString() ?? json['userId']?.toString() ?? '',
      shipmentType: json['shipmentType']?.toString() ?? 'Sea',
      originCountry: json['originCountry']?.toString() ?? json['country']?.toString() ?? 'China',
      portOfEntry: json['portOfEntry']?.toString() ?? json['port']?.toString() ?? 'Apapa Port',
      shipmentStatus: json['shipmentStatus']?.toString() ?? 'In transit',
      shippingLine: json['shippingLine']?.toString(),
      airline: json['airline']?.toString(),
      billOfLadingNumber: json['billOfLadingNumber']?.toString() ?? json['blNumber']?.toString(),
      airWaybillNumber: json['airWaybillNumber']?.toString() ?? json['awbNumber']?.toString(),
      containerNumber: json['containerNumber']?.toString() ?? json['containerNo']?.toString(),
      estimatedArrivalDate: json['estimatedArrivalDate'] != null
          ? DateTime.tryParse(json['estimatedArrivalDate'].toString())
          : null,
      hasMissingShipmentInfo: json['hasMissingShipmentInfo'] == true ||
          json['hasMissingShipmentInfo']?.toString() == 'true',
      status: rawStatus,
      deliveryPreference: json['deliveryPreference']?.toString() ?? 'Deliver to me',
      deliveryAddress: parsedAddress,
      items: parsedItems,
      documents: parsedDocs,
      charges: parsedCharges,
      payments: parsedPayments,
      messages: parsedMessages,
      statusHistory: parsedHistory,
      totalProductsCount: totalCount,
      totalValueUsd: totalVal,
      goodsDescription: desc,
      requiredActionNote: json['requiredActionNote']?.toString(),
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: rawUpdatedAt != null
          ? DateTime.tryParse(rawUpdatedAt.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestNumber': requestNumber,
        'customerId': customerId,
        'shipmentType': shipmentType,
        'originCountry': originCountry,
        'portOfEntry': portOfEntry,
        'shipmentStatus': shipmentStatus,
        'shippingLine': shippingLine,
        'airline': airline,
        'billOfLadingNumber': billOfLadingNumber,
        'airWaybillNumber': airWaybillNumber,
        'containerNumber': containerNumber,
        'estimatedArrivalDate': estimatedArrivalDate?.toIso8601String(),
        'hasMissingShipmentInfo': hasMissingShipmentInfo,
        'status': status,
        'deliveryPreference': deliveryPreference,
        'deliveryAddress': deliveryAddress?.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'documents': documents.map((e) => e.toJson()).toList(),
        'charges': charges.map((e) => e.toJson()).toList(),
        'payments': payments.map((e) => e.toJson()).toList(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
        'requiredActionNote': requiredActionNote,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
