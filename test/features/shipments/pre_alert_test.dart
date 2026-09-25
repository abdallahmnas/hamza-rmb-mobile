import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/storage/local_storage.dart';
import 'package:hamza_rmb/features/pre_alert/views/pre_alert_page.dart';
import 'package:hamza_rmb/features/shipments/data/datasources/shipments_remote_data_source.dart';
import 'package:hamza_rmb/features/shipments/data/models/package_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pre-Alert PackageModel Serialization Tests', () {
    test('parses exact response from POST v1/shipments/pre-alert', () {
      final jsonResponse = {
        'success': true,
        'data': {
          'id': '764b95dd-0581-4e4a-b2c9-138a8037e52d',
          'trackingId': 'HZ-AIR-202609-002',
          'chineseTrackingNo': '11224',
          'customerId': 'HZ-20260922-2212',
          'customerName': 'Mr Ab',
          'status': 'pre_alerted',
          'description': 'Testing',
          'weightKg': 0,
          'cbm': 0,
          'paymentStatus': 'unpaid',
          'preAlertDate': '2026-09-24T12:11:23.041Z',
          'updatedAt': '2026-09-24T12:11:23.042Z',
          'createdAt': '2026-09-24T12:11:23.042Z',
          'dimensions': null,
          'photos': null,
          'linkedBatchId': null,
          'shippingMethod': null,
          'destinationWarehouse': null,
          'invoiceAmount': null,
          'paymentMethod': null,
          'receivedDate': null,
          'shippedDate': null,
          'arrivedDate': null,
          'deliveredDate': null
        }
      };

      final data = jsonResponse['data'] as Map<String, dynamic>;
      final pkg = PackageModel.fromJson(data);

      expect(pkg.id, equals('764b95dd-0581-4e4a-b2c9-138a8037e52d'));
      expect(pkg.trackingId, equals('HZ-AIR-202609-002'));
      expect(pkg.chineseTrackingNo, equals('11224'));
      expect(pkg.trackingNumber, equals('11224'));
      expect(pkg.customerId, equals('HZ-20260922-2212'));
      expect(pkg.customerName, equals('Mr Ab'));
      expect(pkg.status, equals('pre_alerted'));
      expect(pkg.description, equals('Testing'));
      expect(pkg.weightKg, equals(0.0));
      expect(pkg.cbm, equals(0.0));
      expect(pkg.paymentStatus, equals('unpaid'));
      expect(pkg.preAlertDate, isNotNull);
      expect(pkg.createdAt, isNotNull);
      expect(pkg.updatedAt, isNotNull);
      expect(pkg.displayTracking, equals('HZ-AIR-202609-002'));

      final serialized = pkg.toJson();
      expect(serialized['id'], equals('764b95dd-0581-4e4a-b2c9-138a8037e52d'));
      expect(serialized['trackingId'], equals('HZ-AIR-202609-002'));
      expect(serialized['chineseTrackingNo'], equals('11224'));
      expect(serialized['description'], equals('Testing'));
      expect(serialized['status'], equals('pre_alerted'));
    });
  });

  group('ShipmentsRemoteDataSource submitPreAlert Tests', () {
    test('sends payload with originCountry, paymentOption, estimatedItems, and optional fields',
        () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://hamza-rmb.onrender.com/api/v1',
        ),
      );

      RequestOptions? capturedRequest;
      dynamic capturedPayload;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            capturedPayload = options.data;

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'data': {
                    'id': '764b95dd-0581-4e4a-b2c9-138a8037e52d',
                    'trackingId': 'HZ-AIR-202609-002',
                    'chineseTrackingNo': '11224',
                    'customerId': 'HZ-20260922-2212',
                    'customerName': 'Mr Ab',
                    'status': 'pre_alerted',
                    'description': 'Testing',
                    'weightKg': 0,
                    'cbm': 0,
                    'paymentStatus': 'unpaid',
                    'preAlertDate': '2026-09-24T12:11:23.041Z',
                    'updatedAt': '2026-09-24T12:11:23.042Z',
                    'createdAt': '2026-09-24T12:11:23.042Z'
                  }
                },
              ),
            );
          },
        ),
      );

      final dataSource = ShipmentsRemoteDataSourceImpl(dio);

      final result = await dataSource.submitPreAlert(
        chineseTrackingNo: '11224',
        supplierName: 'Mister Shop',
        description: 'Testing',
        originCountry: 'Guangzhou Primary Hub, Guangzhou, China',
        paymentOption: 'pay_before_dispatch',
        estimatedItems: 12,
        notes: 'Highly sensitive',
        photos: ['hamza_rmb.png'],
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, equals('POST'));
      expect(capturedRequest!.path, equals('/shipments/pre-alert'));

      expect(capturedPayload, isA<Map<String, dynamic>>());
      final payload = capturedPayload as Map<String, dynamic>;

      expect(payload['chineseTrackingNo'], equals('11224'));
      expect(payload['supplierName'], equals('Mister Shop'));
      expect(payload['description'], equals('Testing'));
      expect(payload['originCountry'],
          equals('Guangzhou Primary Hub, Guangzhou, China'));
      expect(payload['paymentOption'], equals('pay_before_dispatch'));
      expect(payload['estimatedItems'], equals(12));
      expect(payload['notes'], equals('Highly sensitive'));
      expect(payload['photos'], equals(['hamza_rmb.png']));

      expect(result.id, equals('764b95dd-0581-4e4a-b2c9-138a8037e52d'));
      expect(result.trackingId, equals('HZ-AIR-202609-002'));
      expect(result.chineseTrackingNo, equals('11224'));
      expect(result.status, equals('pre_alerted'));
      expect(result.description, equals('Testing'));
      expect(result.paymentStatus, equals('unpaid'));
    });
  });

  group('PreAlertPage Widget Tests', () {
    testWidgets('renders all pre-alert fields including origin, payment option, estimated items', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: PreAlertPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & header
      expect(find.text('Pre-Alert Cargo'), findsOneWidget);
      expect(find.text('CUSTOMER ID'), findsOneWidget);

      // Section 1: Warehouse
      expect(find.text('1. Warehouse *'), findsOneWidget);
      expect(find.textContaining('Guangzhou Primary Hub'), findsWidgets);

      // Section 2: Payment Option & Quantity
      expect(find.text('2. Payment Option & Quantity *'), findsOneWidget);
      expect(find.text('Pay Before Dispatch'), findsOneWidget);
      expect(find.text('Pay On Delivery'), findsOneWidget);
      expect(find.text('Estimated Items *'), findsOneWidget);

      // Section 3: Shipment Details (Optional)
      expect(find.text('3. Shipment Details (Optional)'), findsOneWidget);
      expect(find.text('Chinese Tracking Number'), findsOneWidget);
      expect(find.text('Supplier / Store Name'), findsOneWidget);
      expect(find.text('Package Description'), findsOneWidget);
      expect(find.text('Special Notes / Instructions'), findsOneWidget);

      // Section 4: Photos (Optional)
      expect(find.text('4. Photos / Invoices (Optional)'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('From Gallery'), findsOneWidget);

      // Submit Button
      expect(find.text('Submit Pre-alert'), findsOneWidget);
    });
  });
}
