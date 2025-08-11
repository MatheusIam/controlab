import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/data/datasources/i_cq_data_source.dart';
import 'package:controlab/features/stock/data/datasources/mock_cq_data_source.dart';
import 'package:controlab/features/stock/domain/i_cq_repository.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:controlab/features/stock/data/stock_repository_impl.dart'; // para mockDatabaseProvider

final cqDataSourceProvider = Provider<ICQDataSource>((ref){
  final db = ref.watch(mockDatabaseProvider); // reutiliza provider já existente do DB
  return MockCQDataSource(db);
});

final cqRepositoryProvider = Provider<ICQRepository>((ref){
  final ds = ref.watch(cqDataSourceProvider);
  return CQRepositoryImpl(ds);
});

class CQRepositoryImpl implements ICQRepository {
  final ICQDataSource _ds;
  CQRepositoryImpl(this._ds);

  @override
  Future<void> addRegistro(RegistroCQ registro) => _ds.addRegistro(registro);

  @override
  Future<List<RegistroCQ>> getRegistrosByProduto(String produtoId) => _ds.getRegistrosByProduto(produtoId);

  @override
  Future<List<RegistroCQ>> getRegistrosByLote(String lote) => _ds.getRegistrosByLote(lote);

  @override
  Future<RegistroCQ?> getUltimoRegistroDoLote(String lote) => _ds.getUltimoRegistroDoLote(lote);
}
