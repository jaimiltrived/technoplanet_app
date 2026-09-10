import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../providers/faculty_providers.dart';
class FacultyMailSendScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyMailSendScreen({super.key, required this.user});

  static const List<Map<String, String>> defaultMailTemplates = [
    {
      'id': 't1',
      'title': 'Event Reminder',
      'subject': 'Reminder: Upcoming TechnoPlanet Event',
      'body': 'Dear Participant,\n\nThis is a friendly reminder regarding your upcoming registered event. Please arrive on time with your digital pass.\n\nBest regards,\nEvent Coordinator',
    },
    {
      'id': 't2',
      'title': 'Winner Announcement',
      'subject': 'Congratulations: Event Results & Rankings Declared',
      'body': 'Dear Participant,\n\nThe official results and rankings have been declared. Please visit your scores dashboard to view podium honours.\n\nBest regards,\nFaculty Coordinator',
    },
    {
      'id': 't3',
      'title': 'General Announcement',
      'subject': 'Notice: Important Event Information',
      'body': 'Dear Student,\n\nPlease find the latest guidelines and venue details updated in your student dashboard.\n\nBest regards,\nTechnoPlanet Organizing Committee',
    },
  ];

  @override
  ConsumerState<FacultyMailSendScreen> createState() => _FacultyMailSendScreenState();
}

class _FacultyMailSendScreenState extends ConsumerState<FacultyMailSendScreen> {
  String _selectedEventId = 'all';
  String _selectedRole = 'all';
  String? _selectedTemplateId;
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sent = false;

  final _roleOptions = [
    {'val': 'all', 'label': 'All Participants'},
    {'val': 'student', 'label': 'Students Only'},
    {'val': 'volunteer', 'label': 'Volunteers Only'},
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myEventsAsync = ref.watch(facultyEventsProvider(widget.user.id));
    
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Send Mail',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _sent
          ? _buildSentScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipients section
                  _sectionTitle('Recipients'),
                  const SizedBox(height: 12),
                  // Event filter
                  _label('Event'),
                  const SizedBox(height: 8),
                  myEventsAsync.when(
                    data: (myEvents) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEventId,
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: 'all', child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text('All My Events', style: AppTypography.bodySm),
                                )),
                            ...myEvents.map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(e.title, overflow: TextOverflow.ellipsis, style: AppTypography.bodySm),
                                ))),
                          ],
                          onChanged: (v) => setState(() => _selectedEventId = v ?? 'all'),
                        ),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),
                  // Role filter
                  _label('Send To'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _roleOptions.map((opt) {
                      final sel = _selectedRole == opt['val'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRole = opt['val']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryContainer : AppColors.cardBackground,
                            border: Border.all(
                                color: sel ? AppColors.primaryContainer : AppColors.cardBorder),
                            borderRadius: AppRadius.fullRadius,
                            boxShadow: sel ? [
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Text(opt['label']!,
                              style: AppTypography.labelBold.copyWith(
                                color: sel ? Colors.white : AppColors.onSurfaceVariant,
                                fontSize: 13,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // Template
                  _sectionTitle('Use Template'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: FacultyMailSendScreen.defaultMailTemplates.map((t) {
                        final sel = _selectedTemplateId == t['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTemplateId = t['id'];
                              _subjectCtrl.text = t['subject'] as String;
                              _bodyCtrl.text = t['body'] as String;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            width: 180,
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primaryContainer.withValues(alpha: 0.08)
                                  : AppColors.cardBackground,
                              border: Border.all(
                                  color: sel ? AppColors.primaryContainer : AppColors.cardBorder,
                                  width: sel ? 2 : 1),
                              borderRadius: AppRadius.mdRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['title'] as String,
                                    maxLines: 2,
                                    style: AppTypography.bodySm.copyWith(
                                      color: sel
                                          ? AppColors.primaryContainer
                                          : AppColors.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    )),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasBackground,
                                    borderRadius: AppRadius.fullRadius,
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Text('For: ${t['role']}',
                                      style: AppTypography.labelBold.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 10)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('Compose'),
                  const SizedBox(height: 12),
                  _label('Subject'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: _inputDeco('Email subject'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _label('Message Body'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bodyCtrl,
                    maxLines: 8,
                    decoration: _inputDeco('Write your message here...'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Text('Tip: Use {{variable}} placeholders like {{student_name}}, {{event_name}}',
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        elevation: 4,
                        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                      ),
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      label: Text('Send Mail',
                          style: AppTypography.bodyLg.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: _subjectCtrl.text.isNotEmpty &&
                              _bodyCtrl.text.isNotEmpty
                          ? () {
                              if (!mounted) return;
                              setState(() => _sent = true);
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold));

  Widget _label(String t) => Text(t,
      style: AppTypography.bodySm.copyWith(
          color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold));

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5)),
      );

  Widget _buildSentScreen() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    color: Color(0xFF2E7D32), size: 50),
              ),
              const SizedBox(height: 28),
              Text('Mail Sent Successfully!',
                  style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.onSurface)),
              const SizedBox(height: 12),
              Text(
                'Your email has been dispatched to all matching recipients. It may take a few minutes for everyone to receive it.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant, height: 1.6, fontSize: 14),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                  ),
                  onPressed: () {
                    setState(() {
                      _sent = false;
                      _subjectCtrl.clear();
                      _bodyCtrl.clear();
                      _selectedTemplateId = null;
                    });
                  },
                  child: Text('Compose Another Mail', 
                      style: AppTypography.bodyLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
}
