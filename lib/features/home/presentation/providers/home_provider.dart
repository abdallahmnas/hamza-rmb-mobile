import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRemoteDataSourceImpl(dio);
});

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

final homeItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return await repository.getItems();
});
