class TransactionModel {
  final String id;
  final String title;
  final String type; // credit / debit / exchange / topup / deposit / withdrawal / payment
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

  bool get isCredit {
    final t = type.toLowerCase();
    return t == 'credit' ||
        t == 'topup' ||
        t == 'deposit' ||
        t == 'inflow' ||
        t.contains('credit');
  }

  DateTime get createdAt => date;
  String get description => title;

  static double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final sanitized = val.replaceAll(',', '').replaceAll('₦', '').replaceAll('\$', '').trim();
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ??
        json['createdAt'] ??
        json['created_at'] ??
        json['timestamp'] ??
        json['time'] ??
        json['updatedAt'];

    return TransactionModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['reference']?.toString() ??
          json['txRef']?.toString() ??
          '',
      title: json['title']?.toString() ??
          json['description']?.toString() ??
          json['narration']?.toString() ??
          json['notes']?.toString() ??
          json['remark']?.toString() ??
          json['reason']?.toString() ??
          'Wallet Transaction',
      type: json['type']?.toString() ??
          json['transactionType']?.toString() ??
          json['category']?.toString() ??
          json['action']?.toString() ??
          'debit',
      amount: _parseAmount(json['amount'] ?? json['value']),
      currency: json['currency']?.toString() ?? 'NGN',
      status: json['status']?.toString() ??
          json['paymentStatus']?.toString() ??
          'completed',
      reference: json['reference']?.toString() ??
          json['referenceId']?.toString() ??
          json['txRef']?.toString() ??
          json['sessionId']?.toString() ??
          json['id']?.toString(),
      date: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
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

