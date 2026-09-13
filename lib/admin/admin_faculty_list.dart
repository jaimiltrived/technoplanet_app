// lib/admin/admin_faculty_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/admin_providers.dart';

class AdminFacultyListScreen extends ConsumerWidget {
  final UserModel user;
  const AdminFacultyListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultyAsync = ref.watch(adminFacultyProvider);
    final volunteersAsync = ref.watch(adminVolunteersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);

    final facultyList = facultyAsync.asData?.value ?? [];
    final volunteersList = volunteersAsync.asData?.value ?? [];
    final eventsList = eventsAsync.asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Faculty List',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryTile('${facultyList.length}', 'Faculty'),
                _vDiv(),
                _summaryTile('${volunteersList.length}', 'Volunteers'),
              ],
            ),
          ),
          Expanded(
            child: facultyAsync.when(
              data: (faculty) {
                if (faculty.isEmpty) {
                  return const Center(child: Text('No faculty records found.'));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _sectionHeader('Faculty Members'),
                    ...faculty.map((f) => _FacultyCard(faculty: f, allEvents: eventsList)),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading faculty: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String v, String l) => Column(
        children: [
          Text(v, style: AppTypography.dataPoint.copyWith(color: Colors.white, fontSize: 22)),
          Text(l, style: AppTypography.labelBold.copyWith(color: Colors.white70, fontSize: 11)),
        ],
      );

  Widget _vDiv() =>
      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3));

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface, fontSize: 15)),
      );
}

class _FacultyCard extends StatelessWidget {
  final UserModel faculty;
  final List<EventModel> allEvents;
  const _FacultyCard({required this.faculty, required this.allEvents});

  @override
  Widget build(BuildContext context) {
    final assignedEvents = allEvents
        .where((e) => faculty.assignedEventIds.contains(e.id) || e.coordinatorId == faculty.id)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.lgRadius,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      faculty.name.isNotEmpty ? faculty.name.substring(0, 1) : 'F',
                      style: AppTypography.headlineMd.copyWith(
                          color: const Color(0xFF00897B), fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(faculty.name,
                          style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface, fontSize: 16)),
                      Text(faculty.email,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                      Text(faculty.department ?? '',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text('${assignedEvents.length} events',
                      style: AppTypography.labelBold.copyWith(
                          color: const Color(0xFF00897B), fontSize: 12)),
                ),
              ],
            ),
          ),
          if (assignedEvents.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assigned Events',
                      style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: assignedEvents.map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: e.category.color.withValues(alpha: 0.08),
                            border: Border.all(
                                color: e.category.color.withValues(alpha: 0.3)),
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(e.category.icon,
                                  color: e.category.color, size: 12),
                              const SizedBox(width: 4),
                              Text(e.title,
                                  style: AppTypography.labelBold.copyWith(
                                      color: e.category.color, fontSize: 11)),
                            ],
                          ),
                        )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
