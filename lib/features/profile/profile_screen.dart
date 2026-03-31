import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/team_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/driver_standing_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/race_provider.dart';
import '../../providers/standings_provider.dart';
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
    final standingsAsync = ref.watch(driverStandingsProvider);

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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Text(
                'MY DRIVERS',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
            ),
          ),

          standingsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryContainer,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'Could not load drivers',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ),
            data: (drivers) {
              final favIds = profile.favoriteDriverIds;
              final favDrivers =
                  drivers.where((d) => favIds.contains(d.driverId)).toList();
              final otherDrivers =
                  drivers.where((d) => !favIds.contains(d.driverId)).toList();

              return SliverList(
                delegate: SliverChildListDelegate([
                  // FOLLOWING section
                  if (favDrivers.isNotEmpty) ...[
                    const SectionHeader(
                      label: '★  Following',
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: favDrivers
                            .map((d) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _DriverCard(
                                    driver: d,
                                    isFavorite: true,
                                    onToggle: () =>
                                        notifier.toggleFavorite(d.driverId),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // ALL DRIVERS section
                  SectionHeader(
                    label: favDrivers.isEmpty ? 'All Drivers' : 'Other Drivers',
                    padding: EdgeInsets.fromLTRB(
                        20, favDrivers.isEmpty ? 20 : 24, 20, 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: otherDrivers
                          .map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _DriverCard(
                                  driver: d,
                                  isFavorite: false,
                                  onToggle: () =>
                                      notifier.toggleFavorite(d.driverId),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // SETTINGS section
                  const SectionHeader(
                    label: '⚙  Settings',
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 10),
                  ),

                  // Team picker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR TEAM',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 12),
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

                  const SizedBox(height: 12),

                  // Notifications
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Race Reminders',
                                      style:
                                          AppTextStyles.headlineSmall.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Get notified before the race starts',
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
                                    profile.copyWith(
                                        notificationsEnabled: val),
                                  );
                                },
                                activeThumbColor: AppColors.primaryContainer,
                                trackColor:
                                    WidgetStateProperty.resolveWith((s) {
                                  if (s.contains(WidgetState.selected)) {
                                    return AppColors.primaryContainer
                                        .withOpacity(0.3);
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
                              'NOTIFY ME BEFORE',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [15, 30, 60].map((mins) {
                                final isSelected =
                                    profile.minutesBefore == mins;
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
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryContainer
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
                                        '$mins MIN',
                                        style:
                                            AppTextStyles.labelBold.copyWith(
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

                  // About
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Version', value: '1.0.0'),
                          const SizedBox(height: 12),
                          _InfoRow(
                              label: 'Data Source',
                              value: 'Jolpica / Ergast API'),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Live Data', value: 'OpenF1 API'),
                          const SizedBox(height: 12),
                          _InfoRow(
                              label: 'Season',
                              value: DateTime.now().year.toString()),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Driver Card ──────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.driver,
    required this.isFavorite,
    required this.onToggle,
  });

  final DriverStandingModel driver;
  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(driver.constructorId);
    final accentColor = teamTheme.accentColor;

    return GestureDetector(
      onTap: () {
        context.push('/driver/${driver.driverId}', extra: {
          'driverNumber': driver.permanentNumber,
          'driverName': driver.fullName,
          'constructorId': driver.constructorId,
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Team color left strip
              Container(width: 4, color: accentColor),
              // Card body
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                child: Row(
                  children: [
                    // Ghost position number
                    SizedBox(
                      width: 36,
                      child: Text(
                        driver.position.toString(),
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 28,
                          color: AppColors.surfaceHighest,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Driver info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                driver.code,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  driver.fullName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.tertiaryContainer,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  driver.constructorName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.tertiaryContainer,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${driver.points.toStringAsFixed(0)} PTS',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${driver.wins} W',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 10,
                                  color: AppColors.tertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Star toggle
                    GestureDetector(
                      onTap: onToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            key: ValueKey(isFavorite),
                            color: isFavorite
                                ? const Color(0xFFFFD700)
                                : AppColors.tertiaryContainer,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                  : theme.accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.accentColor
                    : theme.accentColor.withOpacity(0.25),
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
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
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
