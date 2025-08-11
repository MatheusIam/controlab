
import 'package:controlab/features/auth/application/auth_notifier.dart';
import 'package:controlab/features/auth/ui/screens/login_screen.dart';
import 'package:controlab/features/stock/ui/screens/add_product_screen.dart'; // Importa a nova tela
import 'package:controlab/features/stock/ui/screens/home_screen.dart';
import 'package:controlab/features/stock/ui/screens/product_details_screen.dart';
import 'package:controlab/features/stock/ui/screens/locations_screen.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/app/core/ui/widgets/scaffold_with_nav_bar.dart';

enum AppRoute {
  home,
  login,
  productDetails,
  productForm, // Renomeado de addProduct
  settings,
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = GoRouterAuthRefresh(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    navigatorKey: _rootNavigatorKey,
  // Observers removidos após diagnóstico
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
                  // Rota para adicionar/editar produto
                  GoRoute(
                    path: 'product-form',
                    name: AppRoute.productForm.name,
                    builder: (context, state) {
                      // Passa o produto existente como extra para edição
                      final produto = state.extra as Produto?;
                      return AddProductScreen(produto: produto);
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
                builder: (context, state) => const LocationsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
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

class GoRouterAuthRefresh extends ChangeNotifier {
  late final ProviderSubscription _sub; // ignore: unused_field
  GoRouterAuthRefresh(Ref ref) {
    // Escuta mudanças de auth e notifica router.
    _sub = ref.listen(authStateChangesProvider, (_, __) {
      notifyListeners();
    });
  }
}

