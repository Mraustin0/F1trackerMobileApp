import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/team_theme_extension.dart';
import '../../../data/models/race_model.dart';
import '../../../shared/widgets/circuit_painter.dart';
import '../../../shared/widgets/glass_card.dart';

class CircuitMapCard extends StatelessWidget {
  const CircuitMapCard({super.key, required this.race});

  final RaceModel race;

  bool get _isStreet {
    const streetCircuits = [
      'monaco', 'marina_bay', 'baku', 'jeddah', 'vegas', 'miami'
    ];
    return streetCircuits.contains(race.circuitId.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

    return GlassCard(
      borderRadius: 16,
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
                      race.circuitName.toUpperCase(),
                      style: AppTextStyles.headlineSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${race.locality}, ${race.country}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isStreet
                      ? const Color(0xFF1E3A2F)
                      : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isStreet
                        ? const Color(0xFF358C75)
                        : AppColors.surfaceHighest,
                    width: 1,
                  ),
                ),
                child: Text(
                  _isStreet ? 'STREET CIRCUIT' : 'PERMANENT CIRCUIT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _isStreet
                        ? const Color(0xFF358C75)
                        : AppColors.tertiaryContainer,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GeoJSON-based circuit map with animated trace
          AnimatedCircuitMap(
            circuitId: race.circuitId,
            accentColor: teamTheme.accentColor,
            height: 160,
            animationDuration: const Duration(milliseconds: 2000),
            strokeWidth: 3,
            showLabel: false,
          ),
        ],
      ),
    );
  }
}
