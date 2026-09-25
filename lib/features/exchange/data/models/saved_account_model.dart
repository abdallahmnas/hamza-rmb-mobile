class SavedAccountModel {
  final String id;
  final String? userId;
  final String label;
  final String platform;
  final String accountNumber;
  final String accountName;
  final String barcodeUrl;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedAccountModel({
    required this.id,
    this.userId,
    required this.label,
    required this.platform,
    required this.accountNumber,
    required this.accountName,
    required this.barcodeUrl,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  SavedAccountModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? platform,
    String? accountNumber,
    String? accountName,
    String? barcodeUrl,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      platform: platform ?? this.platform,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      barcodeUrl: barcodeUrl ?? this.barcodeUrl,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SavedAccountModel.fromJson(Map<String, dynamic> json) {
    return SavedAccountModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      label: json['label']?.toString() ?? '',
      platform: json['platform']?.toString() ?? 'alipay',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      barcodeUrl: json['barcodeUrl']?.toString() ??
          json['rmbDestQrCode']?.toString() ??
          json['receivingBarcodeUrl']?.toString() ??
          '',
      isDefault: json['isDefault'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (userId != null) 'userId': userId,
        'label': label,
        'platform': platform,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'barcodeUrl': barcodeUrl,
        'isDefault': isDefault,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  String get uniqueKey => id.isNotEmpty ? id : '${platform}_$accountNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAccountModel &&
          runtimeType == other.runtimeType &&
          uniqueKey == other.uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}
