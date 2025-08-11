import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/application/cq_notifier.dart';

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
  // Observa o estado completo (mantemos por compatibilidade na UI atual).
  final stockState = ref.watch(stockNotifierProvider);
  return stockState.when(
    data: (produtos) {
      try {
        final produto = produtos.firstWhere((p) => p.id == id);
        return AsyncValue.data(produto);
      } catch (e) {
        return AsyncValue.error(
          Exception('Produto com id $id não encontrado.'),
          StackTrace.current,
        );
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Versão ainda mais otimizada que reconstrói apenas quando o produto alvo muda.
/// A UI teria que lidar com Produto? (null enquanto carrega ou não encontrado)
final productDetailsProviderOptimized = Provider.autoDispose
    .family<Produto?, String>((ref, id) {
  return ref.watch(
    stockNotifierProvider.select(
      (asyncList) {
        final list = asyncList.value;
        if (list == null) return null;
        for (final p in list) {
          if (p.id == id) return p;
        }
        return null;
      },
    ),
  );
});

/// Provider simplificado que retorna diretamente (sincrono) o produto ou null.
/// Usa select para minimizar rebuilds e evita embrulhar em AsyncValue adicional.
final productByIdProvider = Provider.autoDispose.family<Produto?, String>((ref, id) {
  return ref.watch(
    stockNotifierProvider.select(
      (asyncList) {
        final produtos = asyncList.value;
        if (produtos == null) return null;
        try {
          return produtos.firstWhere((p) => p.id == id);
        } catch (_) {
          return null;
        }
      },
    ),
  );
});

/// Lista filtrada considerando estado interno do StockNotifier e status CQ.
final filteredStockListProvider = Provider.autoDispose<AsyncValue<List<Produto>>>((ref) {
  final stockState = ref.watch(stockNotifierProvider);
  return stockState.whenData((produtos) {
    final filter = ref.read(stockNotifierProvider.notifier).filterState;
    if (filter.searchTerm.isEmpty && filter.categoria == null && filter.statusCQ == null) {
      return produtos;
    }
    return produtos.where((p) {
      final termOk = filter.searchTerm.isEmpty || p.nome.toLowerCase().contains(filter.searchTerm) || p.lote.toLowerCase().contains(filter.searchTerm);
      if (!termOk) return false;
      final catOk = filter.categoria == null || p.categoria == filter.categoria;
      if (!catOk) return false;
      if (filter.statusCQ != null) {
        final statusAsync = ref.watch(ultimoStatusCQDoLoteProvider(p.lote));
        final statusValue = statusAsync.asData?.value;
        if (statusValue != filter.statusCQ) return false;
      }
      return true;
    }).toList();
  });
});
