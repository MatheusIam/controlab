import 'package:controlab/features/stock/domain/localizacao.dart';

/// Contrato para a fonte de dados de localizações.
abstract class ILocalizacaoDataSource {
  Future<List<Localizacao>> getLocations();
  Future<void> addLocation(String nome);
  Future<void> updateLocation(Localizacao localizacao);
  Future<void> deleteLocation(String id);
}
