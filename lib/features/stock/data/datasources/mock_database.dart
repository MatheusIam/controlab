import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:uuid/uuid.dart';

/// Singleton que simula um banco de dados em memória para a aplicação.
/// Mantém o estado dos dados durante a sessão.
class MockDatabase {
  // Instância singleton
  static final MockDatabase instance = MockDatabase._privateConstructor();
  MockDatabase._privateConstructor();

  final Uuid _uuid = const Uuid();

  // Tabelas simuladas
  final List<Produto> produtos = [];
  final List<Localizacao> localizacoes = [
    const Localizacao(id: 'loc-01', nome: 'Geladeira A'),
    const Localizacao(id: 'loc-02', nome: 'Almoxarifado Principal'),
    const Localizacao(id: 'loc-03', nome: 'Bancada de Hematologia'),
  ];
  // Registros de Controle de Qualidade (CQ) por produto/lote
  final List<RegistroCQ> registrosCQ = [];

  // Métodos utilitários
  String generateId() => _uuid.v4();
}
