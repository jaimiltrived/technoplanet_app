// lib/faculty/faculty_student_detail.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';

class FacultyStudentDetailScreen extends StatelessWidget {
  final ParticipantEntry participant;
  final EventModel? event;

  const FacultyStudentDetailScreen({
    super.key,
    required this.participant,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final college = participant.collegeName ?? 'Not Available';
    final branch = participant.branch ?? 'Not Available';
    final semester = participant.semester ?? 'Not Available';
    final email = participant.email ?? '${participant.enrollmentNo.toLowerCase()}@rku.ac.in';
    final phone = participant.phone ?? 'Not Available';

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        elevation: 0,
        title: const Text(
          'Student Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Student Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        participant.userName.substring(0, 1),
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    participant.userName,
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.enrollmentNo,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      'Registered Student',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academic Details Card
                  _buildSectionHeader('Academic Details'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Column(
                      children: [
                        _buildDetailTile(
                          icon: Icons.account_balance_outlined,
                          label: 'College Name',
                          value: college,
                        ),
                        const Divider(height: 1),
                        _buildDetailTile(
                          icon: Icons.school_outlined,
                          label: 'Department',
                          value: participant.department,
                        ),
                        const Divider(height: 1),
                        _buildDetailTile(
                          icon: Icons.alt_route_rounded,
                          label: 'Branch',
                          value: branch,
                        ),
                        const Divider(height: 1),
                        _buildDetailTile(
                          icon: Icons.class_outlined,
                          label: 'Semester',
                          value: semester,
                        ),
                        const Divider(height: 1),
                        _buildDetailTile(
                          icon: Icons.badge_outlined,
                          label: 'Enrollment No.',
                          value: participant.enrollmentNo,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Details Card
                  _buildSectionHeader('Contact Information'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Column(
                      children: [
                        _buildDetailTile(
                          icon: Icons.email_outlined,
                          label: 'Institutional Email',
                          value: email,
                        ),
                        const Divider(height: 1),
                        _buildDetailTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: phone,
                        ),
                      ],
                    ),
                  ),

                  if (event != null) ...[
                    const SizedBox(height: 20),

                    // Event Participation Card
                    _buildSectionHeader('Event Status'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: event!.accentColor.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.smRadius,
                                ),
                                child: Icon(
                                  event!.category.icon,
                                  color: event!.accentColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event!.title,
                                      style: AppTypography.headlineMd.copyWith(
                                        color: AppColors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      event!.category.label,
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusItem(
                                'Score',
                                participant.score != null
                                    ? '${participant.score} pts'
                                    : 'Not Scored',
                                isPrimary: participant.score != null,
                              ),
                              _buildStatusItem(
                                'Rank',
                                participant.rank != null
                                    ? '#${participant.rank}'
                                    : 'N/A',
                                isPrimary: participant.rank != null,
                              ),
                              _buildStatusItem(
                                'Status',
                                'Registered',
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String val, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelBold.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: AppTypography.headlineMd.copyWith(
            color: isPrimary ? AppColors.primaryContainer : AppColors.onSurface,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
