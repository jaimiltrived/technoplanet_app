import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/faculty_providers.dart';
import 'faculty_rank_declaration.dart';
import 'faculty_mail_send.dart';
import 'faculty_add_coordinator.dart';
import 'faculty_payment_history.dart';
import '../services/auth_service.dart';
import '../login/login_screen_with_accent.dart';

class FacultyProfileScreen extends ConsumerWidget {
  final UserModel user;
  const FacultyProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(facultyEventsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader(context)),
          SliverToBoxAdapter(
            child: myEventsAsync.when(
              data: (myEvents) => _buildStatsRow(myEvents),
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Center(child: Text('Error loading stats: $e')),
            ),
          ),
          SliverToBoxAdapter(child: _buildMenuSection(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
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
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 24),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: AppTypography.headlineMd.copyWith(
                                color: Colors.white, fontSize: 22)),
                        const SizedBox(height: 6),
                        _infoChip(user.email, Icons.email_rounded),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _infoChip(user.role.label, Icons.badge_rounded),
                            const SizedBox(width: 8),
                            _infoChip(user.department ?? '', Icons.business_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(user.department ?? 'N/A',
                        style: AppTypography.bodySm.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.phone_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(user.phone ?? 'N/A',
                        style: AppTypography.bodySm.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(text,
                style: AppTypography.labelBold.copyWith(
                    color: Colors.white, fontSize: 11)),
          ],
        ),
      );

  Widget _buildStatsRow(List<EventModel> myEvents) {
    final upcoming = myEvents.where((e) => e.status == EventStatus.upcoming).length;
    final ongoing = myEvents.where((e) => e.status == EventStatus.ongoing).length;
    final completed = myEvents.where((e) => e.status == EventStatus.completed).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _statTile('${myEvents.length}', 'Total Events'),
          _divider(),
          _statTile('$upcoming', 'Upcoming'),
          _divider(),
          _statTile('$ongoing', 'Ongoing'),
          _divider(),
          _statTile('$completed', 'Completed'),
        ],
      ),
    );
  }

  Widget _statTile(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(val,
                style: AppTypography.dataPoint.copyWith(
                    color: AppColors.primaryContainer, fontSize: 24)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 40, color: AppColors.cardBorder);

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      {
        'icon': Icons.leaderboard_rounded,
        'label': 'Rank Declaration',
        'sub': 'Declare results for your events',
        'color': AppColors.secondary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacultyRankDeclarationScreen(user: user))),
      },
      {
        'icon': Icons.email_rounded,
        'label': 'Send Mail',
        'sub': 'Email participants by role',
        'color': AppColors.primaryContainer,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacultyMailSendScreen(user: user))),
      },
      {
        'icon': Icons.person_add_rounded,
        'label': 'Volunteers',
        'sub': 'Assign helpers to your events',
        'color': AppColors.primary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacultyAddCoordinatorScreen(user: user))),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Payment History',
        'sub': 'Event-wise payment records',
        'color': const Color(0xFF2E7D32),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacultyPaymentHistoryScreen(user: user))),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: item['onTap'] as VoidCallback,
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: item['color'] as Color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'] as String,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(item['sub'] as String,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.onSurfaceVariant, size: 24),
                ],
              ),
            ),
          );
        }).toList(),
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
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
