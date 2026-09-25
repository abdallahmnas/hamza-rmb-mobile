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
    double parseDouble(dynamic v, [double def = 0.0]) {
      if (v == null) return def;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? def;
    }

    final bal = parseDouble(
      json['balance'],
      parseDouble(json['availableBalance'], parseDouble(json['walletBalance'])),
    );
    final availBal = parseDouble(json['availableBalance'], bal);

    return WalletModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user']?.toString() ?? '',
      balance: bal,
      availableBalance: availBal,
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

