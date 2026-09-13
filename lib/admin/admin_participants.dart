// lib/admin/admin_participants.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../providers/admin_providers.dart';
import '../services/score_service.dart';
import '../faculty/faculty_student_detail.dart';

class AdminParticipantsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const AdminParticipantsScreen({super.key, required this.user});

  @override
  ConsumerState<AdminParticipantsScreen> createState() =>
      _AdminParticipantsScreenState();
}

class _AdminParticipantsScreenState extends ConsumerState<AdminParticipantsScreen> {
  EventModel? _selectedEvent;
  String _searchQuery = '';
  String _selectedDept = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  List<ParticipantEntry> _participantsList = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchEventParticipants(String eventId) async {
    setState(() => _isLoading = true);
    try {
      final list = await ScoreService.fetchEventParticipants(eventId);
      if (mounted) {
        setState(() {
          _participantsList = list;
          _isLoading = false;
        });
      }
    } catch (err) {
      debugPrint('[AdminParticipants] _fetchEventParticipants error: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ParticipantEntry> get _filteredParticipants {
    return _participantsList.where((p) {
      final matchDept =
          _selectedDept == 'All' || p.department == _selectedDept;
      final matchSearch = _searchQuery.isEmpty ||
          p.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.enrollmentNo.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchDept && matchSearch;
    }).toList();
  }

  List<String> get _departments {
    final all = _participantsList
        .map((p) => p.department)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...all];
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Participants',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isNotEmpty && _selectedEvent == null) {
            _selectedEvent = events.first;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchEventParticipants(events.first.id);
            });
          }

          return Column(
            children: [
              _buildHeader(events),
              _buildEventSelector(events),
              _buildSearchAndFilter(),
              _buildStats(),
              Expanded(child: _buildList()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading events: $e')),
      ),
    );
  }

  Widget _buildHeader(List<EventModel> events) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        color: AppColors.cardBackground,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Participants',
                  style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface, fontSize: 16),
                ),
                Text(
                  'Select an event to view registered students',
                  style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text(
                '${events.fold(0, (s, e) => s + e.currentParticipants)} Total',
                style: AppTypography.labelBold
                    .copyWith(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      );

  Widget _buildEventSelector(List<EventModel> events) {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: events.map((e) {
            final sel = _selectedEvent?.id == e.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEvent = e;
                  _selectedDept = 'All';
                  _searchCtrl.clear();
                  _searchQuery = '';
                });
                _fetchEventParticipants(e.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryContainer
                      : AppColors.canvasBackground,
                  border: Border.all(
                      color: sel
                          ? AppColors.primaryContainer
                          : AppColors.cardBorder),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.title,
                        style: AppTypography.labelBold.copyWith(
                          color: sel
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontSize: 12,
                        )),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sel
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.primaryContainer
                                .withValues(alpha: 0.1),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        '${e.currentParticipants}',
                        style: AppTypography.labelBold.copyWith(
                          color: sel
                              ? Colors.white
                              : AppColors.primaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by name or enrollment...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.onSurfaceVariant, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                filled: true,
                fillColor: AppColors.canvasBackground,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.mdRadius,
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdRadius,
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _selectedDept = v),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedDept == 'All'
                    ? AppColors.canvasBackground
                    : AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                    color: _selectedDept == 'All'
                        ? AppColors.cardBorder
                        : AppColors.primaryContainer),
              ),
              child: Icon(Icons.filter_list_rounded,
                  color: _selectedDept == 'All'
                      ? AppColors.onSurfaceVariant
                      : AppColors.primaryContainer,
                  size: 20),
            ),
            itemBuilder: (_) => _departments
                .map((d) => PopupMenuItem(value: d, child: Text(d)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final total = _filteredParticipants.length;
    final withScore = _filteredParticipants.where((p) => p.score != null).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.06),
        border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.2)),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        children: [
          _stat('$total', 'Participants'),
          _statDiv(),
          _stat('$withScore', 'Scored'),
          _statDiv(),
          _stat('${total - withScore}', 'Pending'),
          _statDiv(),
          _stat(
            _selectedEvent != null ? _selectedEvent!.title.split(' ').first : '—',
            'Event',
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Column(
          children: [
            Text(v,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dataPoint
                    .copyWith(color: AppColors.primaryContainer, fontSize: 16)),
            Text(l,
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 10)),
          ],
        ),
      );

  Widget _statDiv() => Container(
      width: 1,
      height: 28,
      color: AppColors.primaryContainer.withValues(alpha: 0.2));

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final participants = _filteredParticipants;
    if (_selectedEvent == null) {
      return Center(
        child: Text('No events found',
            style: AppTypography.headlineMd
                .copyWith(color: AppColors.onSurfaceVariant)),
      );
    }

    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_rounded,
                size: 56, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No participants found',
                style: AppTypography.headlineMd
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Try changing the event or clearing filters',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, i) {
        final p = participants[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyStudentDetailScreen(
                  participant: p,
                  event: _selectedEvent,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryContainer.withValues(alpha: 0.8),
                        AppColors.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      p.userName.isNotEmpty ? p.userName.substring(0, 1).toUpperCase() : 'S',
                      style: AppTypography.headlineMd.copyWith(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.userName,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${p.enrollmentNo} · ${p.department}',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12)),
                      if (p.collegeName != null) ...[
                        const SizedBox(height: 2),
                        Text(p.collegeName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (p.score != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${p.score} pts',
                          style: AppTypography.dataPoint.copyWith(
                              color: AppColors.primaryContainer, fontSize: 14)),
                      if (p.rank != null)
                        Text('Rank #${p.rank}',
                            style: AppTypography.labelBold.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11)),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvasBackground,
                      borderRadius: AppRadius.fullRadius,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text('Registered',
                        style: AppTypography.labelBold.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 10)),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
