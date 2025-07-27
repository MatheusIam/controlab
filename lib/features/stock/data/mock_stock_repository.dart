import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';

final stockRepositoryProvider = Provider<IStockRepository>((ref) {
  return MockStockRepository();
});

class MockStockRepository implements IStockRepository {
  // A lista agora começa vazia.
  final List<Produto> _produtos = [];

  @override
  Future<List<Produto>> getProdutos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_produtos);
  }

  @override
  Future<Produto> getProdutoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _produtos.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> addProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _produtos.add(produto);
  }

  @override
  Future<void> updateProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _produtos.indexWhere((p) => p.id == produto.id);
    if (index != -1) {
      _produtos[index] = produto;
    }
  }

  @override
  Future<void> deleteProduto(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _produtos.removeWhere((p) => p.id == id);
  }
}
