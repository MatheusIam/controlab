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
    final statusInfo = produto.status.displayAttributes;
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authNotifierProvider).value;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: colors.primary, size: 40),
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
                      'Estoque: ${produto.quantidade}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Botões de movimentação rápida
              IconButton(
                icon: Icon(Icons.remove_circle, color: colors.error),
                onPressed: () {
                  if (produto.quantidade > 0) {
                    ref
                        .read(stockNotifierProvider.notifier)
                        .updateStock(
                          produto.id,
                          produto.quantidade - 1,
                          user?.name ?? 'System',
                        );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: colors.primary),
                onPressed: () {
                  ref
                      .read(stockNotifierProvider.notifier)
                      .updateStock(
                        produto.id,
                        produto.quantidade + 1,
                        user?.name ?? 'System',
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
