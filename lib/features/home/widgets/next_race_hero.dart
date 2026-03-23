import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/team_theme_extension.dart';
import '../../../data/models/race_model.dart';
import '../../../shared/widgets/pulse_dot.dart';
import '../../../shared/widgets/skew_button.dart';
import '../../../shared/widgets/glass_card.dart';

class NextRaceHero extends StatefulWidget {
  const NextRaceHero({super.key, required this.race});

  final RaceModel race;

  @override
  State<NextRaceHero> createState() => _NextRaceHeroState();
}

class _NextRaceHeroState extends State<NextRaceHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceController.forward();

    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final target = widget.race.raceDate.toLocal();
    final diff = target.difference(now);
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;
    final accentColor = teamTheme.accentColor;

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final localDate = widget.race.raceDate.toLocal();
    final dateStr = DateFormat('d MMM').format(localDate);
    final endDateStr = DateFormat('d MMM yyyy').format(
      localDate,
    );

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GlassCard(
          blur: true,
          borderRadius: 16,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: accentColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulseDot(color: accentColor, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'NEXT GRAND PRIX',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: accentColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ROUND ${widget.race.round}',
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.tertiaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Race name
              Text(
                widget.race.raceName.toUpperCase(),
                style: AppTextStyles.headlineLarge.copyWith(
                  height: 1.05,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),

              // Circuit | Date
              Text(
                '${widget.race.circuitName}  ·  $dateStr – $endDateStr',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.tertiaryContainer,
                ),
              ),
              const SizedBox(height: 20),

              // Countdown
              Row(
                children: [
                  _CountdownUnit(value: days, label: 'DAYS'),
                  const SizedBox(width: 8),
                  _CountdownDivider(),
                  const SizedBox(width: 8),
                  _CountdownUnit(value: hours, label: 'HRS'),
                  const SizedBox(width: 8),
                  _CountdownDivider(),
                  const SizedBox(width: 8),
                  _CountdownUnit(value: minutes, label: 'MINS'),
                  const SizedBox(width: 8),
                  _CountdownDivider(),
                  const SizedBox(width: 8),
                  _CountdownUnit(value: seconds, label: 'SECS'),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Flexible(
                    child: SkewButton(
                      label: 'ADD TO CALENDAR',
                      icon: Icons.add,
                      onTap: () {},
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: SkewButton(
                      label: 'TRACK DETAILS',
                      icon: Icons.map_outlined,
                      onTap: () {},
                      color: AppColors.surfaceHigh,
                      textColor: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTextStyles.countdown,
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
        ),
      ],
    );
  }
}

class _CountdownDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      ':',
      style: AppTextStyles.countdown.copyWith(
        color: AppColors.tertiaryContainer,
        fontSize: 32,
      ),
    );
  }
}
