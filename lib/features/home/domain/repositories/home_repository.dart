import '../entities/item.dart';

abstract class HomeRepository {
  Future<List<Item>> getItems();
}
