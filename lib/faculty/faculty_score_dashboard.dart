import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../providers/faculty_providers.dart';
import '../services/faculty_service.dart';

class FacultyScoreDashboardScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyScoreDashboardScreen({super.key, required this.user});

  @override
  ConsumerState<FacultyScoreDashboardScreen> createState() =>
      _FacultyScoreDashboardScreenState();
}

class _FacultyScoreDashboardScreenState
    extends ConsumerState<FacultyScoreDashboardScreen>
    with SingleTickerProviderStateMixin {
  EventModel? _selectedEvent;
  final Map<String, int> _assignedRanks = {};
  String _searchQuery = '';
  late TabController _tabController;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initRanks(String eventId, List<ParticipantEntry> participants) {
    if (_isInitialized) return;
    _assignedRanks.clear();

    for (final p in participants) {
      if (p.rank != null && p.rank! > 0) {
        _assignedRanks[p.userId] = p.rank!;
      }
    }
    _isInitialized = true;
  }

  int _getNextAvailableRank() {
    if (_assignedRanks.isEmpty) return 1;
    final usedRanks = _assignedRanks.values.toSet();
    int r = 1;
    while (usedRanks.contains(r)) {
      r++;
    }
    return r;
  }

  void _assignRankToStudent(String studentId, int rank) {
    setState(() {
      // If another student had this rank, swap or shift
      final existingHolder = _assignedRanks.entries
          .where((e) => e.value == rank && e.key != studentId)
          .map((e) => e.key)
          .toList();

      if (existingHolder.isNotEmpty) {
        final currentRankOfThisStudent = _assignedRanks[studentId];
        if (currentRankOfThisStudent != null) {
          _assignedRanks[existingHolder.first] = currentRankOfThisStudent;
        } else {
          _assignedRanks.remove(existingHolder.first);
        }
      }

      _assignedRanks[studentId] = rank;
    });
  }

  void _removeRank(String studentId) {
    setState(() {
      _assignedRanks.remove(studentId);
    });
  }

  Future<void> _publishRankings(EventModel currentEvent) async {
    if (_assignedRanks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign at least 1 rank before publishing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    await FacultyService.saveDirectRankings(
      eventId: currentEvent.id,
      ranks: _assignedRanks,
      declareRanks: true,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rankings declared and published for ${currentEvent.title}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 3),
      ),
    );
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
            final scoringEvents = events.where((e) => e.hasScoring).toList();
            final currentEvent = _selectedEvent ??
                (scoringEvents.isNotEmpty ? scoringEvents.first : null);

            if (currentEvent != null && _selectedEvent == null) {
              _selectedEvent = currentEvent;
            }

            return Column(
              children: [
                _buildHeader(currentEvent),
                _buildEventSelector(scoringEvents, currentEvent),
                if (currentEvent == null)
                  Expanded(child: _buildEmpty())
                else
                  Expanded(child: _buildRankingWorkspace(currentEvent)),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (e, st) => Center(child: Text('Error loading events: $e')),
        ),
      ),
    );
  }

  Widget _buildHeader(EventModel? currentEvent) {
    final isDeclared = currentEvent?.ranksDeclared ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002147), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct Rank Assignment',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select students and assign winning ranks directly',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (currentEvent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDeclared
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDeclared
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
                      : const Color(0xFFE65100).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDeclared ? Icons.verified_rounded : Icons.pending_actions_rounded,
                    size: 13,
                    color: isDeclared ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDeclared ? 'DECLARED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDeclared ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventSelector(List<EventModel> events, EventModel? currentEvent) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: events.map((e) {
            final sel = currentEvent?.id == e.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEvent = e;
                  _isInitialized = false;
                  _assignedRanks.clear();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryContainer : AppColors.canvasBackground,
                  border: Border.all(
                    color: sel ? AppColors.primaryContainer : AppColors.cardBorder,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 15,
                      color: sel ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.title,
                      style: TextStyle(
                        color: sel ? Colors.white : AppColors.onSurface,
                        fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12.5,
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

  Widget _buildRankingWorkspace(EventModel event) {
    final participantsAsync = ref.watch(facultyParticipantsProvider(event.id));

    return participantsAsync.when(
      data: (participants) {
        _initRanks(event.id, participants);

        final rankedCount = _assignedRanks.length;
        final totalCount = participants.length;

        return Column(
          children: [
            // Stats summary card
            _buildStatsBar(rankedCount, totalCount),

            // Tab navigation for Ranked vs Roster
            Container(
              color: AppColors.cardBackground,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFFB300),
                indicatorWeight: 3,
                labelColor: AppColors.primaryContainer,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.military_tech_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Ranked Winners ($rankedCount)'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Roster Selection ($totalCount)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRankedWinnersView(participants, event),
                  _buildRosterSelectionView(participants, event),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(event),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatsBar(int rankedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFE3F2FD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              Text(
                '$rankedCount Students Ranked',
                style: const TextStyle(
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          Text(
            '${totalCount - rankedCount} Unranked in Roster',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedWinnersView(List<ParticipantEntry> participants, EventModel event) {
    if (_assignedRanks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.military_tech_outlined, color: Color(0xFFFFA000), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Winners Ranked Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              const Text(
                'Switch to the "Roster Selection" tab to select students and assign 1st, 2nd, 3rd, or custom ranks.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Pick Students to Rank', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ),
      );
    }

    // Sort ranked students by their assigned rank number
    final rankedEntries = _assignedRanks.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      physics: const BouncingScrollPhysics(),
      itemCount: rankedEntries.length,
      itemBuilder: (context, i) {
        final entry = rankedEntries[i];
        final studentId = entry.key;
        final rank = entry.value;

        ParticipantEntry? p;
        for (final item in participants) {
          if (item.userId == studentId) {
            p = item;
            break;
          }
        }

        final studentName = p?.userName ?? 'Student';
        final rollNo = p?.enrollmentNo ?? 'Roll N/A';
        final dept = p?.department ?? 'General';

        return _buildRankedCard(studentId, studentName, rollNo, dept, rank);
      },
    );
  }

  Widget _buildRankedCard(
    String studentId,
    String name,
    String rollNo,
    String dept,
    int rank,
  ) {
    Color badgeColor;
    String medalEmoji;
    String rankTitle;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        medalEmoji = '🥇';
        rankTitle = '1st Place (Winner)';
        break;
      case 2:
        badgeColor = const Color(0xFFE0E0E0); // Silver
        medalEmoji = '🥈';
        rankTitle = '2nd Place (Runner Up)';
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        medalEmoji = '🥉';
        rankTitle = '3rd Place';
        break;
      default:
        badgeColor = const Color(0xFFE3F2FD);
        medalEmoji = '🎖️';
        rankTitle = 'Rank #$rank';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? badgeColor.withValues(alpha: 0.8) : AppColors.cardBorder,
          width: rank <= 3 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (rank <= 3 ? badgeColor : Colors.black).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Rank Badge Column
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                medalEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rankTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: rank <= 3 ? const Color(0xFFE65100) : const Color(0xFF1565C0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '$rollNo • $dept',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Rank Dropdown Selector (Direct Rank modification)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.canvasBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: rank,
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                items: List.generate(10, (idx) => idx + 1).map((r) {
                  return DropdownMenuItem<int>(
                    value: r,
                    child: Text('Rank $r'),
                  );
                }).toList(),
                onChanged: (newRank) {
                  if (newRank != null) {
                    _assignRankToStudent(studentId, newRank);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Remove Rank Button
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
            tooltip: 'Remove from ranking',
            onPressed: () => _removeRank(studentId),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterSelectionView(List<ParticipantEntry> participants, EventModel event) {
    final filtered = participants.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.userName.toLowerCase().contains(_searchQuery) ||
          p.enrollmentNo.toLowerCase().contains(_searchQuery) ||
          p.department.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.cardBackground,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search attendee by name or roll no...',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryContainer),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
              ),
            ),
          ),
        ),

        // List of students in roster
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No students match search criteria.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    final currentRank = _assignedRanks[p.userId];
                    final isRanked = currentRank != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isRanked
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isRanked
                                ? const Color(0xFFE8F5E9)
                                : AppColors.canvasBackground,
                            foregroundColor: isRanked
                                ? const Color(0xFF2E7D32)
                                : AppColors.onSurfaceVariant,
                            child: Text(
                              isRanked ? '#$currentRank' : (p.userName.isNotEmpty ? p.userName.substring(0, 1) : 'S'),
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
                                    fontSize: 13.5,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  '${p.enrollmentNo} • ${p.department}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),

                          // Action button to Assign Rank
                          if (isRanked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rank #$currentRank',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 15),
                              label: Text(
                                'Assign Rank ${_getNextAvailableRank()}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _showRankPickerModal(p);
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
  }

  void _showRankPickerModal(ParticipantEntry student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: Color(0xFFFFB300), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Assign Rank to ${student.userName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${student.enrollmentNo} • ${student.department}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const Divider(height: 24),
              const Text('Select Position / Rank:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _rankOptionButton(student.userId, 1, '🥇 1st Place (Winner)', const Color(0xFFFFD700), ctx),
                  _rankOptionButton(student.userId, 2, '🥈 2nd Place (Runner Up)', const Color(0xFFE0E0E0), ctx),
                  _rankOptionButton(student.userId, 3, '🥉 3rd Place', const Color(0xFFCD7F32), ctx),
                  _rankOptionButton(student.userId, 4, '🎖️ Rank #4', const Color(0xFFE3F2FD), ctx),
                  _rankOptionButton(student.userId, 5, '🎖️ Rank #5', const Color(0xFFE3F2FD), ctx),
                  _rankOptionButton(student.userId, 6, '🎖️ Rank #6', const Color(0xFFE3F2FD), ctx),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _rankOptionButton(String studentId, int rank, String label, Color color, BuildContext ctx) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _assignRankToStudent(studentId, rank);
        _tabController.animateTo(0); // Switch to Ranked Winners view
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.onSurface),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(EventModel event) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.verified_rounded, size: 20),
          label: Text(
            _isSaving ? 'Publishing...' : 'Declare & Publish Rankings',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
          onPressed: _isSaving ? null : () => _publishRankings(event),
        ),
      ),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Text('No scoring events available to rank.'),
      );
}
