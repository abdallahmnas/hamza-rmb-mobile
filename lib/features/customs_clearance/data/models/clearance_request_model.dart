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

  factory ClearanceDeliveryAddress.fromJson(Map<String, dynamic> json) {
    return ClearanceDeliveryAddress(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      instructions: json['instructions'] as String?,
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

  factory ClearanceItem.fromJson(Map<String, dynamic> json) {
    return ClearanceItem(
      id: json['id'] as String? ?? '',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General Goods',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'pieces',
      purchaseValue: (json['purchaseValue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      countryOfManufacture: json['countryOfManufacture'] as String? ?? 'China',
      weight: (json['weight'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      hsCode: json['hsCode'] as String?,
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
      id: json['id'] as String? ?? '',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'Uploaded',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isNotAvailable: json['isNotAvailable'] as bool? ?? false,
      note: json['note'] as String?,
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

  factory ClearanceCharge.fromJson(Map<String, dynamic> json) {
    return ClearanceCharge(
      id: json['id'] as String? ?? '',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      category: json['category'] as String? ?? 'Service Charges',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      status: json['status'] as String? ?? 'Pending',
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

  factory ClearancePayment.fromJson(Map<String, dynamic> json) {
    return ClearancePayment(
      id: json['id'] as String? ?? '',
      paymentNumber: json['paymentNumber'] as String? ?? 'Payment #001',
      clearanceRequestId: json['clearanceRequestId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      status: json['status'] as String? ?? 'Paid',
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'Wallet Balance',
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
    this.requiredActionNote,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total declared value across all products
  double get totalValue =>
      items.fold(0.0, (sum, item) => sum + (item.purchaseValue * item.quantity));

  /// Primary currency used in goods items
  String get primaryCurrency =>
      items.isNotEmpty ? items.first.currency : 'USD';

  /// Total goods quantity count
  double get totalQuantity =>
      items.fold(0.0, (sum, item) => sum + item.quantity);

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
    if (items.isEmpty) return 'General Cargo';
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} + ${items.length - 1} more items';
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
      requiredActionNote: requiredActionNote ?? this.requiredActionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ClearanceRequestModel.fromJson(Map<String, dynamic> json) {
    return ClearanceRequestModel(
      id: json['id'] as String? ?? '',
      requestNumber: json['requestNumber'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      shipmentType: json['shipmentType'] as String? ?? 'Sea',
      originCountry: json['originCountry'] as String? ?? 'China',
      portOfEntry: json['portOfEntry'] as String? ?? 'Apapa Port',
      shipmentStatus: json['shipmentStatus'] as String? ?? 'In transit',
      shippingLine: json['shippingLine'] as String?,
      airline: json['airline'] as String?,
      billOfLadingNumber: json['billOfLadingNumber'] as String?,
      airWaybillNumber: json['airWaybillNumber'] as String?,
      containerNumber: json['containerNumber'] as String?,
      estimatedArrivalDate: json['estimatedArrivalDate'] != null
          ? DateTime.tryParse(json['estimatedArrivalDate'].toString())
          : null,
      hasMissingShipmentInfo: json['hasMissingShipmentInfo'] as bool? ?? false,
      status: json['status'] as String? ?? ClearanceStatus.submitted,
      deliveryPreference:
          json['deliveryPreference'] as String? ?? 'Deliver to me',
      deliveryAddress: json['deliveryAddress'] != null
          ? ClearanceDeliveryAddress.fromJson(
              json['deliveryAddress'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ClearanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map(
                  (e) => ClearanceDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      charges: (json['charges'] as List<dynamic>?)
              ?.map((e) => ClearanceCharge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => ClearancePayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ClearanceMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) =>
                  ClearanceStatusHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiredActionNote: json['requiredActionNote'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
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
