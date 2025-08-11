import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_providers.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:intl/intl.dart';
import 'package:controlab/features/stock/application/localizacao_notifier.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/application/cq_notifier.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produtoAsync = ref.watch(productDetailsProvider(widget.productId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Estoque'),
            Tab(icon: Icon(Icons.playlist_add_check_outlined), text: 'Qualidade'),
          ],
        ),
      ),
      body: produtoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: ${err.toString()}')),
        data: (produto) => TabBarView(
          controller: _tabController,
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList.list(
                      children: [
                        _ProductHeader(produto: produto),
                        const SizedBox(height: 24),
                        _StockDistributionCard(quantidadesPorLocal: produto.quantidadesPorLocal),
                        const SizedBox(height: 24),
                        _ProductInfoGrid(produto: produto),
                        const SizedBox(height: 24),
                        Text(
                          'Movimentações Recentes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        _MovimentacoesList(movimentacoes: produto.historicoUso),
                      ],
                    ),
                  ),
                ],
              ),
              _CQHistoryView(productId: produto.id, lote: produto.lote),
            ],
        ),
      ),
      floatingActionButton: produtoAsync.maybeWhen(
        data: (p) => AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            if (_tabController.index == 1) {
              return FloatingActionButton.extended(
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Registrar CQ'),
                onPressed: () => _showCQRegistrationForm(context, p),
              );
            }
            return _TransferFab(produto: p);
          },
        ),
        orElse: () => null,
      ),
    );
  }

  void _showCQRegistrationForm(BuildContext context, Produto produto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: _CQRegistrationForm(produto: produto),
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
                label: 'Quantidade Total',
                value: '${produto.quantidadeTotal} un.',
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

class _MovimentacoesList extends ConsumerWidget {
  final List<MovimentacaoEstoque> movimentacoes;
  const _MovimentacoesList({required this.movimentacoes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (movimentacoes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('Nenhuma movimentação registrado.')),
        ),
      );
    }

    final sortedMovimentacoes = List<MovimentacaoEstoque>.from(movimentacoes)
      ..sort((a, b) => b.data.compareTo(a.data));

  final locationsAsync = ref.watch(localizacaoNotifierProvider);
    return locationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Erro ao carregar localizações'))),
      data: (locations) {
        final locationMap = {for (var l in locations) l.id: l.nome};
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
              final nomeLocal = mov.locationId == null || mov.locationId!.isEmpty
                  ? 'N/D'
                  : (locationMap[mov.locationId!] ?? mov.locationId!);

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text('${isEntrada ? 'Entrada' : 'Saída'} por ${mov.responsavel}'),
                subtitle: Text('Local: $nomeLocal • ${DateFormat('dd/MM/yyyy HH:mm').format(mov.data)}'),
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
      },
    );
  }
}

class _StockDistributionCard extends ConsumerWidget {
  final Map<String, int> quantidadesPorLocal;
  const _StockDistributionCard({required this.quantidadesPorLocal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (quantidadesPorLocal.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sem estoque registrado'),
        ),
      );
    }

  final locationsAsync = ref.watch(localizacaoNotifierProvider);
    return locationsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, s) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Erro ao carregar localizações'),
        ),
      ),
      data: (locations) {
        final locationMap = {for (var l in locations) l.id: l.nome};
        final tiles = quantidadesPorLocal.entries.map((e) {
          final locId = e.key;
          final qtd = e.value;
            final nomeLocal = locationMap[locId] ?? 'ID: $locId';
          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              nomeLocal,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Text('$qtd un.', style: Theme.of(context).textTheme.bodyLarge),
            dense: true,
          );
        }).toList();
        final total = quantidadesPorLocal.values.fold<int>(0, (p, c) => p + c);
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Estoque por Localização',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          Theme.of(context).colorScheme.primary.withAlpha(26),
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Total: $total',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...tiles,
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _TransferFab extends ConsumerWidget {
  final Produto produto;
  const _TransferFab({required this.produto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.swap_horiz),
      label: const Text('Transferir'),
      onPressed: () => _openTransferDialog(context, ref),
    );
  }

  Future<void> _openTransferDialog(BuildContext context, WidgetRef ref) async {
  final locationsAsync = ref.read(localizacaoNotifierProvider);
  final user = ref.read(authNotifierProvider).value;
    if (locationsAsync is AsyncLoading) return;
    final locations = locationsAsync.value ?? [];
    if (locations.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necessário ao menos duas localizações para transferir.')),
      );
      return;
    }

    String? origemId;
    String? destinoId;
    final quantidadeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Transferir Estoque'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              final origemQtd = origemId == null ? 0 : (produto.quantidadesPorLocal[origemId] ?? 0);
              final podeConfirmar = origemId != null && destinoId != null && origemId != destinoId && (int.tryParse(quantidadeController.text) ?? 0) > 0;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Origem'),
                      value: origemId,
                      items: locations.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome))).toList(),
                      onChanged: (v) => setState(() { origemId = v; }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Destino'),
                      value: destinoId,
                      items: locations.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome))).toList(),
                      onChanged: (v) => setState(() { destinoId = v; }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantidadeController,
                      decoration: InputDecoration(
                        labelText: 'Quantidade (máx $origemQtd)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Disponível na origem: $origemQtd', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar Transferência'),
                      onPressed: podeConfirmar ? () async {
                        final qtd = int.tryParse(quantidadeController.text) ?? 0;
                        if (qtd <= 0) return;
                        Navigator.of(ctx).pop(true);
                        await ref.read(stockNotifierProvider.notifier).transferStock(
                          productId: produto.id,
                          origemLocationId: origemId!,
                          destinoLocationId: destinoId!,
                          quantidade: qtd,
                          responsavel: user?.name ?? 'System',
                        );
                      } : null,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
    quantidadeController.dispose();
  }
}

// ------------------ CQ UI ------------------
class _CQHistoryView extends ConsumerWidget {
  final String productId;
  final String lote;
  const _CQHistoryView({required this.productId, required this.lote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cqHistoryProvider(productId));
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro: $e')),
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Nenhum registro de qualidade.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: history.length,
          itemBuilder: (ctx, i) {
            final r = history[i];
            final disp = r.status.display;
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: disp.color.withOpacity(.15), child: Icon(disp.icon, color: disp.color)),
                title: Text('${disp.label} • ${r.lote}', style: TextStyle(color: disp.color, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Por: ${r.responsavel}\n${DateFormat('dd/MM/yy HH:mm').format(r.data)}\n${r.observacoes}'.trim(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CQRegistrationForm extends ConsumerStatefulWidget {
  final Produto produto;
  const _CQRegistrationForm({required this.produto});
  @override
  ConsumerState<_CQRegistrationForm> createState() => _CQRegistrationFormState();
}

class _CQRegistrationFormState extends ConsumerState<_CQRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  StatusLoteCQ _status = StatusLoteCQ.pendente;
  final _obsController = TextEditingController();

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).value;
    final ok = await ref.read(cqNotifierProvider(widget.produto.id).notifier).adicionarRegistro(
          lote: widget.produto.lote,
          responsavel: user?.name ?? 'System',
          status: _status,
          observacoes: _obsController.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro CQ salvo'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao salvar'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Registrar CQ - Lote ${widget.produto.lote}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<StatusLoteCQ>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status do Lote'),
              items: StatusLoteCQ.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _obsController,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar Registro'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
