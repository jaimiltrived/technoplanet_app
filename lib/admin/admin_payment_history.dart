// lib/admin/admin_payment_history.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../providers/admin_providers.dart';

class AdminPaymentHistoryScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const AdminPaymentHistoryScreen({super.key, required this.user});

  @override
  ConsumerState<AdminPaymentHistoryScreen> createState() =>
      _AdminPaymentHistoryScreenState();
}

class _AdminPaymentHistoryScreenState extends ConsumerState<AdminPaymentHistoryScreen> {
  PaymentStatus? _filterStatus;
  final String _filterEvent = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PaymentModel> _filterPayments(List<PaymentModel> list) {
    return list.where((p) {
      final matchStatus = _filterStatus == null || p.status == _filterStatus;
      final matchEvent = _filterEvent == 'all' || p.eventId == _filterEvent;
      final matchSearch = _searchQuery.isEmpty ||
          p.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.eventTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.transactionId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchStatus && matchEvent && matchSearch;
    }).toList();
  }

  Color _statusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.success: return const Color(0xFF2E7D32);
      case PaymentStatus.pending: return const Color(0xFFFF8F00);
      case PaymentStatus.failed: return const Color(0xFFBA1A1A);
      case PaymentStatus.refunded: return const Color(0xFF1565C0);
    }
  }

  Color _statusBg(PaymentStatus s) => _statusColor(s).withValues(alpha: 0.1);

  IconData _statusIcon(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.success: return Icons.check_circle_rounded;
      case PaymentStatus.pending: return Icons.hourglass_top_rounded;
      case PaymentStatus.failed: return Icons.cancel_rounded;
      case PaymentStatus.refunded: return Icons.refresh_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: paymentsAsync.when(
          data: (allPayments) {
            final filtered = _filterPayments(allPayments);
            final totalRevenue = allPayments
                .where((p) => p.status == PaymentStatus.success)
                .fold(0.0, (s, p) => s + p.amount);

            return Column(
              children: [
                _buildHeader(allPayments.length),
                _buildSummaryBar(totalRevenue, allPayments),
                _buildSearch(),
                _buildStatusFilter(),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _paymentTile(filtered[i]),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading payments: $e')),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCount) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.payments_rounded, color: AppColors.primaryContainer, size: 24),
              const SizedBox(width: 10),
              Text('All Payments',
                  style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.onSurface, fontSize: 22)),
              const Spacer(),
              Text('$totalCount total',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      );

  Widget _buildSummaryBar(double revenue, List<PaymentModel> payments) {
    final success = payments.where((p) => p.status == PaymentStatus.success).length;
    final pending = payments.where((p) => p.status == PaymentStatus.pending).length;
    final failed = payments.where((p) => p.status == PaymentStatus.failed).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primaryContainer,
      child: Row(
        children: [
          _summaryTile('Revenue', '₹${revenue.toInt()}'),
          _vDiv(),
          _summaryTile('Success', '$success'),
          _vDiv(),
          _summaryTile('Pending', '$pending'),
          _vDiv(),
          _summaryTile('Failed', '$failed'),
        ],
      ),
    );
  }

  Widget _summaryTile(String l, String v) => Expanded(
        child: Column(
          children: [
            Text(l, style: AppTypography.labelBold.copyWith(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 2),
            Text(v, style: AppTypography.dataPoint.copyWith(color: Colors.white, fontSize: 18)),
          ],
        ),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.3));

  Widget _buildSearch() => Container(
        color: AppColors.cardBackground,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search by name, event, transaction ID...',
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.onSurfaceVariant, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: AppColors.canvasBackground,
            border: OutlineInputBorder(
                borderRadius: AppRadius.mdRadius,
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdRadius,
                borderSide: BorderSide.none),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    })
                : null,
          ),
        ),
      );

  Widget _buildStatusFilter() {
    final options = [null, ...PaymentStatus.values];
    final labels = ['All', 'Success', 'Pending', 'Failed', 'Refunded'];
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: List.generate(options.length, (i) {
            final sel = _filterStatus == options[i];
            final color = options[i] != null
                ? _statusColor(options[i]!)
                : AppColors.primaryContainer;
            return GestureDetector(
              onTap: () => setState(() => _filterStatus = options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? color.withValues(alpha: 0.15) : Colors.transparent,
                  border: Border.all(color: sel ? color : AppColors.cardBorder),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(labels[i],
                    style: AppTypography.labelBold.copyWith(
                      color: sel ? color : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_rounded,
                size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text('No payments found',
                style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _paymentTile(PaymentModel p) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = p.timestamp;
    final color = _statusColor(p.status);
    final dateStr = '${dt.day.toString().padLeft(2,'0')} ${months[dt.month - 1]} ${dt.year} · ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _statusBg(p.status),
                  borderRadius: AppRadius.regularRadius,
                ),
                child: Icon(_statusIcon(p.status), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(p.eventTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${p.amount.toInt()}',
                      style: AppTypography.dataPoint.copyWith(
                          color: AppColors.onSurface, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusBg(p.status),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(p.status.label,
                        style: AppTypography.labelBold.copyWith(
                            color: color, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
          if (p.transactionId != null) ...[
            const SizedBox(height: 10),
            Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(dateStr,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 12)),
                ),
                Text('TXN · ${p.transactionId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
