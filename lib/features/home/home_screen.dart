import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../providers/race_provider.dart';
import '../../providers/standings_provider.dart';

import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/shimmer_card.dart';
import '../../shared/widgets/staggered_list.dart';
import 'widgets/next_race_hero.dart';
import 'widgets/circuit_map_card.dart';
import 'widgets/championship_standings_preview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() async {
    final season = ref.read(currentSeasonProvider);
    ref.invalidate(scheduleProvider(season));
    ref.invalidate(driverStandingsProvider);
    ref.invalidate(constructorStandingsProvider);
    await Future.wait([
      ref.read(scheduleProvider(season).future),
      ref.read(driverStandingsProvider.future),
      ref.read(constructorStandingsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final season = ref.watch(currentSeasonProvider);
    final nextRace = ref.watch(nextRaceProvider);
    final scheduleAsync = ref.watch(scheduleProvider(season));
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: teamTheme.accentColor,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
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
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
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
                  child: Text(
                    'Failed to load schedule',
                    style: AppTextStyles.bodySmall,
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
                onViewAll: () {},
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ChampionshipStandingsPreview(),
              ),

              // Latest News / Telemetry
              SectionHeader(
                label: 'Latest News',
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredList(
                  delayMs: 60,
                  children: const [
                    _NewsCard(
                      tag: 'RACE REPORT',
                      title: 'Verstappen Claims Dominant Victory in Bahrain',
                      time: '2 HOURS AGO',
                    ),
                    SizedBox(height: 10),
                    _NewsCard(
                      tag: 'TECHNICAL',
                      title: 'Ferrari Unveil Upgraded Floor Package for Imola',
                      time: '5 HOURS AGO',
                    ),
                    SizedBox(height: 10),
                    _NewsCard(
                      tag: 'DRIVER',
                      title:
                          'Hamilton Reflects on Monza Qualifying Pace Improvement',
                      time: '8 HOURS AGO',
                    ),
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

class _NoUpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'No upcoming races in the current season.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.tertiaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.tag,
    required this.title,
    required this.time,
  });

  final String tag;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.headlineSmall.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          Text(time, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
