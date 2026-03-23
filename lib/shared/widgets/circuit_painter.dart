import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Parsed circuit data from GeoJSON.
class CircuitData {
  CircuitData({
    required this.points,
    required this.name,
  });

  /// Normalized [0..1] x/y points of the circuit outline.
  final List<Offset> points;

  /// Circuit display name from GeoJSON properties.
  final String name;

  /// Cache of loaded circuit data keyed by circuitId.
  static final Map<String, CircuitData?> _cache = {};

  /// Load and parse a GeoJSON circuit file by Jolpica circuitId.
  /// Returns null if asset not found.
  static Future<CircuitData?> load(String circuitId) async {
    if (_cache.containsKey(circuitId)) return _cache[circuitId];

    try {
      final jsonStr = await rootBundle
          .loadString('assets/circuits/$circuitId.geojson');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final features = data['features'] as List;
      if (features.isEmpty) {
        _cache[circuitId] = null;
        return null;
      }

      final feature = features[0] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final props = feature['properties'] as Map<String, dynamic>? ?? {};

      List<List<dynamic>> rawCoords;
      if (geometry['type'] == 'MultiLineString') {
        final multi = geometry['coordinates'] as List;
        rawCoords = (multi[0] as List).cast<List<dynamic>>();
      } else {
        // LineString
        rawCoords = (geometry['coordinates'] as List).cast<List<dynamic>>();
      }

      if (rawCoords.isEmpty) {
        _cache[circuitId] = null;
        return null;
      }

      // Extract raw lng/lat
      final lngs = rawCoords.map((c) => (c[0] as num).toDouble()).toList();
      final lats = rawCoords.map((c) => (c[1] as num).toDouble()).toList();

      final minLng = lngs.reduce(math.min);
      final maxLng = lngs.reduce(math.max);
      final minLat = lats.reduce(math.min);
      final maxLat = lats.reduce(math.max);

      final dLng = maxLng - minLng;
      final dLat = maxLat - minLat;

      // Normalize to 0..1 with padding
      const padding = 0.08;
      final points = <Offset>[];
      for (int i = 0; i < rawCoords.length; i++) {
        final nx = dLng == 0
            ? 0.5
            : padding + (lngs[i] - minLng) / dLng * (1 - 2 * padding);
        // Flip Y because lat increases upward but canvas Y increases downward
        final ny = dLat == 0
            ? 0.5
            : padding + (1 - (lats[i] - minLat) / dLat) * (1 - 2 * padding);
        points.add(Offset(nx, ny));
      }

      final result = CircuitData(
        points: points,
        name: (props['Name'] as String?) ?? circuitId,
      );
      _cache[circuitId] = result;
      return result;
    } catch (_) {
      _cache[circuitId] = null;
      return null;
    }
  }
}

/// CustomPainter that draws a circuit outline from GeoJSON data
/// with optional animated progress.
class CircuitPainter extends CustomPainter {
  CircuitPainter({
    required this.circuitData,
    this.progress = 1.0,
    this.accentColor = AppColors.primaryContainer,
    this.baseColor = const Color(0xFF3A3A44),
    this.strokeWidth = 2.5,
    this.glowWidth = 8.0,
    this.showStartDot = true,
    this.showMovingDot = true,
  });

  final CircuitData circuitData;

  /// 0.0 to 1.0 — how much of the track to draw (for animation).
  final double progress;

  final Color accentColor;
  final Color baseColor;
  final double strokeWidth;
  final double glowWidth;
  final bool showStartDot;
  final bool showMovingDot;

  @override
  void paint(Canvas canvas, Size size) {
    if (circuitData.points.length < 2) return;

    final pts = circuitData.points;

    // Scale normalized points to canvas
    // Maintain aspect ratio: fit inside canvas with letterbox
    final aspectRatio = _computeAspectRatio(pts);
    final canvasAR = size.width / size.height;

    double drawW, drawH, offsetX, offsetY;
    if (aspectRatio > canvasAR) {
      // Track is wider than canvas — fit width
      drawW = size.width;
      drawH = size.width / aspectRatio;
      offsetX = 0;
      offsetY = (size.height - drawH) / 2;
    } else {
      // Track is taller — fit height
      drawH = size.height;
      drawW = size.height * aspectRatio;
      offsetX = (size.width - drawW) / 2;
      offsetY = 0;
    }

    Offset toCanvas(Offset p) =>
        Offset(offsetX + p.dx * drawW, offsetY + p.dy * drawH);

    // Build full path
    final fullPath = Path();
    fullPath.moveTo(toCanvas(pts[0]).dx, toCanvas(pts[0]).dy);
    for (int i = 1; i < pts.length; i++) {
      final p = toCanvas(pts[i]);
      fullPath.lineTo(p.dx, p.dy);
    }
    // Close the circuit loop
    fullPath.close();

    // 1. Draw glow (background layer)
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(fullPath, glowPaint);

    // 2. Draw base track (dim)
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, basePaint);

    // 3. Draw animated accent portion
    if (progress > 0) {
      final metrics = fullPath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final totalLen = metrics.fold<double>(0, (s, m) => s + m.length);
        final drawLen = totalLen * progress.clamp(0.0, 1.0);

        final accentPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        // Gradient along accent path
        accentPaint.shader = ui.Gradient.linear(
          toCanvas(pts[0]),
          toCanvas(pts[(pts.length * progress).clamp(0, pts.length - 1).toInt()]),
          [accentColor.withValues(alpha: 0.4), accentColor],
        );

        double drawn = 0;
        for (final metric in metrics) {
          if (drawn >= drawLen) break;
          final remaining = drawLen - drawn;
          final segLen = math.min(remaining, metric.length);
          final extracted = metric.extractPath(0, segLen);
          canvas.drawPath(extracted, accentPaint);
          drawn += segLen;
        }

        // 4. Moving dot at the tip of the accent line
        if (showMovingDot && progress < 1.0) {
          double accumLen = 0;
          for (final metric in metrics) {
            if (accumLen + metric.length >= drawLen) {
              final pos = metric.getTangentForOffset(drawLen - accumLen);
              if (pos != null) {
                // Outer glow
                canvas.drawCircle(
                  pos.position,
                  5,
                  Paint()
                    ..color = accentColor.withValues(alpha: 0.3)
                    ..maskFilter =
                        const MaskFilter.blur(BlurStyle.normal, 3),
                );
                // Inner dot
                canvas.drawCircle(
                  pos.position,
                  3,
                  Paint()..color = accentColor,
                );
              }
              break;
            }
            accumLen += metric.length;
          }
        }
      }
    }

    // 5. Start/finish dot
    if (showStartDot) {
      final start = toCanvas(pts[0]);
      canvas.drawCircle(
        start,
        4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        start,
        2.5,
        Paint()..color = accentColor,
      );
    }
  }

  double _computeAspectRatio(List<Offset> pts) {
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    final w = maxX - minX;
    final h = maxY - minY;
    if (h == 0) return 1;
    return w / h;
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      accentColor != oldDelegate.accentColor ||
      circuitData != oldDelegate.circuitData;
}

/// Convenience widget that loads GeoJSON, animates the circuit trace,
/// and handles loading/error states.
class AnimatedCircuitMap extends StatefulWidget {
  const AnimatedCircuitMap({
    super.key,
    required this.circuitId,
    this.accentColor = AppColors.primaryContainer,
    this.height = 200,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.strokeWidth = 2.5,
    this.showLabel = true,
  });

  final String circuitId;
  final Color accentColor;
  final double height;
  final Duration animationDuration;
  final double strokeWidth;
  final bool showLabel;

  @override
  State<AnimatedCircuitMap> createState() => _AnimatedCircuitMapState();
}

class _AnimatedCircuitMapState extends State<AnimatedCircuitMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CircuitData? _circuitData;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _loadCircuit();
  }

  @override
  void didUpdateWidget(AnimatedCircuitMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.circuitId != widget.circuitId) {
      _controller.reset();
      _loadCircuit();
    }
  }

  Future<void> _loadCircuit() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    final data = await CircuitData.load(widget.circuitId);
    if (!mounted) return;

    setState(() {
      _circuitData = data;
      _loading = false;
      _hasError = data == null;
    });

    if (data != null) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.tertiaryContainer,
            ),
          ),
        ),
      );
    }

    if (_hasError || _circuitData == null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Icon(
            Icons.map_outlined,
            color: AppColors.tertiaryContainer,
            size: 48,
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Circuit drawing
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: CircuitPainter(
                    circuitData: _circuitData!,
                    progress: _controller.value,
                    accentColor: widget.accentColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                );
              },
            ),
          ),

          // Circuit name label
          if (widget.showLabel)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppColors.glassBorder, width: 1),
                  ),
                  child: Text(
                    _circuitData!.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.tertiary,
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
