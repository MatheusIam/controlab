import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/auth/ui/screens/login_screen.dart';
import 'package:controlab/features/stock/ui/screens/home_screen.dart';
import 'package:controlab/features/stock/ui/screens/product_details_screen.dart';
import 'package:controlab/app/core/ui/widgets/scaffold_with_nav_bar.dart';

enum AppRoute { login, home, productDetails, profile, settings }

// Classe auxiliar para notificar o GoRouter sobre mudanças no stream de autenticação.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    // O refreshListenable garante que o GoRouter reavalie as rotas quando o estado de autenticação mudar.
    // CORREÇÃO: O stream é acessado a partir do provider, não do notifier.
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authNotifierProvider.stream),
    ),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authNotifier.isAuthenticated;
      final bool isLoggingIn = state.uri.toString() == '/login';

      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      if (loggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: AppRoute.home.name,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                name: AppRoute.productDetails.name,
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductDetailsScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: AppRoute.profile.name,
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Perfil'),
          ),
          GoRoute(
            path: '/settings',
            name: AppRoute.settings.name,
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Configurações'),
          ),
        ],
      ),
    ],
  );
});

// Tela genérica para funcionalidades ainda não implementadas.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Tela de $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
