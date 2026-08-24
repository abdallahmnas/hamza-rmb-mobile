import 'dart:io';

/// Data model to pass exchange form data between the Exchange
/// and Exchange Review screens via GoRouter's `extra` parameter.
class ExchangeReviewData {
  final String sendAmount;
  final String receiveAmount;
  final String sendCurrency;
  final String receiveCurrency;
  final String exchangeRate;
  final String selectedPlatform;
  final String beneficiaryName;
  final String accountId;
  final File? receiptImage;

  const ExchangeReviewData({
    required this.sendAmount,
    required this.receiveAmount,
    required this.sendCurrency,
    required this.receiveCurrency,
    required this.exchangeRate,
    required this.selectedPlatform,
    required this.beneficiaryName,
    required this.accountId,
    this.receiptImage,
  });

  ExchangeReviewData copyWith({
    String? sendAmount,
    String? receiveAmount,
    String? sendCurrency,
    String? receiveCurrency,
    String? exchangeRate,
    String? selectedPlatform,
    String? beneficiaryName,
    String? accountId,
    File? receiptImage,
    bool clearReceiptImage = false,
  }) {
    return ExchangeReviewData(
      sendAmount: sendAmount ?? this.sendAmount,
      receiveAmount: receiveAmount ?? this.receiveAmount,
      sendCurrency: sendCurrency ?? this.sendCurrency,
      receiveCurrency: receiveCurrency ?? this.receiveCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      selectedPlatform: selectedPlatform ?? this.selectedPlatform,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      accountId: accountId ?? this.accountId,
      receiptImage:
          clearReceiptImage ? null : (receiptImage ?? this.receiptImage),
    );
  }
}
