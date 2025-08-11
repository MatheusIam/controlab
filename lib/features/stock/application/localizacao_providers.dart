import 'package:controlab/features/stock/data/mock_localizacao_repository.dart';
import 'package:controlab/features/stock/domain/i_localizacao_repository.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localizacaoRepositoryProvider = Provider<ILocalizacaoRepository>((ref) {
  return MockLocalizacaoRepository();
});

final locationsListProvider = FutureProvider.autoDispose<List<Localizacao>>((ref) {
  final repo = ref.watch(localizacaoRepositoryProvider);
  return repo.getLocations();
});

final locationByIdProvider = Provider.autoDispose.family<Localizacao?, String>((ref, id) {
  final asyncList = ref.watch(locationsListProvider);
  return asyncList.whenData((locs) {
    try {
      return locs.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }).value;
});
