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

enum TipoMovimentacao { entrada, saida, ajuste }

class MovimentacaoEstoque {
  final TipoMovimentacao tipo;
  final int quantidade;
  final DateTime data;
  final String responsavel; // Nome do usuário que fez a movimentação
  final String? locationId; // Localização onde ocorreu a movimentação (opcional para compatibilidade)
  final String? justificativa; // Justificativa para ajustes manuais

  MovimentacaoEstoque({
    required this.tipo,
    required this.quantidade,
    required this.data,
    required this.responsavel,
    this.locationId,
    this.justificativa,
  });
}

class Produto {
  // Identificador padrão usado para preencher estoque quando ainda não há granularidade de local.
  static const String defaultLocationId = '_global';
  final String id;
  final String nome;
  // Novo modelo: estoques distribuídos por local de armazenamento.
  final Map<String, int> quantidadesPorLocal;
  final String fornecedor;
  final String validade;
  final String lote;
  final List<MovimentacaoEstoque> historicoUso;
  final List<String> alertas;
  final CategoriaProduto categoria;
  final int iconCodePoint; // Armazena o code point do ícone
  final int? estoqueMinimo; // Limite inferior opcional
  final int? estoqueMaximo; // Limite superior opcional

  Produto({
    required this.id,
    required this.nome,
    Map<String, int>? quantidadesPorLocal,
    int? quantidade, // Compatibilidade temporária (será removido futuramente)
    required this.fornecedor,
    required this.validade,
    required this.lote,
    this.historicoUso = const [],
    this.alertas = const [],
    required this.categoria,
    required this.iconCodePoint,
    this.estoqueMinimo,
    this.estoqueMaximo,
  }) : quantidadesPorLocal = quantidadesPorLocal ?? (quantidade != null ? {defaultLocationId: quantidade} : const {});

  IconData get icone => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Quantidade total agregada somando todas as localizações.
  int get quantidadeTotal => quantidadesPorLocal.isEmpty
      ? 0
      : quantidadesPorLocal.values.fold(0, (acc, v) => acc + v);

  /// Getter legado para manter código existente funcional. Use quantidadeTotal.
  @Deprecated('Use quantidadeTotal ao invés de quantidade. Este getter será removido após a migração de UI/Repos.')
  int get quantidade => quantidadeTotal;
  // Sentinel para distinguir parâmetros omitidos.
  static const Object _sentinel = Object();

  Produto copyWith({
    String? nome,
    // Novo: sobrescreve todo o mapa de quantidades por local
    Map<String, int>? quantidadesPorLocal,
    int? quantidade, // Atalho de compatibilidade: sobrescreve usando defaultLocationId
    String? fornecedor,
    String? validade,
    String? lote,
    List<MovimentacaoEstoque>? historicoUso,
    List<String>? alertas,
    CategoriaProduto? categoria,
    int? iconCodePoint,
    Object? estoqueMinimo = _sentinel,
    Object? estoqueMaximo = _sentinel,
  }) {
    Map<String, int> resolvedMap;
    if (quantidadesPorLocal != null) {
      resolvedMap = Map<String, int>.from(quantidadesPorLocal);
    } else if (quantidade != null) {
      resolvedMap = {defaultLocationId: quantidade};
    } else {
      resolvedMap = this.quantidadesPorLocal;
    }

    return Produto(
      id: id,
      nome: nome ?? this.nome,
      quantidadesPorLocal: resolvedMap,
      fornecedor: fornecedor ?? this.fornecedor,
      validade: validade ?? this.validade,
      lote: lote ?? this.lote,
      historicoUso: historicoUso ?? this.historicoUso,
      alertas: alertas ?? this.alertas,
      categoria: categoria ?? this.categoria,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      estoqueMinimo: estoqueMinimo == _sentinel ? this.estoqueMinimo : estoqueMinimo as int?,
      estoqueMaximo: estoqueMaximo == _sentinel ? this.estoqueMaximo : estoqueMaximo as int?,
    );
  }

  // Status calculado dinamicamente com base em validade e estoque mínimo
  StatusProduto get status {
    // 1. Verifica validade (prioridade alta)
    try {
      final parts = validade.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final expiryDate = DateTime(year, month, day);
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        if (expiryDate.isBefore(todayOnly)) {
          return StatusProduto.vencido;
        }
      }
    } catch (_) {
      // Silencia erros de parsing; poderia logar se necessário.
    }

    // 2. Verifica estoque mínimo
  if (estoqueMinimo != null && quantidadeTotal <= estoqueMinimo!) {
      return StatusProduto.baixoEstoque;
    }

    // 3. Padrão
    return StatusProduto.emEstoque;
  }
}
