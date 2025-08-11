import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/data/localizacao_repository_impl.dart';

/// Notifier reativo para a lista de Localizacoes.
class LocalizacaoNotifier extends AutoDisposeAsyncNotifier<List<Localizacao>> {
  @override
  Future<List<Localizacao>> build() async {
    ref.keepAlive();
    final repo = ref.watch(localizacaoRepositoryProvider);
    return repo.getLocations();
  }

  Future<void> addLocation(String nome) async {
    final repo = ref.read(localizacaoRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.addLocation(nome);
      return repo.getLocations();
    });
  // AsyncValue.guard já encapsula erro; nenhuma ação adicional necessária.
  }

  Future<void> updateLocation(Localizacao localizacao) async {
    final repo = ref.read(localizacaoRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.updateLocation(localizacao);
      return repo.getLocations();
    });
  // Mantemos estado de erro conforme retornado por guard.
  }

  Future<void> deleteLocation(String id) async {
    final repo = ref.read(localizacaoRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.deleteLocation(id);
      return repo.getLocations();
    });
  // Mantemos estado de erro conforme retornado por guard.
  }
}

final localizacaoNotifierProvider = AutoDisposeAsyncNotifierProvider<LocalizacaoNotifier, List<Localizacao>>(
  LocalizacaoNotifier.new,
);
