import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/home/domain/entities/item.dart';

void main() {
  group('Item Entity', () {
    test('should create an item with correct id and title', () {
      // Arrange
      const id = 1;
      const title = 'Test Item';

      // Act
      final item = Item(id: id, title: title);

      // Assert
      expect(item.id, equals(1));
      expect(item.title, equals('Test Item'));
    });
  });
}
