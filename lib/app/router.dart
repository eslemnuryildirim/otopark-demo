import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otopark_demo/features/kroki/presentation/kroki_page_new.dart'; // Yeni entegre Kroki
import 'package:otopark_demo/features/vehicles/presentation/vehicles_page.dart';
import 'package:otopark_demo/features/vehicles/presentation/vehicle_detail_page.dart';
import 'package:otopark_demo/features/park_slots/presentation/park_slots_page.dart';
import 'package:otopark_demo/features/operations/presentation/operations_page.dart';
import 'package:otopark_demo/features/counters/presentation/counters_page.dart';
import 'package:otopark_demo/features/vehicle_expertiz/presentation/expertiz_page.dart';
import 'package:otopark_demo/features/auth/presentation/login_page.dart';
import 'package:otopark_demo/features/auth/presentation/register_page.dart';
import 'package:otopark_demo/features/auth/providers/auth_provider.dart';
import 'package:otopark_demo/core/utils/go_router_refresh_stream.dart';
import 'shell_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Firebase Auth kontrolü - eğer başlatılamazsa authentication'ı atla
  bool authEnabled = true;
  Stream<User?>? authStream;
  final authStateAsync = ref.watch(authStateProvider);
  
  try {
    final auth = ref.watch(firebaseAuthProvider);
    if (auth == null) {
      authEnabled = false;
      print('⚠️ Firebase Auth devre dışı - authentication atlanıyor');
    } else {
      authStream = auth.authStateChanges();
    }
  } catch (e) {
    authEnabled = false;
    print('⚠️ Firebase Auth başlatılamadı - authentication atlanıyor: $e');
  }

  return GoRouter(
    redirect: (context, state) {
      // Auth devre dışıysa direkt ana sayfaya git
      if (!authEnabled) {
        if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
          return '/kroki';
        }
        return null; // Yönlendirme yok
      }

      // Auth aktifse normal kontrol yap
      try {
        final isLoggedIn = authStateAsync.valueOrNull != null;
        final isGoingToLogin = state.matchedLocation == '/login' || 
                              state.matchedLocation == '/register';

        // Giriş yapmamışsa ve login sayfasında değilse login'e yönlendir
        if (!isLoggedIn && !isGoingToLogin) {
          return '/login';
        }

        // Giriş yapmışsa ve login sayfasındaysa ana sayfaya yönlendir
        if (isLoggedIn && isGoingToLogin) {
          return '/kroki';
        }
      } catch (e) {
        // Auth hatası varsa direkt ana sayfaya git (offline mode)
        print('⚠️ Auth redirect hatası: $e');
        if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
          return '/kroki';
        }
      }

      return null; // Yönlendirme yok
    },
    refreshListenable: authStream != null 
        ? GoRouterRefreshStream(authStream) 
        : null,
    initialLocation: '/kroki',
    routes: [
      // Auth routes (login/register) - ShellRoute dışında
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RegisterPage(),
        ),
      ),
      // Protected routes - ShellRoute içinde
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
                  GoRoute(
                    path: '/kroki',
                    name: 'kroki',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: KrokiPageNew(),
                    ),
                  ),
          GoRoute(
            path: '/vehicles',
            name: 'vehicles',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VehiclesPage(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'vehicle-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return VehicleDetailPage(vehicle: id); // TODO: pass actual vehicle object
                },
              ),
            ],
          ),
          GoRoute(
            path: '/slots',
            name: 'slots',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ParkSlotsPage(),
            ),
          ),
          GoRoute(
            path: '/operations',
            name: 'operations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperationsPage(),
            ),
          ),
          GoRoute(
            path: '/counters',
            name: 'counters',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CountersPage(),
            ),
          ),
          GoRoute(
            path: '/expertiz',
            name: 'expertiz',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpertizPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
