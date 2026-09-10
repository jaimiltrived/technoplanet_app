// lib/screens/events/widgets/featured_event_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../theme/theme.dart';

class FeaturedEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const FeaturedEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: AppShadows.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mdRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold top border for featured
              Container(
                height: 2,
                width: double.infinity,
                color: AppColors.goldAccent,
              ),
              // Image with category badge
              Stack(
                children: [
                  _buildEventImage(),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildCategoryBadge(),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 17,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    // Placeholder gradient image based on category
    final gradient = _getCategoryGradient(event.category);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Stack(
        children: [
          // Decorative pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _EventPatternPainter(
                category: event.category,
              ),
            ),
          ),
          // Dark overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        event.category.label,
        style: AppTypography.labelBold.copyWith(
          color: AppColors.onSurface,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    final isToday = _isToday(event.dateTime);
    final dateLabel = isToday
        ? 'Today'
        : DateFormat('MMM d').format(event.dateTime);
    final timeLabel = DateFormat('hh:mm a').format(event.dateTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$dateLabel, $timeLabel',
            style: AppTypography.labelBold.copyWith(
              color: AppColors.secondary,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  LinearGradient _getCategoryGradient(EventCategory category) {
    switch (category) {
      case EventCategory.tech:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2540), Color(0xFF1B3B6F), Color(0xFF3B5C99)],
        );
      case EventCategory.sports:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B2D26), Color(0xFFB84A3F), Color(0xFFE07856)],
        );
      case EventCategory.cultural:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A1D5C), Color(0xFF8B3A80), Color(0xFFC66FBD)],
        );
      case EventCategory.academic:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF52B788)],
        );
      case EventCategory.arts:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A4C1F), Color(0xFFB08540), Color(0xFFE9C46A)],
        );
      case EventCategory.all:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF5D6D7E)],
        );
    }
  }
}

// Decorative pattern painter to simulate a photo image
class _EventPatternPainter extends CustomPainter {
  final EventCategory category;

  _EventPatternPainter({required this.category});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw some abstract shapes to simulate an image
    for (int i = 0; i < 8; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 23.0) % size.height;
      canvas.drawCircle(Offset(x, y), 3 + (i % 4).toDouble(), paint);
    }

    // Draw grid lines to look like a photo has structure
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}