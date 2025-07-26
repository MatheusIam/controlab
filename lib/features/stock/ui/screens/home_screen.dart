import 'package:controlab/features/auth/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/ui/widgets/produto_list_item.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockListAsync = ref.watch(stockListProvider);
    // Ouve o estado de autenticação para obter o usuário.
    final AsyncValue<User?> authState = ref.watch(authNotifierProvider);
    final User? user = authState.value;

    return Scaffold(
      // A AppBar foi movida para o ScaffoldWithNavBar, esta é opcional
      // caso queira uma AppBar específica para esta tela.
      // appBar: AppBar(
      //   title: Text(user?.name ?? 'Estoque da Clínica'),
      // ),
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
                fillColor: Theme.of(context).cardColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
                        onTap: () =>
                            context.go('/home/product-details/${produto.id}'),
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
