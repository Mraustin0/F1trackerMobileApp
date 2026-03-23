import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    this.onViewAll,
    this.padding,
  });

  final String label;
  final VoidCallback? onViewAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Red left border accent
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'VIEW ALL',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
