// lib/student/student_contact_us.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class StudentContactUsScreen extends StatefulWidget {
  const StudentContactUsScreen({super.key});

  @override
  State<StudentContactUsScreen> createState() => _StudentContactUsScreenState();
}

class _StudentContactUsScreenState extends State<StudentContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  int _selectedType = 0;
  bool _submitted = false;

  final _types = ['General Query', 'Payment Issue', 'Event Issue', 'Technical Support'];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Contact Us',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info cards
          _buildContactCards(),
          const SizedBox(height: 24),
          Text('Send a Message',
              style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Our team will get back to you within 24 hours.',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue type selector
                Text('Issue Type',
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _types.asMap().entries.map((e) {
                    final sel = _selectedType == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primaryContainer
                              : AppColors.cardBackground,
                          border: Border.all(
                            color: sel
                                ? AppColors.primaryContainer
                                : AppColors.cardBorder,
                          ),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(e.value,
                            style: AppTypography.labelBold.copyWith(
                              color: sel ? Colors.white : AppColors.onSurfaceVariant,
                              fontSize: 12,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Subject',
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Brief subject of your query',
                    prefixIcon: Icon(Icons.subject_rounded,
                        color: AppColors.onSurfaceVariant, size: 18),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter a subject'
                      : null,
                ),
                const SizedBox(height: 14),
                Text('Message',
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _msgCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe your issue in detail...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.trim().length < 20
                      ? 'Message must be at least 20 characters'
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    label: Text('Submit',
                        style: AppTypography.bodyLg.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (!mounted) return;
                        setState(() => _submitted = true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactCards() {
    final contacts = [
      {
        'icon': Icons.email_rounded,
        'label': 'Email',
        'value': 'events@rku.ac.in',
        'color': const Color(0xFF1565C0),
      },
      {
        'icon': Icons.phone_rounded,
        'label': 'Phone',
        'value': '+91 98765 43210',
        'color': const Color(0xFF2E7D32),
      },
      {
        'icon': Icons.location_on_rounded,
        'label': 'Office',
        'value': 'Block A, Ground Floor',
        'color': const Color(0xFFE65100),
      },
    ];

    return Column(
      children: contacts.map((c) {
        final color = c['color'] as Color;
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(c['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['label'] as String,
                      style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 11)),
                  Text(c['value'] as String,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E7D32), width: 3),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF2E7D32), size: 48),
            ),
            const SizedBox(height: 24),
            Text('Message Sent!',
                style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Thank you for reaching out. Our team will respond within 24 hours.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
