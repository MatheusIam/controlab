import 'package:controlab/features/auth/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/ui/widgets/produto_list_item.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/app/config/router/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockListAsync = ref.watch(stockListProvider);
    final AsyncValue<User?> authState = ref.watch(authNotifierProvider);
    final User? user = authState.value;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Olá, ${user?.name ?? 'Usuário'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: stockListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              data: (produtos) {
                if (produtos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto no estoque.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(stockListProvider.future),
                  child: ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];
                      return ProdutoListItem(
                        produto: produto,
                        onTap: () => context.goNamed(
                          AppRoute.productDetails.name,
                          pathParameters: {'id': produto.id},
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
        onPressed: () {
          // Navega para a tela de adicionar produto
          context.goNamed(AppRoute.addProduct.name);
        },
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
