import 'package:flutter/material.dart';

// Enum para representar o status do estoque de um produto.
enum StatusProduto {
  emEstoque,
  baixoEstoque,
  vencido,
}

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

class Produto {
  final String id;
  final String nome;
  final int quantidade;
  final String fornecedor;
  final String validade;
  final String lote;
  final StatusProduto status;

  Produto({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.fornecedor,
    required this.validade,
    required this.lote,
    required this.status,
  });
}