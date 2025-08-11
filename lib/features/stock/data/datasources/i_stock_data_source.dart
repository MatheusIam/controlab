import 'package:controlab/features/stock/domain/produto.dart';

/// Contrato para a fonte de dados de produtos.
abstract class IStockDataSource {
  Future<List<Produto>> getProdutos();
  Future<Produto> getProdutoById(String id);
  Future<void> addProduto(Produto produto);
  Future<void> updateProduto(Produto produto);
  Future<void> deleteProduto(String id);
}
