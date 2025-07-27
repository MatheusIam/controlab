import 'package:flutter/material.dart';

// Enum para as categorias de produtos
enum CategoriaProduto {
  reagentes('Reagentes', Icons.science_outlined),
  vidraria('Vidraria', Icons.biotech_outlined),
  equipamentos('Equipamentos', Icons.precision_manufacturing_outlined),
  consumiveis('Consumíveis', Icons.medication_liquid_outlined),
  outros('Outros', Icons.category_outlined);

  const CategoriaProduto(this.label, this.icon);
  final String label;
  final IconData icon;
}

// Enum para representar o status do estoque de um produto.
enum StatusProduto { emEstoque, baixoEstoque, vencido }

// Classe auxiliar para conter os atributos de exibição do status.
class StatusDisplay {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  StatusDisplay({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
}

// Extensão para associar atributos de UI ao enum.
extension StatusProdutoExtension on StatusProduto {
  StatusDisplay get displayAttributes {
    switch (this) {
      case StatusProduto.emEstoque:
        return StatusDisplay(
          text: 'Em Estoque',
          backgroundColor: Colors.green.shade100,
          textColor: Colors.green.shade800,
        );
      case StatusProduto.baixoEstoque:
        return StatusDisplay(
          text: 'Estoque Baixo',
          backgroundColor: Colors.orange.shade100,
          textColor: Colors.orange.shade800,
        );
      case StatusProduto.vencido:
        return StatusDisplay(
          text: 'Vencido',
          backgroundColor: Colors.red.shade100,
          textColor: Colors.red.shade800,
        );
    }
  }
}

enum TipoMovimentacao { entrada, saida }

class MovimentacaoEstoque {
  final TipoMovimentacao tipo;
  final int quantidade;
  final DateTime data;
  final String responsavel; // Nome do usuário que fez a movimentação

  MovimentacaoEstoque({
    required this.tipo,
    required this.quantidade,
    required this.data,
    required this.responsavel,
  });
}

class Produto {
  final String id;
  final String nome;
  final int quantidade;
  final String fornecedor;
  final String validade;
  final String lote;
  final StatusProduto status;
  final List<MovimentacaoEstoque> historicoUso;
  final List<String> alertas;
  final CategoriaProduto categoria;
  final int iconCodePoint; // Armazena o code point do ícone

  Produto({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.fornecedor,
    required this.validade,
    required this.lote,
    required this.status,
    this.historicoUso = const [],
    this.alertas = const [],
    required this.categoria,
    required this.iconCodePoint,
  });

  IconData get icone => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Produto copyWith({
    String? nome,
    int? quantidade,
    String? fornecedor,
    String? validade,
    String? lote,
    StatusProduto? status,
    List<MovimentacaoEstoque>? historicoUso,
    List<String>? alertas,
    CategoriaProduto? categoria,
    int? iconCodePoint,
  }) {
    return Produto(
      id: id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      fornecedor: fornecedor ?? this.fornecedor,
      validade: validade ?? this.validade,
      lote: lote ?? this.lote,
      status: status ?? this.status,
      historicoUso: historicoUso ?? this.historicoUso,
      alertas: alertas ?? this.alertas,
      categoria: categoria ?? this.categoria,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}
