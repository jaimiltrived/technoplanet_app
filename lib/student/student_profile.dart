// lib/student/student_profile.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import 'student_scores.dart';
import 'student_payment_history.dart';
import 'student_contact_us.dart';
import 'student_event_detail.dart';
import '../services/auth_service.dart';
import '../login/login_screen_with_accent.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score_model.dart';
import '../providers/event_providers.dart';
import '../providers/score_providers.dart';

class StudentProfileScreen extends ConsumerWidget {
  final UserModel user;
  const StudentProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(myEventsProvider);
    final scoresAsync = ref.watch(studentScoresProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: myEventsAsync.when(
        data: (myEvents) => scoresAsync.when(
          data: (scores) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildProfileHeader(context)),
              SliverToBoxAdapter(child: _buildStatsRow(myEvents, scores)),
              SliverToBoxAdapter(child: _buildMenuSection(context, myEvents)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('Participated Events',
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface, fontSize: 15)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _EventHistoryTile(event: myEvents[i], scores: scores),
                  childCount: myEvents.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text('Error loading scores')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('Error loading events')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile',
                      style: AppTypography.headlineLgMobile.copyWith(
                          color: Colors.white, fontSize: 22)),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: AppTypography.headlineMd.copyWith(
                                color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 4),
                        _infoChip(user.email),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _infoChip(user.enrollmentNo ?? ''),
                            const SizedBox(width: 6),
                            _infoChip(user.semester ?? ''),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(user.department ?? '',
                        style: AppTypography.bodySm.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    const Icon(Icons.phone_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(user.phone ?? '',
                        style: AppTypography.bodySm.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(text,
            style: AppTypography.labelBold.copyWith(
                color: Colors.white, fontSize: 10)),
      );

  Widget _buildStatsRow(List<EventModel> myEvents, List<ScoreModel> scores) {
    final completed = myEvents.where((e) => e.status == EventStatus.completed).length;
    final upcoming = myEvents.where((e) => e.status == EventStatus.upcoming).length;
    final declaredScores = scores.where((s) => s.isDeclared).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _statTile('${myEvents.length}', 'Total Events'),
          _divider(),
          _statTile('$completed', 'Completed'),
          _divider(),
          _statTile('$upcoming', 'Upcoming'),
          _divider(),
          _statTile('$declaredScores', 'Scores'),
        ],
      ),
    );
  }

  Widget _statTile(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(val,
                style: AppTypography.dataPoint.copyWith(
                    color: AppColors.primaryContainer, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 36, color: AppColors.cardBorder);

  Widget _buildMenuSection(BuildContext context, List<EventModel> myEvents) {
    final items = [
      {
        'icon': Icons.score_rounded,
        'label': 'My Scores',
        'sub': 'Event-wise performance',
        'color': const Color(0xFF6A1B9A),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StudentScoresScreen())),
      },
      {
        'icon': Icons.payment_rounded,
        'label': 'Payment History',
        'sub': 'All transactions',
        'color': const Color(0xFF2E7D32),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const StudentPaymentHistoryScreen())),
      },
      {
        'icon': Icons.support_agent_rounded,
        'label': 'Contact Us',
        'sub': 'Support & queries',
        'color': const Color(0xFFE65100),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StudentContactUsScreen())),
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Event Reminders',
        'sub': 'Manage your alerts',
        'color': const Color(0xFF1565C0),
        'onTap': () => _showRemindersSheet(context, myEvents),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: item['onTap'] as VoidCallback,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: item['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'] as String,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600)),
                        Text(item['sub'] as String,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showRemindersSheet(BuildContext context, List<EventModel> myEvents) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final upcomingEvents = myEvents
            .where((e) =>
                e.status == EventStatus.upcoming)
            .toList();
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Reminders',
                  style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Text('Set reminders for your registered events',
                  style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
              ...upcomingEvents.map((e) => _ReminderTile(event: e)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout',
            style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
        content: Text('Are you sure you want to logout?',
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreenWithAccent()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _EventHistoryTile extends StatelessWidget {
  final EventModel event;
  final List<ScoreModel> scores;
  const _EventHistoryTile({required this.event, required this.scores});

  @override
  Widget build(BuildContext context) {
    final score = scores.where((s) => s.eventId == event.id && s.isDeclared).firstOrNull;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StudentEventDetailScreen(event: event))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                color: event.category.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.smRadius,
              ),
              child: Icon(event.category.icon, color: event.category.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(event.category.label,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            if (score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rank #${score.rank}',
                      style: AppTypography.labelBold.copyWith(
                          color: AppColors.primaryContainer)),
                  Text('${score.score} pts',
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event.status.color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(event.status.label,
                    style: AppTypography.labelBold.copyWith(
                        color: event.status.color, fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatefulWidget {
  final EventModel event;
  const _ReminderTile({required this.event});

  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvasBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        children: [
          Icon(widget.event.category.icon,
              color: widget.event.category.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurface)),
          ),
          Switch(
            value: _enabled,
            activeThumbColor: AppColors.primaryContainer,
            onChanged: (v) {
              setState(() => _enabled = v);
              if (v) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder set for ${widget.event.title}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
