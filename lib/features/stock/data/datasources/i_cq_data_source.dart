import 'package:controlab/features/stock/domain/registro_cq.dart';

/// Contrato para operações de Controle de Qualidade (CQ) em nível de data source.
abstract class ICQDataSource {
  Future<void> addRegistro(RegistroCQ registro);
  Future<List<RegistroCQ>> getRegistrosByProduto(String produtoId);
  Future<List<RegistroCQ>> getRegistrosByLote(String lote);
  Future<RegistroCQ?> getUltimoRegistroDoLote(String lote);
}
