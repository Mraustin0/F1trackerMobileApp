import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/team_theme_extension.dart';
import '../../../data/models/race_model.dart';
import '../../../shared/widgets/glass_card.dart';

class CircuitMapCard extends StatefulWidget {
  const CircuitMapCard({super.key, required this.race});

  final RaceModel race;

  @override
  State<CircuitMapCard> createState() => _CircuitMapCardState();
}

class _CircuitMapCardState extends State<CircuitMapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pathController;
  late Animation<double> _pathAnim;

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pathAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pathController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _pathController.forward();
    });
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  bool get _isStreet {
    final streetCircuits = [
      'monaco', 'marina_bay', 'baku', 'jeddah', 'las_vegas', 'miami'
    ];
    return streetCircuits.contains(widget.race.circuitId.toLowerCase());
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
                      widget.race.circuitName.toUpperCase(),
                      style: AppTextStyles.headlineSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.race.locality}, ${widget.race.country}',
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

          // Circuit illustration
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: _pathAnim,
              builder: (context, _) => CustomPaint(
                size: const Size(double.infinity, 140),
                painter: _CircuitPainter(
                  progress: _pathAnim.value,
                  accentColor: teamTheme.accentColor,
                  circuitId: widget.race.circuitId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.progress,
    required this.accentColor,
    required this.circuitId,
  });

  final double progress;
  final Color accentColor;
  final String circuitId;

  Path _buildCircuitPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Different shapes per circuit type
    switch (circuitId.toLowerCase()) {
      case 'monaco':
      case 'marina_bay':
        // Tight hairpin-heavy layout
        path.moveTo(w * 0.15, h * 0.3);
        path.lineTo(w * 0.6, h * 0.3);
        path.quadraticBezierTo(w * 0.85, h * 0.3, w * 0.85, h * 0.5);
        path.lineTo(w * 0.85, h * 0.65);
        path.quadraticBezierTo(w * 0.85, h * 0.8, w * 0.7, h * 0.8);
        path.lineTo(w * 0.3, h * 0.8);
        path.quadraticBezierTo(w * 0.12, h * 0.8, w * 0.12, h * 0.62);
        path.quadraticBezierTo(w * 0.12, h * 0.5, w * 0.15, h * 0.3);
        break;
      case 'monza':
      case 'bahrain':
        // Faster oval-ish layout
        path.moveTo(w * 0.2, h * 0.25);
        path.quadraticBezierTo(w * 0.5, h * 0.15, w * 0.8, h * 0.25);
        path.quadraticBezierTo(w * 0.9, h * 0.4, w * 0.85, h * 0.6);
        path.lineTo(w * 0.7, h * 0.75);
        path.quadraticBezierTo(w * 0.5, h * 0.88, w * 0.3, h * 0.78);
        path.lineTo(w * 0.15, h * 0.65);
        path.quadraticBezierTo(w * 0.1, h * 0.45, w * 0.2, h * 0.25);
        break;
      case 'silverstone':
        // High-speed sweepers
        path.moveTo(w * 0.25, h * 0.2);
        path.lineTo(w * 0.75, h * 0.2);
        path.quadraticBezierTo(w * 0.9, h * 0.2, w * 0.88, h * 0.42);
        path.quadraticBezierTo(w * 0.86, h * 0.58, w * 0.7, h * 0.65);
        path.lineTo(w * 0.55, h * 0.78);
        path.quadraticBezierTo(w * 0.4, h * 0.88, w * 0.25, h * 0.8);
        path.lineTo(w * 0.12, h * 0.65);
        path.quadraticBezierTo(w * 0.08, h * 0.45, w * 0.14, h * 0.35);
        path.quadraticBezierTo(w * 0.18, h * 0.22, w * 0.25, h * 0.2);
        break;
      default:
        // Generic F1 circuit shape
        path.moveTo(w * 0.2, h * 0.22);
        path.lineTo(w * 0.65, h * 0.22);
        path.quadraticBezierTo(w * 0.88, h * 0.22, w * 0.88, h * 0.45);
        path.quadraticBezierTo(w * 0.88, h * 0.62, w * 0.72, h * 0.7);
        path.lineTo(w * 0.6, h * 0.78);
        path.quadraticBezierTo(w * 0.45, h * 0.88, w * 0.3, h * 0.82);
        path.lineTo(w * 0.15, h * 0.72);
        path.quadraticBezierTo(w * 0.08, h * 0.6, w * 0.1, h * 0.45);
        path.quadraticBezierTo(w * 0.12, h * 0.28, w * 0.2, h * 0.22);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = _buildCircuitPath(size);
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalLength = metric.length;

    // Shadow/glow
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Main circuit line
    final circuitPaint = Paint()
      ..color = AppColors.surfaceHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Animated accent line
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw full grey track first
    canvas.drawPath(fullPath, glowPaint);
    canvas.drawPath(fullPath, circuitPaint);

    // Draw animated accent portion
    if (progress > 0) {
      final animatedPath =
          metric.extractPath(0, totalLength * progress);
      canvas.drawPath(animatedPath, accentPaint);

      // Draw start dot
      final startPos = metric.getTangentForOffset(0)!.position;
      canvas.drawCircle(startPos, 5,
          Paint()..color = accentColor..style = PaintingStyle.fill);

      // Draw moving dot at current progress
      if (progress < 1.0) {
        final currentOffset = totalLength * math.min(progress, 1.0);
        final tangent = metric.getTangentForOffset(currentOffset);
        if (tangent != null) {
          canvas.drawCircle(
            tangent.position,
            7,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            tangent.position,
            7,
            Paint()
              ..color = accentColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor;
}
