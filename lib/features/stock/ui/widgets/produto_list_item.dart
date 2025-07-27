import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';

class ProdutoListItem extends ConsumerWidget {
  final Produto produto;
  final VoidCallback onTap;

  const ProdutoListItem({
    super.key,
    required this.produto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authNotifierProvider).value;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: Icon(produto.icone, color: colors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estoque: ${produto.quantidade} | Cat: ${produto.categoria.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: colors.error, size: 28),
                onPressed: () {
                  if (produto.quantidade > 0) {
                     ref.read(stockNotifierProvider.notifier).updateStock(
                          produto.id, produto.quantidade - 1, user?.name ?? 'System');
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: colors.primary, size: 28),
                onPressed: () {
                   ref.read(stockNotifierProvider.notifier).updateStock(
                        produto.id, produto.quantidade + 1, user?.name ?? 'System');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
