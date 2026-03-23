import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/race_provider.dart';
import '../../shared/widgets/shimmer_card.dart';
import 'widgets/race_list_item.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late String _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedSeason = DateTime.now().year.toString();
  }

  List<String> get _seasons {
    final currentYear = DateTime.now().year;
    return List.generate(4, (i) => (currentYear - i).toString());
  }

  Future<void> _refresh() async {
    ref.invalidate(scheduleProvider(_selectedSeason));
    await ref.read(scheduleProvider(_selectedSeason).future);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider(_selectedSeason));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 72,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEASON SCHEDULE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.tertiaryContainer,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        '$_selectedSeason CALENDAR',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _SeasonDropdown(
                    value: _selectedSeason,
                    seasons: _seasons,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSeason = v);
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.tertiaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ALL TIMES IN LOCAL TIMEZONE',
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
                  ),
                ],
              ),
            ),
          ),

          scheduleAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...List.generate(
                    8,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerCard(
                        width: double.infinity,
                        height: 120,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.tertiaryContainer,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load schedule',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.tertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _refresh,
                      child: Text(
                        'RETRY',
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (races) {
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < races.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RaceListItem(
                            race: races[index],
                            animationIndex: index,
                          ),
                        );
                      }
                      // Disclaimer at the bottom
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Text(
                          'Schedule data provided by Jolpica/Ergast API. '
                          'Times shown in device local timezone. '
                          'Subject to change by FIA.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryContainer,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    childCount: races.length + 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SeasonDropdown extends StatelessWidget {
  const _SeasonDropdown({
    required this.value,
    required this.seasons,
    required this.onChanged,
  });

  final String value;
  final List<String> seasons;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: DropdownButton<String>(
        value: value,
        items: seasons
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.tertiaryContainer,
          size: 18,
        ),
        dropdownColor: AppColors.surfaceLow,
        isDense: true,
      ),
    );
  }
}
