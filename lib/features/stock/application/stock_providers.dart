import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';

// Este provider simplesmente expõe o estado do StateNotifier.
// A UI irá observá-lo para obter a lista de produtos.
final stockListProvider = Provider.autoDispose<AsyncValue<List<Produto>>>((
  ref,
) {
  return ref.watch(stockNotifierProvider);
});

// CORREÇÃO: Este provider agora deriva o estado AsyncValue de um único produto
// a partir da lista principal, tratando todos os casos (data, loading, error).
// Ele retorna um AsyncValue<Produto> não nulo, que a UI pode usar com .when().
final productDetailsProvider = Provider.autoDispose
    .family<AsyncValue<Produto>, String>((ref, id) {
      // Observa o estado do notifier principal.
      final stockState = ref.watch(stockNotifierProvider);

      // Mapeia o estado da lista para o estado de um único item.
      return stockState.when(
        data: (produtos) {
          try {
            // Tenta encontrar o produto na lista.
            final produto = produtos.firstWhere((p) => p.id == id);
            // Se encontrar, retorna um estado de dados com o produto.
            return AsyncValue.data(produto);
          } catch (e) {
            // Se o produto não for encontrado, retorna um estado de erro claro.
            return AsyncValue.error(
              Exception('Produto com id $id não encontrado.'),
              StackTrace.current,
            );
          }
        },
        // Propaga os estados de carregamento e erro da lista principal.
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    });
