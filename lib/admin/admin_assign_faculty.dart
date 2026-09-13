// lib/admin/admin_assign_faculty.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/admin_providers.dart';
import '../services/admin_service.dart';

class AdminAssignFacultyScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const AdminAssignFacultyScreen({super.key, required this.user});

  @override
  ConsumerState<AdminAssignFacultyScreen> createState() =>
      _AdminAssignFacultyScreenState();
}

class _AdminAssignFacultyScreenState extends ConsumerState<AdminAssignFacultyScreen> {
  String? _selectedEventId;
  String? _selectedFacultyId;
  bool _isAssigning = false;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsProvider);
    final facultyAsync = ref.watch(adminFacultyProvider);

    final events = eventsAsync.asData?.value ?? [];
    final faculty = facultyAsync.asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Assign Faculty to Events',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: eventsAsync.isLoading || facultyAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo(),
                  const SizedBox(height: 20),
                  _buildSection('Step 1: Select Event'),
                  const SizedBox(height: 10),
                  _buildEventSelector(events),
                  const SizedBox(height: 20),
                  _buildSection('Step 2: Select Faculty'),
                  const SizedBox(height: 10),
                  _buildFacultySelector(faculty),
                  if (_selectedEventId != null && _selectedFacultyId != null) ...[
                    const SizedBox(height: 20),
                    _buildAssignmentPreview(events, faculty),
                    const SizedBox(height: 16),
                    _buildAssignButton(context),
                  ],
                  const SizedBox(height: 40),
                  _buildCurrentAssignments(events, faculty),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfo() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
          borderRadius: AppRadius.smRadius,
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_ind_rounded, color: AppColors.primaryContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Assign faculty as event coordinators. They will see only their assigned events in the Faculty Portal.',
                style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF7A4500), fontSize: 13),
              ),
            ),
          ],
        ),
      );

  Widget _buildSection(String title) => Text(title,
      style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface, fontSize: 15));

  Widget _buildEventSelector(List<EventModel> events) {
    if (events.isEmpty) {
      return const Text('No events found.');
    }
    return Column(
      children: events.map((e) {
        final sel = _selectedEventId == e.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedEventId = e.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryContainer.withValues(alpha: 0.06) : AppColors.cardBackground,
              border: Border.all(
                  color: sel ? AppColors.primaryContainer : AppColors.cardBorder,
                  width: sel ? 2 : 1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Row(
              children: [
                Icon(e.category.icon, color: e.category.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600)),
                      Text(
                        e.coordinatorName != null
                            ? 'Current: ${e.coordinatorName}'
                            : 'Unassigned',
                        style: AppTypography.bodySm.copyWith(
                            color: e.coordinatorName != null
                                ? AppColors.onSurfaceVariant
                                : AppColors.error,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (sel)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryContainer, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFacultySelector(List<UserModel> facultyList) {
    if (facultyList.isEmpty) {
      return const Text('No faculty records found.');
    }
    return Column(
      children: facultyList.map((f) {
        final sel = _selectedFacultyId == f.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedFacultyId = f.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primaryContainer.withValues(alpha: 0.06)
                  : AppColors.cardBackground,
              border: Border.all(
                  color: sel ? AppColors.primaryContainer : AppColors.cardBorder,
                  width: sel ? 2 : 1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      f.name.isNotEmpty ? f.name.substring(0, 1) : 'F',
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.primaryContainer, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600)),
                      Text('${f.department ?? 'Faculty'} · ${f.assignedEventIds.length} events',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                if (sel)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryContainer, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssignmentPreview(List<EventModel> events, List<UserModel> facultyList) {
    final event = events.cast<EventModel?>().firstWhere(
      (e) => e?.id == _selectedEventId,
      orElse: () => null,
    );
    final faculty = facultyList.cast<UserModel?>().firstWhere(
      (f) => f?.id == _selectedFacultyId,
      orElse: () => null,
    );
    if (event == null || faculty == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Assign "${faculty.name}" as coordinator for "${event.title}"',
              style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF1B5E20), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignButton(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: _isAssigning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.assignment_turned_in_rounded,
                  color: Colors.white, size: 18),
          label: Text(_isAssigning ? 'Assigning...' : 'Confirm Assignment',
              style: AppTypography.bodyLg.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          onPressed: _isAssigning
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  setState(() => _isAssigning = true);
                  await AdminService.assignFacultyToEvent(_selectedEventId!, _selectedFacultyId!);
                  ref.invalidate(adminEventsProvider);
                  ref.invalidate(adminFacultyProvider);
                  if (!mounted) return;
                  setState(() {
                    _isAssigning = false;
                    _selectedEventId = null;
                    _selectedFacultyId = null;
                  });
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Faculty assigned successfully!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
        ),
      );

  Widget _buildCurrentAssignments(List<EventModel> events, List<UserModel> facultyList) {
    final assigned = events.where((e) => e.coordinatorId != null || e.coordinatorName != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Assignments',
            style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface, fontSize: 15)),
        const SizedBox(height: 10),
        ...assigned.map((e) {
          final faculty = facultyList
              .where((f) => f.id == e.coordinatorId)
              .firstOrNull;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: AppRadius.smRadius,
            ),
            child: Row(
              children: [
                Icon(e.category.icon, color: e.category.color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500)),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(faculty?.name ?? e.coordinatorName ?? '',
                    style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer, fontSize: 12)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
