import '../../domain/entities/item.dart';

class ItemModel extends Item {
  ItemModel({required super.id, required super.title});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(id: json['id'] as int, title: json['title'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
