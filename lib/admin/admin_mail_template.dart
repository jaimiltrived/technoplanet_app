// lib/admin/admin_mail_template.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
class AdminMailTemplateScreen extends StatefulWidget {
  final UserModel user;
  const AdminMailTemplateScreen({super.key, required this.user});

  @override
  State<AdminMailTemplateScreen> createState() =>
      _AdminMailTemplateScreenState();
}

class _AdminMailTemplateScreenState extends State<AdminMailTemplateScreen> {
  String? _expandedId;
  final List<Map<String, dynamic>> _templates = [
    {
      'id': 't1',
      'title': 'Event Registration Confirmation',
      'role': 'student',
      'subject': 'Registration Confirmed: {{event_title}}',
      'body': 'Dear {{student_name}},\n\nYour registration for {{event_title}} has been confirmed. Your Entry Pass ID is {{pass_id}}.\n\nDate: {{event_date}}\nVenue: {{event_venue}}\n\nPlease show your QR pass at the entrance.',
    },
    {
      'id': 't2',
      'title': 'Faculty Assignment Notification',
      'role': 'faculty',
      'subject': 'Assigned as Coordinator: {{event_title}}',
      'body': 'Dear {{faculty_name}},\n\nYou have been assigned as the coordinator for {{event_title}}.\n\nPlease log in to the Faculty Portal to manage scoring, view participants, and declare winners.',
    },
    {
      'id': 't3',
      'title': 'Winner Declaration Announcement',
      'role': 'student',
      'subject': 'Results Declared: {{event_title}}',
      'body': 'Dear Participants,\n\nThe results for {{event_title}} have been declared! Check the app leaderboard to view the full ranking and top 3 winners.',
    },
    {
      'id': 't4',
      'title': 'Payment Receipt Confirmation',
      'role': 'student',
      'subject': 'Payment Received: ₹{{amount}} for {{event_title}}',
      'body': 'Dear {{student_name}},\n\nWe have received your payment of ₹{{amount}} (TXN: {{transaction_id}}) for {{event_title}}.\n\nYour pass is now active.',
    },
  ];

  Color _roleColor(String role) {
    switch (role) {
      case 'student': return const Color(0xFF1565C0);
      case 'faculty': return const Color(0xFF00897B);
      default: return AppColors.primaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Mail Templates',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showAddTemplateSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryContainer, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These templates are used for automated emails. Use {{variable}} placeholders for dynamic content.',
                    style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF7A4500), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _templates.length,
              itemBuilder: (context, i) {
                final t = _templates[i];
                final isExpanded = _expandedId == t['id'];
                final roleColor = _roleColor(t['role'] as String);

                return GestureDetector(
                  onTap: () => setState(() =>
                      _expandedId = isExpanded ? null : t['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: isExpanded ? roleColor : AppColors.cardBorder,
                        width: isExpanded ? 2 : 1,
                      ),
                      borderRadius: AppRadius.lgRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.smRadius,
                                ),
                                child: Icon(Icons.email_rounded,
                                    color: roleColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t['title'] as String,
                                        style: AppTypography.bodySm.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.1),
                                        borderRadius: AppRadius.fullRadius,
                                      ),
                                      child: Text('For: ${t['role']}',
                                          style: AppTypography.labelBold.copyWith(
                                              color: roleColor, fontSize: 10)),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18, color: AppColors.onSurfaceVariant),
                                    onPressed: () =>
                                        _showEditSheet(context, t),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expanded content
                        if (isExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subject',
                                    style: AppTypography.labelBold.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasBackground,
                                    borderRadius: AppRadius.smRadius,
                                  ),
                                  child: Text(t['subject'] as String,
                                      style: AppTypography.bodySm.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(height: 12),
                                Text('Body',
                                    style: AppTypography.labelBold.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasBackground,
                                    borderRadius: AppRadius.smRadius,
                                  ),
                                  child: Text(t['body'] as String,
                                      style: AppTypography.bodySm.copyWith(
                                          color: AppColors.onSurface,
                                          height: 1.6,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, Map<String, dynamic> template) {
    final subjectCtrl = TextEditingController(text: template['subject'] as String);
    final bodyCtrl = TextEditingController(text: template['body'] as String);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Template: ${template['title']}',
                style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 16),
            Text('Subject', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(hintText: 'Subject line'),
            ),
            const SizedBox(height: 12),
            Text('Body', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: bodyCtrl,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Mail body'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template updated!')),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTemplateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Template',
                style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Template name')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(hintText: 'Subject')),
            const SizedBox(height: 10),
            const TextField(maxLines: 4, decoration: InputDecoration(hintText: 'Body')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template created!')),
                  );
                },
                child: const Text('Create Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
