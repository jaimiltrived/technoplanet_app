import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../providers/admin_providers.dart';
import 'admin_assign_faculty.dart';
import 'admin_faculty_list.dart';
import 'admin_mail_template.dart';
import 'admin_coordinator_list.dart';
import '../services/auth_service.dart';
import '../login/login_screen_with_accent.dart';

class AdminProfileScreen extends ConsumerWidget {
  final UserModel user;
  const AdminProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader(context)),
          SliverToBoxAdapter(child: _buildStatsRow(ref)),
          SliverToBoxAdapter(child: _buildMenuSection(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 36),
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
                            _infoChip('Super Admin'),
                            const SizedBox(width: 6),
                            _infoChip('System'),
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
                    const Icon(Icons.verified_user_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text('Full System Access',
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

  Widget _buildStatsRow(WidgetRef ref) {
    final statsAsync = ref.watch(adminStatisticsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: statsAsync.when(
        data: (stats) {
          final totalEvents = stats['totalEvents'] ?? stats['events'] ?? 0;
          final totalFaculty = stats['totalFaculty'] ?? stats['faculty'] ?? 0;
          final totalVolunteers = stats['totalVolunteers'] ?? stats['volunteers'] ?? 0;
          return Row(
            children: [
              _statTile('$totalEvents', 'Events'),
              _divider(),
              _statTile('$totalFaculty', 'Faculty'),
              _divider(),
              _statTile('$totalVolunteers', 'Vols'),
            ],
          );
        },
        loading: () => const Center(
          child: SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (err, stack) => Row(
          children: [
            _statTile('-', 'Events'),
            _divider(),
            _statTile('-', 'Faculty'),
            _divider(),
            _statTile('-', 'Vols'),
          ],
        ),
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

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      {
        'icon': Icons.assignment_ind_rounded,
        'label': 'Assign Faculty to Events',
        'sub': 'Manage event coordinators',
        'color': AppColors.primaryContainer,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminAssignFacultyScreen(user: user))),
      },
      {
        'icon': Icons.school_rounded,
        'label': 'Faculty List',
        'sub': 'All faculty & their events',
        'color': AppColors.primary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminFacultyListScreen(user: user))),
      },
      {
        'icon': Icons.email_rounded,
        'label': 'Mail Templates',
        'sub': 'View & manage templates',
        'color': AppColors.secondary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminMailTemplateScreen(user: user))),
      },
      {
        'icon': Icons.manage_accounts_rounded,
        'label': 'Volunteers',
        'sub': 'View all with access levels',
        'color': AppColors.primaryContainer,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminCoordinatorListScreen(user: user))),
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
