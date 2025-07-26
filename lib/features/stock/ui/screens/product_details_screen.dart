import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/domain/produto.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
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
                const _MovimentacoesList(),
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
            const Icon(
              Icons.local_hospital,
              size: 40,
              color: Color(0xFF4F46E5),
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
                icon: Icons.inventory,
                label: 'Quantidade',
                value: '${produto.quantidade} un.',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoCard(
                icon: Icons.factory,
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
                icon: Icons.calendar_today,
                label: 'Validade',
                value: produto.validade,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoCard(
                icon: Icons.qr_code_2,
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
  const _MovimentacoesList();

  @override
  Widget build(BuildContext context) {
    // Dados mockados para as movimentações
    final movimentacoes = [
      {
        'tipo': 'Entrada',
        'qtd': '+50',
        'data': '20/07/2025',
        'cor': Colors.green.shade700,
      },
      {
        'tipo': 'Saída',
        'qtd': '-10',
        'data': '22/07/2025',
        'cor': Colors.red.shade700,
      },
      {
        'tipo': 'Saída',
        'qtd': '-5',
        'data': '24/07/2025',
        'cor': Colors.red.shade700,
      },
    ];

    return Card(
      child: Column(
        children: List.generate(movimentacoes.length, (index) {
          final mov = movimentacoes[index];
          return ListTile(
            leading: Icon(
              mov['tipo'] == 'Entrada'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: mov['cor'] as Color,
            ),
            title: Text(mov['tipo'] as String),
            subtitle: Text(mov['data'] as String),
            trailing: Text(
              mov['qtd'] as String,
              style: TextStyle(
                color: mov['cor'] as Color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }),
      ),
    );
  }
}
