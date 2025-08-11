// Interface de repositório para gerenciar localizações de estoque.
import 'package:controlab/features/stock/domain/localizacao.dart';

abstract class ILocalizacaoRepository {
  Future<List<Localizacao>> getLocations();
  Future<void> addLocation(String nome);
  Future<void> updateLocation(Localizacao localizacao);
  Future<void> deleteLocation(String id);
}
