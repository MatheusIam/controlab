import 'package:controlab/features/stock/domain/registro_cq.dart';

abstract class ICQRepository {
  Future<void> addRegistro(RegistroCQ registro);
  Future<List<RegistroCQ>> getRegistrosByProduto(String produtoId);
  Future<List<RegistroCQ>> getRegistrosByLote(String lote);
  Future<RegistroCQ?> getUltimoRegistroDoLote(String lote);
}
