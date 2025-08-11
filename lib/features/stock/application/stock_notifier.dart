import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/data/stock_repository_impl.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';

// Estado de filtros aplicado à lista de produtos
class StockFilterState {
  final String searchTerm;
  final CategoriaProduto? categoria;
  final StatusLoteCQ? statusCQ;
  const StockFilterState({
    this.searchTerm = '',
    this.categoria,
    this.statusCQ,
  });

  StockFilterState copyWith({
    String? searchTerm,
    CategoriaProduto? categoria,
    StatusLoteCQ? statusCQ,
    bool resetCategoria = false,
    bool resetStatus = false,
  }) {
    return StockFilterState(
      searchTerm: searchTerm ?? this.searchTerm,
      categoria: resetCategoria ? null : (categoria ?? this.categoria),
      statusCQ: resetStatus ? null : (statusCQ ?? this.statusCQ),
    );
  }
}

class StockNotifier extends StateNotifier<AsyncValue<List<Produto>>> {
  final IStockRepository _repository;
  StockFilterState _filterState = const StockFilterState();
  StockFilterState get filterState => _filterState;

  StockNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProdutos();
  }

  Future<void> loadProdutos() async {
    try {
      state = const AsyncValue.loading();
      final produtos = await _repository.getProdutos();
      state = AsyncValue.data(produtos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ----------------- Filtro / Busca -----------------
  void setSearchTerm(String term) {
    final normalized = term.trim().toLowerCase();
    // Não altera lista, apenas estado derivado será filtrado
    _filterState = _filterState.copyWith(searchTerm: normalized);
    // Força rebuild para derivations usando select/watch
    state = state.whenData((value) => value);
  }

  void applyFilters({CategoriaProduto? categoria, StatusLoteCQ? statusCQ}) {
    _filterState = _filterState.copyWith(categoria: categoria, statusCQ: statusCQ);
    state = state.whenData((value) => value);
  }

  void clearFilters() {
    _filterState = const StockFilterState();
    state = state.whenData((value) => value);
  }

  Future<void> addProduct(Produto produto) async {
    state = await AsyncValue.guard(() async {
      await _repository.addProduto(produto);
      final current = state.value ?? [];
      return [...current, produto];
    });
  }
  
  Future<void> updateProduct(Produto produto) async {
    state = await AsyncValue.guard(() async {
      await _repository.updateProduto(produto);
      final current = state.value ?? [];
      return [
        for (final p in current) if (p.id == produto.id) produto else p,
      ];
    });
  }

  Future<void> updateStock(String productId, int quantidade, String responsavel) async {
    state = await AsyncValue.guard(() async {
      final produto = await _repository.getProdutoById(productId);
      final totalAtual = produto.quantidadeTotal;
      final diferenca = quantidade - totalAtual;
      if (diferenca == 0) return state.value ?? [];

      final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
      final keyAjuste = mapa.containsKey(Produto.defaultLocationId)
          ? Produto.defaultLocationId
          : (mapa.isNotEmpty ? mapa.keys.first : Produto.defaultLocationId);
      final atualLocal = mapa[keyAjuste] ?? 0;
      var novoLocal = atualLocal + diferenca;
      if (novoLocal < 0) novoLocal = 0;
      mapa[keyAjuste] = novoLocal;
      if (mapa[keyAjuste] == 0 && mapa.length > 1) {
        mapa.remove(keyAjuste);
      }

      final tipo = diferenca > 0 ? TipoMovimentacao.entrada : TipoMovimentacao.saida;
      final novaMovimentacao = MovimentacaoEstoque(
        tipo: tipo,
        quantidade: diferenca.abs(),
        data: DateTime.now(),
        responsavel: responsavel,
        locationId: keyAjuste,
      );
      final novoHistorico = List<MovimentacaoEstoque>.from(produto.historicoUso)..add(novaMovimentacao);

      final produtoAtualizado = produto.copyWith(
        quantidadesPorLocal: mapa,
        historicoUso: novoHistorico,
      );
      await _repository.updateProduto(produtoAtualizado);

      final current = state.value ?? [];
      return [
        for (final p in current) if (p.id == produtoAtualizado.id) produtoAtualizado else p,
      ];
    });
  }

  /// Nova versão considerando localização específica.
  Future<void> updateStockAtLocation({
    required String productId,
    required String locationId,
    required int novaQuantidadeLocal,
    required String responsavel,
  }) async {
    state = await AsyncValue.guard(() async {
      final produto = await _repository.getProdutoById(productId);
      final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
      final quantidadeAnteriorLocal = mapa[locationId] ?? 0;
      final diferenca = novaQuantidadeLocal - quantidadeAnteriorLocal;
      if (diferenca == 0) return state.value ?? [];

      mapa[locationId] = novaQuantidadeLocal;

      final tipo = diferenca > 0 ? TipoMovimentacao.entrada : TipoMovimentacao.saida;
      final novaMovimentacao = MovimentacaoEstoque(
        tipo: tipo,
        quantidade: diferenca.abs(),
        data: DateTime.now(),
        responsavel: responsavel,
        locationId: locationId,
      );
      final novoHistorico = List<MovimentacaoEstoque>.from(produto.historicoUso)..add(novaMovimentacao);

      final produtoAtualizado = produto.copyWith(
        quantidadesPorLocal: mapa,
        historicoUso: novoHistorico,
      );
      await _repository.updateProduto(produtoAtualizado);

      final current = state.value ?? [];
      return [
        for (final p in current) if (p.id == produtoAtualizado.id) produtoAtualizado else p,
      ];
    });
  }

  /// Transfere quantidade entre duas localizações (origem -> destino) de forma atômica.
  /// Regras:
  /// - Se origem não tiver a quantidade solicitada, limita à disponível.
  /// - Remove entradas com zero do mapa após operação.
  /// - Gera duas movimentações (saída na origem, entrada no destino).
  Future<void> transferStock({
    required String productId,
    required String origemLocationId,
    required String destinoLocationId,
    required int quantidade,
    required String responsavel,
  }) async {
    if (quantidade <= 0) return; // nada a fazer
    if (origemLocationId == destinoLocationId) return; // transferência irrelevante
    state = await AsyncValue.guard(() async {
      final produto = await _repository.getProdutoById(productId);
      final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
      final origemAtual = mapa[origemLocationId] ?? 0;
      if (origemAtual <= 0) return state.value ?? [];
      final mover = quantidade > origemAtual ? origemAtual : quantidade;
      final destinoAtual = mapa[destinoLocationId] ?? 0;

      mapa[origemLocationId] = origemAtual - mover;
      mapa[destinoLocationId] = destinoAtual + mover;
      if (mapa[origemLocationId] == 0) {
        mapa.remove(origemLocationId);
      }

      final now = DateTime.now();
      final movSaida = MovimentacaoEstoque(
        tipo: TipoMovimentacao.saida,
        quantidade: mover,
        data: now,
        responsavel: responsavel,
        locationId: origemLocationId,
      );
      final movEntrada = MovimentacaoEstoque(
        tipo: TipoMovimentacao.entrada,
        quantidade: mover,
        data: now,
        responsavel: responsavel,
        locationId: destinoLocationId,
      );

      final novoHistorico = List<MovimentacaoEstoque>.from(produto.historicoUso)
        ..add(movSaida)
        ..add(movEntrada);

      final produtoAtualizado = produto.copyWith(
        quantidadesPorLocal: mapa,
        historicoUso: novoHistorico,
      );
      await _repository.updateProduto(produtoAtualizado);

      final current = state.value ?? [];
      return [
        for (final p in current) if (p.id == produtoAtualizado.id) produtoAtualizado else p,
      ];
    });
  }
}

final stockNotifierProvider =
    StateNotifierProvider<StockNotifier, AsyncValue<List<Produto>>>((ref) {
  return StockNotifier(ref.watch(stockRepositoryProvider));
});
