import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:controlab/features/reports/application/reports_providers.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(stockNotifierProvider);
    final produtos = produtosAsync.value ?? [];
    _selectedProductId ??= produtos.isNotEmpty ? produtos.first.id : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_down), text: 'Consumo'),
            Tab(icon: Icon(Icons.event_busy), text: 'Validade'),
            Tab(icon: Icon(Icons.science), text: 'Não Conform.'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsumption(produtos),
          _buildExpiry(),
          _buildQualityPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildConsumption(List<Produto> produtos){
    if (produtos.isEmpty) return const Center(child: Text('Sem dados de produtos.'));
    final entries = _selectedProductId==null ? [] : ref.watch(consumptionReportProvider(_selectedProductId!));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            value: _selectedProductId,
            items: produtos.map((p)=> DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
            onChanged: (v)=> setState(()=> _selectedProductId = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: entries.isEmpty
              ? const Center(child: Text('Sem movimentações de saída.'))
              : BarChart(BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta){
                      final index = value.toInt();
                      if (index <0 || index >= entries.length) return const SizedBox.shrink();
                      return Transform.rotate(angle: -0.5, child: Text(entries[index].month.substring(5))); // mostra MM
                    })),
                  ),
                  barGroups: [
                    for (int i=0;i<entries.length;i++)
                      BarChartGroupData(x: i, barRods: [BarChartRodData(toY: entries[i].quantidadeSaida.toDouble(), color: Theme.of(context).colorScheme.primary)])
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiry(){
    final buckets = ref.watch(expiryReportProvider);
    return ListView.builder(
      itemCount: buckets.length,
      itemBuilder: (ctx,i){
        final b = buckets[i];
        if (b.produtos.isEmpty) return const SizedBox.shrink();
        return ExpansionTile(
          title: Text('${b.label} (${b.produtos.length})'),
          children: b.produtos.map((p)=> ListTile(
            title: Text(p.nome),
            subtitle: Text('Val: ${p.validade} • Qtde: ${p.quantidadeTotal}'),
          )).toList(),
        );
      },
    );
  }

  Widget _buildQualityPlaceholder(){
    return const Center(child: Text('Relatório de não conformidades - FUTURO'));
  }
}
