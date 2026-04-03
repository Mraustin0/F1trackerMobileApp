import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';
import 'race_provider.dart';
import 'standings_provider.dart';

/// Watches connectivity and auto-invalidates all data providers
/// when the device comes back online (offline → online transition).
final connectivityRefresherProvider = Provider<void>((ref) {
  ref.listen<bool>(isOnlineProvider, (previous, current) {
    if (previous == false && current == true) {
      ref.invalidate(driverStandingsProvider);
      ref.invalidate(constructorStandingsProvider);
      ref.invalidate(scheduleProvider);
    }
  });
});
