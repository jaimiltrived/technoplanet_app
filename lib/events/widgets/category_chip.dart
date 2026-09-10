// lib/screens/events/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : AppColors.cardBackground,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: isSelected
                ? AppColors.onSecondaryContainer
                : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}