import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/connectivity_refresher.dart';
import 'providers/profile_provider.dart';
import 'providers/race_provider.dart';
import 'providers/standings_provider.dart';
import 'providers/widget_sync_provider.dart';
import 'router/app_router.dart';
import 'services/widget_data_service.dart';

class F1TrackerApp extends ConsumerStatefulWidget {
  const F1TrackerApp({super.key});

  @override
  ConsumerState<F1TrackerApp> createState() => _F1TrackerAppState();
}

class _F1TrackerAppState extends ConsumerState<F1TrackerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final race = ref.read(nextRaceProvider);
      ref.read(driverStandingsProvider).whenData((drivers) {
        WidgetDataService.instance.push(race: race, drivers: drivers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final router = ref.watch(appRouterProvider);
    ref.watch(connectivityRefresherProvider);
    ref.watch(widgetSyncProvider);

    return AnimatedTheme(
      data: AppTheme.darkTheme(teamTheme: profile.teamTheme),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: MaterialApp.router(
        title: 'F1 Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(teamTheme: profile.teamTheme),
        routerConfig: router,
      ),
    );
  }
}
