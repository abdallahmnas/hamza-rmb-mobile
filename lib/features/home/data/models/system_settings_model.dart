class SystemSettingsModel {
  final double cnyExchangeRate;
  final double usdExchangeRate;
  final double airFreightRatePerKg;
  final double seaFreightRatePerCbm;
  final double seaFreightRatePerKg;
  final double minAirFreightKg;
  final double minSeaFreightCbm;
  final double buyForMeFeePercent;
  final double buyForMeFixedFee;
  final String ngnEscrowBankName;
  final String ngnEscrowAccountNo;
  final String ngnEscrowAccountName;
  final String companyName;
  final String chinaAirCargoAddressCn;
  final String nigeriaOfficeAddress;

  const SystemSettingsModel({
    this.cnyExchangeRate = 215.0,
    this.usdExchangeRate = 1550.0,
    this.airFreightRatePerKg = 12500.0,
    this.seaFreightRatePerCbm = 450000.0,
    this.seaFreightRatePerKg = 3500.0,
    this.minAirFreightKg = 1.0,
    this.minSeaFreightCbm = 0.1,
    this.buyForMeFeePercent = 5.0,
    this.buyForMeFixedFee = 1000.0,
    this.ngnEscrowBankName = 'GTBank',
    this.ngnEscrowAccountNo = '0123456789',
    this.ngnEscrowAccountName = 'Hamza RMB Trading Escrow Ltd',
    this.companyName = 'HAMZA RMB GLOBAL COMPANY LTD',
    this.chinaAirCargoAddressCn = '义乌市稠州北路国贸大厦6楼602',
    this.nigeriaOfficeAddress =
        'No. 08 Gwarzo Road Beside Shopwell, Gwale Kano State, Nigeria',
  });

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      cnyExchangeRate: (json['cnyExchangeRate'] as num?)?.toDouble() ?? 215.0,
      usdExchangeRate: (json['usdExchangeRate'] as num?)?.toDouble() ?? 1550.0,
      airFreightRatePerKg:
          (json['airFreightRatePerKg'] as num?)?.toDouble() ?? 12500.0,
      seaFreightRatePerCbm:
          (json['seaFreightRatePerCbm'] as num?)?.toDouble() ?? 450000.0,
      seaFreightRatePerKg:
          (json['seaFreightRatePerKg'] as num?)?.toDouble() ?? 3500.0,
      minAirFreightKg:
          (json['minAirFreightKg'] as num?)?.toDouble() ?? 1.0,
      minSeaFreightCbm:
          (json['minSeaFreightCbm'] as num?)?.toDouble() ?? 0.1,
      buyForMeFeePercent:
          (json['buyForMeFeePercent'] as num?)?.toDouble() ?? 5.0,
      buyForMeFixedFee:
          (json['buyForMeFixedFee'] as num?)?.toDouble() ?? 1000.0,
      ngnEscrowBankName:
          json['ngnEscrowBankName']?.toString() ?? 'GTBank',
      ngnEscrowAccountNo:
          json['ngnEscrowAccountNo']?.toString() ?? '0123456789',
      ngnEscrowAccountName: json['ngnEscrowAccountName']?.toString() ??
          'Hamza RMB Trading Escrow Ltd',
      companyName: json['companyName']?.toString() ??
          'HAMZA RMB GLOBAL COMPANY LTD',
      chinaAirCargoAddressCn: json['chinaAirCargoAddressCn']?.toString() ??
          '义乌市稠州北路国贸大厦6楼602',
      nigeriaOfficeAddress: json['nigeriaOfficeAddress']?.toString() ??
          'No. 08 Gwarzo Road Beside Shopwell, Gwale Kano State, Nigeria',
    );
  }

  Map<String, dynamic> toJson() => {
        'cnyExchangeRate': cnyExchangeRate,
        'usdExchangeRate': usdExchangeRate,
        'airFreightRatePerKg': airFreightRatePerKg,
        'seaFreightRatePerCbm': seaFreightRatePerCbm,
        'seaFreightRatePerKg': seaFreightRatePerKg,
        'minAirFreightKg': minAirFreightKg,
        'minSeaFreightCbm': minSeaFreightCbm,
        'buyForMeFeePercent': buyForMeFeePercent,
        'buyForMeFixedFee': buyForMeFixedFee,
        'ngnEscrowBankName': ngnEscrowBankName,
        'ngnEscrowAccountNo': ngnEscrowAccountNo,
        'ngnEscrowAccountName': ngnEscrowAccountName,
        'companyName': companyName,
        'chinaAirCargoAddressCn': chinaAirCargoAddressCn,
        'nigeriaOfficeAddress': nigeriaOfficeAddress,
      };
}
