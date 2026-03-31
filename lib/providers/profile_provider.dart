import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/constants/hive_constants.dart';
import '../core/constants/team_colors.dart';
import '../core/theme/team_theme_extension.dart';

class ProfileState {
  final String selectedTeamKey;
  final bool notificationsEnabled;
  final int minutesBefore;
  final List<String> favoriteDriverIds;

  const ProfileState({
    this.selectedTeamKey = '',
    this.notificationsEnabled = true,
    this.minutesBefore = 30,
    this.favoriteDriverIds = const [],
  });

  TeamTheme get teamTheme =>
      TeamColors.themes[selectedTeamKey] ?? TeamColors.themes['']!;

  ProfileState copyWith({
    String? selectedTeamKey,
    bool? notificationsEnabled,
    int? minutesBefore,
    List<String>? favoriteDriverIds,
  }) {
    return ProfileState(
      selectedTeamKey: selectedTeamKey ?? this.selectedTeamKey,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      favoriteDriverIds: favoriteDriverIds ?? this.favoriteDriverIds,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    _load();
  }

  void _load() {
    final box = Hive.box(HiveConstants.prefsBox);
    final team = box.get(HiveConstants.teamKey, defaultValue: '') as String;
    final notif =
        box.get(HiveConstants.notifEnabledKey, defaultValue: true) as bool;
    final mins =
        box.get(HiveConstants.notifMinutesKey, defaultValue: 30) as int;
    final favs =
        (box.get(HiveConstants.favoriteDriversKey, defaultValue: <String>[])
                as List)
            .cast<String>();
    state = ProfileState(
      selectedTeamKey: team,
      notificationsEnabled: notif,
      minutesBefore: mins,
      favoriteDriverIds: favs,
    );
  }

  Future<void> selectTeam(String teamKey) async {
    final box = Hive.box(HiveConstants.prefsBox);
    await box.put(HiveConstants.teamKey, teamKey);
    state = state.copyWith(selectedTeamKey: teamKey);
  }

  Future<void> setNotifications({required bool enabled}) async {
    final box = Hive.box(HiveConstants.prefsBox);
    await box.put(HiveConstants.notifEnabledKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setMinutesBefore(int minutes) async {
    final box = Hive.box(HiveConstants.prefsBox);
    await box.put(HiveConstants.notifMinutesKey, minutes);
    state = state.copyWith(minutesBefore: minutes);
  }

  Future<void> setFavoriteDrivers(List<String> driverIds) async {
    final box = Hive.box(HiveConstants.prefsBox);
    await box.put(HiveConstants.favoriteDriversKey, driverIds);
    state = state.copyWith(favoriteDriverIds: driverIds);
  }

  Future<void> toggleFavorite(String driverId) async {
    final current = List<String>.from(state.favoriteDriverIds);
    if (current.contains(driverId)) {
      current.remove(driverId);
    } else {
      current.add(driverId);
    }
    final box = Hive.box(HiveConstants.prefsBox);
    await box.put(HiveConstants.favoriteDriversKey, current);
    state = state.copyWith(favoriteDriverIds: current);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
