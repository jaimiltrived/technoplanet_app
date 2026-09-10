// lib/student/student_event_detail.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import 'student_event_registration.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_providers.dart';

class StudentEventDetailScreen extends ConsumerWidget {
  final EventModel event;
  const StudentEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(myEventsProvider);
    final isRegistered = myEventsAsync.maybeWhen(
      data: (events) => events.any((e) => e.id == event.id),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isRegistered),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: event.accentColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: AppRadius.smRadius,
          ),
          child:
              const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [event.accentColor, event.accentColor.withValues(alpha: 0.6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(event.category.label),
                      const SizedBox(width: 8),
                      _pill(event.status.label),
                      if (event.ranksDeclared) ...[
                        const SizedBox(width: 8),
                        _pill('Results Out', bg: AppColors.goldAccent),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Text(event.title,
                      style: AppTypography.headlineLgMobile.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, {Color? bg}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withValues(alpha: 0.2),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(label,
            style: AppTypography.labelBold.copyWith(
              color: bg != null ? AppColors.primaryContainer : Colors.white,
              fontSize: 11,
            )),
      );

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Info Cards
          _buildInfoGrid(),
          const SizedBox(height: 20),
          // Description
          Text('About this Event',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 16,
              )),
          const SizedBox(height: 8),
          Text(event.description,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.7,
              )),
          const SizedBox(height: 20),
          // Coordinator
          if (event.coordinatorName != null) ...[
            Text('Event Coordinator',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 16,
                )),
            const SizedBox(height: 10),
            _buildCoordinatorCard(),
            const SizedBox(height: 20),
          ],
          // Registration deadline
          if (event.registrationDeadline != null) ...[
            _buildDeadlineBanner(),
            const SizedBox(height: 20),
          ],
          // Rules / Info
          _buildRulesSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = event.dateTime;
    final items = [
      {'icon': Icons.calendar_today_rounded, 'label': 'Date', 'value': '${dt.day} ${months[dt.month - 1]}, ${dt.year}'},
      {'icon': Icons.access_time_rounded, 'label': 'Time', 'value': _timeStr(dt)},
      {'icon': Icons.location_on_rounded, 'label': 'Venue', 'value': event.location},
      {'icon': event.isTeamEvent ? Icons.groups_rounded : Icons.person_rounded, 'label': 'Format', 'value': event.isTeamEvent ? 'Team (${event.minTeamSize}-${event.maxTeamSize})' : 'Solo'},
      {'icon': Icons.payments_rounded, 'label': 'Fee', 'value': event.registrationFee == 0 ? 'Free' : '₹${event.registrationFee.toInt()}'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Scoring', 'value': event.hasScoring ? 'Yes' : 'No'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item['icon'] as IconData,
                  color: event.accentColor, size: 18),
              const Spacer(),
              Text(item['label'] as String,
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  )),
              const SizedBox(height: 2),
              Text(item['value'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoordinatorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primaryContainer, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.coordinatorName ?? 'Unassigned',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  )),
              Text('Event Coordinator · ${event.category.label}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBanner() {
    final dl = event.registrationDeadline!;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Registration deadline: ${dl.day} ${months[dl.month - 1]}, ${dl.year}',
              style: AppTypography.bodySm.copyWith(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    final rules = [
      'Participants must carry their university ID card.',
      'Late entries will not be accepted after registration deadline.',
      'Participants must adhere to the event schedule.',
      'Any form of malpractice will lead to disqualification.',
      'Results declared by the coordinator will be final.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Rules',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 16,
            )),
        const SizedBox(height: 10),
        ...rules.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    decoration: BoxDecoration(
                      color: event.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(r,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        )),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isRegistered) {
    final isDeadlinePassed = event.registrationDeadline != null &&
        DateTime.now().isAfter(event.registrationDeadline!);
    final canRegister = event.status == EventStatus.upcoming && !isRegistered && !isDeadlinePassed;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          // Reminder button
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder set! ✓')),
              );
            },
            icon: const Icon(Icons.notifications_outlined, size: 18),
            label: const Text('Remind'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(width: 12),
          // Register / View Result
          Expanded(
            child: ElevatedButton(
              onPressed: canRegister
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentEventRegistrationScreen(event: event),
                        ),
                      )
                  : event.ranksDeclared
                      ? () {}
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered
                    ? AppColors.outline
                    : isDeadlinePassed
                        ? AppColors.outline
                        : canRegister
                            ? AppColors.primaryContainer
                            : event.ranksDeclared
                                ? AppColors.goldAccent
                                : AppColors.outline,
                foregroundColor:
                    event.ranksDeclared && !isRegistered ? AppColors.primaryContainer : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isRegistered
                    ? 'Registered ✓'
                    : isDeadlinePassed
                        ? 'Deadline Passed'
                        : canRegister
                            ? 'Register Now'
                            : event.ranksDeclared
                                ? 'View Results'
                                : 'Registration Closed',
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: event.ranksDeclared && !isRegistered
                      ? AppColors.primaryContainer
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeStr(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
