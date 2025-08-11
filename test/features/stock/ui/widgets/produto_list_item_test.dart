import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/ui/widgets/produto_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Widget createTestableWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  final baseProduct = Produto(
    id: '1',
    nome: 'Produto Base',
    quantidade: 10,
    fornecedor: 'Fornecedor',
    lote: 'LOTE001',
    validade: formatter.format(DateTime.now().add(const Duration(days: 30))),
    categoria: CategoriaProduto.reagentes,
    iconCodePoint: Icons.science.codePoint,
  );

  group('Testes Visuais do ProdutoListItem', () {
    testWidgets('deve renderizar com destaque CRÍTICO quando o produto está vencido', (tester) async {
      final produtoVencido = baseProduct.copyWith(
        validade: formatter.format(DateTime.now().subtract(const Duration(days: 1))),
      );

      await tester.pumpWidget(createTestableWidget(
        child: ProdutoListItem(produto: produtoVencido, onTap: () {}),
      ));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.red.shade50);
      expect((card.shape as RoundedRectangleBorder).side.color, Colors.red.shade400);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('deve renderizar com destaque de ATENÇÃO quando o estoque está baixo', (tester) async {
      final produtoEstoqueBaixo = baseProduct.copyWith(quantidade: 5, estoqueMinimo: 5);

      await tester.pumpWidget(createTestableWidget(
        child: ProdutoListItem(produto: produtoEstoqueBaixo, onTap: () {}),
      ));

      final card = tester.widget<Card>(find.byType(Card));
      expect((card.shape as RoundedRectangleBorder).side.color, Colors.orange.shade600);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('deve renderizar com destaque INFORMATIVO quando o estoque está alto', (tester) async {
      final produtoEstoqueAlto = baseProduct.copyWith(quantidade: 20, estoqueMaximo: 20);

      await tester.pumpWidget(createTestableWidget(
        child: ProdutoListItem(produto: produtoEstoqueAlto, onTap: () {}),
      ));

      final card = tester.widget<Card>(find.byType(Card));
      expect((card.shape as RoundedRectangleBorder).side.color, Colors.blue.shade600);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('deve renderizar sem destaque visual quando o produto está normal', (tester) async {
      final produtoNormal = baseProduct.copyWith(
        quantidade: 15,
        estoqueMinimo: 10,
        estoqueMaximo: 20,
      );

      await tester.pumpWidget(createTestableWidget(
        child: ProdutoListItem(produto: produtoNormal, onTap: () {}),
      ));

      final card = tester.widget<Card>(find.byType(Card));
      expect((card.shape as RoundedRectangleBorder).side.color, Colors.transparent);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
    });
  });
}
