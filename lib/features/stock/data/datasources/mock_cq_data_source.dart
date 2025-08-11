import 'package:controlab/features/stock/data/datasources/i_cq_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_database.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';

class MockCQDataSource implements ICQDataSource {
  final MockDatabase _db;
  MockCQDataSource(this._db);

  @override
  Future<void> addRegistro(RegistroCQ registro) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _db.registrosCQ.add(registro);
  }

  @override
  Future<List<RegistroCQ>> getRegistrosByProduto(String produtoId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _db.registrosCQ.where((r) => r.produtoId == produtoId).toList()
      ..sort((a,b)=> b.data.compareTo(a.data));
  }

  @override
  Future<List<RegistroCQ>> getRegistrosByLote(String lote) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _db.registrosCQ.where((r) => r.lote == lote).toList()
      ..sort((a,b)=> b.data.compareTo(a.data));
  }

  @override
  Future<RegistroCQ?> getUltimoRegistroDoLote(String lote) async {
    final registros = await getRegistrosByLote(lote);
    if (registros.isEmpty) return null;
    return registros.first; // já ordenado desc
  }
}
