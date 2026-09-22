class TransactionModel {
  final String id;
  final String title;
  final String type; // credit / debit
  final double amount;
  final String currency;
  final String status;
  final String? reference;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    this.currency = 'NGN',
    this.status = 'completed',
    this.reference,
    required this.date,
  });

  bool get isCredit => type.toLowerCase() == 'credit' || type.toLowerCase() == 'topup';
  DateTime get createdAt => date;
  String get description => title;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ??
          json['description']?.toString() ??
          'Wallet Transaction',
      type: json['type']?.toString() ?? 'debit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'NGN',
      status: json['status']?.toString() ?? 'completed',
      reference: json['reference']?.toString(),
      date: json['date'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['date'] ?? json['createdAt']).toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'amount': amount,
        'currency': currency,
        'status': status,
        'reference': reference,
        'date': date.toIso8601String(),
      };
}
