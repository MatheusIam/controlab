import 'dart:async';

import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/auth/domain/user.dart';
import 'package:controlab/features/auth/ui/screens/login_screen.dart';
import 'package:controlab/features/stock/ui/screens/home_screen.dart';
import 'package:controlab/features/stock/ui/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/app/core/ui/widgets/scaffold_with_nav_bar.dart';

enum AppRoute { home, login, productDetails, settings }

final goRouterProvider = Provider<GoRouter>((ref) {
  // CORREÇÃO: A lógica foi alterada para usar o novo authStateChangesProvider.
  // Isso fornece um stream estável para o GoRouter escutar.
  final refreshListenable = GoRouterRefreshStream(
    ref.watch(authStateChangesProvider.stream),
  );

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'product-details/:id',
                    name: AppRoute.productDetails.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final productId = state.pathParameters['id']!;
                      return ProductDetailsScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoute.settings.name,
                builder: (context, state) =>
                    const Center(child: Text('Tela de Configurações')),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // A lógica de redirect continua lendo o estado do AuthNotifier
      // para tomar a decisão no momento do redirecionamento.
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn && isAuthenticated) {
        return '/home';
      }

      return null;
    },
  );
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'HomeShell');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'SettingsShell',
);

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
