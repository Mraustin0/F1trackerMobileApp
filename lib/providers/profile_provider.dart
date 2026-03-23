import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/constants/hive_constants.dart';
import '../core/constants/team_colors.dart';
import '../core/theme/team_theme_extension.dart';

class ProfileState {
  final String selectedTeamKey;
  final bool notificationsEnabled;
  final int minutesBefore;

  const ProfileState({
    this.selectedTeamKey = '',
    this.notificationsEnabled = true,
    this.minutesBefore = 30,
  });

  TeamTheme get teamTheme =>
      TeamColors.themes[selectedTeamKey] ?? TeamColors.themes['']!;

  ProfileState copyWith({
    String? selectedTeamKey,
    bool? notificationsEnabled,
    int? minutesBefore,
  }) {
    return ProfileState(
      selectedTeamKey: selectedTeamKey ?? this.selectedTeamKey,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
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
    state = ProfileState(
      selectedTeamKey: team,
      notificationsEnabled: notif,
      minutesBefore: mins,
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
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
