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
    final produtoStatus = produto.status;

    // Estilos dinâmicos conforme hierarquia
    Color cardBackgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
    Color borderColor = Colors.transparent;
    IconData? alertIcon;
    Color? alertIconColor;

    if (produtoStatus == StatusProduto.vencido) {
      cardBackgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade400;
      alertIcon = Icons.error_outline_rounded;
      alertIconColor = Colors.red.shade700;
    } else {
      final bool isEstoqueBaixo = produto.estoqueMinimo != null && produto.quantidade <= produto.estoqueMinimo!;
      final bool isEstoqueAlto = produto.estoqueMaximo != null && produto.quantidade >= produto.estoqueMaximo!;

      if (isEstoqueBaixo) {
        borderColor = Colors.orange.shade600;
        alertIcon = Icons.warning_amber_rounded;
        alertIconColor = Colors.orange.shade700;
      } else if (isEstoqueAlto) {
        borderColor = Colors.blue.shade600;
        alertIcon = Icons.info_outline_rounded;
        alertIconColor = Colors.blue.shade700;
      }
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: borderColor, width: borderColor == Colors.transparent ? 0 : 1.5),
      ),
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
              if (alertIcon != null)
                Tooltip(
                  message: _getTooltipMessage(produto),
                  preferBelow: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(alertIcon, color: alertIconColor),
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

  String _getTooltipMessage(Produto produto) {
    final produtoStatus = produto.status;
    if (produtoStatus == StatusProduto.vencido) {
      return 'Produto vencido em ${produto.validade}';
    }
    final bool isEstoqueBaixo = produto.estoqueMinimo != null && produto.quantidade <= produto.estoqueMinimo!;
    if (isEstoqueBaixo) {
      return 'Estoque abaixo do mínimo definido (${produto.estoqueMinimo})';
    }
    final bool isEstoqueAlto = produto.estoqueMaximo != null && produto.quantidade >= produto.estoqueMaximo!;
    if (isEstoqueAlto) {
      return 'Estoque acima do máximo definido (${produto.estoqueMaximo})';
    }
    return '';
  }
}
