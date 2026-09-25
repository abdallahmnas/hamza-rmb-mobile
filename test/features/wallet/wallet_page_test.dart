import 'dart:io';
import 'dart:typed_data';
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
import 'package:hamza_rmb/features/wallet/views/wallet_page.dart';
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
      WalletDepositModel(
        id: 'dep-1',
        amount: amount,
        senderName: senderName,
        sessionId: sessionId,
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

  group('WalletPage Widget Tests', () {
    testWidgets('renders balance card, quick actions, and currency accounts', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'cache_wallet':
            '{"id":"wlt-1","balance":1250000.0,"availableBalance":1250000.0}',
      });
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
            home: WalletPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and title
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Verify balance container
      expect(find.text('TOTAL ESTIMATED BALANCE'), findsOneWidget);
      expect(find.text('1,250,000'), findsOneWidget);
      expect(find.textContaining('CNY'), findsWidgets);

      // Verify actions
      expect(find.text('Fund'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Exchange'), findsWidgets);
      expect(find.text('Transfer'), findsOneWidget);

      // Verify currency accounts
      expect(find.text('Currency Accounts'), findsOneWidget);
      expect(find.text('CNY'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('NGN'), findsOneWidget);

      // Verify recent transactions
      expect(find.text('Recent Transactions'), findsOneWidget);
    });

    testWidgets('toggles balance visibility when eye button is tapped', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'cache_wallet':
            '{"id":"wlt-1","balance":1250000.0,"availableBalance":1250000.0}',
      });
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
            home: WalletPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial visible state
      expect(find.text('1,250,000'), findsOneWidget);

      // Find and tap eye button
      final eyeIcon = find.byIcon(Icons.visibility_outlined);
      expect(eyeIcon, findsOneWidget);
      await tester.tap(eyeIcon);
      await tester.pump();

      // Now hidden
      expect(find.text('1,250,000'), findsNothing);
      expect(find.text('••••••••••••'), findsOneWidget);
    });
  });
}
