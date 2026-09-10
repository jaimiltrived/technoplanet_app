import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../providers/faculty_providers.dart';
import 'faculty_student_detail.dart';

class FacultyParticipantsListScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final EventModel? initialEvent;
  const FacultyParticipantsListScreen({super.key, required this.user, this.initialEvent});

  @override
  ConsumerState<FacultyParticipantsListScreen> createState() =>
      _FacultyParticipantsListScreenState();
}

class _FacultyParticipantsListScreenState
    extends ConsumerState<FacultyParticipantsListScreen> {
  EventModel? _selectedEvent;
  String _searchQuery = '';
  String _selectedDept = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _selectedEvent = widget.initialEvent;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(facultyEventsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: eventsAsync.when(
          data: (events) {
            final currentEvent = _selectedEvent ?? (events.isNotEmpty ? events.first : null);
            if (currentEvent == null) {
              return const Center(child: Text('No assigned events'));
            }

            final participantsAsync = ref.watch(facultyParticipantsProvider(currentEvent.id));

            return participantsAsync.when(
              data: (rawParticipants) {
                final departments = ['All', ...rawParticipants.map((p) => p.department).toSet().toList()..sort()];
                final filtered = rawParticipants.where((p) {
                  final matchDept = _selectedDept == 'All' || p.department == _selectedDept;
                  final matchSearch = _searchQuery.isEmpty ||
                      p.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      p.enrollmentNo.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchDept && matchSearch;
                }).toList();

                return Column(
                  children: [
                    _buildHeader(),
                    _buildEventSelector(events, currentEvent),
                    _buildSearchAndFilter(departments),
                    _buildStats(filtered),
                    Expanded(child: _buildList(filtered, currentEvent)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: Row(
          children: [
            if (Navigator.canPop(context)) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
            ],
            const Icon(Icons.people_alt_rounded, color: AppColors.primaryContainer, size: 24),
            const SizedBox(width: 10),
            Text('Participants',
                style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface)),
          ],
        ),
      );

  Widget _buildEventSelector(List<EventModel> events, EventModel currentEvent) {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: events.map((e) {
            final sel = currentEvent.id == e.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedEvent = e;
                _selectedDept = 'All';
                _searchCtrl.clear();
                _searchQuery = '';
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryContainer : AppColors.canvasBackground,
                  border: Border.all(color: sel ? AppColors.primaryContainer : AppColors.cardBorder),
                  borderRadius: AppRadius.fullRadius,
                  boxShadow: sel ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: Text(e.title,
                    style: AppTypography.labelBold.copyWith(
                      color: sel ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 13,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(List<String> departments) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.canvasBackground,
                borderRadius: AppRadius.mdRadius,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search participants...',
                  hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _selectedDept = v),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedDept == 'All' ? AppColors.canvasBackground : AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdRadius,
                border: Border.all(
                    color: _selectedDept == 'All' ? AppColors.cardBorder : AppColors.primaryContainer),
              ),
              child: Icon(Icons.tune_rounded,
                  color: _selectedDept == 'All' ? AppColors.onSurfaceVariant : AppColors.primaryContainer,
                  size: 22),
            ),
            itemBuilder: (_) => departments
                .map((d) => PopupMenuItem(
                      value: d,
                      child: Text(d, style: AppTypography.bodySm),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<ParticipantEntry> participants) {
    final total = participants.length;
    final withScore = participants.where((p) => p.score != null).length;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          _stat('$total', 'Total\nParticipants', Icons.groups_rounded),
          _statDiv(),
          _stat('$withScore', 'Scores\nEntered', Icons.check_circle_outline_rounded),
          _statDiv(),
          _stat('${total - withScore}', 'Pending\nScores', Icons.pending_actions_rounded),
        ],
      ),
    );
  }

  Widget _stat(String v, String l, IconData icon) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 6),
            Text(v,
                style: AppTypography.dataPoint.copyWith(
                    color: Colors.white, fontSize: 24)),
            const SizedBox(height: 2),
            Text(l,
                textAlign: TextAlign.center,
                style: AppTypography.labelBold.copyWith(
                    color: Colors.white70, fontSize: 10, height: 1.2)),
          ],
        ),
      );

  Widget _statDiv() =>
      Container(width: 1, height: 40, color: Colors.white24);

  Widget _buildList(List<ParticipantEntry> participants, EventModel currentEvent) {
    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No participants found',
                style: AppTypography.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, i) {
        final p = participants[i];
        final hasScore = p.score != null;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyStudentDetailScreen(
                  participant: p,
                  event: currentEvent,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: AppRadius.mdRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasScore 
                        ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                        : [AppColors.primaryContainer, const Color(0xFF003D7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(p.userName.substring(0, 1),
                        style: AppTypography.headlineMd.copyWith(
                            color: Colors.white, fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.userName,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('${p.enrollmentNo} · ${p.department}',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                if (p.rank != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.rank == 1
                          ? const Color(0xFFFFF8E1)
                          : (p.rank == 2
                              ? const Color(0xFFECEFF1)
                              : (p.rank == 3 ? const Color(0xFFEFEBE9) : const Color(0xFFE3F2FD))),
                      borderRadius: AppRadius.smRadius,
                      border: Border.all(
                        color: p.rank == 1
                            ? const Color(0xFFFFB300)
                            : (p.rank == 2
                                ? Colors.grey
                                : (p.rank == 3 ? Colors.brown : const Color(0xFF1565C0))),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      p.rank == 1
                          ? '🥇 1st Place'
                          : (p.rank == 2
                              ? '🥈 2nd Place'
                              : (p.rank == 3 ? '🥉 3rd Place' : 'Rank #${p.rank}')),
                      style: AppTypography.labelBold.copyWith(
                        color: p.rank == 1
                            ? const Color(0xFFE65100)
                            : (p.rank == 2
                                ? Colors.blueGrey
                                : (p.rank == 3 ? Colors.brown : const Color(0xFF1565C0))),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (hasScore)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Text('${p.score} pts',
                            style: AppTypography.dataPoint.copyWith(
                                color: const Color(0xFF2E7D32), fontSize: 14)),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_actions_rounded, color: Color(0xFFFF8F00), size: 14),
                        const SizedBox(width: 4),
                        Text('Pending',
                            style: AppTypography.labelBold.copyWith(
                                color: const Color(0xFFFF8F00), fontSize: 11)),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
