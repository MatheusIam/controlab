import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O provider agora retorna um AsyncValue<Produto> não nulo.
    final productAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      // A chamada a .when() agora é segura.
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: ${err.toString()}')),
        data: (produto) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductHeader(produto: produto),
                const SizedBox(height: 24),
                _ProductInfoGrid(produto: produto),
                const SizedBox(height: 24),
                Text(
                  'Movimentações Recentes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _MovimentacoesList(movimentacoes: produto.historicoUso),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final Produto produto;
  const _ProductHeader({required this.produto});

  @override
  Widget build(BuildContext context) {
    final statusInfo = produto.status.displayAttributes;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusInfo.text,
                      style: TextStyle(
                        color: statusInfo.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.science_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoGrid extends StatelessWidget {
  final Produto produto;
  const _ProductInfoGrid({required this.produto});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.inventory_2_outlined,
                label: 'Quantidade',
                value: '${produto.quantidade} un.',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoCard(
                icon: Icons.factory_outlined,
                label: 'Fornecedor',
                value: produto.fornecedor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.calendar_today_outlined,
                label: 'Validade',
                value: produto.validade,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoCard(
                icon: Icons.qr_code_2_outlined,
                label: 'Lote',
                value: produto.lote,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimentacoesList extends StatelessWidget {
  final List<MovimentacaoEstoque> movimentacoes;
  const _MovimentacoesList({required this.movimentacoes});

  @override
  Widget build(BuildContext context) {
    if (movimentacoes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('Nenhuma movimentação registrada.')),
        ),
      );
    }

    final sortedMovimentacoes = List<MovimentacaoEstoque>.from(movimentacoes)
      ..sort((a, b) => b.data.compareTo(a.data));

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedMovimentacoes.length,
        itemBuilder: (context, index) {
          final mov = sortedMovimentacoes[index];
          final isEntrada = mov.tipo == TipoMovimentacao.entrada;
          final color = isEntrada ? Colors.green.shade700 : Colors.red.shade700;
          final icon = isEntrada ? Icons.arrow_downward : Icons.arrow_upward;
          final prefix = isEntrada ? '+' : '-';

          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(
              '${isEntrada ? 'Entrada' : 'Saída'} por ${mov.responsavel}',
            ),
            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(mov.data)),
            trailing: Text(
              '$prefix${mov.quantidade}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
