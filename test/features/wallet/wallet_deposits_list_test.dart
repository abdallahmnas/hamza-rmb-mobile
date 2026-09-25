import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:hamza_rmb/features/wallet/data/models/wallet_deposit_model.dart';

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
  late WalletRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://hamza-rmb.onrender.com/api/v1'));
    dataSource = WalletRemoteDataSourceImpl(dio);
  });

  group('Wallet Recent Deposits API & Model Tests', () {
    test('WalletDepositModel parses sample response from GET /api/v1/wallet/deposits', () {
      final sampleJson = {
        "id": "5379cdb1-478b-4f4e-89f8-c259845d9ecc",
        "userId": "d9cdacfa-23ba-4bfb-a703-18e01785de80",
        "customerId": "HZ-20260922-2212",
        "customerName": "Mr Ab",
        "amount": 120000,
        "currency": "NGN",
        "senderName": "Abdul",
        "paymentReceiptUrl":
            "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790251594/wallet_receipts/receipt_1790251594383_685.jpg",
        "sessionId": "1214",
        "status": "pending",
        "rejectionReason": null,
        "reviewedBy": null,
        "reviewedAt": null,
        "createdAt": "2026-09-24T12:06:35.528Z",
        "updatedAt": "2026-09-24T12:06:35.528Z"
      };

      final deposit = WalletDepositModel.fromJson(sampleJson);

      expect(deposit.id, '5379cdb1-478b-4f4e-89f8-c259845d9ecc');
      expect(deposit.userId, 'd9cdacfa-23ba-4bfb-a703-18e01785de80');
      expect(deposit.customerId, 'HZ-20260922-2212');
      expect(deposit.customerName, 'Mr Ab');
      expect(deposit.amount, 120000.0);
      expect(deposit.currency, 'NGN');
      expect(deposit.senderName, 'Abdul');
      expect(deposit.paymentReceiptUrl, contains('receipt_1790251594383_685.jpg'));
      expect(deposit.sessionId, '1214');
      expect(deposit.status, 'pending');
      expect(deposit.rejectionReason, isNull);
      expect(deposit.reviewedBy, isNull);
      expect(deposit.reviewedAt, isNull);
      expect(deposit.createdAt, DateTime.parse("2026-09-24T12:06:35.528Z"));
      expect(deposit.updatedAt, DateTime.parse("2026-09-24T12:06:35.528Z"));
    });

    test('fetchDeposits calls GET /wallet/deposits and returns list of WalletDepositModel',
        () async {
      final responsePayload = {
        "success": true,
        "data": [
          {
            "id": "5379cdb1-478b-4f4e-89f8-c259845d9ecc",
            "userId": "d9cdacfa-23ba-4bfb-a703-18e01785de80",
            "customerId": "HZ-20260922-2212",
            "customerName": "Mr Ab",
            "amount": 120000,
            "currency": "NGN",
            "senderName": "Abdul",
            "paymentReceiptUrl":
                "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790251594/wallet_receipts/receipt_1790251594383_685.jpg",
            "sessionId": "1214",
            "status": "pending",
            "rejectionReason": null,
            "reviewedBy": null,
            "reviewedAt": null,
            "createdAt": "2026-09-24T12:06:35.528Z",
            "updatedAt": "2026-09-24T12:06:35.528Z"
          }
        ]
      };

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/wallet/deposits');
        expect(options.method, 'GET');

        return ResponseBody.fromString(
          jsonEncode(responsePayload),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final list = await dataSource.fetchDeposits();

      expect(list.length, 1);
      final item = list.first;
      expect(item.id, '5379cdb1-478b-4f4e-89f8-c259845d9ecc');
      expect(item.amount, 120000.0);
      expect(item.senderName, 'Abdul');
      expect(item.sessionId, '1214');
      expect(item.status, 'pending');
    });
  });
}
