import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/volunteer_providers.dart';
import '../services/volunteer_service.dart';

class VolunteerParticipantsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final String? initialEventId;

  const VolunteerParticipantsScreen({
    super.key,
    required this.user,
    this.initialEventId,
  });

  @override
  ConsumerState<VolunteerParticipantsScreen> createState() =>
      _VolunteerParticipantsScreenState();
}

class _VolunteerParticipantsScreenState
    extends ConsumerState<VolunteerParticipantsScreen> {
  String? _selectedEventId;
  String _searchQuery = '';
  int _filterIndex = 0; // 0 = All, 1 = Checked-In, 2 = Pending

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEventId;
  }

  @override
  Widget build(BuildContext context) {
    // Watch attendance changes to re-evaluate isCheckedIn states dynamically
    ref.watch(attendanceChangeProvider);
    final eventsAsync = ref.watch(volunteerEventsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        title: const Text('Attendee Roster & Attendance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Event Dropdown Header
          _buildEventSelector(eventsAsync),

          // Search and Filter Bar
          _buildFilterBar(),

          // Participants List
          Expanded(
            child: _selectedEventId == null
                ? const Center(child: Text('Select an event to view attendees'))
                : _buildParticipantsList(_selectedEventId!),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSelector(AsyncValue<List<EventModel>> eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No events assigned.'),
          );
        }
        if (_selectedEventId == null || !events.any((e) => e.id == _selectedEventId)) {
          _selectedEventId = events.first.id;
        }

        return Container(
          color: const Color(0xFF004D40),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEventId,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF004D40)),
                items: events.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(
                      e.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Color(0xFF004D40),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedEventId = val);
                },
              ),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: Color(0xFF00897B)),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          // Search input
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search attendee by name or enrollment...',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF00897B)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: AppColors.canvasBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips
          Row(
            children: [
              _buildFilterChip('All', 0),
              const SizedBox(width: 8),
              _buildFilterChip('Checked-In', 1),
              const SizedBox(width: 8),
              _buildFilterChip('Pending', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _filterIndex == index;
    return InkWell(
      onTap: () => setState(() => _filterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00897B) : AppColors.canvasBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00897B) : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsList(String eventId) {
    final participantsAsync = ref.watch(volunteerParticipantsProvider(eventId));

    return participantsAsync.when(
      data: (participants) {
        final filtered = participants.where((p) {
          final matchesSearch = _searchQuery.isEmpty ||
              p.userName.toLowerCase().contains(_searchQuery) ||
              p.enrollmentNo.toLowerCase().contains(_searchQuery) ||
              p.department.toLowerCase().contains(_searchQuery);

          if (!matchesSearch) return false;

          final isChecked = VolunteerService.isCheckedIn(eventId, p.userId);
          if (_filterIndex == 1 && !isChecked) return false;
          if (_filterIndex == 2 && isChecked) return false;

          return true;
        }).toList();

        final totalParticipants = participants.length;
        final checkedInCount = participants.where((p) => VolunteerService.isCheckedIn(eventId, p.userId)).length;
        final double percent = totalParticipants > 0 ? (checkedInCount / totalParticipants) : 0.0;

        return Column(
          children: [
            // Attendance Progress Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFFE0F2F1),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Checked In: $checkedInCount / $totalParticipants',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004D40),
                              ),
                            ),
                            Text(
                              '${(percent * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF004D40),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List of attendees
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No attendees matching criteria.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final p = filtered[i];
                        final isChecked = VolunteerService.isCheckedIn(eventId, p.userId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isChecked
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                              : AppColors.cardBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isChecked
                                ? const Color(0xFFE8F5E9)
                                : AppColors.canvasBackground,
                            foregroundColor: isChecked
                                ? const Color(0xFF2E7D32)
                                : AppColors.onSurfaceVariant,
                            child: Text(
                              p.userName.isNotEmpty ? p.userName.substring(0, 1) : 'S',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.enrollmentNo} • ${p.department}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 1-Tap Attendance Check-In Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isChecked
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: Icon(
                              isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              size: 15,
                            ),
                            label: Text(
                              isChecked ? 'Present' : 'Check In',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              VolunteerService.toggleManualAttendance(eventId, p.userId);
                              ref.read(attendanceChangeProvider.notifier).notifyChanged();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF004D40)),
      ),
      error: (e, _) => Center(
        child: Text('Error loading participants: $e'),
      ),
    );
  }
}
