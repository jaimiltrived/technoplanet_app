import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import '../services/api_service.dart';

class StudentPaymentScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final Map<String, dynamic> formData;
  
  const StudentPaymentScreen({
    super.key, 
    required this.event, 
    required this.formData,
  });

  @override
  ConsumerState<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends ConsumerState<StudentPaymentScreen> {
  int _selectedMethod = 0;
  bool _paymentDone = false;

  final List<Map<String, dynamic>> _methods = [
    {'icon': Icons.account_balance_rounded, 'label': 'Net Banking', 'sub': 'All major banks'},
    {'icon': Icons.credit_card_rounded, 'label': 'Credit / Debit Card', 'sub': 'Visa, Mastercard, RuPay'},
    {'icon': Icons.qr_code_rounded, 'label': 'UPI', 'sub': 'GPay, PhonePe, Paytm'},
    {'icon': Icons.wallet_rounded, 'label': 'Wallet', 'sub': 'Paytm, Mobikwik'},
  ];

  void _processPayment() async {
    final total = widget.event.registrationFee + (widget.event.registrationFee > 0 ? 5 : 0);
    final success = await ref.read(eventActionProvider.notifier).registerForEvent(
      widget.event.id,
      formData: widget.formData,
      amount: total,
    );
    if (mounted && success) {
      setState(() {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });

    final total = widget.event.registrationFee + (widget.event.registrationFee > 0 ? 5 : 0);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Payment',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
              ),
            ),
            child: Column(
              children: [
                Text('Amount to Pay',
                    style: AppTypography.bodySm.copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  total == 0 ? 'FREE' : '₹${total.toInt()}',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.goldAccent,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.event.title,
                    style: AppTypography.bodySm.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Payment Method',
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface, fontSize: 15)),
                  const SizedBox(height: 12),
                  ..._methods.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final selected = _selectedMethod == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryContainer.withValues(alpha: 0.05)
                              : AppColors.cardBackground,
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryContainer
                                : AppColors.cardBorder,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryContainer.withValues(alpha: 0.1)
                                    : AppColors.canvasBackground,
                                borderRadius: AppRadius.smRadius,
                              ),
                              child: Icon(
                                m['icon'] as IconData,
                                color: selected
                                    ? AppColors.primaryContainer
                                    : AppColors.onSurfaceVariant,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['label'] as String,
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text(m['sub'] as String,
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurfaceVariant,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryContainer,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
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
                            'Your payment is secured with 256-bit SSL encryption.',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontSize: 12,
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
          // Pay button
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
                onPressed: isProcessing ? null : _processPayment,
                child: isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        total == 0 ? 'Confirm Registration' : 'Pay ₹${total.toInt()}',
                        style: AppTypography.bodyLg.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        child: Center(
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
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF2E7D32), size: 52),
                ),
                const SizedBox(height: 24),
                Text('Payment Successful!',
                    style: AppTypography.headlineLgMobile.copyWith(
                        color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text('You are now registered for\n${widget.event.title}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant, height: 1.6)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Column(
                    children: [
                      _txnRow('Transaction ID', 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                      if (widget.formData['teamName'] != null) ...[
                        const Divider(height: 16),
                        _txnRow('Team Name', widget.formData['teamName'].toString()),
                        const Divider(height: 16),
                        _txnRow('Team Size', '${widget.formData['teamSize'] ?? 2} Members'),
                      ],
                      const Divider(height: 16),
                      _txnRow('Amount Paid',
                          widget.event.registrationFee == 0 ? 'Free' : '₹${(widget.event.registrationFee + 5).toInt()}'),
                      const Divider(height: 16),
                      _txnRow('Status', 'Success ✓'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('Download Receipt'),
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
          Text(label,
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value,
              style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurface, fontWeight: FontWeight.w600)),
        ],
      );
}
