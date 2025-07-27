import 'package:controlab/features/stock/domain/produto.dart';

abstract class IStockRepository {
  Future<List<Produto>> getProdutos();
  Future<Produto> getProdutoById(String id);
  Future<void> addProduto(Produto produto);
  Future<void> updateProduto(Produto produto);
  Future<void> deleteProduto(String id);
}
