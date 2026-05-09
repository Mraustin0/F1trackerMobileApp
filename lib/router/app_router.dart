import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/race_detail/race_detail_screen.dart';
import '../features/standings/standings_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/driver_detail/driver_detail_screen.dart';
import '../shared/widgets/f1_nav_bar.dart';
import '../data/models/race_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return F1ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/standings',
                builder: (context, state) => const StandingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/race/:circuitId',
        builder: (context, state) {
          final circuitId = state.pathParameters['circuitId'] ?? '';
          final race = state.extra as RaceModel?;
          return RaceDetailScreen(circuitId: circuitId, race: race);
        },
      ),
      GoRoute(
        path: '/driver/:driverId',
        builder: (context, state) {
          final driverId = state.pathParameters['driverId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DriverDetailScreen(
            driverId: driverId,
            driverNumber: extra['driverNumber'] as int? ?? 0,
            driverName: extra['driverName'] as String? ?? '',
            constructorId: extra['constructorId'] as String? ?? '',
          );
        },
      ),
    ],
  );
});

class F1ShellScaffold extends StatelessWidget {
  const F1ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: F1NavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
