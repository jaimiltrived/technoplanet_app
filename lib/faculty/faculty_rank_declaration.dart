import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../providers/faculty_providers.dart';
import '../services/faculty_service.dart';

class FacultyRankDeclarationScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyRankDeclarationScreen({super.key, required this.user});

  @override
  ConsumerState<FacultyRankDeclarationScreen> createState() =>
      _FacultyRankDeclarationScreenState();
}

class _FacultyRankDeclarationScreenState
    extends ConsumerState<FacultyRankDeclarationScreen> {
  EventModel? _selectedEvent;
  bool _declaredLocally = false;
  final Map<String, int> _customRanks = {};

  void _initDefaultRanks(List<ParticipantEntry> participants, String eventId) {
    if (_customRanks.isNotEmpty) return; // already initialized
    
    for (int i = 0; i < participants.length; i++) {
      if (participants[i].rank != null) {
        _customRanks[participants[i].userId] = participants[i].rank!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(facultyEventsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Rank Declaration',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: eventsAsync.when(
        data: (events) {
          final eligibleEvents = events.where((e) => e.hasScoring).toList();
          final currentEvent = _selectedEvent ?? (eligibleEvents.isNotEmpty ? eligibleEvents.first : null);

          return Column(
            children: [
              _buildEventSelector(eligibleEvents, currentEvent),
              Expanded(
                child: currentEvent == null
                    ? _buildEmpty()
                    : _buildContentWrapper(currentEvent),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEventSelector(List<EventModel> events, EventModel? currentEvent) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.primaryContainer, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Event to Assign Ranks',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.canvasBackground,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentEvent?.id,
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                ),
                items: events
                    .map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: e.ranksDeclared ? const Color(0xFF2E7D32).withValues(alpha: 0.1) : const Color(0xFFFF8F00).withValues(alpha: 0.1),
                                  borderRadius: AppRadius.smRadius,
                                ),
                                child: Text(
                                  e.ranksDeclared ? "Declared" : "Pending",
                                  style: AppTypography.labelBold.copyWith(
                                    color: e.ranksDeclared ? const Color(0xFF2E7D32) : const Color(0xFFFF8F00),
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      final match = events.firstWhere((e) => e.id == v);
                      _selectedEvent = match;
                      _declaredLocally = false;
                      _customRanks.clear(); // Reset custom ranks for new event
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded,
                size: 64, color: AppColors.outline.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No events pending rank declaration',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildContentWrapper(EventModel event) {
    final participantsAsync = ref.watch(facultyParticipantsProvider(event.id));

    return participantsAsync.when(
      data: (allParticipants) {
        if (allParticipants.isEmpty) {
          return const Center(child: Text("No registered participants for this event."));
        }

        _initDefaultRanks(allParticipants, event.id);
        return _buildContent(allParticipants, event);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(List<ParticipantEntry> participants, EventModel event) {
    // Assign custom ranks from state
    for (final p in participants) {
      if (_customRanks.containsKey(p.userId)) {
        p.rank = _customRanks[p.userId];
      }
    }

    // Sort by rank assigned
    participants.sort((a, b) => (a.rank ?? 99).compareTo(b.rank ?? 99));

    final isReadOnly = event.ranksDeclared || _declaredLocally;

    return Column(
      children: [
        if (isReadOnly)
          _buildAlreadyDeclaredBanner()
        else
          _buildPendingBanner(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            physics: const BouncingScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (_, i) {
              final p = participants[i];
              final currentRank = p.rank ?? (i + 1);

              return _RankRow(
                participant: p,
                rank: currentRank,
                totalCount: participants.length,
                isReadOnly: isReadOnly,
                onRankChanged: (newRank) {
                  setState(() {
                    _customRanks[p.userId] = newRank;
                  });
                },
              );
            },
          ),
        ),
        if (!isReadOnly)
          _buildDeclareButton(context),
      ],
    );
  }

  Widget _buildPendingBanner() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(color: const Color(0xFFFFCC02)),
          borderRadius: AppRadius.mdRadius,
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFFFF8F00), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select ranks for each student using the rank dropdowns below, then click "Declare Results" to publish.',
                style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF8B5E00), height: 1.4),
              ),
            ),
          ],
        ),
      );

  Widget _buildAlreadyDeclaredBanner() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          border: Border.all(color: const Color(0xFF2E7D32)),
          borderRadius: AppRadius.mdRadius,
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF2E7D32), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ranks have been declared and published to all students.',
                style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

  Widget _buildDeclareButton(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00),
              elevation: 4,
              shadowColor: const Color(0xFFFF8F00).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            ),
            icon: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
            label: Text('Declare Results & Notify',
                style: AppTypography.bodyLg.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () => _showConfirmDialog(context),
          ),
        ),
      );

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Rank Declaration',
            style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
        content: Text(
          'Once ranks are declared, final positions will be published and all participants will be notified. Proceed?',
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8F00)),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              if (_selectedEvent != null) {
                await FacultyService.saveDirectRankings(
                  eventId: _selectedEvent!.id,
                  ranks: _customRanks,
                  declareRanks: true,
                );
              }
              if (!mounted) return;
              setState(() => _declaredLocally = true);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Ranks declared successfully! Students notified.'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            child: const Text('Declare Ranks'),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final ParticipantEntry participant;
  final int rank;
  final int totalCount;
  final bool isReadOnly;
  final ValueChanged<int> onRankChanged;

  const _RankRow({
    required this.participant,
    required this.rank,
    required this.totalCount,
    required this.isReadOnly,
    required this.onRankChanged,
  });

  @override
  Widget build(BuildContext context) {
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final medalColor = rank <= 3 ? medalColors[rank - 1] : AppColors.onSurfaceVariant.withValues(alpha: 0.5);

    final rankOptions = List.generate(
      totalCount > 10 ? totalCount : 10,
      (index) => index + 1,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: rank <= 3 ? medalColor.withValues(alpha: 0.5) : AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
        boxShadow: rank <= 3 ? [
          BoxShadow(
            color: medalColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? medalColor.withValues(alpha: 0.2) : AppColors.canvasBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('#$rank',
                  style: AppTypography.labelBold.copyWith(
                    color: rank <= 3 ? medalColor : AppColors.onSurfaceVariant,
                    fontSize: 14,
                  )),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.userName,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('${participant.score} pts',
                    style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 11)),
              ],
            ),
          ),
          if (isReadOnly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.canvasBackground,
                borderRadius: AppRadius.smRadius,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'Rank $rank',
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface, fontSize: 13),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.canvasBackground,
                borderRadius: AppRadius.smRadius,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: rank,
                  items: rankOptions
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text('Rank $r',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurface)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onRankChanged(v);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
