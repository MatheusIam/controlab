import 'package:controlab/features/stock/domain/i_localizacao_repository.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:uuid/uuid.dart';

class MockLocalizacaoRepository implements ILocalizacaoRepository {
  final List<Localizacao> _localizacoes = const [
    Localizacao(id: 'loc-01', nome: 'Geladeira A'),
    Localizacao(id: 'loc-02', nome: 'Almoxarifado Principal'),
    Localizacao(id: 'loc-03', nome: 'Bancada de Hematologia'),
  ].toList();

  final _uuid = const Uuid();

  @override
  Future<List<Localizacao>> getLocations() async {
  await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_localizacoes);
  }

  @override
  Future<void> addLocation(String nome) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _localizacoes.add(Localizacao(id: _uuid.v4(), nome: nome));
  }

  @override
  Future<void> updateLocation(Localizacao localizacao) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _localizacoes.indexWhere((l) => l.id == localizacao.id);
    if (index != -1) {
      _localizacoes[index] = localizacao;
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _localizacoes.removeWhere((l) => l.id == id);
  }
}
