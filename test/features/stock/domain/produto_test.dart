import 'package:controlab/features/stock/domain/produto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  Produto baseProduct = Produto(
    id: '1',
    nome: 'Produto Teste',
    quantidade: 10,
    fornecedor: 'Fornecedor Teste',
    lote: 'LOTE001',
    validade: formatter.format(DateTime.now().add(const Duration(days: 30))),
    categoria: CategoriaProduto.reagentes,
    iconCodePoint: CategoriaProduto.reagentes.icon.codePoint,
    estoqueMinimo: 5,
  );

  group('Lógica do Getter de Status do Produto', () {
    test('deve retornar "vencido" para um produto com data de validade passada', () {
      final dataVencida = formatter.format(DateTime.now().subtract(const Duration(days: 1)));
      final produtoVencido = baseProduct.copyWith(validade: dataVencida);
      expect(produtoVencido.status, StatusProduto.vencido);
    });

    test('deve retornar "vencido" mesmo que o estoque esteja baixo', () {
      final dataVencida = formatter.format(DateTime.now().subtract(const Duration(days: 1)));
      final produtoVencidoEstoqueBaixo = baseProduct.copyWith(
        validade: dataVencida,
        quantidade: 3,
        estoqueMinimo: 5,
      );
      expect(produtoVencidoEstoqueBaixo.status, StatusProduto.vencido);
    });

    test('deve retornar "baixoEstoque" quando a quantidade for igual ao estoque mínimo', () {
      final produtoNoLimite = baseProduct.copyWith(quantidade: 5, estoqueMinimo: 5);
      expect(produtoNoLimite.status, StatusProduto.baixoEstoque);
    });

    test('deve retornar "baixoEstoque" quando a quantidade for menor que o estoque mínimo', () {
      final produtoAbaixoLimite = baseProduct.copyWith(quantidade: 4, estoqueMinimo: 5);
      expect(produtoAbaixoLimite.status, StatusProduto.baixoEstoque);
    });

    test('deve retornar "emEstoque" quando a quantidade for maior que o estoque mínimo', () {
      final produtoOk = baseProduct.copyWith(quantidade: 6, estoqueMinimo: 5);
      expect(produtoOk.status, StatusProduto.emEstoque);
    });

    test('deve retornar "emEstoque" para um produto que vence hoje', () {
      final dataDeHoje = formatter.format(DateTime.now());
      final produtoVenceHoje = baseProduct.copyWith(validade: dataDeHoje);
      expect(produtoVenceHoje.status, StatusProduto.emEstoque);
    });

    test('deve retornar "emEstoque" quando o estoque mínimo não está definido', () {
      final produtoSemMinimo = baseProduct.copyWith(estoqueMinimo: null, quantidade: 1);
      expect(produtoSemMinimo.status, StatusProduto.emEstoque);
    });

    test('deve checar o estoque se a data de validade for mal formatada', () {
      final produtoDataInvalida = baseProduct.copyWith(
        validade: 'DATA_INVALIDA',
        quantidade: 3,
        estoqueMinimo: 5,
      );
      expect(produtoDataInvalida.status, StatusProduto.baixoEstoque);
    });
  });
}
