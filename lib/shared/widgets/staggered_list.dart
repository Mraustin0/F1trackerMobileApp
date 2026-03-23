import 'package:flutter/material.dart';

class StaggeredList extends StatefulWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.delayMs = 50,
    this.initialDelay = 0,
    this.axis = Axis.vertical,
  });

  final List<Widget> children;
  final int delayMs;
  final int initialDelay;
  final Axis axis;

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    final count = widget.children.length;
    if (count == 0) {
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _slideAnims = [];
      _fadeAnims = [];
      return;
    }

    final totalDuration =
        widget.initialDelay + widget.delayMs * (count - 1) + 350;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
    );

    _slideAnims = List.generate(count, (i) {
      final start =
          (widget.initialDelay + i * widget.delayMs) / totalDuration;
      final end = (start + 350 / totalDuration).clamp(0.0, 1.0);
      return Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeAnims = List.generate(count, (i) {
      final start =
          (widget.initialDelay + i * widget.delayMs) / totalDuration;
      final end = (start + 300 / totalDuration).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(widget.children.length, (i) {
            final slideOffset = _slideAnims[i].value * 30;
            return FadeTransition(
              opacity: _fadeAnims[i],
              child: Transform.translate(
                offset: widget.axis == Axis.vertical
                    ? Offset(0, slideOffset)
                    : Offset(slideOffset, 0),
                child: widget.children[i],
              ),
            );
          }),
        );
      },
    );
  }
}
