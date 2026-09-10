import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/payment_model.dart';
import '../providers/admin_providers.dart';
import '../providers/event_providers.dart';
import 'admin_event_dashboard.dart';
import 'admin_assign_faculty.dart';
import 'admin_payment_history.dart';
import 'admin_faculty_list.dart';
import 'admin_mail_template.dart';
import 'admin_coordinator_list.dart';
import 'admin_profile.dart';
import 'admin_participants.dart';

class AdminHomeScreen extends StatefulWidget {
  final UserModel user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _navIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _AdminDashboard(user: widget.user),
      AdminEventDashboardScreen(user: widget.user),
      AdminParticipantsScreen(user: widget.user),
      AdminPaymentHistoryScreen(user: widget.user),
      AdminProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() => BottomNavigationBar(
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
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event_rounded),
              label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group_rounded),
              label: 'Participants'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments_rounded),
              label: 'Payments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class _AdminDashboard extends ConsumerWidget {
  final UserModel user;
  const _AdminDashboard({required this.user});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEventsAsync = ref.watch(allEventsProvider);
    final facultyAsync = ref.watch(adminFacultyProvider);
    final paymentsAsync = ref.watch(adminPaymentsProvider);

    List<EventModel> events = [];
    bool eventsLoading = allEventsAsync.isLoading || facultyAsync.isLoading || paymentsAsync.isLoading;
    bool eventsError = allEventsAsync.hasError || facultyAsync.hasError || paymentsAsync.hasError;
    
    if (allEventsAsync.valueOrNull != null) {
      events = allEventsAsync.value!;
    }

    final totalEvents = events.length;
    final totalParticipants =
        events.fold<int>(0, (s, e) => s + e.currentParticipants);

    final faculty = facultyAsync.valueOrNull ?? [];
    final payments = paymentsAsync.valueOrNull ?? [];

    final totalFaculty = faculty.length;
    final totalRevenue = payments
        .where((p) => p.status == PaymentStatus.success)
        .fold(0.0, (s, p) => s + p.amount);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allEventsProvider);
            ref.invalidate(adminFacultyProvider);
            ref.invalidate(adminPaymentsProvider);
            await Future.wait([
              ref.read(allEventsProvider.future).catchError((_) => <EventModel>[]),
              ref.read(adminFacultyProvider.future).catchError((_) => <UserModel>[]),
              ref.read(adminPaymentsProvider.future).catchError((_) => <PaymentModel>[]),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context)),
              SliverToBoxAdapter(child: _buildWelcomeBanner()),
              if (eventsError)
                SliverToBoxAdapter(child: _buildErrorBanner(ref)),
              SliverToBoxAdapter(child: _buildStatsGrid(
                totalRevenue, totalParticipants, totalEvents, totalFaculty,
                eventsLoading: eventsLoading,
              )),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              SliverToBoxAdapter(child: _buildSectionHeader('Recent Transactions', null)),
              SliverToBoxAdapter(child: _buildRecentActivity()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Failed to load data. Please check your connection.',
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF991B1B),
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.invalidate(allEventsProvider);
              ref.invalidate(adminFacultyProvider);
              ref.invalidate(adminPaymentsProvider);
            },
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
                    '${user.role.label} · TechnoPlanet Management',
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
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 36),
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

  Widget _buildStatsGrid(double totalRevenue, int totalParticipants, int totalEvents, int totalFaculty, {bool eventsLoading = false}) {
    final stats = [
      {'val': eventsLoading ? '...' : '$totalEvents', 'label': 'Total Events', 'icon': Icons.event_rounded, 'color': AppColors.primaryContainer},
      {'val': eventsLoading ? '...' : '$totalParticipants', 'label': 'Registrations', 'icon': Icons.group_rounded, 'color': const Color(0xFF2E7D32)},
      {'val': '$totalFaculty', 'label': 'Faculty', 'icon': Icons.school_rounded, 'color': AppColors.primaryContainer},
      {'val': '₹${totalRevenue.toInt()}', 'label': 'Revenue', 'icon': Icons.payments_rounded, 'color': const Color(0xFF2E7D32)},
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.assignment_ind_rounded, 'label': 'Assign Faculty', 'color': const Color(0xFF1565C0), 'screen': AdminAssignFacultyScreen(user: user)},
      {'icon': Icons.people_rounded, 'label': 'Faculty List', 'color': const Color(0xFF6A1B9A), 'screen': AdminFacultyListScreen(user: user)},
      {'icon': Icons.email_rounded, 'label': 'Mail Templates', 'color': const Color(0xFFE65100), 'screen': AdminMailTemplateScreen(user: user)},
      {'icon': Icons.manage_accounts_rounded, 'label': 'Volunteers', 'color': const Color(0xFF2E7D32), 'screen': AdminCoordinatorListScreen(user: user)},
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
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => a['screen'] as Widget)),
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

  Widget _buildRecentActivity() {
    return Consumer(
      builder: (context, ref, _) {
        final paymentsAsync = ref.watch(adminPaymentsProvider);

        return paymentsAsync.when(
          data: (payments) {
            final recent = payments.take(4).toList();
            if (recent.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No recent activity yet.', style: TextStyle(color: Colors.grey)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: recent.map((p) {
                  final color = p.status.name == 'success'
                      ? const Color(0xFF2E7D32)
                      : p.status.name == 'pending'
                          ? const Color(0xFFFF8F00)
                          : const Color(0xFFBA1A1A);
                  return Container(
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
                            color: color.withValues(alpha: 0.1),
                            borderRadius: AppRadius.smRadius,
                          ),
                          child: Icon(Icons.receipt_rounded, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(p.eventTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('₹${p.amount.toInt()}',
                            style: AppTypography.dataPoint.copyWith(
                                color: AppColors.onSurface, fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => const SizedBox.shrink(),
        );
      },
    );
  }
}

