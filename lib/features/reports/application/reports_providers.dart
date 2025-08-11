import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/application/cq_notifier.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';

// Modelo simples para dados de consumo mensal (mockado por enquanto)
class ConsumptionEntry {
  final String month; // e.g. '2025-08'
  final int quantidadeSaida;
  ConsumptionEntry(this.month, this.quantidadeSaida);
}

final consumptionReportProvider = Provider.autoDispose.family<List<ConsumptionEntry>, String>((ref, productId) {
  // Observa apenas a lista resolvida (value) reduzindo rebuilds.
  final produtos = ref.watch(stockNotifierProvider.select((s) => s.value ?? const <Produto>[]));
  final produto = produtos.firstWhere(
    (p) => p.id == productId,
    orElse: () => Produto(
      id: 'NA', nome: 'N/A', fornecedor: '', validade: '01/01/2099', lote: '', categoria: CategoriaProduto.outros, iconCodePoint: 0,
    ),
  );
  // Agrupa movimentações de saída por mês
  final mapa = <String,int>{};
  for (final m in produto.historicoUso) {
    if (m.tipo == TipoMovimentacao.saida) {
      final key = '${m.data.year}-${m.data.month.toString().padLeft(2,'0')}';
      mapa[key] = (mapa[key] ?? 0) + m.quantidade;
    }
  }
  final entries = mapa.entries.map((e) => ConsumptionEntry(e.key, e.value)).toList()
    ..sort((a,b) => a.month.compareTo(b.month));
  return entries;
});

// Produtos por proximidade de validade (<=30 dias e <=7 dias) e vencidos
class ExpiryBucket {
  final String label; final List<Produto> produtos; ExpiryBucket(this.label,this.produtos);
}

final expiryReportProvider = Provider.autoDispose<List<ExpiryBucket>>((ref){
  final produtos = ref.watch(stockNotifierProvider.select((s) => s.value ?? const <Produto>[]));
  final now = DateTime.now();
  final sete = <Produto>[]; final trinta = <Produto>[]; final vencidos = <Produto>[];
  for (final p in produtos) {
    try {
      final parts = p.validade.split('/');
      if (parts.length==3){
        final d=int.parse(parts[0]);final m=int.parse(parts[1]);final y=int.parse(parts[2]);
        final exp=DateTime(y,m,d);
        final diff=exp.difference(now).inDays;
        if (diff < 0) { vencidos.add(p); }
        else if (diff <=7) { sete.add(p); }
        else if (diff <=30) { trinta.add(p); }
      }
    } catch(_){ }
  }
  return [
    ExpiryBucket('Vencidos', vencidos),
    ExpiryBucket('Vencem em 7 dias', sete),
    ExpiryBucket('Vencem em 30 dias', trinta),
  ];
});

// ---------------- Dashboard Unificado ----------------
class DashboardStats {
  final int totalProdutos;
  final int itensEstoqueBaixo;
  final int lotesReprovados;
  final int lotesEmQuarentena;
  const DashboardStats({
    required this.totalProdutos,
    required this.itensEstoqueBaixo,
    required this.lotesReprovados,
    required this.lotesEmQuarentena,
  });
}

final dashboardStatsProvider = Provider.autoDispose<DashboardStats>((ref) {
  final produtos = ref.watch(stockNotifierProvider.select((s) => s.value ?? const <Produto>[]));
  int baixo = 0;
  final lotesReprovadosSet = <String>{};
  final lotesQuarentenaSet = <String>{};
  for (final p in produtos) {
    if (p.estoqueMinimo != null && p.quantidadeTotal <= p.estoqueMinimo!) baixo++;
    final statusAsync = ref.watch(ultimoStatusCQDoLoteProvider(p.lote));
    final st = statusAsync.asData?.value;
    if (st == StatusLoteCQ.reprovado) lotesReprovadosSet.add(p.lote);
    if (st == StatusLoteCQ.emQuarentena) lotesQuarentenaSet.add(p.lote);
  }
  return DashboardStats(
    totalProdutos: produtos.length,
    itensEstoqueBaixo: baixo,
    lotesReprovados: lotesReprovadosSet.length,
    lotesEmQuarentena: lotesQuarentenaSet.length,
  );
});

// --------------- Não Conformidades (CQ Reprovados) ---------------
final nonConformanceReportProvider = Provider.autoDispose<List<RegistroCQ>>((ref) {
  // Estratégia simples: percorre todos os produtos, busca último status por lote e filtra reprovados no histórico.
  // Em cenário real, ideal agregar via data source.
  final produtos = ref.watch(stockNotifierProvider.select((s) => s.value ?? const <Produto>[]));
  final registros = <RegistroCQ>[];
  for (final p in produtos) {
    final cqState = ref.watch(cqNotifierProvider(p.id));
    final hist = cqState.registros.value;
    if (hist != null) {
      registros.addAll(hist.where((r) => r.status == StatusLoteCQ.reprovado));
    }
  }
  registros.sort((a,b) => b.data.compareTo(a.data));
  return registros;
});
