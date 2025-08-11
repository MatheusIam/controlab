import 'package:flutter/material.dart';

enum NotificationType { qualidade, estoque, validade }

class AppNotification {
  final String id;
  final String titulo;
  final String mensagem;
  final DateTime data;
  final NotificationType tipo;
  final bool foiLida;
  const AppNotification({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.data,
    required this.tipo,
    this.foiLida = false,
  });

  AppNotification copyWith({bool? foiLida}) => AppNotification(
        id: id,
        titulo: titulo,
        mensagem: mensagem,
        data: data,
        tipo: tipo,
        foiLida: foiLida ?? this.foiLida,
      );

  IconData get icon => switch (tipo) {
        NotificationType.qualidade => Icons.science_outlined,
        NotificationType.estoque => Icons.inventory_2_outlined,
        NotificationType.validade => Icons.event_busy_outlined,
      };
}
