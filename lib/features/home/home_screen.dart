import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../data/models/race_model.dart';
import '../../providers/race_provider.dart';

import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/shimmer_card.dart';
import '../../shared/widgets/staggered_list.dart';
import 'widgets/next_race_hero.dart';
import 'widgets/circuit_map_card.dart';
import 'widgets/championship_standings_preview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(currentSeasonProvider);
    final nextRace = ref.watch(nextRaceProvider);
    final scheduleAsync = ref.watch(scheduleProvider(season));
    final pastRaces = ref.watch(pastRacesProvider);
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: teamTheme.accentColor,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(scheduleProvider(season));
          await ref.read(scheduleProvider(season).future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 64,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                title: Row(
                  children: [
                    Text(
                      'F1',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: teamTheme.accentColor,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TRACKER',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.tertiaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Content
            SliverList(
              delegate: SliverChildListDelegate([
                // Next Race Hero
                scheduleAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: ShimmerCard(
                      width: double.infinity,
                      height: 280,
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: _ErrorCard(
                      message: 'Failed to load schedule',
                      onRetry: () => ref.invalidate(scheduleProvider(season)),
                    ),
                  ),
                  data: (_) => nextRace != null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: NextRaceHero(race: nextRace),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _NoUpcomingCard(),
                        ),
                ),

                // Circuit Map
                if (nextRace != null) ...[
                  SectionHeader(
                    label: 'Circuit',
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CircuitMapCard(race: nextRace),
                  ),
                ],

                // Championship Preview
                SectionHeader(
                  label: 'Championship',
                  onViewAll: () => context.go('/standings'),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ChampionshipStandingsPreview(),
                ),

                // Recent Results
                SectionHeader(
                  label: 'Recent Results',
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: pastRaces.isEmpty
                      ? _NoResultsCard()
                      : StaggeredList(
                          delayMs: 60,
                          children: [
                            for (int i = 0; i < pastRaces.take(3).length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              _RecentRaceCard(race: pastRaces[i]),
                            ],
                          ],
                        ),
                ),

                // Bottom padding for nav bar
                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: AppColors.tertiaryContainer,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoUpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            color: AppColors.tertiaryContainer,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No upcoming races in the current season.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NoResultsCard extends StatelessWidget {
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
          Icon(
            Icons.hourglass_empty,
            color: AppColors.tertiaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No race results yet this season',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRaceCard extends ConsumerWidget {
  const _RecentRaceCard({required this.race});

  final RaceModel race;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(currentSeasonProvider);
    final resultsAsync = ref.watch(raceResultsProvider('$season:${race.round}'));
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

    return GestureDetector(
      onTap: () => context.push('/race/${race.circuitId}', extra: race),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: Row(
          children: [
            // Round badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: teamTheme.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'R${race.round}',
                  style: AppTextStyles.labelBold.copyWith(
                    color: teamTheme.accentColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Race info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.raceName,
                    style: AppTextStyles.labelBold.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    race.circuitName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.tertiaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Winner
            resultsAsync.when(
              loading: () => SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: teamTheme.accentColor,
                ),
              ),
              error: (_, __) => Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.tertiaryContainer,
              ),
              data: (results) {
                if (results.isEmpty) {
                  return const SizedBox.shrink();
                }
                final winner = results.first;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        winner.driverCode,
                        style: AppTextStyles.labelBold.copyWith(
                          color: const Color(0xFFFFD700),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
