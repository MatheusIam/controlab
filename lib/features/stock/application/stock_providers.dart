import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/data/mock_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';

// Provider que busca a lista de todos os produtos.
final stockListProvider = FutureProvider.autoDispose<List<Produto>>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getProdutos();
});

// Provider de "família" que busca um produto específico pelo seu ID.
final productDetailsProvider =
    FutureProvider.autoDispose.family<Produto, String>((ref, id) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getProdutoById(id);
});