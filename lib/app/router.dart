import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/presentation/kroki_page_new.dart'; // Yeni entegre Kroki
import 'package:otopark_demo/features/vehicles/presentation/vehicles_page.dart';
import 'package:otopark_demo/features/vehicles/presentation/vehicle_detail_page.dart';
import 'package:otopark_demo/features/park_slots/presentation/park_slots_page.dart';
import 'package:otopark_demo/features/operations/presentation/operations_page.dart';
import 'package:otopark_demo/features/counters/presentation/counters_page.dart';
import 'shell_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/kroki',
    routes: [
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
        ],
      ),
    ],
  );
});
