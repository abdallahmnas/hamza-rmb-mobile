import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/wallet/views/wallet_page.dart';

void main() {
  group('WalletPage Widget Tests', () {
    testWidgets('renders balance card, quick actions, and currency accounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletPage(),
        ),
      );

      // Verify header and title
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Verify balance container
      expect(find.text('TOTAL ESTIMATED BALANCE'), findsOneWidget);
      expect(find.text('1,250,000'), findsOneWidget);
      expect(find.text('≈ ¥6,346.60 CNY'), findsOneWidget);

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
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletPage(),
        ),
      );

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
