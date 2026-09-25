import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/storage/local_storage.dart';
import 'package:hamza_rmb/features/shipments/views/air_freight_details_page.dart';
import 'package:hamza_rmb/features/shipments/views/sea_freight_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AirFreightDetailsPage Widget Tests', () {
    testWidgets('renders all key sections and header information', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: AirFreightDetailsPage(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Air Freight Service Details'), findsOneWidget);

      // Verify corridor info
      expect(find.text('CAN  ✈  LOS DIRECT'), findsOneWidget);
      expect(find.text('Guangzhou to Lagos Express'), findsOneWidget);
      expect(find.text('\$8.50'), findsOneWidget);

      // Verify estimator
      expect(find.text('Estimate Air Cargo\nCost'), findsOneWidget);
      expect(find.text('5.0 KG'), findsOneWidget);
      expect(find.text('₦65,875'), findsOneWidget);

      // Verify bottom action buttons
      expect(find.text('Copy Hub'), findsOneWidget);
      expect(find.text('Start Air Shipment'), findsOneWidget);
    });
  });

  group('SeaFreightDetailsPage Widget Tests', () {
    testWidgets('renders maritime header, CBM calculator, and booking actions', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: SeaFreightDetailsPage(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Sea Freight Service Details'), findsOneWidget);

      // Verify transit time and badges
      expect(find.text('35 – 45 Days'), findsOneWidget);
      expect(find.text('FCL & LCL Groupage'), findsOneWidget);
      expect(find.text('From \$190 / CBM'), findsOneWidget);

      // Verify CBM Shipping Calculator
      expect(find.text('CBM Shipping Calculator'), findsOneWidget);
      expect(find.text('0.96 CBM'), findsOneWidget);
      expect(find.text('₦273,600'), findsOneWidget);

      // Verify bottom buttons
      expect(find.text('Get Estimate'), findsOneWidget);
      expect(find.text('Book Sea Freight'), findsOneWidget);
    });
  });
}
