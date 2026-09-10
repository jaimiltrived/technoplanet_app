// lib/student/student_event_registration.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import 'student_payment.dart';

class GroupMemberEntry {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController enrollCtrl = TextEditingController();
  final TextEditingController deptCtrl = TextEditingController();
  final TextEditingController semCtrl = TextEditingController(text: '6th Semester');
  final TextEditingController phoneCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    enrollCtrl.dispose();
    deptCtrl.dispose();
    semCtrl.dispose();
    phoneCtrl.dispose();
  }

  Map<String, String> toMap() {
    return {
      'name': nameCtrl.text.trim(),
      'enrollmentNo': enrollCtrl.text.trim(),
      'department': deptCtrl.text.trim(),
      'semester': semCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
    };
  }
}

class StudentEventRegistrationScreen extends StatefulWidget {
  final EventModel event;
  const StudentEventRegistrationScreen({super.key, required this.event});

  @override
  State<StudentEventRegistrationScreen> createState() =>
      _StudentEventRegistrationScreenState();
}

class _StudentEventRegistrationScreenState
    extends State<StudentEventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Primary Registrant / Team Leader
  final _leaderNameCtrl = TextEditingController(text: 'Jaimil Trivedi');
  final _leaderEnrollCtrl = TextEditingController(text: '22CS001');
  final _collegeCtrl = TextEditingController(text: 'School of Engineering, RK University');
  final _deptCtrl = TextEditingController(text: 'Computer Science');
  final _branchCtrl = TextEditingController(text: 'Computer Engineering');
  final _semCtrl = TextEditingController(text: '6th Semester');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');

  // Team Details
  final _teamNameCtrl = TextEditingController();
  late bool _isTeamMode;
  final List<GroupMemberEntry> _groupMembers = [];
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    _isTeamMode = widget.event.isTeamEvent;
    if (_isTeamMode) {
      _teamNameCtrl.text = 'Team ${widget.event.title.split(' ').first}';
      // Add at least 1 group member by default for team events
      _addGroupMember();
    }
  }

  void _addGroupMember() {
    final maxMembers = widget.event.maxTeamSize - 1; // excluding leader
    if (_groupMembers.length < maxMembers) {
      setState(() {
        final member = GroupMemberEntry();
        // Friendly prefill hint for quick testing
        if (_groupMembers.isEmpty) {
          member.nameCtrl.text = 'Riya Patel';
          member.enrollCtrl.text = '22CS014';
          member.deptCtrl.text = 'Computer Science';
          member.phoneCtrl.text = '+91 98765 12345';
        }
        _groupMembers.add(member);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum team size is ${widget.event.maxTeamSize} members.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeGroupMember(int index) {
    if (_groupMembers.length > 1 || !widget.event.isTeamEvent) {
      setState(() {
        _groupMembers[index].dispose();
        _groupMembers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum ${widget.event.minTeamSize} members required for this team event.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _leaderNameCtrl.dispose();
    _leaderEnrollCtrl.dispose();
    _collegeCtrl.dispose();
    _deptCtrl.dispose();
    _branchCtrl.dispose();
    _semCtrl.dispose();
    _phoneCtrl.dispose();
    _teamNameCtrl.dispose();
    for (final m in _groupMembers) {
      m.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTeamSize = 1 + _groupMembers.length;

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: Text(
          _isTeamMode ? 'Team Event Registration' : 'Event Registration',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildEventSummary(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode Selector if event allows both solo and team
                    _buildModeToggle(),
                    const SizedBox(height: 16),

                    if (_isTeamMode) ...[
                      _buildTeamHeaderCard(totalTeamSize),
                      const SizedBox(height: 16),
                      _sectionTitle('Team / Group Details', icon: Icons.group_work_rounded),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Team / Group Name *',
                        _teamNameCtrl,
                        Icons.groups_rounded,
                        hintText: 'e.g. CyberKnights, CodeNinjas',
                      ),
                      const SizedBox(height: 20),
                    ],

                    _sectionTitle(
                      _isTeamMode ? 'Team Leader / Primary Contact (You)' : 'Personal & Academic Details',
                      icon: _isTeamMode ? Icons.workspace_premium_rounded : Icons.person_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Full Name *', _leaderNameCtrl, Icons.person_outline_rounded),
                    const SizedBox(height: 14),
                    _buildTextField('Enrollment Number *', _leaderEnrollCtrl, Icons.badge_outlined),
                    const SizedBox(height: 14),
                    _buildTextField('College Name', _collegeCtrl, Icons.account_balance_outlined),
                    const SizedBox(height: 14),
                    _buildTextField('Department', _deptCtrl, Icons.school_outlined),
                    const SizedBox(height: 14),
                    _buildTextField('Branch', _branchCtrl, Icons.alt_route_rounded),
                    const SizedBox(height: 14),
                    _buildTextField('Semester', _semCtrl, Icons.class_outlined),
                    const SizedBox(height: 14),
                    _buildTextField('Phone Number *', _phoneCtrl, Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),

                    // Team Members Section (when team mode is active)
                    if (_isTeamMode) ...[
                      _buildGroupMembersSection(),
                      const SizedBox(height: 24),
                    ],

                    _sectionTitle('Payment Summary', icon: Icons.receipt_long_rounded),
                    const SizedBox(height: 12),
                    _buildPaymentSummary(),
                    const SizedBox(height: 20),
                    _buildTermsCheckbox(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.event.accentColor, widget.event.accentColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(
              widget.event.isTeamEvent ? Icons.groups_rounded : widget.event.category.icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMd.copyWith(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.event.location,
                  style: AppTypography.bodySm.copyWith(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        widget.event.registrationFee == 0
                            ? 'Free Entry'
                            : 'Fee: ₹${widget.event.registrationFee.toInt()}',
                        style: AppTypography.labelBold.copyWith(
                            color: AppColors.primaryContainer, fontSize: 11),
                      ),
                    ),
                    if (widget.event.isTeamEvent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: AppRadius.fullRadius,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '👥 Team Event (${widget.event.minTeamSize}-${widget.event.maxTeamSize} Members)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTeamMode = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isTeamMode ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: !_isTeamMode ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Individual Entry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: !_isTeamMode ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTeamMode = true;
                  if (_groupMembers.isEmpty) {
                    _addGroupMember();
                  }
                  if (_teamNameCtrl.text.isEmpty) {
                    _teamNameCtrl.text = 'Team ${widget.event.title.split(' ').first}';
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isTeamMode ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 16,
                      color: _isTeamMode ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Team / Group Entry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: _isTeamMode ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeaderCard(int totalSize) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group / Team Registration Enabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current Team: $totalSize Members (1 Leader + ${_groupMembers.length} Members)',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF2E7D32)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupMembersSection() {
    final maxMembers = widget.event.maxTeamSize - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Group Members (${_groupMembers.length})', icon: Icons.people_outline_rounded),
            if (_groupMembers.length < maxMembers)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('+ Add Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _addGroupMember,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add credentials for each teammate participating in this event:',
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 14),

        // List of Group Members
        ..._groupMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final memberNumber = index + 2; // 1 is leader

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Member #$memberNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Remove member',
                      onPressed: () => _removeGroupMember(index),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildTextField('Member Full Name *', member.nameCtrl, Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _buildTextField('Enrollment / Roll No *', member.enrollCtrl, Icons.badge_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Department *', member.deptCtrl, Icons.school_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Semester', member.semCtrl, Icons.class_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Phone Number',
                  member.phoneCtrl,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          );
        }),

        // Add Member Button Footer
        if (_groupMembers.length < maxMembers)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              side: const BorderSide(color: AppColors.primaryContainer),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 44),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: Text(
              'Add Team Member (${_groupMembers.length + 1} of ${widget.event.maxTeamSize})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _addGroupMember,
          ),
      ],
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primaryContainer),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? keyboardType,
    String? hintText,
  }) {
    final isRequired = label.contains('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
            ),
          ),
          validator: (v) {
            if (isRequired && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        children: [
          _payRow(
            'Event Registration Fee',
            widget.event.registrationFee == 0 ? 'Free' : '₹${widget.event.registrationFee.toInt()}',
          ),
          if (_isTeamMode) ...[
            const Divider(height: 16),
            _payRow('Registration Type', 'Team (${1 + _groupMembers.length} Members)'),
          ],
          const Divider(height: 16),
          _payRow('Convenience Charge', widget.event.registrationFee == 0 ? '₹0' : '₹5'),
          const Divider(height: 16),
          _payRow(
            'Total Payable',
            widget.event.registrationFee == 0
                ? 'Free'
                : '₹${(widget.event.registrationFee + 5).toInt()}',
            bold: true,
            color: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _payRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: bold ? AppColors.onSurface : AppColors.onSurfaceVariant,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            color: color ?? AppColors.onSurface,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: bold ? 15 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeTerms,
          activeColor: AppColors.primaryContainer,
          onChanged: (v) => setState(() => _agreeTerms = v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'I agree to the event rules, group participation guidelines, and RK University terms & conditions.',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _agreeTerms
            ? () {
                if (widget.event.registrationDeadline != null &&
                    DateTime.now().isAfter(widget.event.registrationDeadline!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration deadline has passed for this event.'),
                      backgroundColor: Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_formKey.currentState!.validate()) {
                  final groupMembersData = _groupMembers.map((m) => m.toMap()).toList();

                  final formData = <String, dynamic>{
                    'fullName': _leaderNameCtrl.text.trim(),
                    'enrollmentNumber': _leaderEnrollCtrl.text.trim(),
                    'collegeName': _collegeCtrl.text.trim(),
                    'department': _deptCtrl.text.trim(),
                    'branch': _branchCtrl.text.trim(),
                    'semester': _semCtrl.text.trim(),
                    'phoneNumber': _phoneCtrl.text.trim(),
                    'isTeamRegistration': _isTeamMode,
                    if (_isTeamMode) ...{
                      'teamName': _teamNameCtrl.text.trim(),
                      'teamSize': 1 + _groupMembers.length,
                      'groupMembers': groupMembersData,
                    },
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentPaymentScreen(
                        event: widget.event,
                        formData: formData,
                      ),
                    ),
                  );
                }
              }
            : null,
        child: Text(
          widget.event.registrationFee == 0
              ? (_isTeamMode ? 'Confirm Team Registration' : 'Confirm Registration')
              : 'Proceed to Payment',
          style: AppTypography.bodyLg.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
