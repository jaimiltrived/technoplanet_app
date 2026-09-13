// lib/screens/events/widgets/upcoming_event_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/event_model.dart';
import '../../../../theme/theme.dart';

class UpcomingEventTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const UpcomingEventTile({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.mdRadius,
            border: Border.all(color: AppColors.cardBorder, width: 1),
            boxShadow: AppShadows.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdRadius,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left color rail
                  Container(
                    width: 4,
                    color: event.accentColor,
                  ),
                  // Date block
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: AppColors.surfaceContainerLow,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(event.dateTime).toUpperCase(),
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd').format(event.dateTime),
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            event.title,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('HH:mm').format(event.dateTime),
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  event.location,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chevron
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                      size: 20,
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