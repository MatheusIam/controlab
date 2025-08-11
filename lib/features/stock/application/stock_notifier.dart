import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/data/mock_stock_repository.dart';

class StockNotifier extends StateNotifier<AsyncValue<List<Produto>>> {
  final IStockRepository _repository;

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

  Future<void> addProduct(Produto produto) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addProduto(produto);
      await loadProdutos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateProduct(Produto produto) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProduto(produto);
      await loadProdutos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStock(String productId, int quantidade, String responsavel) async {
     try {
      final produto = await _repository.getProdutoById(productId);
      final diferenca = quantidade - produto.quantidade;

      if (diferenca == 0) return;

      final tipo = diferenca > 0 ? TipoMovimentacao.entrada : TipoMovimentacao.saida;
      
      final novaMovimentacao = MovimentacaoEstoque(
        tipo: tipo,
        quantidade: diferenca.abs(),
        data: DateTime.now(),
        responsavel: responsavel,
      );

      final novoHistorico = List<MovimentacaoEstoque>.from(produto.historicoUso)..add(novaMovimentacao);

      final produtoAtualizado = produto.copyWith(
        quantidade: quantidade,
        historicoUso: novoHistorico,
      );

      await _repository.updateProduto(produtoAtualizado);
      await loadProdutos();
    } catch (e, st) {
      // Tratar erro
    }
  }

  /// Nova versão considerando localização específica.
  Future<void> updateStockAtLocation({
    required String productId,
    required String locationId,
    required int novaQuantidadeLocal,
    required String responsavel,
  }) async {
    try {
      final produto = await _repository.getProdutoById(productId);
      final mapa = Map<String, int>.from(produto.quantidadesPorLocal);
      final quantidadeAnteriorLocal = mapa[locationId] ?? 0;
      final diferenca = novaQuantidadeLocal - quantidadeAnteriorLocal;
      if (diferenca == 0) return;

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
      await loadProdutos();
    } catch (_) {
      // TODO: log / error handling
    }
  }
}

final stockNotifierProvider =
    StateNotifierProvider<StockNotifier, AsyncValue<List<Produto>>>((ref) {
  return StockNotifier(ref.watch(stockRepositoryProvider));
});
