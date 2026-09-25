class WalletDepositModel {
  final String id;
  final String userId;
  final String customerId;
  final String customerName;
  final double amount;
  final String currency;
  final String senderName;
  final String paymentReceiptUrl;
  final String sessionId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const WalletDepositModel({
    required this.id,
    this.userId = '',
    this.customerId = '',
    this.customerName = '',
    required this.amount,
    this.currency = 'NGN',
    required this.senderName,
    this.paymentReceiptUrl = '',
    required this.sessionId,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory WalletDepositModel.fromJson(Map<String, dynamic> json) {
    return WalletDepositModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'NGN',
      senderName: json['senderName']?.toString() ?? '',
      paymentReceiptUrl: json['paymentReceiptUrl']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason']?.toString(),
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'customerId': customerId,
        'customerName': customerName,
        'amount': amount,
        'currency': currency,
        'senderName': senderName,
        'paymentReceiptUrl': paymentReceiptUrl,
        'sessionId': sessionId,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt?.toIso8601String(),
      };
}
