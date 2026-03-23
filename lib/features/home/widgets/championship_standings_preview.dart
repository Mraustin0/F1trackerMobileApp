import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/team_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/driver_standing_model.dart';
import '../../../providers/standings_provider.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/staggered_list.dart';
import '../../../shared/widgets/glass_card.dart';

class ChampionshipStandingsPreview extends ConsumerWidget {
  const ChampionshipStandingsPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(driverStandingsProvider);

    return standingsAsync.when(
      loading: () => const ShimmerList(
        itemCount: 5,
        itemHeight: 56,
        spacing: 8,
      ),
      error: (e, _) => GlassCard(
        child: Text(
          'Failed to load standings',
          style: AppTextStyles.bodySmall,
        ),
      ),
      data: (standings) {
        final top5 = standings.take(5).toList();
        return GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: StaggeredList(
            delayMs: 50,
            children: top5
                .map((driver) => _DriverRow(driver: driver))
                .toList(),
          ),
        );
      },
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.driver});

  final DriverStandingModel driver;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(driver.constructorId);
    final isLeader = driver.position == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 32,
            child: Text(
              driver.position.toString(),
              style: AppTextStyles.rankLarge.copyWith(
                fontSize: 20,
                color: isLeader
                    ? AppColors.primaryContainer
                    : AppColors.tertiaryContainer,
              ),
            ),
          ),

          // Team color stripe
          Container(
            width: 3,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: teamTheme.accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.familyName.toUpperCase(),
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  driver.constructorName,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                driver.points.toStringAsFixed(
                    driver.points % 1 == 0 ? 0 : 1),
                style: AppTextStyles.rankLarge.copyWith(
                  fontSize: 22,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'PTS',
                style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
