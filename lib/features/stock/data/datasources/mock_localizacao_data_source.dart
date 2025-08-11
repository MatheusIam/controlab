import 'package:controlab/features/stock/data/datasources/i_localizacao_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_database.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';

class MockLocalizacaoDataSource implements ILocalizacaoDataSource {
  final MockDatabase _db;

  MockLocalizacaoDataSource(this._db);

  @override
  Future<List<Localizacao>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_db.localizacoes);
  }

  @override
  Future<void> addLocation(String nome) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _db.localizacoes.add(Localizacao(id: _db.generateId(), nome: nome));
  }

  @override
  Future<void> updateLocation(Localizacao localizacao) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _db.localizacoes.indexWhere((l) => l.id == localizacao.id);
    if (index != -1) {
      _db.localizacoes[index] = localizacao;
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _db.localizacoes.removeWhere((l) => l.id == id);
  }
}
