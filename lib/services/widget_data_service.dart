import 'package:home_widget/home_widget.dart';

import '../data/models/driver_standing_model.dart';
import '../data/models/race_model.dart';

class WidgetDataService {
  WidgetDataService._();
  static final WidgetDataService instance = WidgetDataService._();

  static const _appGroupId = 'group.com.example.flutter_application_1.widget';
  static const _androidProviderName = 'NextRaceWidgetProvider';
  static const _iOSWidgetName = 'NextRaceWidget';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _initialized = true;
  }

  Future<void> push({
    required RaceModel? race,
    required List<DriverStandingModel> drivers,
  }) async {
    await init();

    if (race == null) {
      await HomeWidget.saveWidgetData<String>('race_name', 'Season Complete');
      await HomeWidget.saveWidgetData<String>('circuit_name', '—');
      await HomeWidget.saveWidgetData<String>('country_flag', '🏁');
      await HomeWidget.saveWidgetData<String>('countdown', '—');
      await HomeWidget.saveWidgetData<String>('qualifying_label', '—');
      await HomeWidget.saveWidgetData<String>('race_date_iso', '');
    } else {
      await HomeWidget.saveWidgetData<String>('race_name', race.raceName);
      await HomeWidget.saveWidgetData<String>('circuit_name', race.circuitName);
      await HomeWidget.saveWidgetData<String>('country_flag', _flag(race.country));
      await HomeWidget.saveWidgetData<String>('countdown', _countdown(race.raceDate));
      await HomeWidget.saveWidgetData<String>(
        'qualifying_label',
        race.qualifyingDate != null ? _formatDate(race.qualifyingDate!) : '—',
      );
      await HomeWidget.saveWidgetData<String>(
          'race_date_iso', race.raceDate.toIso8601String());
    }

    final top3 = drivers.take(3).toList();
    for (var i = 0; i < 3; i++) {
      if (i < top3.length) {
        final d = top3[i];
        await HomeWidget.saveWidgetData<String>('driver_${i}_code', d.code);
        await HomeWidget.saveWidgetData<String>(
          'driver_${i}_pts',
          d.points % 1 == 0 ? d.points.toInt().toString() : d.points.toString(),
        );
        await HomeWidget.saveWidgetData<String>('driver_${i}_team', d.constructorName);
      } else {
        await HomeWidget.saveWidgetData<String>('driver_${i}_code', '—');
        await HomeWidget.saveWidgetData<String>('driver_${i}_pts', '—');
        await HomeWidget.saveWidgetData<String>('driver_${i}_team', '—');
      }
    }

    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidProviderName,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _countdown(DateTime raceDate) {
    final diff = raceDate.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'Race complete';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours.remainder(24)}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return '${diff.inMinutes}m';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${local.day} ${months[local.month - 1]}, '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  static const _countryFlags = <String, String>{
    'Australia': '🇦🇺', 'Austria': '🇦🇹', 'Azerbaijan': '🇦🇿',
    'Bahrain': '🇧🇭', 'Belgium': '🇧🇪', 'Brazil': '🇧🇷',
    'Canada': '🇨🇦', 'China': '🇨🇳', 'France': '🇫🇷',
    'Germany': '🇩🇪', 'Hungary': '🇭🇺', 'Italy': '🇮🇹',
    'Japan': '🇯🇵', 'Mexico': '🇲🇽', 'Monaco': '🇲🇨',
    'Netherlands': '🇳🇱', 'Portugal': '🇵🇹', 'Qatar': '🇶🇦',
    'Saudi Arabia': '🇸🇦', 'Singapore': '🇸🇬', 'Spain': '🇪🇸',
    'UAE': '🇦🇪', 'United Arab Emirates': '🇦🇪',
    'United Kingdom': '🇬🇧', 'UK': '🇬🇧',
    'USA': '🇺🇸', 'United States': '🇺🇸', 'Miami': '🇺🇸',
    'Las Vegas': '🇺🇸',
  };

  String _flag(String country) => _countryFlags[country] ?? '🏎';
}
