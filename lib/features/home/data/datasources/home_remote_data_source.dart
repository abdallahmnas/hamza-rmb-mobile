import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../../../../core/errors/app_errors.dart';

abstract class HomeRemoteDataSource {
  Future<List<ItemModel>> fetchItems();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ItemModel>> fetchItems() async {
    try {
      final response = await _dio.get('/posts'); // Dummy API
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load items');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}
