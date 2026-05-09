import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';

class F1NavBar extends StatefulWidget {
  const F1NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<F1NavBar> createState() => _F1NavBarState();
}

class _F1NavBarState extends State<F1NavBar> {
  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'CALENDAR'),
    _NavItem(icon: Icons.leaderboard_rounded, label: 'STANDINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    final teamTheme = Theme.of(context).extension<TeamTheme>() ??
        TeamTheme.defaultTheme;
    final accentColor = teamTheme.accentColor;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: Color(0xFF2A2A35), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: List.generate(_items.length, (index) {
                  final isActive = index == widget.currentIndex;
                  return Expanded(
                    child: _NavBarItem(
                      item: _items[index],
                      isActive: isActive,
                      accentColor: accentColor,
                      onTap: () => widget.onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isActive ? 1.0 : 0.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _colorAnim = ColorTween(
      begin: AppColors.tertiaryContainer,
      end: widget.accentColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (widget.accentColor != oldWidget.accentColor) {
      _colorAnim = ColorTween(
        begin: AppColors.tertiaryContainer,
        end: widget.accentColor,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final color = _colorAnim.value ?? AppColors.tertiaryContainer;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Red top indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 6),
                width: widget.isActive ? 24 : 0,
                height: widget.isActive ? 3 : 0,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Transform.scale(
                scale: _scaleAnim.value,
                child: Icon(
                  widget.item.icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.label,
                style: AppTextStyles.navLabel.copyWith(color: color),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
