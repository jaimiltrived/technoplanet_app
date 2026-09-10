// lib/faculty/faculty_home.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import 'faculty_events_list.dart';
import 'faculty_participants_list.dart';

import 'faculty_score_dashboard.dart';
import 'faculty_rank_declaration.dart';
import 'faculty_mail_send.dart';
import 'faculty_add_coordinator.dart';
import 'faculty_payment_history.dart';
import 'faculty_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/faculty_providers.dart';
import '../services/auth_service.dart';
import '../login/login_screen_with_accent.dart';

class FacultyHomeScreen extends StatefulWidget {
  final UserModel user;
  const FacultyHomeScreen({super.key, required this.user});

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  int _navIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _FacultyDashboard(
        user: widget.user,
        onSeeAllEvents: () => setState(() => _navIndex = 1),
      ),
      FacultyEventsListScreen(user: widget.user),
      FacultyScoreDashboardScreen(user: widget.user),
      FacultyProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      selectedItemColor: AppColors.primaryContainer,
      unselectedItemColor: AppColors.outline,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardBackground,
      elevation: 12,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (i) => setState(() => _navIndex = i),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event_rounded),
            label: 'My Events'),
        BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events_rounded),
            label: 'Rankings'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FACULTY DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class _FacultyDashboard extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onSeeAllEvents;
  const _FacultyDashboard({required this.user, this.onSeeAllEvents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(facultyEventsProvider(user.id));
    final revenueAsync = ref.watch(facultyTotalRevenueProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(facultyEventsProvider(user.id));
            ref.invalidate(facultyTotalRevenueProvider(user.id));
            await ref.read(facultyEventsProvider(user.id).future).catchError((_) => <EventModel>[]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context)),
              SliverToBoxAdapter(child: _buildWelcomeBanner()),
              myEventsAsync.when(
                data: (myEvents) {
                  final totalParticipants = myEvents.fold(0, (s, e) => s + e.currentParticipants);
                  final pendingRanks = myEvents.where((e) => e.hasScoring && !e.ranksDeclared && e.status.index >= 1).length;
                  final revenue = revenueAsync.value ?? 0.0;
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsGrid(myEvents.length, totalParticipants, pendingRanks, revenue),
                      _buildQuickActions(context),
                      _buildSectionHeader('My Events', onSeeAllEvents),
                      _buildEventsSummary(context, myEvents),
                      const SizedBox(height: 100),
                    ]),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $err', style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(facultyEventsProvider(user.id));
                            ref.invalidate(facultyTotalRevenueProvider(user.id));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.onSurface, size: 24),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
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
                Text(user.name,
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
                    '${user.role.label} · ${user.department}',
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
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int events, int participants, int pending, double revenue) {
    final stats = [
      {'val': '$events', 'label': 'My Events', 'icon': Icons.event_rounded, 'color': AppColors.primaryContainer},
      {'val': '$participants', 'label': 'Participants', 'icon': Icons.group_rounded, 'color': const Color(0xFF1565C0)},
      {'val': '$pending', 'label': 'Pending Ranks', 'icon': Icons.pending_actions_rounded, 'color': const Color(0xFFFF8F00)},
      {'val': '₹${revenue.toInt()}', 'label': 'Revenue', 'icon': Icons.payments_rounded, 'color': const Color(0xFF2E7D32)},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) {
          final s = stats[i];
          final color = s['color'] as Color;
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(s['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s['val'] as String,
                          style: AppTypography.dataPoint.copyWith(
                              color: AppColors.onSurface, fontSize: 20)),
                      Text(s['label'] as String,
                          style: AppTypography.labelBold.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.leaderboard_rounded,
        'label': 'Declare Ranks',
        'color': const Color(0xFFFF8F00),
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => FacultyRankDeclarationScreen(user: user))),
      },
      {
        'icon': Icons.email_rounded,
        'label': 'Send Mail',
        'color': const Color(0xFF1565C0),
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => FacultyMailSendScreen(user: user))),
      },
      {
        'icon': Icons.person_add_rounded,
        'label': 'Add Volunteer',
        'color': const Color(0xFF5C6BC0),
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => FacultyAddCoordinatorScreen(user: user))),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Payments',
        'color': const Color(0xFF2E7D32),
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => FacultyPaymentHistoryScreen(user: user))),
      },
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
                    onTap: a['onTap'] as VoidCallback,
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

  Widget _buildEventsSummary(BuildContext context, List<EventModel> myEvents) {
    if (myEvents.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: AppRadius.mdRadius,
        ),
        child: Center(
          child: Text(
            'No events assigned yet',
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: myEvents.take(3).map((e) {
          final countText = '${e.currentParticipants} ${e.currentParticipants == 1 ? 'participant' : 'participants'}';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.mdRadius,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyParticipantsListScreen(
                        user: user,
                        initialEvent: e,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: e.category.color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Icon(e.category.icon, color: e.category.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              countText,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: e.status.color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          e.status.label,
                          style: AppTypography.labelBold.copyWith(
                            color: e.status.color,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
