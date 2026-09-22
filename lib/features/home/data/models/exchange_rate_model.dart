class ExchangeRateModel {
  final double buyRate;
  final double sellRate;
  final double platformRate;

  const ExchangeRateModel({
    this.buyRate = 213.0,
    this.sellRate = 217.0,
    this.platformRate = 215.0,
  });

  double get rate => platformRate;


  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      buyRate: (json['buyRate'] as num?)?.toDouble() ?? 213.0,
      sellRate: (json['sellRate'] as num?)?.toDouble() ?? 217.0,
      platformRate: (json['platformRate'] as num?)?.toDouble() ??
          (json['rate'] as num?)?.toDouble() ??
          215.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'buyRate': buyRate,
        'sellRate': sellRate,
        'platformRate': platformRate,
      };
}
