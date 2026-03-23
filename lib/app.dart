import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/profile_provider.dart';
import 'router/app_router.dart';

class F1TrackerApp extends ConsumerWidget {
  const F1TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final router = ref.watch(appRouterProvider);

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
