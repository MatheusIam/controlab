import 'package:controlab/features/stock/data/datasources/i_stock_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_database.dart';
import 'package:controlab/features/stock/domain/produto.dart';

class MockStockDataSource implements IStockDataSource {
  final MockDatabase _db;

  MockStockDataSource(this._db);

  @override
  Future<List<Produto>> getProdutos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_db.produtos);
  }

  @override
  Future<Produto> getProdutoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _db.produtos.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> addProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _db.produtos.add(produto);
  }

  @override
  Future<void> updateProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _db.produtos.indexWhere((p) => p.id == produto.id);
    if (index != -1) {
      _db.produtos[index] = produto;
    }
  }

  @override
  Future<void> deleteProduto(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _db.produtos.removeWhere((p) => p.id == id);
  }
}
