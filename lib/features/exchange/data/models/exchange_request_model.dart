class ExchangeRequestModel {
  final String id;
  final String customerId;
  final double amountNaira;
  final double amountRmb;
  final double exchangeRate;
  final double platformFee;
  final double totalNaira;
  final String status;
  final String rmbDestType;
  final String rmbDestAccount;
  final String rmbDestName;
  final String? qrCodeUrl;
  final String? receiptUrl;
  final DateTime? createdAt;

  const ExchangeRequestModel({
    required this.id,
    this.customerId = '',
    required this.amountNaira,
    required this.amountRmb,
    this.exchangeRate = 215.0,
    this.platformFee = 5000.0,
    required this.totalNaira,
    this.status = 'pending',
    required this.rmbDestType,
    required this.rmbDestAccount,
    required this.rmbDestName,
    this.qrCodeUrl,
    this.receiptUrl,
    this.createdAt,
  });

  factory ExchangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      amountNaira: (json['amountNaira'] as num?)?.toDouble() ?? 0.0,
      amountRmb: (json['amountRmb'] as num?)?.toDouble() ?? 0.0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 215.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      totalNaira: (json['totalNaira'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      rmbDestType: json['rmbDestType']?.toString() ?? 'alipay',
      rmbDestAccount: json['rmbDestAccount']?.toString() ?? '',
      rmbDestName: json['rmbDestName']?.toString() ?? '',
      qrCodeUrl: json['qrCodeUrl']?.toString() ?? json['receiptUrl']?.toString(),
      receiptUrl: json['receiptUrl']?.toString() ?? json['imageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'amountNaira': amountNaira,
        'amountRmb': amountRmb,
        'exchangeRate': exchangeRate,
        'platformFee': platformFee,
        'totalNaira': totalNaira,
        'status': status,
        'rmbDestType': rmbDestType,
        'rmbDestAccount': rmbDestAccount,
        'rmbDestName': rmbDestName,
        'qrCodeUrl': qrCodeUrl,
        'receiptUrl': receiptUrl,
        'createdAt': createdAt?.toIso8601String(),
      };
}
