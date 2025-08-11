import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/application/localizacao_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Reexporta o provider do repositório para que a UI não precise importar diretamente a camada de dados.
export 'package:controlab/features/stock/data/localizacao_repository_impl.dart' show localizacaoRepositoryProvider;

// O provider do repositório agora vem da implementação concreta baseada em data source.
// Mantemos a mesma assinatura pública para não quebrar a UI existente.

final locationByIdProvider = Provider.autoDispose.family<Localizacao?, String>((ref, id) {
  final asyncList = ref.watch(localizacaoNotifierProvider);
  return asyncList.when(
    data: (locs) {
      try {
        return locs.firstWhere((l) => l.id == id);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
