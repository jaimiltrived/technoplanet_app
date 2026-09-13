// lib/screens/events/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search for events...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.regularRadius,
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyLg.copyWith(
          color: AppColors.onSurface,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyLg.copyWith(
            color: AppColors.outline,
            fontSize: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          isDense: true,
        ),
      ),
    );
  }
}