import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'app_notification.dart';

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(const []);
  final _uuid = const Uuid();

  void add({required String titulo, required String mensagem, required NotificationType tipo}) {
    state = [
      AppNotification(id: _uuid.v4(), titulo: titulo, mensagem: mensagem, data: DateTime.now(), tipo: tipo),
      ...state,
    ];
  }

  void marcarComoLida(String id) {
    state = [
      for (final n in state) if (n.id == id) n.copyWith(foiLida: true) else n,
    ];
  }

  void marcarTodasComoLidas() {
    state = [for (final n in state) n.copyWith(foiLida: true)];
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationNotifierProvider);
  return list.where((n) => !n.foiLida).length;
});
