class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double availableBalance;
  final String currency;
  final String bankName;
  final String accountNumber;
  final String accountName;

  const WalletModel({
    required this.id,
    this.userId = '',
    this.balance = 0.0,
    this.availableBalance = 0.0,
    this.currency = 'NGN',
    this.bankName = 'Wema Bank',
    this.accountNumber = '9876543210',
    this.accountName = 'Hamza Logistics Ltd',
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0.0,
      currency: json['currency']?.toString() ?? 'NGN',
      bankName: json['bankName']?.toString() ?? 'Wema Bank',
      accountNumber: json['accountNumber']?.toString() ?? '9876543210',
      accountName: json['accountName']?.toString() ?? 'Hamza Logistics Ltd',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'balance': balance,
        'availableBalance': availableBalance,
        'currency': currency,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountName': accountName,
      };
}

