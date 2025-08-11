import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:controlab/features/stock/ui/widgets/produto_list_item.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/app/config/router/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final stockListAsync = ref.watch(filteredStockListProvider);
  final filterState = ref.watch(stockNotifierProvider.select((_) => ref.read(stockNotifierProvider.notifier).filterState));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Consumer(
              builder: (context, ref, _) {
                final user = ref.watch(
                  authNotifierProvider.select((s) => s.value),
                );
                return Text(
                  'Olá, ${user?.name ?? 'Usuário'}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar produto (nome ou lote)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: filterState.searchTerm.isNotEmpty
                          ? IconButton(
                              tooltip: 'Limpar busca',
                              icon: const Icon(Icons.close),
                              onPressed: () => ref.read(stockNotifierProvider.notifier).setSearchTerm(''),
                            )
                          : null,
                    ),
                    onChanged: (v) => ref.read(stockNotifierProvider.notifier).setSearchTerm(v),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Filtros avançados',
                  child: IconButton(
                    icon: Badge(
                      isLabelVisible: filterState.categoria != null || filterState.statusCQ != null,
                      label: const Text('!'),
                      child: const Icon(Icons.filter_list),
                    ),
                    onPressed: () => _showFilterModal(context, ref),
                  ),
                ),
              ],
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
                  onRefresh: () =>
                      ref.read(stockNotifierProvider.notifier).loadProdutos(),
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
          // CORREÇÃO: A rota foi atualizada de 'addProduct' para 'productForm'.
          context.goNamed(AppRoute.productForm.name);
        },
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

void _showFilterModal(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _FilterModal(),
  );
}

class _FilterModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  CategoriaProduto? _categoria;
  StatusLoteCQ? _statusCQ;

  @override
  void initState() {
    super.initState();
    final fs = ref.read(stockNotifierProvider.notifier).filterState;
    _categoria = fs.categoria;
    _statusCQ = fs.statusCQ;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(stockNotifierProvider.notifier).clearFilters();
                  setState(() { _categoria = null; _statusCQ = null; });
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Categoria', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              for (final c in CategoriaProduto.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _categoria == c,
                  onSelected: (sel) => setState(() => _categoria = sel ? c : null),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Status CQ', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              for (final s in StatusLoteCQ.values)
                ChoiceChip(
                  label: Text(s.name),
                  selected: _statusCQ == s,
                  onSelected: (sel) => setState(() => _statusCQ = sel ? s : null),
                ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Aplicar'),
              onPressed: () {
                ref.read(stockNotifierProvider.notifier).applyFilters(categoria: _categoria, statusCQ: _statusCQ);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
