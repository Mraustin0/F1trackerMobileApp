import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../data/models/race_model.dart';
import '../../data/models/lap_record_model.dart';
import '../../providers/race_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/pulse_dot.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/staggered_list.dart';

const kCircuitData = {
  'suzuka': {'laps': 53, 'length': '5.807 km'},
  'marina_bay': {'laps': 62, 'length': '5.063 km'},
  'monza': {'laps': 53, 'length': '5.793 km'},
  'spa': {'laps': 44, 'length': '7.004 km'},
  'silverstone': {'laps': 52, 'length': '5.891 km'},
  'monaco': {'laps': 78, 'length': '3.337 km'},
  'bahrain': {'laps': 57, 'length': '5.412 km'},
  'albert_park': {'laps': 58, 'length': '5.278 km'},
  'americas': {'laps': 56, 'length': '5.513 km'},
  'hungaroring': {'laps': 70, 'length': '4.381 km'},
  'red_bull_ring': {'laps': 71, 'length': '4.318 km'},
  'zandvoort': {'laps': 72, 'length': '4.259 km'},
  'interlagos': {'laps': 71, 'length': '4.309 km'},
  'yas_marina': {'laps': 58, 'length': '5.281 km'},
  'baku': {'laps': 51, 'length': '6.003 km'},
  'jeddah': {'laps': 50, 'length': '6.174 km'},
  'miami': {'laps': 57, 'length': '5.412 km'},
  'las_vegas': {'laps': 50, 'length': '6.120 km'},
  'losail': {'laps': 57, 'length': '5.380 km'},
  'catalunya': {'laps': 66, 'length': '4.657 km'},
};

class RaceDetailScreen extends ConsumerWidget {
  const RaceDetailScreen({
    super.key,
    required this.circuitId,
    this.race,
  });

  final String circuitId;
  final RaceModel? race;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(currentSeasonProvider);
    final scheduleAsync = ref.watch(scheduleProvider(season));

    // Resolve race from extra or from schedule
    RaceModel? resolvedRace = race;
    if (resolvedRace == null) {
      scheduleAsync.whenData((races) {
        try {
          resolvedRace =
              races.firstWhere((r) => r.circuitId == circuitId);
        } catch (_) {}
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: resolvedRace == null
          ? _buildLoading()
          : _RaceDetailBody(race: resolvedRace!, circuitId: circuitId),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryContainer),
    );
  }
}

class _RaceDetailBody extends StatelessWidget {
  const _RaceDetailBody({required this.race, required this.circuitId});

  final RaceModel race;
  final String circuitId;

  List<_SessionEntry> _buildSessions() {
    final entries = <_SessionEntry>[];

    if (race.practice1Date != null) {
      entries.add(_SessionEntry(
        name: 'Practice 1',
        date: race.practice1Date!,
        durationMins: 60,
      ));
    }
    if (race.practice2Date != null) {
      entries.add(_SessionEntry(
        name: race.sprintDate != null ? 'Sprint Qualifying' : 'Practice 2',
        date: race.practice2Date!,
        durationMins: 60,
      ));
    }
    if (race.practice3Date != null) {
      entries.add(_SessionEntry(
        name: 'Practice 3',
        date: race.practice3Date!,
        durationMins: 60,
      ));
    }
    if (race.sprintDate != null) {
      entries.add(_SessionEntry(
        name: 'Sprint Race',
        date: race.sprintDate!,
        durationMins: 60,
      ));
    }
    if (race.qualifyingDate != null) {
      entries.add(_SessionEntry(
        name: 'Qualifying',
        date: race.qualifyingDate!,
        durationMins: 60,
        isUpNext: !race.isCompleted &&
            race.qualifyingDate!.isAfter(DateTime.now().toUtc()),
      ));
    }
    entries.add(_SessionEntry(
      name: 'Race',
      date: race.raceDate,
      durationMins: 120,
      isRace: true,
      isUpNext: race.isNextRace,
    ));

    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;
    final circuitInfo = kCircuitData[circuitId.toLowerCase()];
    final lapRecord = kLapRecords[circuitId.toLowerCase()];
    final sessions = _buildSessions();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Sliver app bar with hero circuit name
        SliverAppBar(
          pinned: true,
          expandedHeight: 180,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: teamTheme.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: teamTheme.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    race.isNextRace
                        ? 'NEXT RACE'
                        : 'ROUND ${race.round}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: teamTheme.accentColor,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Race name with Hero
                Hero(
                  tag: 'race-name-$circuitId',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      race.raceName.toUpperCase(),
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    teamTheme.accentColor.withOpacity(0.08),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            // Circuit subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${race.circuitName}  ·  ${race.locality}, ${race.country}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.tertiaryContainer,
                ),
              ),
            ),

            // Track Stats
            if (circuitInfo != null) ...[
              const SectionHeader(
                label: 'Track Stats',
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'LAPS',
                        value: circuitInfo['laps'].toString(),
                        icon: Icons.repeat_rounded,
                        accentColor: teamTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'LENGTH',
                        value: circuitInfo['length'].toString(),
                        icon: Icons.straighten_rounded,
                        accentColor: teamTheme.accentColor,
                      ),
                    ),
                    if (lapRecord != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'LAP RECORD',
                          value: lapRecord.lapTime,
                          sublabel: lapRecord.driverCode,
                          icon: Icons.timer_outlined,
                          accentColor: const Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Lap Record Detail
            if (lapRecord != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B59B6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FASTEST LAP RECORD',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF9B59B6),
                                fontSize: 8,
                              ),
                            ),
                            Text(
                              lapRecord.lapTime,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: const Color(0xFFD7B4F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(lapRecord.driverName,
                              style: AppTextStyles.bodyMedium),
                          Text(
                            lapRecord.team,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Session Schedule
            const SectionHeader(
              label: 'Weekend Schedule',
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StaggeredList(
                delayMs: 60,
                children: sessions
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SessionCard(
                              session: s,
                              accentColor: teamTheme.accentColor),
                        ))
                    .toList(),
              ),
            ),

            // Live tracking card if next race
            if (race.isNextRace)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _LiveTrackingCard(accentColor: teamTheme.accentColor),
              ),

            const SizedBox(height: 100),
          ]),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.sublabel,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 16,
              color: AppColors.onSurface,
            ),
          ),
          if (sublabel != null)
            Text(sublabel!, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}

class _SessionEntry {
  const _SessionEntry({
    required this.name,
    required this.date,
    required this.durationMins,
    this.isUpNext = false,
    this.isRace = false,
  });

  final String name;
  final DateTime date;
  final int durationMins;
  final bool isUpNext;
  final bool isRace;
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.accentColor,
  });

  final _SessionEntry session;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final localDate = session.date.toLocal();
    final dayStr = DateFormat('EEE').format(localDate).toUpperCase();
    final dateStr = DateFormat('d MMM').format(localDate);
    final timeStr = DateFormat('HH:mm').format(localDate);
    final endTime = localDate.add(Duration(minutes: session.durationMins));
    final endTimeStr = DateFormat('HH:mm').format(endTime);

    return Container(
      decoration: BoxDecoration(
        color: session.isRace
            ? accentColor.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: session.isRace
              ? accentColor.withOpacity(0.3)
              : AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Day / Date
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayStr,
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
                  Text(
                    dateStr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.glassBorder,
            ),

            // Session name + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.name.toUpperCase(),
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 12,
                          color: session.isRace
                              ? accentColor
                              : AppColors.onSurface,
                        ),
                      ),
                      if (session.isUpNext) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'UP NEXT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: accentColor,
                              fontSize: 7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$timeStr – $endTimeStr',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Bell icon
            Icon(
              Icons.notifications_outlined,
              color: AppColors.tertiaryContainer,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTrackingCard extends StatelessWidget {
  const _LiveTrackingCard({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: true,
      borderColor: accentColor.withOpacity(0.3),
      backgroundColor: accentColor.withOpacity(0.06),
      child: Row(
        children: [
          PulseDot(color: accentColor, size: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE TRACKING ACTIVE',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 13,
                    color: accentColor,
                  ),
                ),
                Text(
                  'Real-time telemetry available via OpenF1',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.tertiaryContainer),
        ],
      ),
    );
  }
}
