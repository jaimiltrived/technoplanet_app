// lib/events/event_registration_screen.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';

// ─── SEMESTER OPTIONS ─────────────────────────────────────────────────────────

const List<String> _semesterOptions = [
  'Semester 1',
  'Semester 2',
  'Semester 3',
  'Semester 4',
  'Semester 5',
  'Semester 6',
  'Semester 7',
  'Semester 8',
];

// ─── SCREEN ──────────────────────────────────────────────────────────────────

class EventRegistrationScreen extends StatefulWidget {
  final String eventTitle;
  final String eventDate;
  final String eventCategory;
  final Color badgeColor;

  const EventRegistrationScreen({
    super.key,
    this.eventTitle = 'Annual Innovation Summit 2024',
    this.eventDate = 'August 1, 2024',
    this.eventCategory = 'TECH',
    this.badgeColor = const Color(0xFF3B82F6),
  });

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _branchController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  String? _selectedSemester;
  bool _isLoading = false;
  bool _isSubmitted = false;

  // Focus nodes for field animation
  final _nameFocus = FocusNode();
  final _collegeFocus = FocusNode();
  final _branchFocus = FocusNode();
  final _emailFocus = FocusNode();

  // Animation
  late AnimationController _successController;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _successOpacity = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _collegeFocus.dispose();
    _branchFocus.dispose();
    _emailFocus.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSubmitted = true;
    });
    _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: _isSubmitted ? _buildSuccessState() : _buildFormState(),
    );
  }

  // ─── SUCCESS STATE ──────────────────────────────────────────────────────────

  Widget _buildSuccessState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              ScaleTransition(
                scale: _successScale,
                child: FadeTransition(
                  opacity: _successOpacity,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.onPrimary,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _successOpacity,
                child: Column(
                  children: [
                    Text(
                      'You\'re Registered!',
                      style: AppTypography.headlineLgMobile.copyWith(
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your spot for ${widget.eventTitle} has been\nconfirmed. Check your email for details.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Event info chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.primaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.eventDate,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.regularRadius,
                          ),
                        ),
                        child: Text(
                          'Back to Events',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FORM STATE ─────────────────────────────────────────────────────────────

  Widget _buildFormState() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventSummaryCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    focusNode: _nameFocus,
                    nextFocus: _collegeFocus,
                    icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (v.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'College Name',
                    hint: 'e.g. RK University',
                    controller: _collegeController,
                    focusNode: _collegeFocus,
                    nextFocus: _branchFocus,
                    icon: Icons.account_balance_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your college name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Academic Details'),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Branch / Department',
                    hint: 'e.g. Computer Science Engineering',
                    controller: _branchController,
                    focusNode: _branchFocus,
                    nextFocus: _emailFocus,
                    icon: Icons.school_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your branch';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSemesterDropdown(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Contact'),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Email Address',
                    hint: 'yourname@email.com',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                  _buildDisclaimerText(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.cardBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top nav bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _buildBackButton(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.eventCategory,
                      style: AppTypography.labelBold.copyWith(
                        color: widget.badgeColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Accent divider
            Container(height: 1, color: AppColors.cardBorder),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.smRadius,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  // ─── EVENT SUMMARY CARD ─────────────────────────────────────────────────────

  Widget _buildEventSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.regularRadius,
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left accent
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registering for',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.eventTitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.eventDate,
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(
              Icons.event_available_outlined,
              color: AppColors.primaryContainer,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTypography.labelBold.copyWith(
            color: AppColors.onSurface,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ─── FORM FIELD ─────────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autocorrect: false,
          style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLg.copyWith(
              color: AppColors.outline.withValues(alpha: 0.55),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.bodySm.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ─── SEMESTER DROPDOWN ──────────────────────────────────────────────────────

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Semester'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedSemester,
          hint: Text(
            'Select your semester',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.outline.withValues(alpha: 0.55),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.layers_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          dropdownColor: AppColors.cardBackground,
          style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
          borderRadius: AppRadius.regularRadius,
          items: _semesterOptions.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedSemester = v),
          validator: (v) {
            if (v == null) return 'Please select your semester';
            return null;
          },
        ),
      ],
    );
  }

  // ─── SUBMIT BUTTON ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.55),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.regularRadius),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isLoading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.onPrimary,
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.how_to_reg_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Submit Registration',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── DISCLAIMER ─────────────────────────────────────────────────────────────

  Widget _buildDisclaimerText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          'By registering, you agree to receive event updates\nand notifications via the provided email.',
          style: AppTypography.labelBold.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
