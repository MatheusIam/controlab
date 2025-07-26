import 'dart:async';

import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/auth/domain/user.dart';
import 'package:controlab/features/auth/ui/screens/login_screen.dart';
import 'package:controlab/features/stock/ui/screens/home_screen.dart';
import 'package:controlab/features/stock/ui/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importação que faltava para o ScaffoldWithNavBar
import 'package:controlab/app/core/ui/widgets/scaffold_with_nav_bar.dart';

// Enum para as rotas da aplicação para evitar erros de digitação.
enum AppRoute { home, login, productDetails }

// Provider para o GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  // Notifier para escutar as mudanças de autenticação e atualizar o router.
  // Esta é a abordagem recomendada para o refreshListenable.
  final authState = GoRouterRefreshStream(
    ref.watch(authNotifierProvider.notifier).stream,
  );

  return GoRouter(
    initialLocation: '/login',
    // O refreshListenable agora escuta o nosso notifier.
    refreshListenable: authState,
    // Chave global para o Navigator principal.
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      // Rota aninhada para telas que usam a barra de navegação.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // O widget ScaffoldWithNavBar agora é resolvido corretamente.
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch para a tela principal (Home)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // Rota de detalhe do produto aninhada sob a home.
                  GoRoute(
                    path: 'product-details/:id',
                    name: AppRoute.productDetails.name,
                    builder: (context, state) {
                      final productId = state.pathParameters['id']!;
                      return ProductDetailsScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Outras branches (telas) da barra de navegação podem ser adicionadas aqui.
          // Exemplo:
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/settings',
          //       builder: (context, state) => const SettingsScreen(),
          //     ),
          //   ],
          // ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Lógica de redirecionamento baseada no estado de autenticação.
      final user = ref.read(authNotifierProvider).value;
      final isAuthenticated = user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        // Se não estiver autenticado, redireciona para o login.
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        // Se estiver autenticado e na tela de login, redireciona para a home.
        return '/home';
      }

      return null; // Nenhuma ação de redirecionamento necessária.
    },
  );
});

// Chaves de navegador para o GoRouter.
// Uma para o roteador raiz e outra para o shell de navegação interna.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Classe auxiliar que converte o Stream de autenticação em um Listenable.
// O GoRouter usa isso para saber quando reavaliar suas rotas (redirect).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  GoRouterRefreshStream(Stream<User?> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
