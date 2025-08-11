import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/core/notifications/notification_notifier.dart';
import 'package:controlab/features/auth/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Widget que representa a estrutura principal da tela com uma barra de navegação.
/// Este widget é usado pelo [StatefulShellRoute] do GoRouter para encapsular
/// as diferentes branches (telas) da navegação.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// O shell de navegação fornecido pelo GoRouter. Contém o widget filho
  /// (a tela atual) e os métodos para navegar entre as branches.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta as mudanças no estado de autenticação para, por exemplo,
    // deslogar o usuário caso o estado se torne nulo.
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      // Exemplo: poderia mostrar um snackbar em caso de erro de autenticação.
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de autenticação: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      // O corpo do Scaffold é a tela atual gerenciada pelo navigationShell.
      body: navigationShell,
      // A barra de navegação inferior.
      bottomNavigationBar: Consumer(builder: (context, ref, _) {
        final role = ref.watch(currentUserRoleProvider);
        final isAdmin = role == UserRole.administrador;
        final destinations = <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Relatórios',
            ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ];
        // Branch order in router: 0 Home, 1 Reports, 2 Settings (reports always registered).
        int current = navigationShell.currentIndex;
        int effectiveIndex;
        if (isAdmin) {
          effectiveIndex = current; // direct mapping 0,1,2
        } else {
          // Hide reports: map router index 0->0, 2->1. If currently on 1 (reports) fallback to 0.
            if (current == 0) {
              effectiveIndex = 0;
            } else if (current == 2) {
              effectiveIndex = 1;
            } else { // current == 1 (reports hidden)
              effectiveIndex = 0;
            }
        }
        return NavigationBar(
          selectedIndex: effectiveIndex,
          destinations: destinations,
          onDestinationSelected: (tapIndex) {
            int targetBranchIndex;
            if (isAdmin) {
              targetBranchIndex = tapIndex; // 0,1,2
            } else {
              // tap 0->home(0), tap1->settings(2)
              targetBranchIndex = tapIndex == 0 ? 0 : 2;
            }
            navigationShell.goBranch(
              targetBranchIndex,
              initialLocation: targetBranchIndex == navigationShell.currentIndex,
            );
          },
        );
      }),
      // Exemplo de AppBar que poderia ter ações de logout.
      appBar: AppBar(
        title: const Text('Controlab'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final unread = ref.watch(unreadNotificationsCountProvider);
            return IconButton(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text(unread.toString()),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () { context.push('/notifications'); },
            );
          }),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Chama o método de logout do notificador de autenticação.
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
