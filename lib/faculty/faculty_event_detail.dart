// lib/faculty/faculty_event_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../services/faculty_service.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import 'faculty_participants_list.dart';
import 'faculty_event_gallery.dart';
import 'faculty_rank_declaration.dart';
import 'faculty_score_dashboard.dart';
import 'faculty_mail_send.dart';
import 'faculty_add_coordinator.dart';
import 'faculty_student_detail.dart';

class FacultyEventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final UserModel user;

  const FacultyEventDetailScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  ConsumerState<FacultyEventDetailScreen> createState() =>
      _FacultyEventDetailScreenState();
}

class _FacultyEventDetailScreenState
    extends ConsumerState<FacultyEventDetailScreen> {
  late EventModel _event;
  List<ParticipantEntry> _participants = [];
  List<Map<String, dynamic>> _volunteers = [];
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchEventDetailsAndVolunteers(),
      _fetchParticipants(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchEventDetailsAndVolunteers() async {
    try {
      final res = await ApiService.get(ApiConfig.facultyEventById(_event.id));
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _event = EventModel.fromJson(data);
            if (data['volunteers'] is List) {
              _volunteers = List<Map<String, dynamic>>.from(
                (data['volunteers'] as List).whereType<Map<String, dynamic>>(),
              );
            }
          });
        }
        return;
      }
    } catch (_) {
      // Fallback to public event by id endpoint
      try {
        final res = await ApiService.get(ApiConfig.eventById(_event.id));
        if (res['success'] == true && res['data'] != null) {
          final data = res['data'] as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _event = EventModel.fromJson(data);
              if (data['volunteers'] is List) {
                _volunteers = List<Map<String, dynamic>>.from(
                  (data['volunteers'] as List).whereType<Map<String, dynamic>>(),
                );
              }
            });
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _fetchParticipants() async {
    try {
      final list = await FacultyService.fetchEventParticipants(_event.id);
      if (mounted) {
        setState(() {
          _participants = list;
        });
      }
    } catch (err) {
      debugPrint('[FacultyEventDetail] Error loading participants: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryContainer,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewStatsGrid(),
                    const SizedBox(height: 16),
                    _buildCapacityAndDeadlineCard(),
                    const SizedBox(height: 20),
                    _buildActionCenter(),
                    const SizedBox(height: 20),
                    _buildCoordinatorAndVolunteersCard(),
                    const SizedBox(height: 20),
                    _buildAboutSection(),
                    const SizedBox(height: 20),
                    _buildParticipantsSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // ─── SLIVER APP BAR ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 2,
      backgroundColor: _event.accentColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Event Gallery',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyEventGalleryScreen(
                  event: _event,
                  user: widget.user,
                  isCoordinator: true,
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: _loadData,
        ),
        const SizedBox(width: 6),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_event.hasBannerImage)
              Image.network(
                _event.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _event.accentColor,
                        _event.accentColor.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _event.accentColor,
                      _event.accentColor.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _event.category.icon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            // High contrast gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.25, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildPill(
                          _event.category.label,
                          bg: Colors.white.withValues(alpha: 0.25),
                          fg: Colors.white,
                          icon: _event.category.icon,
                        ),
                        if (_event.status == EventStatus.ongoing)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: AppRadius.fullRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE NOW',
                                  style: AppTypography.labelBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _buildPill(
                            _event.status.label,
                            bg: _event.status.color.withValues(alpha: 0.85),
                            fg: Colors.white,
                          ),
                        if (_event.ranksDeclared)
                          _buildPill(
                            'Results Declared',
                            bg: const Color(0xFFFFB300),
                            fg: Colors.black87,
                            icon: Icons.emoji_events_rounded,
                          ),
                        _buildPill(
                          _event.isTeamEvent
                              ? 'Team (${_event.minTeamSize}-${_event.maxTeamSize})'
                              : 'Solo Event',
                          bg: Colors.white.withValues(alpha: 0.2),
                          fg: Colors.white,
                          icon: _event.isTeamEvent
                              ? Icons.groups_rounded
                              : Icons.person_rounded,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineLgMobile.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(
    String text, {
    Color? bg,
    Color? fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg ?? Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.labelBold.copyWith(
              color: fg ?? Colors.white,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. CORE METRICS GRID ───────────────────────────────────────────────────
  Widget _buildOverviewStatsGrid() {
    final dt = _event.dateTime;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    final timeStr = _formatTime(dt);

    final items = [
      {
        'label': 'Event Date',
        'value': dateStr,
        'icon': Icons.calendar_month_rounded,
        'color': const Color(0xFF1565C0),
      },
      {
        'label': 'Start Time',
        'value': timeStr,
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF00838F),
      },
      {
        'label': 'Venue',
        'value': _event.location,
        'icon': Icons.place_rounded,
        'color': const Color(0xFFE65100),
      },
      {
        'label': 'Registration Fee',
        'value': _event.registrationFee == 0
            ? 'Free Entry'
            : '₹${_event.registrationFee.toInt()} / Participant',
        'icon': Icons.currency_rupee_rounded,
        'color': const Color(0xFF2E7D32),
      },
      {
        'label': 'Registration Type',
        'value': _event.isTeamEvent
            ? 'Team (${_event.minTeamSize}-${_event.maxTeamSize})'
            : 'Individual',
        'icon': _event.isTeamEvent ? Icons.groups_rounded : Icons.person_rounded,
        'color': const Color(0xFF5C6BC0),
      },
      {
        'label': 'Evaluation & Ranks',
        'value': _event.hasScoring
            ? (_event.ranksDeclared ? 'Rankings Declared' : 'Scoring Pending')
            : 'No Scoring',
        'icon': Icons.military_tech_rounded,
        'color': _event.ranksDeclared
            ? const Color(0xFFF57F17)
            : const Color(0xFF757575),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final color = item['color'] as Color;
            return Container(
              width: itemWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['value'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─── 2. CAPACITY & DEADLINE CARD ───────────────────────────────────────────
  Widget _buildCapacityAndDeadlineCard() {
    final cur = _participants.isNotEmpty
        ? _participants.length
        : _event.currentParticipants;
    final max = _event.maxParticipants > 0 ? _event.maxParticipants : 100;
    final fillPct = (cur / max).clamp(0.0, 1.0);
    final seatsLeft = (max - cur).clamp(0, max);

    final dl = _event.registrationDeadline;
    final isDeadlinePassed = dl != null && DateTime.now().isAfter(dl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.how_to_reg_rounded,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Capacity & Seat Fill',
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: seatsLeft == 0
                      ? Colors.red.withValues(alpha: 0.1)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  seatsLeft == 0 ? 'Full House' : '$seatsLeft Seats Remaining',
                  style: AppTypography.labelBold.copyWith(
                    color: seatsLeft == 0 ? Colors.red : const Color(0xFF2E7D32),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$cur Registered',
                style: AppTypography.dataPoint.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 18,
                ),
              ),
              Text(
                'Max: $max (${(fillPct * 100).toInt()}%)',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppRadius.fullRadius,
            child: LinearProgressIndicator(
              value: fillPct,
              minHeight: 8,
              backgroundColor: AppColors.canvasBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                fillPct >= 0.9 ? Colors.red : _event.accentColor,
              ),
            ),
          ),
          if (dl != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDeadlinePassed
                    ? Colors.red.withValues(alpha: 0.08)
                    : const Color(0xFF1565C0).withValues(alpha: 0.08),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: isDeadlinePassed
                      ? Colors.red.withValues(alpha: 0.25)
                      : const Color(0xFF1565C0).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDeadlinePassed
                        ? Icons.timer_off_outlined
                        : Icons.timer_outlined,
                    size: 16,
                    color: isDeadlinePassed
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDeadlinePassed
                          ? 'Registration closed on ${_formatDate(dl)}'
                          : 'Registration open until ${_formatDate(dl)}',
                      style: AppTypography.bodySm.copyWith(
                        color: isDeadlinePassed
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF1565C0),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 3. FACULTY MANAGEMENT ACTION CENTER ────────────────────────────────────
  Widget _buildActionCenter() {
    final curParticipants = _participants.isNotEmpty
        ? _participants.length
        : _event.currentParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Faculty Event Hub',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 16,
              ),
            ),
            Text(
              'Quick Actions',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.primaryContainer,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Participants',
                subtitle: '$curParticipants Enrolled',
                icon: Icons.groups_rounded,
                color: AppColors.primaryContainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyParticipantsListScreen(
                        user: widget.user,
                        initialEvent: _event,
                      ),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Scoring & Ranks',
                subtitle: _event.hasScoring
                    ? (_event.ranksDeclared ? 'Rankings Declared' : 'Enter Scores')
                    : 'Not Configured',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFFF8F00),
                onTap: () {
                  if (_event.hasScoring) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyScoreDashboardScreen(
                          user: widget.user,
                          initialEvent: _event,
                        ),
                      ),
                    ).then((_) => _loadData());
                  } else {
                    _showScoringNotice();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Event Gallery',
                subtitle: 'Upload & View Photos',
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF00838F),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyEventGalleryScreen(
                        event: _event,
                        user: widget.user,
                        isCoordinator: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Send Mail',
                subtitle: 'Notify Participants',
                icon: Icons.mail_rounded,
                color: const Color(0xFF1565C0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyMailSendScreen(
                        user: widget.user,
                        initialEvent: _event,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: AppRadius.mdRadius,
      child: InkWell(
        borderRadius: AppRadius.mdRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScoringNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Scoring Disabled',
          style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          'Scoring evaluation is currently disabled or not required for this event type.',
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── 4. COORDINATOR & VOLUNTEERS CARD ──────────────────────────────────────
  Widget _buildCoordinatorAndVolunteersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Faculty & Organizing Crew',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    size: 20, color: AppColors.primaryContainer),
                tooltip: 'Add Volunteer',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FacultyAddCoordinatorScreen(user: widget.user),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Assigned Faculty Member
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvasBackground,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.primaryContainer.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event.coordinatorName ?? widget.user.name,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assigned Faculty Coordinator · ${_event.category.label}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    'Coordinator',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.primaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Volunteers Subheading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assigned Volunteers (${_volunteers.length})',
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_volunteers.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.canvasBackground.withValues(alpha: 0.5),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: AppColors.cardBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No student volunteers assigned yet for this event.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _volunteers.map((vol) {
                final name = vol['name']?.toString() ?? 'Volunteer';
                final email = vol['email']?.toString() ?? '';
                final phone = vol['phone']?.toString();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.canvasBackground,
                    borderRadius: AppRadius.smRadius,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF5C6BC0),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (phone != null && phone.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_rounded,
                                  size: 11, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 4),
                              Text(
                                phone,
                                style: AppTypography.labelBold.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ─── 5. ABOUT & DESCRIPTION ────────────────────────────────────────────────
  Widget _buildAboutSection() {
    final text = _event.cleanDescription.trim();
    final isLong = text.length > 300;
    final displayText = (!isLong || _isDescriptionExpanded)
        ? text
        : '${text.substring(0, 300)}...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Event Overview & Rules',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayText.isNotEmpty
                ? displayText
                : 'No additional description provided for this event.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
              fontSize: 13,
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() =>
                  _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isDescriptionExpanded ? 'Show Less' : 'Read Full Details',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      _isDescriptionExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primaryContainer,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── 6. PARTICIPANTS LIST PREVIEW ──────────────────────────────────────────
  Widget _buildParticipantsSection() {
    final curCount = _participants.isNotEmpty
        ? _participants.length
        : _event.currentParticipants;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Registered Students ($curCount)',
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (_participants.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyParticipantsListScreen(
                          user: widget.user,
                          initialEvent: _event,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'View All',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.primaryContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_participants.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 40,
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No participants have registered yet.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ..._participants.take(5).map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.canvasBackground,
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            _event.accentColor.withValues(alpha: 0.15),
                        child: Text(
                          p.userName.isNotEmpty
                              ? p.userName[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color: _event.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        p.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        p.enrollmentNo.isNotEmpty
                            ? '${p.enrollmentNo} · ${p.department}'
                            : (p.department.isNotEmpty ? p.department : 'Student'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      trailing: p.rank != null && p.rank! > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300)
                                    .withValues(alpha: 0.2),
                                borderRadius: AppRadius.fullRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events_rounded,
                                      size: 13, color: Color(0xFFF57F17)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rank #${p.rank}',
                                    style: AppTypography.labelBold.copyWith(
                                      color: const Color(0xFFF57F17),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.outline,
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FacultyStudentDetailScreen(
                              participant: p,
                              event: _event,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                if (_participants.length > 5) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FacultyParticipantsListScreen(
                              user: widget.user,
                              initialEvent: _event,
                            ),
                          ),
                        ).then((_) => _loadData());
                      },
                      icon: const Icon(Icons.list_alt_rounded, size: 16),
                      label: Text('View All ${_participants.length} Participants'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryContainer,
                        side: const BorderSide(color: AppColors.primaryContainer),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdRadius,
                        ),
                        textStyle: AppTypography.labelBold.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // ─── BOTTOM STICKY ACTION BAR ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyParticipantsListScreen(
                        user: widget.user,
                        initialEvent: _event,
                      ),
                    ),
                  ).then((_) => _loadData());
                },
                icon: const Icon(Icons.group_rounded, size: 18),
                label: const Text('Manage Participants'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdRadius,
                  ),
                  textStyle: AppTypography.labelBold.copyWith(fontSize: 13),
                ),
              ),
            ),
            if (_event.hasScoring) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyRankDeclarationScreen(
                          user: widget.user,
                          initialEvent: _event,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  icon: const Icon(Icons.emoji_events_rounded, size: 18),
                  label: const Text('Ranks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                    textStyle: AppTypography.labelBold.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mStr = minute < 10 ? '0$minute' : '$minute';
    return '$h12:$mStr $ampm';
  }
}
