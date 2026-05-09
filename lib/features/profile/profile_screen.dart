import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/team_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../providers/profile_provider.dart';
import '../../providers/race_provider.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/section_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _scheduleOrCancelNotifications(ProfileState profile) async {
    final notifService = NotificationService.instance;
    await notifService.cancelAll();
    if (!profile.notificationsEnabled) return;
    final season = ref.read(currentSeasonProvider);
    final scheduleAsync = ref.read(scheduleProvider(season));
    scheduleAsync.whenData((races) {
      final upcoming = races.where((r) => !r.isCompleted).take(5);
      for (final race in upcoming) {
        notifService.scheduleRaceNotification(race, profile.minutesBefore);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 64,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 20, 14),
              title: Text(
                'SETTINGS',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // Team Selection
              const SectionHeader(
                label: 'Your Team',
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose your favorite team to personalize the app theme',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TeamGrid(
                        selectedKey: profile.selectedTeamKey,
                        onSelect: (key) async {
                          await notifier.selectTeam(key);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Notifications Section
              const SectionHeader(
                label: 'Notifications',
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: teamTheme.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: teamTheme.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Race Reminders',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Get notified before races start',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: profile.notificationsEnabled,
                            onChanged: (val) async {
                              await notifier.setNotifications(enabled: val);
                              if (val) {
                                await NotificationService.instance
                                    .requestPermissions();
                              }
                              await _scheduleOrCancelNotifications(
                                profile.copyWith(notificationsEnabled: val),
                              );
                            },
                            activeThumbColor: teamTheme.accentColor,
                            trackColor: WidgetStateProperty.resolveWith((s) {
                              if (s.contains(WidgetState.selected)) {
                                return teamTheme.accentColor
                                    .withValues(alpha: 0.3);
                              }
                              return AppColors.surfaceHigh;
                            }),
                          ),
                        ],
                      ),
                      if (profile.notificationsEnabled) ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 16),
                        Text(
                          'REMIND ME',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [15, 30, 60].map((mins) {
                            final isSelected = profile.minutesBefore == mins;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  await notifier.setMinutesBefore(mins);
                                  await _scheduleOrCancelNotifications(
                                    profile.copyWith(minutesBefore: mins),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? teamTheme.accentColor
                                        : AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: AppColors.glassBorder,
                                            width: 1,
                                          ),
                                  ),
                                  child: Text(
                                    '$mins min before',
                                    style: AppTextStyles.labelBold.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.tertiaryContainer,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // About Section
              const SectionHeader(
                label: 'About',
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.info_outline,
                        label: 'Version',
                        value: '1.0.0',
                        accentColor: teamTheme.accentColor,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Season',
                        value: DateTime.now().year.toString(),
                        accentColor: teamTheme.accentColor,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.cloud_outlined,
                        label: 'Data',
                        value: 'Jolpica API',
                        accentColor: teamTheme.accentColor,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.speed_outlined,
                        label: 'Live Data',
                        value: 'OpenF1 API',
                        accentColor: teamTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Center(
                  child: Text(
                    'Powered by OpenF1 API & Jolpica API\nNot affiliated with Formula 1 or FOM',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiaryContainer,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Team Grid ────────────────────────────────────────────────────────────────

class _TeamGrid extends StatelessWidget {
  const _TeamGrid({
    required this.selectedKey,
    required this.onSelect,
  });

  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final teams =
        TeamColors.themes.entries.where((e) => e.key.isNotEmpty).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: teams.map((entry) {
        final key = entry.key;
        final theme = entry.value;
        final isSelected = selectedKey == key;

        return GestureDetector(
          onTap: () => onSelect(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.accentColor
                  : theme.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.accentColor
                    : theme.accentColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Text(
              theme.teamName,
              style: AppTextStyles.labelBold.copyWith(
                color: isSelected ? Colors.white : theme.accentColor,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: accentColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
