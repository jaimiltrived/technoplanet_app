// lib/admin/admin_coordinator_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/admin_providers.dart';

class AdminCoordinatorListScreen extends ConsumerWidget {
  final UserModel user;
  const AdminCoordinatorListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteersAsync = ref.watch(adminVolunteersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final allEvents = eventsAsync.asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Event Volunteers',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: volunteersAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return const Center(child: Text('No volunteer records found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: people.length,
            itemBuilder: (_, i) => _PersonCard(person: people[i], allEvents: allEvents),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading volunteers: $e')),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final UserModel person;
  final List<EventModel> allEvents;
  const _PersonCard({required this.person, required this.allEvents});

  Color get _accentColor => AppColors.secondary;

  @override
  Widget build(BuildContext context) {
    final assignedEvents = allEvents
        .where((e) => person.assignedEventIds.contains(e.id))
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      person.name.isNotEmpty ? person.name.substring(0, 1) : 'V',
                      style: AppTypography.headlineMd.copyWith(
                          color: _accentColor, fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name,
                          style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface, fontSize: 16)),
                      Text(person.email,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(person.role.label,
                          style: AppTypography.labelBold.copyWith(
                              color: _accentColor, fontSize: 10)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.canvasBackground,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text('Read-only',
                          style: AppTypography.labelBold.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 10)),
                    ),
                  ],
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
                  const SizedBox(height: 6),
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
                          child: Text(e.title,
                              style: AppTypography.labelBold.copyWith(
                                  color: e.category.color, fontSize: 11)),
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
