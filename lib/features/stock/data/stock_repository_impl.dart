import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/data/datasources/i_stock_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_database.dart';
import 'package:controlab/features/stock/data/datasources/mock_stock_data_source.dart';

// Provider para o banco de dados simulado (singleton)
final mockDatabaseProvider = Provider<MockDatabase>((ref) {
  return MockDatabase.instance;
});

// Provider para a fonte de dados de produtos
final stockDataSourceProvider = Provider<IStockDataSource>((ref) {
  final db = ref.watch(mockDatabaseProvider);
  return MockStockDataSource(db);
});

// Provider para o repositório de produtos
final stockRepositoryProvider = Provider<IStockRepository>((ref) {
  final ds = ref.watch(stockDataSourceProvider);
  return StockRepositoryImpl(ds);
});

class StockRepositoryImpl implements IStockRepository {
  final IStockDataSource _dataSource;

  StockRepositoryImpl(this._dataSource);

  @override
  Future<List<Produto>> getProdutos() {
    return _dataSource.getProdutos();
  }

  @override
  Future<Produto> getProdutoById(String id) {
    return _dataSource.getProdutoById(id);
  }

  @override
  Future<void> addProduto(Produto produto) {
    return _dataSource.addProduto(produto);
  }

  @override
  Future<void> updateProduto(Produto produto) {
    return _dataSource.updateProduto(produto);
  }

  @override
  Future<void> deleteProduto(String id) {
    return _dataSource.deleteProduto(id);
  }
}
