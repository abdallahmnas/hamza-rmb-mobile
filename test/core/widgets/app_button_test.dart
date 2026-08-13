import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/core/widgets/app_button.dart';

void main() {
  group('AppButton Widget', () {
    testWidgets('should display text when not loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppButton(text: 'Click Me')),
        ),
      );

      // Assert
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display loading indicator when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppButton(text: 'Click Me', isLoading: true)),
        ),
      );

      // Assert
      expect(find.text('Click Me'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
