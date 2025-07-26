import 'package:controlab/features/stock/domain/produto.dart';

abstract class IStockRepository {
  Future<List<Produto>> getProdutos();
  Future<Produto> getProdutoById(String id);
}