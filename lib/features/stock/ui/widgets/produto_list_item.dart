import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/application/cq_notifier.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';

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
  final statusCQAsync = ref.watch(ultimoStatusCQDoLoteProvider(produto.lote));
  final statusCQ = statusCQAsync.value; // null se ainda carregando

    // Estilos dinâmicos conforme hierarquia
    Color cardBackgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
    Color borderColor = Colors.transparent;
    IconData? alertIcon;
    Color? alertIconColor;

    // Prioridade CQ
  final bool isActionBlocked = statusCQ == StatusLoteCQ.reprovado || statusCQ == StatusLoteCQ.emQuarentena;

  if (statusCQ == StatusLoteCQ.reprovado) {
      cardBackgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade700;
      alertIcon = Icons.gpp_bad_outlined;
      alertIconColor = Colors.red.shade700;
    } else if (statusCQ == StatusLoteCQ.emQuarentena) {
      cardBackgroundColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade700;
      alertIcon = Icons.science_outlined;
      alertIconColor = Colors.amber.shade800;
    } else if (produtoStatus == StatusProduto.vencido) {
      cardBackgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade400;
      alertIcon = Icons.error_outline_rounded;
      alertIconColor = Colors.red.shade700;
    } else {
  final total = produto.quantidadeTotal;
  final bool isEstoqueBaixo = produto.estoqueMinimo != null && total <= produto.estoqueMinimo!;
  final bool isEstoqueAlto = produto.estoqueMaximo != null && total >= produto.estoqueMaximo!;

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
                backgroundColor: Color.alphaBlend(colors.primary.withAlpha(26), Colors.white),
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
                      'Total: ${produto.quantidadeTotal} | Cat: ${produto.categoria.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    if (statusCQ != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: statusCQ == StatusLoteCQ.reprovado
                                ? Colors.red.shade100
                                : statusCQ == StatusLoteCQ.emQuarentena
                                    ? Colors.amber.shade100
                                    : Colors.green.shade100,
                            label: Text(
                              statusCQ.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: statusCQ == StatusLoteCQ.reprovado
                                    ? Colors.red.shade700
                                    : statusCQ == StatusLoteCQ.emQuarentena
                                        ? Colors.amber.shade800
                                        : Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (alertIcon != null)
                Tooltip(
                  message: _getTooltipMessage(produto, statusCQ),
                  preferBelow: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(alertIcon, color: alertIconColor),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: isActionBlocked ? Colors.grey : colors.error, size: 28),
                onPressed: isActionBlocked ? null : () {
                  // Ajuste simples: usar localização default para operações rápidas.
                  final defaultLoc = Produto.defaultLocationId;
                  final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
                  final atual = mapa[defaultLoc] ?? produto.quantidadeTotal; // fallback se ainda não separado
                  if (atual > 0) {
                    final nova = atual - 1;
                    mapa[defaultLoc] = nova;
                    if (nova == 0) mapa.remove(defaultLoc);
                    ref.read(stockNotifierProvider.notifier).updateStockAtLocation(
                      productId: produto.id,
                      locationId: defaultLoc,
                      novaQuantidadeLocal: nova,
                      responsavel: user?.name ?? 'System',
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: isActionBlocked ? Colors.grey : colors.primary, size: 28),
                onPressed: isActionBlocked ? null : () {
                  final defaultLoc = Produto.defaultLocationId;
                  final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
                  final atual = mapa[defaultLoc] ?? 0;
                  final nova = atual + 1;
                  ref.read(stockNotifierProvider.notifier).updateStockAtLocation(
                    productId: produto.id,
                    locationId: defaultLoc,
                    novaQuantidadeLocal: nova,
                    responsavel: user?.name ?? 'System',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTooltipMessage(Produto produto, StatusLoteCQ? statusCQ) {
    if (statusCQ == StatusLoteCQ.reprovado) {
      return 'Lote ${produto.lote} REPROVADO no CQ. Bloquear uso.';
    }
    if (statusCQ == StatusLoteCQ.emQuarentena) {
      return 'Lote ${produto.lote} em quarentena aguardando liberação.';
    }
    final produtoStatus = produto.status;
    if (produtoStatus == StatusProduto.vencido) {
      return 'Produto vencido em ${produto.validade}';
    }
    final total = produto.quantidadeTotal;
    final bool isEstoqueBaixo = produto.estoqueMinimo != null && total <= produto.estoqueMinimo!;
    if (isEstoqueBaixo) {
      return 'Estoque abaixo do mínimo definido (${produto.estoqueMinimo})';
    }
    final bool isEstoqueAlto = produto.estoqueMaximo != null && total >= produto.estoqueMaximo!;
    if (isEstoqueAlto) {
      return 'Estoque acima do máximo definido (${produto.estoqueMaximo})';
    }
    return '';
  }
}
