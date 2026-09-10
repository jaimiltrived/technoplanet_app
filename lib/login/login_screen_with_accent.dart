// lib/screens/login/login_screen_with_accent.dart
// This version includes the left purple/navy accent bar visible in the design image
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../student/student_home.dart';
import '../../faculty/faculty_home.dart';
import '../../admin/admin_home.dart';
import '../../volunteer/volunteer_home.dart';
import 'register_screen.dart';

class LoginScreenWithAccent extends StatefulWidget {
  const LoginScreenWithAccent({super.key});

  @override
  State<LoginScreenWithAccent> createState() => _LoginScreenWithAccentState();
}

class _LoginScreenWithAccentState extends State<LoginScreenWithAccent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        final user = await AuthService.login(email, password);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (user == null) {
          debugPrint('[Login] User is null. Invalid credentials for $email');
          _showErrorSnackBar('Invalid credentials. Please check your email/password.');
          return;
        }

        Widget destination;
        switch (user.role) {
          case UserRole.faculty:
            destination = FacultyHomeScreen(user: user);
            break;
          case UserRole.volunteer:
            destination = VolunteerHomeScreen(user: user);
            break;
          case UserRole.admin:
            destination = AdminHomeScreen(user: user);
            break;
          case UserRole.student:
            destination = StudentHomeScreen(user: user);
            break;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        debugPrint('[Login] ApiException caught in LoginScreen: ${e.message} (status: ${e.statusCode})');
        _showErrorSnackBar(e.message);
      } catch (e, stack) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        debugPrint('[Login] Unexpected error in LoginScreen: $e\n$stack');
        _showErrorSnackBar('Something went wrong. Please try again.');
      }
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Row(
        children: [
          // Left accent strip (visible in design)
          Container(
            width: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B3FBF), // Purple-blue accent
                  AppColors.primaryContainer,
                ],
              ),
            ),
          ),
          // Main content area
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),
                        // University branding
                        _buildBranding(),
                        const SizedBox(height: 28),
                        // Title & subtitle
                        _buildTitle(),
                        const SizedBox(height: 32),
                        // Form
                        _buildForm(),
                        const SizedBox(height: 28),
                        // Sign In Button
                        _buildPrimaryButton(),
                        const SizedBox(height: 18),
                        // Quick demo role autofill
                        _buildQuickRoleSelectors(),
                        const SizedBox(height: 18),
                        // OR divider
                        _buildOrDivider(),
                        const SizedBox(height: 20),
                        // RK Email button
                        _buildSecondaryButton(),
                        const SizedBox(height: 28),
                        // Register link
                        _buildFooterLink(),
                        const Spacer(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'RK UNIVERSITY',
          style: AppTypography.labelBold.copyWith(
            color: AppColors.onSurface,
            letterSpacing: 2.0,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TechnoPlanet',
          style: AppTypography.headlineLgMobile.copyWith(
            color: AppColors.onSurface,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Student · Faculty · Admin Portal',
          style: AppTypography.labelBold.copyWith(
            color: AppColors.primaryContainer,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with your institutional @rku.ac.in\ncredentials. Your role is auto-detected.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
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
          // Email Label
          Text(
            'Institutional Email',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Email Input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'yourname@rku.ac.in',
              hintStyle: AppTypography.bodyLg.copyWith(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 48,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.trim().endsWith('@rku.ac.in')) {
                return 'Only RK institutional emails are allowed';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password Label with Forgot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to forgot password
                },
                child: Text(
                  'Forgot?',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Password Input
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignIn(),
            style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTypography.bodyLg.copyWith(
                color: AppColors.outline.withValues(alpha: 0.5),
                letterSpacing: 4,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.lock_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 48,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.regularRadius,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Sign In',
                style: AppTypography.bodyLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildQuickRoleSelectors() {
    final roles = [
      {'label': 'Student', 'email': 'student1@rku.ac.in', 'pass': 'student123', 'color': const Color(0xFF1565C0)},
      {'label': 'Faculty', 'email': 'faculty@rku.ac.in', 'pass': 'student123', 'color': const Color(0xFF00897B)},
      {'label': 'Volunteer', 'email': 'volunteer@rku.ac.in', 'pass': 'student123', 'color': const Color(0xFF004D40)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              'Quick Demo Login:',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: roles.map((r) {
            final col = r['color'] as Color;
            return InkWell(
              onTap: () {
                setState(() {
                  _emailController.text = r['email'] as String;
                  _passwordController.text = r['pass'] as String;
                });
                _handleSignIn();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: col.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r['label'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: col,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: AppTypography.labelBold.copyWith(
              color: AppColors.outline,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
      ],
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO: RK Email SSO
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.regularRadius,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sign in with RK Email',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to the institution? ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () {
             Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            child: Text(
              'Register Account',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.onSurface,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}