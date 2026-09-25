import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/storage/local_storage.dart';
import 'package:hamza_rmb/features/procurement/data/datasources/procurement_remote_data_source.dart';
import 'package:hamza_rmb/features/procurement/data/models/procurement_request_model.dart';
import 'package:hamza_rmb/features/procurement/views/buy_for_me_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProcurementRemoteDataSource implements ProcurementRemoteDataSource {
  ProcurementRequestModel? lastSubmittedRequest;

  @override
  Future<ProcurementRequestModel> submitRequest({
    required String productUrl,
    required int quantity,
    required String specifications,
    String? notes,
  }) async {
    final model = ProcurementRequestModel(
      id: 'proc-test-123',
      productUrl: productUrl,
      quantity: quantity,
      specifications: specifications,
      notes: notes,
    );
    lastSubmittedRequest = model;
    return model;
  }

  @override
  Future<List<ProcurementRequestModel>> fetchRequests() async => [];

  @override
  Future<void> approveQuote(String id) async {}
}

void main() {
  late MockProcurementRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProcurementRemoteDataSource();
  });

  testWidgets('BuyForMePage renders description field with sample hint "Please confirm stock"', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          procurementRemoteDataSourceProvider.overrideWithValue(mockDataSource),
        ],
        child: const MaterialApp(
          home: BuyForMePage(),
        ),
      ),
    );

    // Verify Title and core fields
    expect(find.text('Buy For Me'), findsOneWidget);
    expect(find.text('Product URL'), findsOneWidget);
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Estimated Price (¥ CNY)'), findsOneWidget);
    expect(find.text('Variants / Specifications (Optional)'), findsOneWidget);

    // Verify Description field with "Please confirm stock" hint
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Please confirm stock'), findsOneWidget);
  });

  testWidgets('BuyForMePage submits description field as notes in request payload', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          procurementRemoteDataSourceProvider.overrideWithValue(mockDataSource),
        ],
        child: const MaterialApp(
          home: BuyForMePage(),
        ),
      ),
    );

    // Fill in product URL
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Paste link here (e.g. 1688.com/... )'),
      'https://detail.1688.com/offer/123456789.html',
    );

    // Fill in product name
    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g. Women Summer Dress'),
      'Wireless Noise Cancelling Earbuds',
    );

    // Fill in description with "Please confirm stock"
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Please confirm stock'),
      'Please confirm stock',
    );

    await tester.pumpAndSettle();

    // Scroll down to submit button and tap
    await tester.ensureVisible(find.text('Submit Procurement Request'));
    await tester.tap(find.text('Submit Procurement Request'));
    await tester.pumpAndSettle();

    // Verify that the request was submitted with notes: "Please confirm stock"
    expect(mockDataSource.lastSubmittedRequest, isNotNull);
    expect(mockDataSource.lastSubmittedRequest!.productUrl, 'https://detail.1688.com/offer/123456789.html');
    expect(mockDataSource.lastSubmittedRequest!.specifications, 'Wireless Noise Cancelling Earbuds');
    expect(mockDataSource.lastSubmittedRequest!.notes, 'Please confirm stock');

    final json = mockDataSource.lastSubmittedRequest!.toJson();
    expect(json['notes'], 'Please confirm stock');
  });
}
