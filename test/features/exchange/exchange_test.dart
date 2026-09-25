import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/exchange/data/datasources/exchange_remote_data_source.dart';
import 'package:hamza_rmb/features/exchange/data/models/exchange_request_model.dart';
import 'package:hamza_rmb/features/exchange/data/models/saved_account_model.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late ExchangeRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://hamza-rmb.onrender.com/api/v1'));
    dataSource = ExchangeRemoteDataSourceImpl(dio);
  });

  group('RMB Exchange & Saved Accounts Models & DataSource Tests', () {
    test('SavedAccountModel parses sample response from POST and GET /exchanges/saved-accounts', () {
      final sampleJson = {
        "id": "cfcfb2d4-f950-44f8-bec4-8d57fb9815dd",
        "userId": "d9cdacfa-23ba-4bfb-a703-18e01785de80",
        "label": "hamzarmb",
        "platform": "wechat_pay",
        "accountNumber": "9011223344",
        "accountName": "Hamza RMB",
        "barcodeUrl":
            "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg",
        "isDefault": true,
        "createdAt": "2026-09-24T12:38:36.711Z",
        "updatedAt": "2026-09-24T12:38:36.711Z"
      };

      final account = SavedAccountModel.fromJson(sampleJson);

      expect(account.id, 'cfcfb2d4-f950-44f8-bec4-8d57fb9815dd');
      expect(account.userId, 'd9cdacfa-23ba-4bfb-a703-18e01785de80');
      expect(account.label, 'hamzarmb');
      expect(account.platform, 'wechat_pay');
      expect(account.accountNumber, '9011223344');
      expect(account.accountName, 'Hamza RMB');
      expect(account.barcodeUrl, contains('barcodes_1790253510845_385.jpg'));
      expect(account.isDefault, isTrue);
      expect(account.createdAt, DateTime.parse("2026-09-24T12:38:36.711Z"));
      expect(account.updatedAt, DateTime.parse("2026-09-24T12:38:36.711Z"));
    });

    test('createSavedAccount calls POST /exchanges/saved-accounts with correct JSON body', () async {
      final responsePayload = {
        "success": true,
        "data": {
          "id": "cfcfb2d4-f950-44f8-bec4-8d57fb9815dd",
          "userId": "d9cdacfa-23ba-4bfb-a703-18e01785de80",
          "label": "hamzarmb",
          "platform": "wechat_pay",
          "accountNumber": "9011223344",
          "accountName": "Hamza RMB",
          "barcodeUrl":
              "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg",
          "isDefault": true,
          "updatedAt": "2026-09-24T12:38:36.711Z",
          "createdAt": "2026-09-24T12:38:36.711Z"
        }
      };

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/exchanges/saved-accounts');
        expect(options.method, 'POST');
        expect(options.data, {
          "platform": "wechat_pay",
          "accountNumber": "9011223344",
          "accountName": "Hamza RMB",
          "label": "hamzarmb",
          "barcodeUrl":
              "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg",
          "isDefault": true,
        });

        return ResponseBody.fromString(
          jsonEncode(responsePayload),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await dataSource.createSavedAccount(
        platform: 'wechat_pay',
        accountNumber: '9011223344',
        accountName: 'Hamza RMB',
        label: 'hamzarmb',
        barcodeUrl:
            'https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg',
        isDefault: true,
      );

      expect(result.id, 'cfcfb2d4-f950-44f8-bec4-8d57fb9815dd');
      expect(result.platform, 'wechat_pay');
      expect(result.label, 'hamzarmb');
      expect(result.isDefault, isTrue);
    });

    test('fetchSavedAccounts calls GET /exchanges/saved-accounts', () async {
      final responsePayload = {
        "success": true,
        "data": [
          {
            "id": "cfcfb2d4-f950-44f8-bec4-8d57fb9815dd",
            "userId": "d9cdacfa-23ba-4bfb-a703-18e01785de80",
            "label": "hamzarmb",
            "platform": "wechat_pay",
            "accountNumber": "9011223344",
            "accountName": "Hamza RMB",
            "barcodeUrl": "https://res.cloudinary.com/dmkovtnqj/barcode.jpg",
            "isDefault": true,
            "createdAt": "2026-09-24T12:38:36.711Z",
            "updatedAt": "2026-09-24T12:38:36.711Z"
          }
        ]
      };

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/exchanges/saved-accounts');
        expect(options.method, 'GET');

        return ResponseBody.fromString(
          jsonEncode(responsePayload),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final list = await dataSource.fetchSavedAccounts();
      expect(list.length, 1);
      expect(list.first.label, 'hamzarmb');
      expect(list.first.accountNumber, '9011223344');
    });

    test('ExchangeRequestModel parses sample response from POST /exchanges', () {
      final sampleJson = {
        "id": "21edd022-6292-4e60-8348-7c97f6de16d5",
        "customerId": "HZ-20260922-2212",
        "customerName": "Mr Ab",
        "direction": "ngn_to_rmb",
        "amountNaira": 2000,
        "amountRmb": 8.89,
        "exchangeRate": 225,
        "platformFee": 5000,
        "totalNaira": 7000,
        "status": "receipt_uploaded",
        "escrowBankName": "GTBank",
        "escrowAccountNo": "0123456789",
        "escrowAccountName": "Hamza RMB Trading Escrow Ltd",
        "nairaReceiptUrl":
            "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253716/logicore/exchange-receipts/logicore/exchange-receipts_1790253716226_229.jpg",
        "rmbDestType": "wechat_pay",
        "rmbDestAccount": "9011223344",
        "rmbDestName": "Hamza RMB",
        "rmbDestQrCode":
            "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg",
        "receivingBarcodeUrl":
            "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/barcodes/logicore/barcodes_1790253510845_385.jpg",
        "requestedAt": "2026-09-24T12:41:59.580Z",
        "expiresAt": "2026-09-25T12:41:59.580Z",
        "updatedAt": "2026-09-24T12:41:59.580Z",
        "createdAt": "2026-09-24T12:41:59.580Z",
        "rmbReceiptUrl": null,
        "rejectionReason": null,
        "nairaConfirmedAt": null,
        "rmbReleasedAt": null,
        "completedAt": null
      };

      final req = ExchangeRequestModel.fromJson(sampleJson);

      expect(req.id, '21edd022-6292-4e60-8348-7c97f6de16d5');
      expect(req.customerId, 'HZ-20260922-2212');
      expect(req.customerName, 'Mr Ab');
      expect(req.direction, 'ngn_to_rmb');
      expect(req.amountNaira, 2000.0);
      expect(req.amountRmb, 8.89);
      expect(req.exchangeRate, 225.0);
      expect(req.platformFee, 5000.0);
      expect(req.totalNaira, 7000.0);
      expect(req.status, 'receipt_uploaded');
      expect(req.escrowBankName, 'GTBank');
      expect(req.escrowAccountNo, '0123456789');
      expect(req.escrowAccountName, 'Hamza RMB Trading Escrow Ltd');
      expect(req.nairaReceiptUrl, contains('exchange-receipts_1790253716226_229.jpg'));
      expect(req.rmbDestType, 'wechat_pay');
      expect(req.rmbDestAccount, '9011223344');
      expect(req.rmbDestName, 'Hamza RMB');
      expect(req.rmbDestQrCode, contains('barcodes_1790253510845_385.jpg'));
      expect(req.receivingBarcodeUrl, contains('barcodes_1790253510845_385.jpg'));
      expect(req.requestedAt, DateTime.parse("2026-09-24T12:41:59.580Z"));
    });

    test('createExchangeRequest calls POST /exchanges with correct body and returns ExchangeRequestModel',
        () async {
      final responsePayload = {
        "success": true,
        "data": {
          "id": "21edd022-6292-4e60-8348-7c97f6de16d5",
          "customerId": "HZ-20260922-2212",
          "customerName": "Mr Ab",
          "direction": "ngn_to_rmb",
          "amountNaira": 2000,
          "amountRmb": 8.89,
          "exchangeRate": 225,
          "platformFee": 5000,
          "totalNaira": 7000,
          "status": "receipt_uploaded",
          "escrowBankName": "GTBank",
          "escrowAccountNo": "0123456789",
          "escrowAccountName": "Hamza RMB Trading Escrow Ltd",
          "nairaReceiptUrl": "https://res.cloudinary.com/receipt.jpg",
          "rmbDestType": "wechat_pay",
          "rmbDestAccount": "9011223344",
          "rmbDestName": "Hamza RMB",
          "rmbDestQrCode": "https://res.cloudinary.com/barcode.jpg",
          "receivingBarcodeUrl": "https://res.cloudinary.com/barcode.jpg",
          "requestedAt": "2026-09-24T12:41:59.580Z",
          "expiresAt": "2026-09-25T12:41:59.580Z",
          "updatedAt": "2026-09-24T12:41:59.580Z",
          "createdAt": "2026-09-24T12:41:59.580Z",
        }
      };

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/exchanges');
        expect(options.method, 'POST');
        expect(options.data, {
          "amountNaira": 2000.0,
          "rmbDestType": "wechat_pay",
          "rmbDestAccount": "9011223344",
          "rmbDestName": "Hamza RMB",
          "rmbDestQrCode": "https://res.cloudinary.com/barcode.jpg",
          "receivingBarcodeUrl": "https://res.cloudinary.com/barcode.jpg",
          "nairaReceiptUrl": "https://res.cloudinary.com/receipt.jpg",
          "saveAccount": false,
        });

        return ResponseBody.fromString(
          jsonEncode(responsePayload),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await dataSource.createExchangeRequest(
        amountNaira: 2000.0,
        rmbDestType: 'wechat_pay',
        rmbDestAccount: '9011223344',
        rmbDestName: 'Hamza RMB',
        rmbDestQrCode: 'https://res.cloudinary.com/barcode.jpg',
        receivingBarcodeUrl: 'https://res.cloudinary.com/barcode.jpg',
        nairaReceiptUrl: 'https://res.cloudinary.com/receipt.jpg',
        saveAccount: false,
      );

      expect(result.id, '21edd022-6292-4e60-8348-7c97f6de16d5');
      expect(result.amountNaira, 2000.0);
      expect(result.amountRmb, 8.89);
      expect(result.status, 'receipt_uploaded');
      expect(result.escrowBankName, 'GTBank');
    });
  });
}
