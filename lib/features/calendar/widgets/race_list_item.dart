import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/race_model.dart';
import '../../../shared/widgets/skew_button.dart';

enum _RaceStatus { completed, nextRace, upcoming }

class RaceListItem extends StatefulWidget {
  const RaceListItem({
    super.key,
    required this.race,
    this.animationIndex = 0,
  });

  final RaceModel race;
  final int animationIndex;

  @override
  State<RaceListItem> createState() => _RaceListItemState();
}

class _RaceListItemState extends State<RaceListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(
      Duration(milliseconds: 60 * widget.animationIndex),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _RaceStatus get _status {
    if (widget.race.isNextRace) return _RaceStatus.nextRace;
    if (widget.race.isCompleted) return _RaceStatus.completed;
    return _RaceStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final isNext = status == _RaceStatus.nextRace;
    final isCompleted = status == _RaceStatus.completed;

    final localDate = widget.race.raceDate.toLocal();
    final dateStr = DateFormat('EEE, MMM d').format(localDate);
    final timeStr = DateFormat('HH:mm').format(localDate);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: () => context.push(
            '/race/${widget.race.circuitId}',
            extra: widget.race,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.glassBorder)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar
                    Container(
                      width: isNext
                          ? 4
                          : isCompleted
                              ? 3
                              : 1,
                      color: isNext
                          ? AppColors.primaryContainer
                          : isCompleted
                              ? AppColors.tertiaryContainer
                              : Colors.transparent,
                    ),

                    // Card content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Round number column
                            SizedBox(
                              width: 48,
                              child: Column(
                                children: [
                                  Text(
                                    'ROUND',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(fontSize: 7),
                                  ),
                                  Text(
                                    widget.race.round.toString(),
                                    style: AppTextStyles.rankLarge.copyWith(
                                      fontSize: 28,
                                      color: isNext
                                          ? AppColors.primaryContainer
                                          : AppColors.tertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Main content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StatusBadge(status: status),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.race.raceName.toUpperCase(),
                                    style: AppTextStyles.headlineSmall
                                        .copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.race.locality}, ${widget.race.country}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: AppColors.tertiaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LIGHTS OUT  ',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          fontSize: 8,
                                          color: AppColors.tertiaryContainer,
                                        ),
                                      ),
                                      Text(
                                        '$dateStr · $timeStr',
                                        style:
                                            AppTextStyles.labelBold.copyWith(
                                          color: AppColors.onSurface,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (isCompleted)
                                        Flexible(
                                          child: SkewButton(
                                            label: 'VIEW RESULTS',
                                            icon: Icons.emoji_events_outlined,
                                            onTap: () => context.push(
                                              '/race/${widget.race.circuitId}',
                                              extra: widget.race,
                                            ),
                                            color: AppColors.surfaceHigh,
                                            textColor:
                                                AppColors.tertiaryContainer,
                                          ),
                                        )
                                      else
                                        Flexible(
                                          child: SkewButton(
                                            label: 'TRACK DETAILS',
                                            icon: Icons.map_outlined,
                                            onTap: () => context.push(
                                              '/race/${widget.race.circuitId}',
                                              extra: widget.race,
                                            ),
                                            color: isNext
                                                ? AppColors.primaryContainer
                                                : AppColors.surfaceHigh,
                                            textColor: AppColors.onSurface,
                                          ),
                                        ),
                                      const Spacer(),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.tertiaryContainer,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _RaceStatus status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color textColor;

    switch (status) {
      case _RaceStatus.completed:
        label = 'COMPLETED';
        bg = AppColors.surfaceHigh;
        textColor = AppColors.tertiaryContainer;
        break;
      case _RaceStatus.nextRace:
        label = 'NEXT RACE';
        bg = const Color(0x26FF553D); // primaryContainer 15%
        textColor = AppColors.primaryContainer;
        break;
      case _RaceStatus.upcoming:
        label = 'UPCOMING';
        bg = AppColors.surfaceLowest;
        textColor = AppColors.tertiaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: status == _RaceStatus.nextRace
            ? const Border.fromBorderSide(
                BorderSide(color: Color(0x66FF553D)))
            : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontSize: 8,
        ),
      ),
    );
  }
}
