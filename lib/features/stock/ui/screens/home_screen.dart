import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/ui/widgets/produto_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockListAsync = ref.watch(stockListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque da Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: stockListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              data: (produtos) {
                if (produtos.isEmpty) {
                  return const Center(child: Text('Nenhum produto no estoque.'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(stockListProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ProdutoListItem(
                          produto: produto,
                          onTap: () => context.go('/home/product/${produto.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}