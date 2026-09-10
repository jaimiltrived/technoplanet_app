// lib/student/student_rankings.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_providers.dart';
import '../providers/score_providers.dart';

class StudentRankingsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const StudentRankingsScreen({super.key, required this.user});

  @override
  ConsumerState<StudentRankingsScreen> createState() => _StudentRankingsScreenState();
}

class _StudentRankingsScreenState extends ConsumerState<StudentRankingsScreen> {
  EventModel? _selectedEvent;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: eventsAsync.when(
          data: (events) {
            final completedEvents = events.where((e) => e.ranksDeclared).toList();
            if (_selectedEvent == null && completedEvents.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _selectedEvent = completedEvents.first);
              });
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildCountdownCard(events)),
                SliverToBoxAdapter(child: _buildEventSelector(completedEvents)),
                if (_selectedEvent != null)
                  SliverToBoxAdapter(
                    child: ref.watch(eventRankingsProvider(_selectedEvent!.id)).when(
                      data: (participants) => Column(
                        children: [
                          _buildTop3(participants),
                          _buildFullLeaderboard(participants),
                        ],
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text('Error loading rankings', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant))),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text('Error loading events')),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          const Icon(Icons.leaderboard_rounded,
              color: AppColors.primaryContainer, size: 24),
          const SizedBox(width: 10),
          Text('Rankings',
              style: AppTypography.headlineLgMobile.copyWith(
                  color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(List<EventModel> events) {
    final upcomingEvents = events.where((e) => e.hasScoring && !e.ranksDeclared && e.dateTime.isAfter(DateTime.now())).toList();
    if (upcomingEvents.isEmpty) return const SizedBox.shrink();

    upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextEvent = upcomingEvents.first;
    
    final diff = nextEvent.dateTime.difference(DateTime.now());
    final remaining = diff.isNegative ? Duration.zero : diff;

    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    String pad(int n) => n.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Next Rank Announcement',
              style: AppTypography.bodySm.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(nextEvent.title,
              style: AppTypography.headlineMd.copyWith(
                  color: Colors.white, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _countUnit(pad(h), 'HRS'),
              _colon(),
              _countUnit(pad(m), 'MIN'),
              _colon(),
              _countUnit(pad(s), 'SEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countUnit(String val, String label) => Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.smRadius,
            ),
            child: Center(
              child: Text(val,
                  style: AppTypography.headlineLg.copyWith(
                      color: Colors.white, fontSize: 28)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTypography.labelBold.copyWith(
                  color: Colors.white60, fontSize: 10)),
        ],
      );

  Widget _colon() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(':',
            style: AppTypography.headlineLg.copyWith(
                color: Colors.white60, fontSize: 28)),
      );

  Widget _buildEventSelector(List<EventModel> events) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Event',
              style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface, fontSize: 15)),
          const SizedBox(height: 10),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No rankings available yet.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: events.map((e) {
                final sel = _selectedEvent?.id == e.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEvent = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryContainer
                          : AppColors.cardBackground,
                      border: Border.all(
                        color: sel
                            ? AppColors.primaryContainer
                            : AppColors.cardBorder,
                      ),
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Text(e.title,
                        style: AppTypography.bodySm.copyWith(
                          color: sel ? Colors.white : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop3(List<ParticipantEntry> participants) {
    final sorted = participants
        .where((p) => p.rank != null)
        .toList()
      ..sort((a, b) => (a.rank as int).compareTo(b.rank as int));
    if (sorted.length < 3) return const SizedBox.shrink();

    final podiumColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final podiumHeights = [110.0, 80.0, 60.0];
    final order = [1, 0, 2]; // Display order: 2nd, 1st, 3rd

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 3 Winners',
              style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface, fontSize: 15)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.05),
                  AppColors.goldAccent.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                // Avatars row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: order.map((idx) {
                    final p = sorted[idx];
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (idx == 0)
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFD700), size: 24),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: podiumColors[idx].withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: podiumColors[idx], width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                p.userName.substring(0, 1),
                                style: AppTypography.headlineMd.copyWith(
                                    color: podiumColors[idx], fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(p.userName.split(' ').first,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              )),
                          Text(
                            p.score != null && p.score! > 0
                                ? '${p.score} pts'
                                : (idx == 0 ? 'Winner 🥇' : (idx == 1 ? 'Runner Up 🥈' : '3rd Place 🥉')),
                            style: AppTypography.labelBold.copyWith(
                                color: podiumColors[idx], fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          // Podium block
                          Container(
                            height: podiumHeights[idx],
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: podiumColors[idx].withValues(alpha: 0.15),
                              border: Border.all(
                                  color: podiumColors[idx].withValues(alpha: 0.4)),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '#${idx + 1}',
                                style: AppTypography.headlineMd.copyWith(
                                    color: podiumColors[idx], fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullLeaderboard(List<ParticipantEntry> participants) {
    final sorted = participants
        .where((p) => p.rank != null)
        .toList()
      ..sort((a, b) => (a.rank as int).compareTo(b.rank as int));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full Leaderboard',
              style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface, fontSize: 15)),
          const SizedBox(height: 10),
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final isMe = p.userId == widget.user.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryContainer.withValues(alpha: 0.06)
                    : AppColors.cardBackground,
                border: Border.all(
                  color: isMe
                      ? AppColors.primaryContainer
                      : AppColors.cardBorder,
                  width: isMe ? 2 : 1,
                ),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: i < 3
                          ? [
                              const Color(0xFFFFD700),
                              const Color(0xFFC0C0C0),
                              const Color(0xFFCD7F32)
                            ][i].withValues(alpha: 0.2)
                          : AppColors.canvasBackground,
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Center(
                      child: Text('#${p.rank}',
                          style: AppTypography.labelBold.copyWith(
                            color: i < 3
                                ? [
                                    const Color(0xFFB8860B),
                                    const Color(0xFF757575),
                                    const Color(0xFF8B4513)
                                  ][i]
                                : AppColors.onSurfaceVariant,
                            fontSize: 12,
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.userName,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                )),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppRadius.fullRadius,
                                ),
                                child: Text('You',
                                    style: AppTypography.labelBold.copyWith(
                                        color: Colors.white, fontSize: 9)),
                              ),
                            ],
                          ],
                        ),
                        Text(p.department,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (p.score != null && p.score! > 0) ...[
                    Text('${p.score}',
                        style: AppTypography.dataPoint.copyWith(
                            color: AppColors.onSurface, fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('pts',
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (p.rank ?? 99) <= 3
                            ? const Color(0xFFFFF8E1)
                            : AppColors.canvasBackground,
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Text(
                        (p.rank ?? 99) == 1
                            ? '🥇 1st'
                            : ((p.rank ?? 99) == 2
                                ? '🥈 2nd'
                                : ((p.rank ?? 99) == 3 ? '🥉 3rd' : 'Rank #${p.rank}')),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: (p.rank ?? 99) <= 3
                              ? const Color(0xFFE65100)
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
