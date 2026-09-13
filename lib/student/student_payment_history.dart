// lib/student/student_payment_history.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/payment_model.dart';
import '../services/auth_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_providers.dart';

class StudentPaymentHistoryScreen extends ConsumerWidget {
  const StudentPaymentHistoryScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = AuthService.currentUser?.id ?? '';
    final paymentsAsync = ref.watch(studentPaymentsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Payment History',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: paymentsAsync.when(
        data: (payments) {
          final total = payments
              .where((p) => p.status == PaymentStatus.success)
              .fold(0.0, (sum, p) => sum + p.amount);

          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.primaryContainer,
                child: Row(
                  children: [
                    _summaryTile('Total Spent', '₹${total.toInt()}'),
                    _divider(),
                    _summaryTile('Transactions', '${payments.length}'),
                    _divider(),
                    _summaryTile('Success',
                        '${payments.where((p) => p.status == PaymentStatus.success).length}'),
                  ],
                ),
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
        error: (err, _) => const Center(child: Text('Error loading payments')),
      ),
    );
  }

  Widget _summaryTile(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: AppTypography.dataPoint.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.labelBold.copyWith(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3));

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: AppColors.outline.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No payments yet',
                style: AppTypography.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildPaymentCard(PaymentModel p) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = p.timestamp;
    final dateStr = '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _statusBg(p.status),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(_statusIcon(p.status),
                    color: _statusColor(p.status), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.eventTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                    Text(dateStr,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(p.amount == 0 ? 'Free' : '₹${p.amount.toInt()}',
                      style: AppTypography.dataPoint.copyWith(
                          color: AppColors.onSurface, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusBg(p.status),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(p.status.label,
                        style: AppTypography.labelBold.copyWith(
                            color: _statusColor(p.status), fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
          if (p.transactionId != null) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.tag_rounded, size: 13, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Txn ID: ${p.transactionId}',
                    style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
