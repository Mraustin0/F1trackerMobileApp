import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/team_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../data/models/lap_record_model.dart';
import '../../data/models/race_model.dart';
import '../../data/models/race_result_model.dart';
import '../../providers/race_provider.dart';
import '../../shared/widgets/circuit_painter.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/pulse_dot.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/staggered_list.dart';

// ---- Circuit metadata ----
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
  'vegas': {'laps': 50, 'length': '6.120 km'},
  'losail': {'laps': 57, 'length': '5.380 km'},
  'catalunya': {'laps': 66, 'length': '4.657 km'},
  'villeneuve': {'laps': 70, 'length': '4.361 km'},
  'shanghai': {'laps': 56, 'length': '5.451 km'},
  'imola': {'laps': 63, 'length': '4.909 km'},
  'rodriguez': {'laps': 71, 'length': '4.304 km'},
};

// Map circuitId -> F1 race card photo slug
const _kCircuitPhotoSlugs = {
  'albert_park': 'australia',
  'shanghai': 'china',
  'suzuka': 'japan',
  'bahrain': 'bahrain',
  'jeddah': 'saudi-arabia',
  'miami': 'miami',
  'imola': 'emilia-romagna',
  'monaco': 'monaco',
  'catalunya': 'spain',
  'villeneuve': 'canada',
  'red_bull_ring': 'austria',
  'silverstone': 'great-britain',
  'spa': 'belgium',
  'hungaroring': 'hungary',
  'zandvoort': 'netherlands',
  'monza': 'italy',
  'baku': 'azerbaijan',
  'marina_bay': 'singapore',
  'americas': 'united-states',
  'rodriguez': 'mexico',
  'interlagos': 'brazil',
  'vegas': 'las-vegas',
  'losail': 'qatar',
  'yas_marina': 'abu-dhabi',
};

String _circuitPhotoUrl(String circuitId) {
  final slug = _kCircuitPhotoSlugs[circuitId] ?? circuitId;
  return 'https://media.formula1.com/image/upload/'
      'c_lfill,w_1320/q_auto/v1740000001/'
      'fom-website/static-assets/2026/races/card/$slug.webp';
}

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

    // If race was passed directly, use it
    if (race != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _RaceDetailBody(race: race!, circuitId: circuitId),
      );
    }

    // Otherwise, find it from the schedule
    return Scaffold(
      backgroundColor: AppColors.background,
      body: scheduleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.tertiaryContainer, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load race', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(scheduleProvider(season)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (races) {
          final foundRace = races.where((r) => r.circuitId == circuitId).firstOrNull;
          if (foundRace == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, color: AppColors.tertiaryContainer, size: 48),
                  const SizedBox(height: 16),
                  Text('Race not found', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }
          return _RaceDetailBody(race: foundRace, circuitId: circuitId);
        },
      ),
    );
  }
}

// =========================================================
// Body — now a ConsumerWidget so it can watch raceResults
// =========================================================
class _RaceDetailBody extends ConsumerWidget {
  const _RaceDetailBody({required this.race, required this.circuitId});

  final RaceModel race;
  final String circuitId;

  List<_SessionEntry> _buildSessions() {
    final entries = <_SessionEntry>[];

    if (race.practice1Date != null) {
      entries.add(_SessionEntry(
          name: 'Practice 1', date: race.practice1Date!, durationMins: 60));
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
          name: 'Practice 3', date: race.practice3Date!, durationMins: 60));
    }
    if (race.sprintDate != null) {
      entries.add(_SessionEntry(
          name: 'Sprint Race', date: race.sprintDate!, durationMins: 60));
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
  Widget build(BuildContext context, WidgetRef ref) {
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;
    final circuitInfo = kCircuitData[circuitId.toLowerCase()];
    final lapRecord = kLapRecords[circuitId.toLowerCase()];
    final sessions = _buildSessions();
    final resultsKey = '${race.season}:${race.round}';

    // Fetch race results if completed
    AsyncValue<List<RaceResultModel>>? resultsAsync;
    if (race.isCompleted) {
      resultsAsync = ref.watch(raceResultsProvider(resultsKey));
    }

    return RefreshIndicator(
      color: teamTheme.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        if (race.isCompleted) {
          ref.invalidate(raceResultsProvider(resultsKey));
          await ref.read(raceResultsProvider(resultsKey).future);
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
        // ---- Header with real circuit photograph ----
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: teamTheme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: teamTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    race.isCompleted
                        ? 'COMPLETED'
                        : race.isNextRace
                            ? 'NEXT RACE'
                            : 'ROUND ${race.round}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: teamTheme.accentColor,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Hero(
                  tag: 'race-name-$circuitId',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      race.raceName.toUpperCase(),
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 22, height: 1.1),
                    ),
                  ),
                ),
              ],
            ),
            // Real circuit photograph as background
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _circuitPhotoUrl(circuitId),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.surfaceLow,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceLow,
                    child: const Icon(Icons.landscape_rounded,
                        color: AppColors.tertiaryContainer, size: 48),
                  ),
                ),
                // Dark gradient overlay for text legibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.3, 0.7, 1.0],
                      colors: [
                        AppColors.background.withValues(alpha: 0.2),
                        AppColors.background.withValues(alpha: 0.3),
                        AppColors.background.withValues(alpha: 0.7),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ],
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
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.tertiaryContainer),
              ),
            ),

            // ============ RACE RESULTS (for completed races) ============
            if (race.isCompleted && resultsAsync != null)
              resultsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryContainer, strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _ResultsErrorCard(
                    onRetry: () => ref.invalidate(raceResultsProvider(resultsKey)),
                  ),
                ),
                data: (results) {
                  if (results.isEmpty) return const SizedBox.shrink();
                  return _RaceResultsSection(
                    results: results,
                    accentColor: teamTheme.accentColor,
                  );
                },
              ),

            // Circuit map
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: AnimatedCircuitMap(
                  circuitId: circuitId,
                  accentColor: teamTheme.accentColor,
                  height: 180,
                  animationDuration: const Duration(milliseconds: 2500),
                  strokeWidth: 3,
                  showLabel: true,
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

            // Lap Record
            if (lapRecord != null)
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
                            Text('FASTEST LAP RECORD',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF9B59B6),
                                    fontSize: 8)),
                            Text(lapRecord.lapTime,
                                style: AppTextStyles.headlineMedium.copyWith(
                                    color: const Color(0xFFD7B4F3))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(lapRecord.driverName,
                              style: AppTextStyles.bodyMedium),
                          Text(lapRecord.team, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Weekend Schedule
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

            // Live tracking
            if (race.isNextRace)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _LiveTrackingCard(accentColor: teamTheme.accentColor),
              ),

            const SizedBox(height: 100),
          ]),
        ),
      ],
      ),
    );
  }
}

// =========================================================
// Race Results Section — Podium P1/P2/P3 + remaining results
// =========================================================
class _RaceResultsSection extends StatelessWidget {
  const _RaceResultsSection({
    required this.results,
    required this.accentColor,
  });

  final List<RaceResultModel> results;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final podium = results.take(3).toList();
    // Show all remaining drivers (P4-P20), not just P4-P10
    final rest = results.length > 3 ? results.sublist(3) : <RaceResultModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          label: 'Race Results',
          trailing: Text(
            '${results.length} DRIVERS',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.tertiaryContainer,
              fontSize: 9,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        ),

        // Podium cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // P1 — full width winner card
              if (podium.isNotEmpty) _WinnerCard(result: podium[0]),
              const SizedBox(height: 8),

              // P2 + P3 side by side
              if (podium.length >= 2)
                Row(
                  children: [
                    Expanded(child: _PodiumCard(result: podium[1])),
                    const SizedBox(width: 8),
                    if (podium.length >= 3)
                      Expanded(child: _PodiumCard(result: podium[2])),
                  ],
                ),
            ],
          ),
        ),

        // Rest of results (P4+)
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: rest
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _ResultRow(result: r),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// Error card for failed results loading
class _ResultsErrorCard extends StatelessWidget {
  const _ResultsErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.tertiaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load race results',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.primaryContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// P1 winner card — large, prominent
class _WinnerCard extends StatelessWidget {
  const _WinnerCard({required this.result});
  final RaceResultModel result;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(result.constructorId);
    final teamColor = teamTheme.accentColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: teamColor.withValues(alpha: 0.3)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: teamColor),
              Expanded(
                child: Stack(
                  children: [
                    // Ghost "1" behind
                    Positioned(
                      right: -4,
                      top: -12,
                      child: Text(
                        '1',
                        style: AppTextStyles.rankXL.copyWith(
                          fontSize: 90,
                          color: teamColor.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Winner badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'WINNER',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFFFFD700),
                                fontSize: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.familyName.toUpperCase(),
                            style: AppTextStyles.headlineLarge
                                .copyWith(fontSize: 26),
                          ),
                          Text(result.givenName,
                              style: AppTextStyles.bodySmall),
                          const SizedBox(height: 4),
                          Text(
                            result.constructorName,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: teamColor),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (result.time != null) ...[
                                Icon(Icons.timer_outlined,
                                    size: 14, color: AppColors.tertiary),
                                const SizedBox(width: 4),
                                Text(
                                  result.time!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                '${result.points.toStringAsFixed(0)} PTS',
                                style: AppTextStyles.labelBold.copyWith(
                                  color: teamColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// P2/P3 podium card — compact
class _PodiumCard extends StatelessWidget {
  const _PodiumCard({required this.result});
  final RaceResultModel result;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(result.constructorId);
    final teamColor = teamTheme.accentColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: teamColor),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      right: -4,
                      top: -8,
                      child: Text(
                        result.position.toString(),
                        style: AppTextStyles.rankXL.copyWith(
                          fontSize: 60,
                          color: AppColors.surfaceHigh,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'P${result.position}',
                            style: AppTextStyles.labelBold
                                .copyWith(color: teamColor, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.familyName.toUpperCase(),
                            style: AppTextStyles.headlineSmall
                                .copyWith(fontSize: 15),
                          ),
                          Text(result.constructorName,
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 11)),
                          const SizedBox(height: 8),
                          if (result.time != null)
                            Text(
                              result.time!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.tertiary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// P4+ result row — minimal
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});
  final RaceResultModel result;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(result.constructorId);
    final teamColor = teamTheme.accentColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border:
              Border.fromBorderSide(BorderSide(color: AppColors.glassBorder)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 2, color: teamColor),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          'P${result.position}',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.tertiaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          result.fullName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (result.hasFastestLap)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.bolt_rounded,
                              size: 14, color: const Color(0xFF9B59B6)),
                        ),
                      Text(
                        result.time ?? (result.isFinished ? '' : result.status),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.tertiary),
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

// =========================================================
// Supporting widgets (unchanged)
// =========================================================

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
          Text(value,
              style: AppTextStyles.headlineSmall
                  .copyWith(fontSize: 16, color: AppColors.onSurface)),
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
  const _SessionCard({required this.session, required this.accentColor});

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
            ? accentColor.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: session.isRace
              ? accentColor.withValues(alpha: 0.3)
              : AppColors.glassBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayStr,
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
                  Text(dateStr,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.glassBorder,
            ),
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
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('UP NEXT',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: accentColor, fontSize: 7)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$timeStr – $endTimeStr',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.notifications_outlined,
                color: AppColors.tertiaryContainer, size: 18),
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
      borderColor: accentColor.withValues(alpha: 0.3),
      backgroundColor: accentColor.withValues(alpha: 0.06),
      child: Row(
        children: [
          PulseDot(color: accentColor, size: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIVE TRACKING ACTIVE',
                    style: AppTextStyles.headlineSmall
                        .copyWith(fontSize: 13, color: accentColor)),
                Text('Real-time telemetry available via OpenF1',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.tertiaryContainer),
        ],
      ),
    );
  }
}
