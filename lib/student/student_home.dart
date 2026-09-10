// lib/student/student_home.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import 'student_events_list.dart';
import 'student_rankings.dart';
import 'student_gallery.dart';
import 'student_profile.dart';
import 'student_event_detail.dart';
import 'student_payment_history.dart';
import 'student_scores.dart';
import 'student_contact_us.dart';



class StudentHomeScreen extends StatefulWidget {
  final UserModel user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _StudentHomePage(user: widget.user),
      StudentEventsListScreen(user: widget.user),
      StudentRankingsScreen(user: widget.user),
      StudentGalleryScreen(),
      StudentProfileScreen(user: widget.user),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentNavIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const activeColor = AppColors.primaryContainer;
    const items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event_rounded),
          label: 'Events'),
      BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard_outlined),
          activeIcon: Icon(Icons.leaderboard_rounded),
          label: 'Rankings'),
      BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library_rounded),
          label: 'Gallery'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile'),
    ];

    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      selectedItemColor: activeColor,
      unselectedItemColor: AppColors.outline,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardBackground,
      elevation: 12,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (i) => setState(() => _currentNavIndex = i),
      items: items,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _StudentHomePage extends ConsumerStatefulWidget {
  final UserModel user;
  const _StudentHomePage({required this.user});

  @override
  ConsumerState<_StudentHomePage> createState() => __StudentHomePageState();
}

class __StudentHomePageState extends ConsumerState<_StudentHomePage> {
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(eventsProvider);
    ref.invalidate(myEventsProvider);
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(eventsProvider);
    final myEventsAsyncValue = ref.watch(myEventsProvider);

    final nextEvent = eventsAsyncValue.whenOrNull(
      data: (events) {
        final now = DateTime.now();
        final upcoming = events.where((e) => e.dateTime.isAfter(now)).toList();
        if (upcoming.isEmpty) return null;
        upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return upcoming.first;
      },
    );

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryContainer,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildAppBar()),
              // ── Welcome Banner ────────────────────────────────────────
              SliverToBoxAdapter(child: _buildWelcomeBanner()),
              // ── Countdown ─────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildCountdown(nextEvent)),
              // ── Quick Actions ─────────────────────────────────────────
              SliverToBoxAdapter(child: _buildQuickActions()),
              // ── Featured Events ───────────────────────────────────────
              SliverToBoxAdapter(child: _buildSectionHeader('Featured Events', null)),
              SliverToBoxAdapter(
                child: eventsAsyncValue.when(
                  loading: () => const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => _buildInlineError(
                    'Could not load events',
                    () => ref.invalidate(eventsProvider),
                  ),
                  data: (events) {
                    final featured = events.where((e) => e.isFeatured).toList();
                    final featuredList = featured.isNotEmpty ? featured : events;
                    return _buildFeaturedCarousel(featuredList);
                  },
                ),
              ),
              // ── My Registered Events ─────────────────────────────────
              SliverToBoxAdapter(
                  child: _buildSectionHeader('My Registered Events', () {})),
              SliverToBoxAdapter(
                child: myEventsAsyncValue.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => _buildInlineError(
                    'Could not load your events',
                    () => ref.invalidate(myEventsProvider),
                  ),
                  data: (myEvents) => _buildRegisteredEventsList(myEvents),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildInlineError(String message, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF991B1B), fontSize: 13)),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: AppRadius.smRadius,
              ),
              child: Text('Retry',
                  style: AppTypography.labelBold.copyWith(
                      color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.account_balance_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RK UNIVERSITY',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  )),
              Text('TechnoPlanet',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  )),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.onSurface, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white70,
                    )),
                const SizedBox(height: 4),
                Text(widget.user.name,
                    style: AppTypography.headlineMd.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    )),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    '${widget.user.enrollmentNo ?? ''} · ${widget.user.department ?? ''}',
                    style: AppTypography.labelBold.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(EventModel? nextEvent) {
    if (nextEvent == null) return const SizedBox.shrink();

    final diff = nextEvent.dateTime.difference(DateTime.now());
    final remaining = diff.isNegative ? Duration.zero : diff;

    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    
    final days = remaining.inDays;
    final daysStr = days > 0 ? '$days days away' : 'Today';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.goldAccent,
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(Icons.timer_outlined,
                color: AppColors.primaryContainer, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Event: ${nextEvent.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 2),
                Text('${nextEvent.location} · $daysStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          _CountdownUnit(value: _pad(h), label: 'H'),
          const SizedBox(width: 4),
          Text(':', style: AppTypography.dataPoint.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(width: 4),
          _CountdownUnit(value: _pad(m), label: 'M'),
          const SizedBox(width: 4),
          Text(':', style: AppTypography.dataPoint.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(width: 4),
          _CountdownUnit(value: _pad(s), label: 'S'),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.app_registration_rounded, 'label': 'Register', 'color': const Color(0xFF1565C0)},
      {'icon': Icons.payment_rounded, 'label': 'Payments', 'color': const Color(0xFF2E7D32)},
      {'icon': Icons.score_rounded, 'label': 'My Scores', 'color': const Color(0xFF6A1B9A)},
      {'icon': Icons.support_agent_rounded, 'label': 'Contact', 'color': const Color(0xFFE65100)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 16,
              )),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      final label = a['label'] as String;
                      Widget page;
                      if (label == 'Payments') {
                        page = const StudentPaymentHistoryScreen();
                      } else if (label == 'My Scores') {
                        page = const StudentScoresScreen();
                      } else if (label == 'Contact') {
                        page = const StudentContactUsScreen();
                      } else {
                        page = StudentEventsListScreen(user: widget.user);
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => page),
                      );
                    },
                    child: Column(


                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (a['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: AppRadius.mdRadius,
                            border: Border.all(
                              color: (a['color'] as Color).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(a['icon'] as IconData,
                              color: a['color'] as Color, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(a['label'] as String,
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 16,
              )),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w600,
                  )),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<EventModel> events) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final ev = events[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentEventDetailScreen(event: ev),
              ),
            ),
            child: Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ev.accentColor,
                    ev.accentColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: AppRadius.lgRadius,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(ev.category.label,
                        style: AppTypography.labelBold.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        )),
                  ),
                  const Spacer(),
                  Text(ev.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(ev.location,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent,
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          ev.registrationFee == 0
                              ? 'Free'
                              : '₹${ev.registrationFee.toInt()}',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primaryContainer,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisteredEventsList(List<EventModel> myEvents) {
    if (myEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No registered events yet',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }


    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: myEvents.length,
      itemBuilder: (context, i) {
        final ev = myEvents[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentEventDetailScreen(event: ev),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ev.category.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(ev.category.icon,
                      color: ev.category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ev.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(ev.location,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ev.status.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(ev.status.label,
                      style: AppTypography.labelBold.copyWith(
                        color: ev.status.color,
                        fontSize: 10,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: AppTypography.dataPoint.copyWith(
              color: AppColors.primaryContainer,
              fontSize: 20,
            )),
        Text(label,
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            )),
      ],
    );
  }
}
