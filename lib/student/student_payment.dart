import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class StudentPaymentScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final Map<String, dynamic> formData;

  const StudentPaymentScreen({
    super.key,
    required this.event,
    required this.formData,
  });

  @override
  ConsumerState<StudentPaymentScreen> createState() =>
      _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends ConsumerState<StudentPaymentScreen> {
  bool _paymentDone = false;
  bool _hasLaunchedPortal = false;
  final TextEditingController _txnIdCtrl = TextEditingController();
  String _confirmedTxnId = '';

  @override
  void dispose() {
    _txnIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchPaymentPortal() async {
    final uri = Uri.parse(ApiConfig.paymentGatewayUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        if (mounted) {
          setState(() {
            _hasLaunchedPortal = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open payment link. Please copy and open in your browser.',
              ),
              backgroundColor: Color(0xFFD32F2F),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening payment portal: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  void _copyPaymentLink() {
    Clipboard.setData(
      const ClipboardData(text: ApiConfig.paymentGatewayUrl),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Payment link copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _processPayment() async {
    final total = widget.event.registrationFee;
    final txn = _txnIdCtrl.text.trim();
    final effectiveTxnId = txn.isNotEmpty
        ? txn
        : (total > 0
            ? 'paytm_${DateTime.now().millisecondsSinceEpoch}'
            : 'free_${DateTime.now().millisecondsSinceEpoch}');

    final success =
        await ref.read(eventActionProvider.notifier).registerForEvent(
              widget.event.id,
              formData: widget.formData,
              amount: total,
              transactionId: effectiveTxnId,
            );

    if (mounted && success) {
      setState(() {
        _confirmedTxnId = effectiveTxnId;
        _paymentDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentDone) return _buildSuccessScreen(context);

    final actionState = ref.watch(eventActionProvider);
    final isProcessing = actionState.isLoading;

    // Show snackbar on error
    ref.listen<AsyncValue>(eventActionProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        final rawErr = next.error;
        final String errorMsg = rawErr is ApiException
            ? rawErr.message
            : rawErr.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMsg,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    });

    final total = widget.event.registrationFee;
    final isFree = total <= 0;

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: Text(
          isFree ? 'Confirm Registration' : 'Complete Payment',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  isFree ? 'Registration Fee' : 'Amount to Pay',
                  style: AppTypography.bodySm.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  isFree ? 'FREE' : '₹${total.toInt()}',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.goldAccent,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.event.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Purpose: TECHNOPLANET-2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFree) ...[
                    // Official Payment Gateway Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadius.mdRadius,
                        border: Border.all(
                          color: const Color(0xFF00B9F5).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B9F5).withValues(alpha: 0.08),
                            blurRadius: 12,
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF002E6E),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Color(0xFF00B9F5),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Paytm Payment Gateway',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF00B9F5),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Payee: SCHOOL OF ENGINEERING',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF002E6E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Click the button below to pay securely on the official School of Engineering Paytm link via UPI, Cards, or Net Banking.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pay via Paytm Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _launchPaymentPortal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF002E6E),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: Color(0xFF00B9F5),
                              ),
                              label: Text(
                                'Pay ₹${total.toInt()} via Paytm / UPI',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Copy Link Option
                          OutlinedButton.icon(
                            onPressed: _copyPaymentLink,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                              side: BorderSide(
                                color: AppColors.cardBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text(
                              'Copy Payment Link',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_hasLaunchedPortal) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Payment portal opened. After completing payment, confirm below.',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Step-by-Step Instructions
                    Text(
                      'Payment Instructions',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _instructionStep(
                      step: '1',
                      title: 'Open Paytm Gateway',
                      desc: 'Tap "Pay via Paytm / UPI" to open the official payment link.',
                    ),
                    _instructionStep(
                      step: '2',
                      title: 'Complete Payment',
                      desc: 'Pay ₹${total.toInt()} using UPI (GPay/PhonePe/Paytm), Card, or Net Banking.',
                    ),
                    _instructionStep(
                      step: '3',
                      title: 'Confirm Registration',
                      desc: 'Return to this screen, optionally enter your Transaction ID/UTR, and tap confirm.',
                      isLast: true,
                    ),

                    const SizedBox(height: 20),

                    // Transaction ID / Reference Input
                    Text(
                      'Transaction Reference',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _txnIdCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Paytm Txn ID or Bank UTR (Optional)',
                        hintStyle: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: AppColors.onSurfaceVariant,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste_rounded, size: 18),
                          tooltip: 'Paste',
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null && data!.text!.isNotEmpty) {
                              _txnIdCtrl.text = data.text!.trim();
                            }
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primaryContainer, width: 2),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Free registration info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadius.mdRadius,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.event_available_rounded,
                                  color: Color(0xFF2E7D32), size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Free Registration Event',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No payment is required for this event. Tap "Confirm Registration" below to register and generate your event pass.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Security note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security_rounded,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isFree
                                ? 'Your registration details are securely verified.'
                                : 'Official payment link verified for School of Engineering, RK University.',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isProcessing ? null : _processPayment,
                child: isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isFree
                            ? 'Confirm Free Registration'
                            : "I've Paid — Confirm Registration",
                        style: AppTypography.bodyLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionStep({
    required String step,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainer,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: AppColors.primaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 28,
                color: AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2E7D32),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Registration Confirmed!',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You are registered for\n${widget.event.title}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Column(
                    children: [
                      _txnRow('Transaction / Pass ID', _confirmedTxnId),
                      const Divider(height: 16),
                      _txnRow('Payee', 'School of Engineering'),
                      if (widget.formData['fullName'] != null) ...[
                        const Divider(height: 16),
                        _txnRow(
                          'Participant',
                          widget.formData['fullName'].toString(),
                        ),
                      ],
                      if (widget.formData['teamName'] != null) ...[
                        const Divider(height: 16),
                        _txnRow(
                          'Team Name',
                          widget.formData['teamName'].toString(),
                        ),
                        const Divider(height: 16),
                        _txnRow(
                          'Team Size',
                          '${widget.formData['teamSize'] ?? 2} Members',
                        ),
                      ],
                      const Divider(height: 16),
                      _txnRow(
                        'Amount Paid',
                        widget.event.registrationFee == 0
                            ? 'Free'
                            : '₹${widget.event.registrationFee.toInt()}',
                      ),
                      const Divider(height: 16),
                      _txnRow('Payment Status', 'Success ✓'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _txnRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
}
