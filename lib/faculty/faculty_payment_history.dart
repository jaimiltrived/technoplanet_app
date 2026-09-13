import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../providers/faculty_providers.dart';

class FacultyPaymentHistoryScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyPaymentHistoryScreen({super.key, required this.user});

  @override
  ConsumerState<FacultyPaymentHistoryScreen> createState() =>
      _FacultyPaymentHistoryScreenState();
}

class _FacultyPaymentHistoryScreenState
    extends ConsumerState<FacultyPaymentHistoryScreen> {
  String _selectedEventId = 'all';

  Color _statusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.success:
        return const Color(0xFF2E7D32);
      case PaymentStatus.pending:
        return const Color(0xFFFF8F00);
      case PaymentStatus.failed:
        return const Color(0xFFBA1A1A);
      case PaymentStatus.refunded:
        return const Color(0xFF1565C0);
    }
  }

  Color _statusBg(PaymentStatus s) => _statusColor(s).withValues(alpha: 0.1);
  IconData _statusIcon(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.success:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
        return Icons.hourglass_top_rounded;
      case PaymentStatus.failed:
        return Icons.cancel_rounded;
      case PaymentStatus.refunded:
        return Icons.refresh_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myEventsAsync = ref.watch(facultyEventsProvider(widget.user.id));
    final paymentsAsync = ref.watch(facultyAllPaymentsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Payment History',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: paymentsAsync.when(
        data: (allPayments) {
          final payments = _selectedEventId == 'all'
              ? allPayments
              : allPayments.where((p) => p.eventId == _selectedEventId).toList();
              
          final totalRevenue = payments
              .where((p) => p.status == PaymentStatus.success)
              .fold(0.0, (s, p) => s + p.amount);

          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryContainer, Color(0xFF003D7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    _summaryTile('Revenue', '₹${totalRevenue.toInt()}', Icons.account_balance_wallet_rounded),
                    _divider(),
                    _summaryTile('Transactions', '${payments.length}', Icons.receipt_long_rounded),
                    _divider(),
                    _summaryTile('Successful',
                        '${payments.where((p) => p.status == PaymentStatus.success).length}', Icons.check_circle_outline_rounded),
                  ],
                ),
              ),
              // Event filter
              myEventsAsync.when(
                data: (events) {
                  return Container(
                    color: AppColors.cardBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.canvasBackground,
                        borderRadius: AppRadius.regularRadius,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEventId,
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                          ),
                          items: [
                            DropdownMenuItem(value: 'all', child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('All Events', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold)),
                            )),
                            ...events.map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(e.title, overflow: TextOverflow.ellipsis, style: AppTypography.bodySm),
                                ))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedEventId = v ?? 'all'),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              Expanded(
                child: payments.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        physics: const BouncingScrollPhysics(),
                        itemCount: payments.length,
                        itemBuilder: (context, i) => _buildPaymentCard(payments[i]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: AppTypography.dataPoint.copyWith(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.labelBold.copyWith(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 46, color: Colors.white.withValues(alpha: 0.2));

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: AppColors.outline.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No payments found',
                style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildPaymentCard(PaymentModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TXN: ${p.transactionId}',
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
              Text('₹${p.amount.toInt()}',
                  style: AppTypography.dataPoint.copyWith(
                      color: AppColors.primaryContainer, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(p.userName.substring(0, 1),
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.primaryContainer, fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.userName,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(p.eventTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBg(p.status),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(p.status),
                        color: _statusColor(p.status), size: 14),
                    const SizedBox(width: 4),
                    Text(p.status.name.toUpperCase(),
                        style: AppTypography.labelBold.copyWith(
                            color: _statusColor(p.status), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmtDateTime(p.timestamp),
                  style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
              Text('Method: Online',
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    var hr = dt.hour % 12;
    if (hr == 0) hr = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year} · $hr:$min $ampm';
  }
}
