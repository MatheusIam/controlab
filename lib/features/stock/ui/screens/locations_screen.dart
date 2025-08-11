import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/stock/application/localizacao_providers.dart';
import 'package:controlab/features/stock/application/localizacao_notifier.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final locationsAsync = ref.watch(localizacaoNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Localizações')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLocationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Erro ao carregar localizações:\n$err'),
          ),
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nenhuma localização cadastrada.\nToque no "+" para adicionar a primeira.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(loc.nome),
                  subtitle: Text('ID: ${loc.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showLocationDialog(context, ref, current: loc),
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, ref, loc),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref, {Localizacao? current}) {
    final controller = TextEditingController(text: current?.nome ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(current == null ? 'Nova Localização' : 'Editar Localização'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da Localização',
            hintText: 'Ex: Geladeira A',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveLocation(ref, controller.text, current),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _saveLocation(ref, controller.text, current),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLocation(WidgetRef ref, String name, Localizacao? current) async {
    if (name.trim().isEmpty) return;
    final notifier = ref.read(localizacaoNotifierProvider.notifier);
    if (current == null) {
      await notifier.addLocation(name.trim());
    } else {
      await notifier.updateLocation(Localizacao(id: current.id, nome: name.trim()));
    }
    // ignore: use_build_context_synchronously
    Navigator.of(ref.context).maybePop();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Localizacao loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Localização'),
        content: Text('Tem certeza que deseja excluir "${loc.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await ref.read(localizacaoNotifierProvider.notifier).deleteLocation(loc.id);
              // ignore: use_build_context_synchronously
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
