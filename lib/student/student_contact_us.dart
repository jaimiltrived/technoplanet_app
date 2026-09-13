// lib/student/student_contact_us.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';

class StudentContactUsScreen extends StatelessWidget {
  const StudentContactUsScreen({super.key});

  Future<void> _copyToClipboard(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryContainer,
      ),
    );
  }

  Future<void> _launchUri(Uri uri, BuildContext context, String fallbackText) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        _copyToClipboard(context, fallbackText, 'Detail');
      }
    } catch (_) {
      if (!context.mounted) return;
      _copyToClipboard(context, fallbackText, 'Detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text(
          'Contact & Support',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            // Main Contact Cards
            _buildSectionTitle('Direct Communication'),
            const SizedBox(height: 10),
            _buildContactItem(
              context,
              icon: Icons.email_rounded,
              iconColor: const Color(0xFF1565C0),
              title: 'Event Enquiries & Registrations',
              subtitle: 'events@rku.ac.in',
              actionLabel: 'Send Email',
              onTap: () => _launchUri(
                Uri.parse('mailto:events@rku.ac.in?subject=Technoplanet%20Query'),
                context,
                'events@rku.ac.in',
              ),
              onLongPress: () => _copyToClipboard(context, 'events@rku.ac.in', 'Email'),
            ),
            const SizedBox(height: 10),
            _buildContactItem(
              context,
              icon: Icons.support_agent_rounded,
              iconColor: const Color(0xFF00897B),
              title: 'Technical & App Support',
              subtitle: 'support@rku.ac.in',
              actionLabel: 'Email Support',
              onTap: () => _launchUri(
                Uri.parse('mailto:support@rku.ac.in?subject=Technoplanet%20Technical%20Support'),
                context,
                'support@rku.ac.in',
              ),
              onLongPress: () => _copyToClipboard(context, 'support@rku.ac.in', 'Email'),
            ),
            const SizedBox(height: 10),
            _buildContactItem(
              context,
              icon: Icons.phone_in_talk_rounded,
              iconColor: const Color(0xFF2E7D32),
              title: 'Student Helpdesk Hotline',
              subtitle: '+91 98765 43210',
              actionLabel: 'Call Now',
              onTap: () => _launchUri(
                Uri.parse('tel:+919876543210'),
                context,
                '+91 98765 43210',
              ),
              onLongPress: () => _copyToClipboard(context, '+91 98765 43210', 'Phone number'),
            ),
            const SizedBox(height: 10),
            _buildContactItem(
              context,
              icon: Icons.phone_android_rounded,
              iconColor: const Color(0xFF6A1B9A),
              title: 'Coordinator Desk Line',
              subtitle: '+91 99887 76655',
              actionLabel: 'Call Now',
              onTap: () => _launchUri(
                Uri.parse('tel:+919988776655'),
                context,
                '+91 99887 76655',
              ),
              onLongPress: () => _copyToClipboard(context, '+91 99887 76655', 'Phone number'),
            ),

            const SizedBox(height: 24),
            // Campus Location Card
            _buildSectionTitle('Campus Location & Help Desk'),
            const SizedBox(height: 10),
            _buildLocationCard(context),

            const SizedBox(height: 24),
            // Operating Hours Card
            _buildSectionTitle('Operating Hours'),
            const SizedBox(height: 10),
            _buildHoursCard(),

            const SizedBox(height: 24),
            // Advisory Note
            _buildAdvisoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF001B3D),
            Color(0xFF002D62),
          ],
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002147).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RK UNIVERSITY',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.goldAccent,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      'Technoplanet Central Helpdesk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Need assistance regarding event registrations, venue schedules, scoring, or technical issues? Contact the student council and faculty coordinator team through the official channels below.',
            style: AppTypography.bodySm.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: AppRadius.mdRadius,
      child: Container(
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.smRadius,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: AppRadius.fullRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.primaryContainer,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: AppColors.primaryContainer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    const address =
        'RK University Main Campus, Bhavnagar Highway, Kasturbadham, Rajkot - 360020, Gujarat';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smRadius,
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: Colors.deepOrange, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CENTRAL COORDINATION OFFICE',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Student Activity Centre (SAC)',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Block A, Ground Floor · Room 102',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.cardBorder),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.map_outlined, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _copyToClipboard(context, address, 'Campus Address'),
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Copy Address', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursCard() {
    final hours = [
      {'day': 'Regular Days (Mon – Sat)', 'time': '09:00 AM – 05:00 PM'},
      {'day': 'Technoplanet Fest Days', 'time': '08:00 AM – 08:30 PM'},
      {'day': 'Sundays & Public Holidays', 'time': 'Closed (Email Support Only)'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        children: hours.map((h) {
          final isLast = hours.indexOf(h) == hours.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    h['day']!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  h['time']!,
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.primaryContainer,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please carry your valid University ID Card when visiting the central helpdesk on campus. For queries regarding specific events, you can also connect directly with the assigned faculty coordinator listed on that event\'s detail page.',
              style: AppTypography.bodySm.copyWith(
                color: Colors.brown.shade800,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
