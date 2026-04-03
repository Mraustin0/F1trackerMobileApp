import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/widget_data_service.dart';
import 'race_provider.dart';
import 'standings_provider.dart';

/// Watches [nextRaceProvider] and [driverStandingsProvider].
/// Whenever either resolves or changes, pushes updated data to the
/// home-screen widget automatically.
final widgetSyncProvider = Provider<void>((ref) {
  final race = ref.watch(nextRaceProvider);
  final standingsAsync = ref.watch(driverStandingsProvider);

  standingsAsync.whenData((drivers) {
    WidgetDataService.instance.push(race: race, drivers: drivers);
  });
});
