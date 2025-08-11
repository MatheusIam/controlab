import 'package:flutter/material.dart';

/// Enum representando o status de Controle de Qualidade (CQ) de um lote.
enum StatusLoteCQ { aprovado, emQuarentena, reprovado, pendente }

/// Entidade que registra um evento de verificação/validação de qualidade de um produto/lote.
class RegistroCQ {
  final String id;
  final String produtoId; // Referência ao produto
  final String lote; // Número do lote avaliado
  final DateTime data; // Data/hora da verificação
  final String responsavel; // Nome do usuário que realizou
  final StatusLoteCQ status; // Resultado
  final String observacoes; // Notas livres
  final String? anexoPath; // Caminho para arquivo (laudo/foto) opcional

  const RegistroCQ({
    required this.id,
    required this.produtoId,
    required this.lote,
    required this.data,
    required this.responsavel,
    required this.status,
    required this.observacoes,
    this.anexoPath,
  });

  RegistroCQ copyWith({
    String? produtoId,
    String? lote,
    DateTime? data,
    String? responsavel,
    StatusLoteCQ? status,
    String? observacoes,
    String? anexoPath,
  }) => RegistroCQ(
        id: id,
        produtoId: produtoId ?? this.produtoId,
        lote: lote ?? this.lote,
        data: data ?? this.data,
        responsavel: responsavel ?? this.responsavel,
        status: status ?? this.status,
        observacoes: observacoes ?? this.observacoes,
        anexoPath: anexoPath ?? this.anexoPath,
      );
}

// UI helpers para exibir status de CQ
class StatusCQDisplay {
  final String label;
  final Color color;
  final IconData icon;
  const StatusCQDisplay({required this.label, required this.color, required this.icon});
}

extension StatusLoteCQDisplayExt on StatusLoteCQ {
  StatusCQDisplay get display {
    switch (this) {
      case StatusLoteCQ.aprovado:
        return StatusCQDisplay(label: 'Aprovado', color: Colors.green.shade700, icon: Icons.verified_outlined);
      case StatusLoteCQ.emQuarentena:
        return StatusCQDisplay(label: 'Quarentena', color: Colors.amber.shade800, icon: Icons.science_outlined);
      case StatusLoteCQ.reprovado:
        return StatusCQDisplay(label: 'Reprovado', color: Colors.red.shade700, icon: Icons.gpp_bad_outlined);
      case StatusLoteCQ.pendente:
        return StatusCQDisplay(label: 'Pendente', color: Colors.grey.shade600, icon: Icons.hourglass_bottom_outlined);
    }
  }
}
