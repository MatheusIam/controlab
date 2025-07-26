import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/ui/screens/login_screen.dart';
import 'package:controlab/features/stock/ui/screens/home_screen.dart';
import 'package:controlab/features/stock/ui/screens/product_details_screen.dart';
import 'package:controlab/app/core/ui/widgets/scaffold_with_nav_bar.dart';

// Enum para as rotas, evitando o uso de strings "mágicas".
enum AppRoute { login, home, productDetails, profile, settings }

// Provider do GoRouter para ser acessado globalmente.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      // ShellRoute permite UI persistente (como a BottomNavBar) entre rotas filhas.
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
