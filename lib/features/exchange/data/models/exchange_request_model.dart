class ExchangeRequestModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String direction;
  final double amountNaira;
  final double amountRmb;
  final double exchangeRate;
  final double platformFee;
  final double totalNaira;
  final String status;
  final String? escrowBankName;
  final String? escrowAccountNo;
  final String? escrowAccountName;
  final String? nairaReceiptUrl;
  final String rmbDestType;
  final String rmbDestAccount;
  final String rmbDestName;
  final String? rmbDestQrCode;
  final String? receivingBarcodeUrl;
  final DateTime? requestedAt;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? rmbReceiptUrl;
  final String? rejectionReason;
  final DateTime? nairaConfirmedAt;
  final DateTime? rmbReleasedAt;
  final DateTime? completedAt;

  const ExchangeRequestModel({
    required this.id,
    this.customerId = '',
    this.customerName,
    this.direction = 'ngn_to_rmb',
    required this.amountNaira,
    required this.amountRmb,
    this.exchangeRate = 225.0,
    this.platformFee = 5000.0,
    required this.totalNaira,
    this.status = 'pending',
    this.escrowBankName,
    this.escrowAccountNo,
    this.escrowAccountName,
    this.nairaReceiptUrl,
    required this.rmbDestType,
    required this.rmbDestAccount,
    required this.rmbDestName,
    this.rmbDestQrCode,
    this.receivingBarcodeUrl,
    this.requestedAt,
    this.expiresAt,
    this.updatedAt,
    this.createdAt,
    this.rmbReceiptUrl,
    this.rejectionReason,
    this.nairaConfirmedAt,
    this.rmbReleasedAt,
    this.completedAt,
  });

  // Backward compatibility getters
  String? get qrCodeUrl => rmbDestQrCode ?? receivingBarcodeUrl;
  String? get receiptUrl => nairaReceiptUrl;

  ExchangeRequestModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? direction,
    double? amountNaira,
    double? amountRmb,
    double? exchangeRate,
    double? platformFee,
    double? totalNaira,
    String? status,
    String? escrowBankName,
    String? escrowAccountNo,
    String? escrowAccountName,
    String? nairaReceiptUrl,
    String? rmbDestType,
    String? rmbDestAccount,
    String? rmbDestName,
    String? rmbDestQrCode,
    String? receivingBarcodeUrl,
    DateTime? requestedAt,
    DateTime? expiresAt,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? rmbReceiptUrl,
    String? rejectionReason,
    DateTime? nairaConfirmedAt,
    DateTime? rmbReleasedAt,
    DateTime? completedAt,
  }) {
    return ExchangeRequestModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      direction: direction ?? this.direction,
      amountNaira: amountNaira ?? this.amountNaira,
      amountRmb: amountRmb ?? this.amountRmb,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      platformFee: platformFee ?? this.platformFee,
      totalNaira: totalNaira ?? this.totalNaira,
      status: status ?? this.status,
      escrowBankName: escrowBankName ?? this.escrowBankName,
      escrowAccountNo: escrowAccountNo ?? this.escrowAccountNo,
      escrowAccountName: escrowAccountName ?? this.escrowAccountName,
      nairaReceiptUrl: nairaReceiptUrl ?? this.nairaReceiptUrl,
      rmbDestType: rmbDestType ?? this.rmbDestType,
      rmbDestAccount: rmbDestAccount ?? this.rmbDestAccount,
      rmbDestName: rmbDestName ?? this.rmbDestName,
      rmbDestQrCode: rmbDestQrCode ?? this.rmbDestQrCode,
      receivingBarcodeUrl: receivingBarcodeUrl ?? this.receivingBarcodeUrl,
      requestedAt: requestedAt ?? this.requestedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rmbReceiptUrl: rmbReceiptUrl ?? this.rmbReceiptUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      nairaConfirmedAt: nairaConfirmedAt ?? this.nairaConfirmedAt,
      rmbReleasedAt: rmbReleasedAt ?? this.rmbReleasedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory ExchangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString(),
      direction: json['direction']?.toString() ?? 'ngn_to_rmb',
      amountNaira: (json['amountNaira'] as num?)?.toDouble() ?? 0.0,
      amountRmb: (json['amountRmb'] as num?)?.toDouble() ?? 0.0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 225.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      totalNaira: (json['totalNaira'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      escrowBankName: json['escrowBankName']?.toString(),
      escrowAccountNo: json['escrowAccountNo']?.toString(),
      escrowAccountName: json['escrowAccountName']?.toString(),
      nairaReceiptUrl: json['nairaReceiptUrl']?.toString() ??
          json['receiptUrl']?.toString() ??
          json['imageUrl']?.toString(),
      rmbDestType: json['rmbDestType']?.toString() ?? 'wechat_pay',
      rmbDestAccount: json['rmbDestAccount']?.toString() ?? '',
      rmbDestName: json['rmbDestName']?.toString() ?? '',
      rmbDestQrCode: json['rmbDestQrCode']?.toString() ??
          json['qrCodeUrl']?.toString() ??
          json['receivingBarcodeUrl']?.toString(),
      receivingBarcodeUrl: json['receivingBarcodeUrl']?.toString() ??
          json['rmbDestQrCode']?.toString() ??
          json['barcodeUrl']?.toString(),
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      rmbReceiptUrl: json['rmbReceiptUrl']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      nairaConfirmedAt: json['nairaConfirmedAt'] != null
          ? DateTime.tryParse(json['nairaConfirmedAt'].toString())
          : null,
      rmbReleasedAt: json['rmbReleasedAt'] != null
          ? DateTime.tryParse(json['rmbReleasedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        if (customerName != null) 'customerName': customerName,
        'direction': direction,
        'amountNaira': amountNaira,
        'amountRmb': amountRmb,
        'exchangeRate': exchangeRate,
        'platformFee': platformFee,
        'totalNaira': totalNaira,
        'status': status,
        if (escrowBankName != null) 'escrowBankName': escrowBankName,
        if (escrowAccountNo != null) 'escrowAccountNo': escrowAccountNo,
        if (escrowAccountName != null) 'escrowAccountName': escrowAccountName,
        if (nairaReceiptUrl != null) 'nairaReceiptUrl': nairaReceiptUrl,
        'rmbDestType': rmbDestType,
        'rmbDestAccount': rmbDestAccount,
        'rmbDestName': rmbDestName,
        if (rmbDestQrCode != null) 'rmbDestQrCode': rmbDestQrCode,
        if (receivingBarcodeUrl != null)
          'receivingBarcodeUrl': receivingBarcodeUrl,
        if (requestedAt != null) 'requestedAt': requestedAt!.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (rmbReceiptUrl != null) 'rmbReceiptUrl': rmbReceiptUrl,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (nairaConfirmedAt != null)
          'nairaConfirmedAt': nairaConfirmedAt!.toIso8601String(),
        if (rmbReleasedAt != null)
          'rmbReleasedAt': rmbReleasedAt!.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      };
}
