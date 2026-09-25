import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/storage/local_storage.dart';
import 'package:hamza_rmb/features/home/data/datasources/public_metadata_remote_data_source.dart';
import 'package:hamza_rmb/features/home/data/models/banner_model.dart';
import 'package:hamza_rmb/features/home/data/models/delivery_vehicle_model.dart';
import 'package:hamza_rmb/features/home/data/models/exchange_rate_model.dart';
import 'package:hamza_rmb/features/home/data/models/facility_model.dart';
import 'package:hamza_rmb/features/home/data/models/system_settings_model.dart';
import 'package:hamza_rmb/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:hamza_rmb/features/wallet/data/models/transaction_model.dart';
import 'package:hamza_rmb/features/wallet/data/models/wallet_deposit_model.dart';
import 'package:hamza_rmb/features/wallet/data/models/wallet_model.dart';
import 'package:hamza_rmb/features/wallet/views/fund_wallet_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWalletRemoteDataSource implements WalletRemoteDataSource {
  @override
  Future<WalletModel> fetchWallet() async =>
      const WalletModel(id: 'wlt-1', balance: 1250000.0);

  @override
  Future<List<TransactionModel>> fetchTransactions() async => [];

  @override
  Future<List<WalletDepositModel>> fetchDeposits() async => [];

  @override
  Future<void> topupWallet({
    required double amount,
    required String paymentMethod,
    required String reference,
    String? imageUrl,
  }) async {}

  @override
  Future<WalletDepositModel> depositWallet({
    required double amount,
    required String senderName,
    required String sessionId,
    File? receiptFile,
    Uint8List? receiptBytes,
    String? receiptFileName,
  }) async =>
      const WalletDepositModel(
        id: 'dep-1',
        amount: 10000,
        senderName: 'Test',
        sessionId: '123',
        status: 'pending',
      );
}

class MockPublicMetadataRemoteDataSource
    implements PublicMetadataRemoteDataSource {
  @override
  Future<List<BannerModel>> fetchBanners() async => [];

  @override
  Future<List<DeliveryVehicleModel>> fetchDeliveryVehicles() async => [];

  @override
  Future<ExchangeRateModel> fetchExchangeRate() async =>
      const ExchangeRateModel(buyRate: 213, sellRate: 217, platformRate: 215);

  @override
  Future<SystemSettingsModel> fetchSettings() async =>
      const SystemSettingsModel(cnyExchangeRate: 215.0);

  @override
  Future<List<FacilityModel>> fetchFacilities() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletDepositModel Tests', () {
    test('parses exact API deposit response correctly', () {
      final jsonResponse = {
        'success': true,
        'data': {
          'id': '5379cdb1-478b-4f4e-89f8-c259845d9ecc',
          'userId': 'd9cdacfa-23ba-4bfb-a703-18e01785de80',
          'customerId': 'HZ-20260922-2212',
          'customerName': 'Mr Ab',
          'amount': 120000,
          'currency': 'NGN',
          'senderName': 'Abdul',
          'paymentReceiptUrl':
              'https://res.cloudinary.com/dmkovtnqj/image/upload/v1790251594/wallet_receipts/receipt_1790251594383_685.jpg',
          'sessionId': '1214',
          'status': 'pending',
          'updatedAt': '2026-09-24T12:06:35.528Z',
          'createdAt': '2026-09-24T12:06:35.528Z',
          'rejectionReason': null,
          'reviewedBy': null,
          'reviewedAt': null
        }
      };

      final data = jsonResponse['data'] as Map<String, dynamic>;
      final model = WalletDepositModel.fromJson(data);

      expect(model.id, equals('5379cdb1-478b-4f4e-89f8-c259845d9ecc'));
      expect(model.userId, equals('d9cdacfa-23ba-4bfb-a703-18e01785de80'));
      expect(model.customerId, equals('HZ-20260922-2212'));
      expect(model.customerName, equals('Mr Ab'));
      expect(model.amount, equals(120000.0));
      expect(model.currency, equals('NGN'));
      expect(model.senderName, equals('Abdul'));
      expect(
        model.paymentReceiptUrl,
        equals(
          'https://res.cloudinary.com/dmkovtnqj/image/upload/v1790251594/wallet_receipts/receipt_1790251594383_685.jpg',
        ),
      );
      expect(model.sessionId, equals('1214'));
      expect(model.status, equals('pending'));
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
      expect(model.rejectionReason, isNull);

      final serialized = model.toJson();
      expect(serialized['id'], equals(model.id));
      expect(serialized['amount'], equals(120000.0));
      expect(serialized['senderName'], equals('Abdul'));
      expect(serialized['sessionId'], equals('1214'));
    });
  });

  group('WalletRemoteDataSource depositWallet Tests', () {
    test('sends POST /v1/wallet/deposit multipart form-data request', () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://hamza-rmb.onrender.com/api/v1',
        ),
      );

      RequestOptions? capturedRequest;
      dynamic capturedData;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            capturedData = options.data;

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'data': {
                    'id': '5379cdb1-478b-4f4e-89f8-c259845d9ecc',
                    'userId': 'd9cdacfa-23ba-4bfb-a703-18e01785de80',
                    'customerId': 'HZ-20260922-2212',
                    'customerName': 'Mr Ab',
                    'amount': 120000,
                    'currency': 'NGN',
                    'senderName': 'Abdul',
                    'paymentReceiptUrl':
                        'https://res.cloudinary.com/dmkovtnqj/image/upload/v1790251594/wallet_receipts/receipt_1790251594383_685.jpg',
                    'sessionId': '1214',
                    'status': 'pending',
                    'updatedAt': '2026-09-24T12:06:35.528Z',
                    'createdAt': '2026-09-24T12:06:35.528Z'
                  }
                },
              ),
            );
          },
        ),
      );

      final dataSource = WalletRemoteDataSourceImpl(dio);

      final receiptBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await dataSource.depositWallet(
        amount: 120000,
        senderName: 'Abdul',
        sessionId: '1214',
        receiptBytes: receiptBytes,
        receiptFileName: 'test_receipt.jpg',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, equals('POST'));
      expect(capturedRequest!.path, equals('/wallet/deposit'));

      // Check FormData
      expect(capturedData, isA<FormData>());
      final formData = capturedData as FormData;

      // Verify fields
      final fields = {for (var e in formData.fields) e.key: e.value};
      expect(fields['amount'], equals('120000'));
      expect(fields['senderName'], equals('Abdul'));
      expect(fields['sessionId'], equals('1214'));

      // Verify files
      expect(formData.files.any((f) => f.key == 'receipt'), isTrue);
      final receiptFile = formData.files.firstWhere((f) => f.key == 'receipt');
      expect(receiptFile.value.filename, equals('test_receipt.jpg'));

      // Verify returned model
      expect(result.id, equals('5379cdb1-478b-4f4e-89f8-c259845d9ecc'));
      expect(result.amount, equals(120000));
      expect(result.senderName, equals('Abdul'));
      expect(result.sessionId, equals('1214'));
      expect(result.status, equals('pending'));
    });
  });

  group('FundWalletPage Widget Tests', () {
    testWidgets('renders all deposit fields including Sender Name and Session ID', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            walletRemoteDataSourceProvider
                .overrideWithValue(MockWalletRemoteDataSource()),
            publicMetadataRemoteDataSourceProvider
                .overrideWithValue(MockPublicMetadataRemoteDataSource()),
          ],
          child: const MaterialApp(
            home: FundWalletPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Fund Wallet'), findsOneWidget);

      // Section 1: Amount
      expect(find.text('1. Enter Funding Amount'), findsOneWidget);
      expect(find.text('Top-up Amount (NGN)'), findsOneWidget);

      // Section 2: Payment Method
      expect(find.text('2. Payment Method'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);

      // Section 3: Transfer to Escrow Account
      expect(find.text('3. Transfer to Escrow Account'), findsOneWidget);

      // Section 4: Transfer Verification Details
      expect(find.text('4. Transfer Verification Details'), findsOneWidget);
      expect(find.text('Sender Account Name *'), findsOneWidget);
      expect(find.text('Session ID / Transaction Ref *'), findsOneWidget);

      // Section 5: Proof of Payment Upload
      expect(find.text('5. Upload Payment Screenshot *'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);

      // Submit Button
      expect(find.textContaining('Confirm & Submit'), findsOneWidget);
    });
  });
}
