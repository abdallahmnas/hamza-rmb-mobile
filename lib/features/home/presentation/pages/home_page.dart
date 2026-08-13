import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(homeItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              title: 'No items found',
              message: 'No items found.',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('ID: ${item.id}'),
              );
            },
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(homeItemsProvider),
        ),
      ),
    );
  }
}
