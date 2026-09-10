// lib/login/register_screen.dart
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Dropdown values
  String? _selectedDepartment;
  String? _selectedSemester;

  static const List<String> _departments = [
    'Computer Engineering',
    'Information Technology',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electronics & Communication',
    'Chemical Engineering',
    'Biomedical Engineering',
  ];

  static const List<String> _semesters = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollNoController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDepartment == null || _selectedSemester == null) {
      _showErrorSnackBar('Please fill in all dropdown fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rollNo: _rollNoController.text.trim(),
        department: _selectedDepartment!,
        semester: int.parse(_selectedSemester!),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      _showSuccessSnackBar(message);

      // Navigate back to login after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('[Register] ApiException caught in RegisterScreen: ${e.message} (status: ${e.statusCode})');
      _showErrorSnackBar(e.message);
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('[Register] Unexpected error in RegisterScreen: $e\n$stack');
      _showErrorSnackBar('Something went wrong. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white,
                size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildBackButton(),
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 28),
                _buildForm(),
                const SizedBox(height: 28),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.regularRadius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.smRadius,
              ),
              child: const Center(
                child: Icon(
                  Icons.school_outlined,
                  color: AppColors.onPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'RK UNIVERSITY',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.onSurface,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: AppTypography.headlineLgMobile.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register with your institutional details\nto get started with TechnoPlanet.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name ───────────────────────────────────
          _buildFieldLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'Rahul Sharma',
            icon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 18),

          // ── Email ─────────────────────────────────
          _buildFieldLabel('Institutional Email'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'yourname@rku.ac.in',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.endsWith('@rku.ac.in')) {
                return 'Please use your RK institutional email';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // ── Roll No ───────────────────────────────
          _buildFieldLabel('Roll Number'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _rollNoController,
            hint: 'SOE2024099',
            icon: Icons.badge_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your roll number'
                : null,
          ),
          const SizedBox(height: 18),

          // ── Phone ─────────────────────────────────
          _buildFieldLabel('Phone Number'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _phoneController,
            hint: '9876543299',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
              if (v.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // ── Department ────────────────────────────
          _buildFieldLabel('Department'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedDepartment,
            hint: 'Select your department',
            icon: Icons.category_outlined,
            items: _departments,
            onChanged: (v) => setState(() => _selectedDepartment = v),
          ),
          const SizedBox(height: 18),

          // ── Semester ──────────────────────────────
          _buildFieldLabel('Semester'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedSemester,
            hint: 'Select semester',
            icon: Icons.calendar_today_outlined,
            items: _semesters,
            onChanged: (v) => setState(() => _selectedSemester = v),
          ),
          const SizedBox(height: 18),

          // ── Password ──────────────────────────────
          _buildFieldLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _passwordController,
            hint: '••••••••',
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a password';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // ── Confirm Password ──────────────────────
          _buildFieldLabel('Confirm Password'),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hint: '••••••••',
            obscure: _obscureConfirmPassword,
            onToggle: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Reusable field widgets ──────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.bodySm.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: false,
      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyLg.copyWith(
          color: AppColors.outline.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyLg.copyWith(
          color: AppColors.outline.withValues(alpha: 0.6),
          letterSpacing: 3,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            Icons.lock_outlined,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: onToggle,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          size: 20, color: AppColors.onSurfaceVariant),
      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyLg.copyWith(
          color: AppColors.outline.withValues(alpha: 0.6),
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
      dropdownColor: AppColors.cardBackground,
      borderRadius: AppRadius.regularRadius,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select an option' : null,
    );
  }

  // ── Bottom actions ─────────────────────────────────────────────────────────

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.6),
          disabledForegroundColor:
              AppColors.onPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.regularRadius,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : const Text('Create Account'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              'Sign In',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
