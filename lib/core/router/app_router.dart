import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/auth_session.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/auth/login_page.dart';
import '../../presentation/screens/dashboard/dashboard_page.dart';
import '../../presentation/screens/favorites/favorites_page.dart';
import '../../presentation/screens/products/product_details_page.dart';
import '../../presentation/screens/products/products_page.dart';
import '../../presentation/screens/shell/home_shell.dart';
import '../../presentation/screens/splash/splash_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // redirects re-run whenever the auth session changes
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authSessionProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);
      final atLogin = state.matchedLocation == '/login';
      final atSplash = state.matchedLocation == '/splash';

      if (session.isLoading) return atSplash ? null : '/splash';
      if (session.value is! SignedIn) return atLogin ? null : '/login';
      return (atLogin || atSplash) ? '/' : null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    // details open above the shell
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => ProductDetailsPage(
                      productId:
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);

  return router;
});
