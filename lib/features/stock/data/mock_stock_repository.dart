import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/domain/i_stock_repository.dart';
import 'package:controlab/features/stock/domain/produto.dart';

final stockRepositoryProvider = Provider<IStockRepository>((ref) {
  return MockStockRepository();
});

class MockStockRepository implements IStockRepository {
  final List<Produto> _produtos = [
    Produto(
      id: '1',
      nome: 'Kit Soro Fisiológico 0,9%',
      quantidade: 150,
      fornecedor: 'Farmalab',
      validade: '12/12/2026',
      lote: 'LOTE2024A1',
      status: StatusProduto.emEstoque,
    ),
    Produto(
      id: '2',
      nome: 'Luvas Descartáveis (Caixa)',
      quantidade: 20,
      fornecedor: 'MedSafe',
      validade: '01/05/2027',
      lote: 'LOTE2024B2',
      status: StatusProduto.baixoEstoque,
    ),
    Produto(
      id: '3',
      nome: 'Gaze Estéril (Pacote)',
      quantidade: 300,
      fornecedor: 'Farmalab',
      validade: '10/02/2028',
      lote: 'LOTE2023C5',
      status: StatusProduto.emEstoque,
    ),
    Produto(
      id: '4',
      nome: 'Álcool 70% (1 Litro)',
      quantidade: 8,
      fornecedor: 'QuimiClean',
      validade: '30/06/2025',
      lote: 'LOTE2024D1',
      status: StatusProduto.baixoEstoque,
    ),
    Produto(
      id: '5',
      nome: 'Analgésico (Cartela)',
      quantidade: 45,
      fornecedor: 'MedSafe',
      validade: '25/04/2025',
      lote: 'LOTE2023E9',
      status: StatusProduto.vencido,
    ),
  ];

  @override
  Future<List<Produto>> getProdutos() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _produtos;
  }

  @override
  Future<Produto> getProdutoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final produto = _produtos.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Produto não encontrado!'),
    );
    return produto;
  }
}