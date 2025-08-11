import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/core/notifications/notification_notifier.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(notificationNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationNotifierProvider.notifier).marcarTodasComoLidas(),
            child: const Text('Marcar todas', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Nenhuma notificação.'))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (ctx, i) {
                final n = list[i];
                final style = Theme.of(context).textTheme.bodyMedium;
                return ListTile(
                  leading: Icon(n.icon, color: n.foiLida ? Colors.grey : Theme.of(context).colorScheme.primary),
                  title: Text(n.titulo, style: style?.copyWith(fontWeight: n.foiLida ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(n.data)}\n${n.mensagem}'),
                  isThreeLine: true,
                  trailing: n.foiLida ? null : const Icon(Icons.fiber_new, color: Colors.blue),
                  onTap: () => ref.read(notificationNotifierProvider.notifier).marcarComoLida(n.id),
                );
              },
            ),
    );
  }
}
