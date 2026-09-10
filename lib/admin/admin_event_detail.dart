// lib/admin/admin_event_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../services/score_service.dart';
import '../services/admin_service.dart';
import '../providers/event_providers.dart';
import '../faculty/faculty_student_detail.dart';
import 'admin_event_form.dart';

class AdminEventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;
  const AdminEventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<AdminEventDetailScreen> createState() => _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState extends ConsumerState<AdminEventDetailScreen> {
  List<ParticipantEntry> _participants = [];
  bool _isLoading = false;

  EventModel get event => widget.event;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEventFormScreen(event: event),
      ),
    );
    if (!mounted) return;
    if (updated == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Event', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await AdminService.deleteEvent(event.id);
        if (success) {
          ref.invalidate(eventsProvider);
          ref.invalidate(allEventsProvider);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully'), backgroundColor: Color(0xFF2E7D32)),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to delete event');
        }
      } catch (e, stack) {
        debugPrint('[AdminEventDetail] Error deleting event: $e\n$stack');
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting event: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);
    try {
      final list = await ScoreService.fetchEventParticipants(widget.event.id);
      if (mounted) {
        setState(() {
          _participants = list;
          _isLoading = false;
        });
      }
    } catch (err) {
      debugPrint('[AdminEventDetail] _loadParticipants error: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── Sliver App Bar ───────────────────────────────────────────────────────
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
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 18),
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
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => _navigateToEdit(),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => _confirmDelete(),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                event.accentColor,
                event.accentColor.withValues(alpha: 0.55),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      _pill(event.category.label),
                      _pill(event.status.label),
                      if (event.ranksDeclared)
                        _pill('Results Out', bg: AppColors.goldAccent),
                      if (event.hasScoring) _pill('Scored Event'),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    event.title,
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 4),
                      Text(event.location,
                          style: AppTypography.bodySm
                              .copyWith(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
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

  // ─── Content ──────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoGrid(),
          const SizedBox(height: 20),

          // Admin stats row
          _buildAdminStatsRow(),
          const SizedBox(height: 20),

          // Description
          _sectionTitle('About this Event'),
          const SizedBox(height: 8),
          Text(event.description,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.7,
              )),
          const SizedBox(height: 20),

          // Coordinator
          if (event.coordinatorName != null) ...[
            _sectionTitle('Assigned Faculty'),
            const SizedBox(height: 10),
            _buildCoordinatorCard(),
            const SizedBox(height: 20),
          ],

          // Registration Deadline
          if (event.registrationDeadline != null) ...[
            _buildDeadlineBanner(),
            const SizedBox(height: 20),
          ],

          // Top 3 participants
          _buildTop3Section(context),

          const SizedBox(height: 20),

          // All participants list
          _buildParticipantsList(context),

          // Rules
          const SizedBox(height: 20),
          _buildRulesSection(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
      );

  Widget _buildInfoGrid() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dt = event.dateTime;
    final items = [
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'Date',
        'value': '${dt.day} ${months[dt.month - 1]}, ${dt.year}'
      },
      {
        'icon': Icons.access_time_rounded,
        'label': 'Time',
        'value': _timeStr(dt)
      },
      {
        'icon': Icons.location_on_rounded,
        'label': 'Venue',
        'value': event.location
      },
      {
        'icon': Icons.group_rounded,
        'label': 'Participants',
        'value': '${event.currentParticipants}/${event.maxParticipants}'
      },
      {
        'icon': Icons.payments_rounded,
        'label': 'Fee',
        'value': event.registrationFee == 0
            ? 'Free'
            : '₹${event.registrationFee.toInt()}'
      },
      {
        'icon': Icons.emoji_events_rounded,
        'label': 'Scoring',
        'value': event.hasScoring ? 'Yes' : 'No'
      },
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

  Widget _buildAdminStatsRow() {
    final participants = _participants;
    final scored = participants.where((p) => p.score != null).length;
    final pending = participants.length - scored;
    final fillPct = event.maxParticipants > 0
        ? (event.currentParticipants / event.maxParticipants * 100)
            .clamp(0.0, 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.05),
        border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.2)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.primaryContainer, size: 16),
              const SizedBox(width: 6),
              Text('Admin Overview',
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.primaryContainer, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStat('${participants.length}', 'Registered',
                  AppColors.primaryContainer),
              _miniStat('$scored', 'Scored', const Color(0xFF2E7D32)),
              _miniStat('$pending', 'Pending', Colors.orange),
              _miniStat(
                  '${fillPct.toInt()}%', 'Filled', event.accentColor),
            ],
          ),
          const SizedBox(height: 10),
          // Fill progress bar
          ClipRRect(
            borderRadius: AppRadius.fullRadius,
            child: LinearProgressIndicator(
              value: fillPct / 100,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(event.accentColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.currentParticipants} of ${event.maxParticipants} seats filled',
            style: AppTypography.bodySm
                .copyWith(color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String val, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(val,
                style: AppTypography.dataPoint
                    .copyWith(color: color, fontSize: 18)),
            Text(label,
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 10)),
          ],
        ),
      );

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
              Text('Assigned Faculty · ${event.category.label}',
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
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
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

  Widget _buildTop3Section(BuildContext context) {
    final ranked = _participants
        .where((p) => p.rank != null)
        .toList()
      ..sort((a, b) => (a.rank ?? 99).compareTo(b.rank ?? 99));
    if (ranked.isEmpty) return const SizedBox.shrink();

    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final top3 = ranked.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('🏆 Top 3 Rankings'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryContainer.withValues(alpha: 0.04),
                AppColors.primaryContainer.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.25)),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Column(
            children: List.generate(top3.length, (i) {
              final p = top3[i];
              final color = medalColors[i];
              final medalLabel = i == 0 ? '🥇' : i == 1 ? '🥈' : '🥉';
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FacultyStudentDetailScreen(participant: p, event: event),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: i < top3.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Row(
                    children: [
                      Text(medalLabel,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.userName,
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600)),
                            Text('${p.enrollmentNo} · ${p.department}',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${p.score} pts',
                              style: AppTypography.labelBold.copyWith(
                                  color: AppColors.onSurface, fontSize: 13)),
                          Text('Rank #${p.rank}',
                              style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.onSurfaceVariant, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsList(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final participants = _participants;
    if (participants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle('All Participants'),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text('${participants.length}',
                  style: AppTypography.labelBold
                      .copyWith(color: Colors.white, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...participants.map((p) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FacultyStudentDetailScreen(participant: p, event: event),
                ),
              ),
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            event.accentColor.withValues(alpha: 0.7),
                            event.accentColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          p.userName.substring(0, 1).toUpperCase(),
                          style: AppTypography.headlineMd.copyWith(
                              color: Colors.white, fontSize: 16),
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
                        ],
                      ),
                    ),
                    if (p.score != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${p.score} pts',
                              style: AppTypography.dataPoint.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontSize: 14)),
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
                        child: Text('No score',
                            style: AppTypography.labelBold.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10)),
                      ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant, size: 18),
                  ],
                ),
              ),
            )),
      ],
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
        _sectionTitle('Event Rules'),
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

  String _timeStr(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
