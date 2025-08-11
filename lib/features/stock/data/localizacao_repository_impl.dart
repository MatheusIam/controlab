import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_localizacao_repository.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/data/datasources/i_localizacao_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_localizacao_data_source.dart';
import 'package:controlab/features/stock/data/stock_repository_impl.dart';

// Reuso do mesmo banco de dados mock
final localizacaoDataSourceProvider = Provider<ILocalizacaoDataSource>((ref) {
  final db = ref.watch(mockDatabaseProvider); // definido em stock_repository_impl.dart
  return MockLocalizacaoDataSource(db);
});

final localizacaoRepositoryProvider = Provider<ILocalizacaoRepository>((ref) {
  final ds = ref.watch(localizacaoDataSourceProvider);
  return LocalizacaoRepositoryImpl(ds);
});

class LocalizacaoRepositoryImpl implements ILocalizacaoRepository {
  final ILocalizacaoDataSource _dataSource;

  LocalizacaoRepositoryImpl(this._dataSource);

  @override
  Future<List<Localizacao>> getLocations() {
    return _dataSource.getLocations();
  }

  @override
  Future<void> addLocation(String nome) {
    return _dataSource.addLocation(nome);
  }

  @override
  Future<void> updateLocation(Localizacao localizacao) {
    return _dataSource.updateLocation(localizacao);
  }

  @override
  Future<void> deleteLocation(String id) {
    return _dataSource.deleteLocation(id);
  }
}
