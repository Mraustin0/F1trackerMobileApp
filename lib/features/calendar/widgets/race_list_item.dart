import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/race_model.dart';
import '../../../services/calendar_service.dart';
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

    void navigateToRace() =>
        context.push('/race/${widget.race.circuitId}', extra: widget.race);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
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

                  // Card content — upper part is tap-to-navigate, buttons handle themselves
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Round number — tappable
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: navigateToRace,
                            child: SizedBox(
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
                          ),
                          const SizedBox(width: 12),

                          // Main content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Upper info block — tappable for navigation
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: navigateToRace,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              fontSize: 8,
                                              color:
                                                  AppColors.tertiaryContainer,
                                            ),
                                          ),
                                          Text(
                                            '$dateStr · $timeStr',
                                            style: AppTextStyles.labelBold
                                                .copyWith(
                                              color: AppColors.onSurface,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Action buttons — independent tap targets, NOT wrapped in nav gesture
                                Row(
                                  children: [
                                    if (isCompleted)
                                      Flexible(
                                        child: SkewButton(
                                          label: 'VIEW RESULTS',
                                          icon: Icons.emoji_events_outlined,
                                          onTap: navigateToRace,
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
                                          onTap: navigateToRace,
                                          color: isNext
                                              ? AppColors.primaryContainer
                                              : AppColors.surfaceHigh,
                                          textColor: AppColors.onSurface,
                                        ),
                                      ),
                                    const Spacer(),
                                    if (!isCompleted)
                                      _CalendarButton(race: widget.race),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: navigateToRace,
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.tertiaryContainer,
                                        size: 20,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Calendar Button ──────────────────────────────────────────────────────────

class _CalendarButton extends StatefulWidget {
  const _CalendarButton({required this.race});
  final RaceModel race;

  @override
  State<_CalendarButton> createState() => _CalendarButtonState();
}

class _CalendarButtonState extends State<_CalendarButton> {
  Future<void> _onTap() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CalendarSheet(race: widget.race),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.tertiaryContainer,
              ),
      ),
    );
  }
}

// ─── Calendar Bottom Sheet ────────────────────────────────────────────────────

class _CalendarSheet extends StatefulWidget {
  const _CalendarSheet({required this.race});
  final RaceModel race;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  bool _addingAll = false;
  final Set<int> _addingIndex = {};
  final Set<int> _addedIndex = {};

  List<RaceSession> get _sessions => sessionsForRace(widget.race);

  Future<void> _addAll() async {
    setState(() => _addingAll = true);
    final count = await CalendarService.instance.addRaceWeekend(widget.race);
    if (!mounted) return;
    setState(() => _addingAll = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? 'Added $count sessions to your calendar'
              : count == -1
                  ? 'Calendar permission denied'
                  : 'Could not add events',
        ),
        backgroundColor: count > 0 ? const Color(0xFF1B5E20) : Colors.red[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addSingle(int index, RaceSession session) async {
    setState(() => _addingIndex.add(index));
    final ok = await CalendarService.instance
        .addSession(widget.race, session.type);
    if (!mounted) return;
    setState(() {
      _addingIndex.remove(index);
      if (ok) _addedIndex.add(index);
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not add event — check calendar permission'),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;
    final fmt = DateFormat('EEE d MMM · HH:mm');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            widget.race.raceName.toUpperCase(),
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 14),
          ),
          Text(
            '${widget.race.locality}, ${widget.race.country}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Session list
          ...sessions.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final isAdding = _addingIndex.contains(i);
            final isAdded = _addedIndex.contains(i);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.label.toUpperCase(),
                          style: AppTextStyles.labelBold
                              .copyWith(fontSize: 11, color: AppColors.onSurface),
                        ),
                        Text(
                          fmt.format(s.date.toLocal()),
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (isAdding || isAdded)
                        ? null
                        : () => _addSingle(i, s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? const Color(0xFF1B5E20)
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isAdded
                                ? Colors.green
                                : AppColors.glassBorder,
                            width: 1),
                      ),
                      child: isAdding
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.tertiaryContainer),
                            )
                          : Icon(
                              isAdded
                                  ? Icons.check
                                  : Icons.add,
                              size: 14,
                              color: isAdded
                                  ? Colors.green
                                  : AppColors.tertiaryContainer,
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Add all button
          GestureDetector(
            onTap: _addingAll ? null : _addAll,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _addingAll
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'ADD ALL SESSIONS TO CALENDAR',
                        style: AppTextStyles.labelBold.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

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
