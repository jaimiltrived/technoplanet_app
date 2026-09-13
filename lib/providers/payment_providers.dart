// lib/providers/payment_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

final studentPaymentsProvider = FutureProvider.family<List<PaymentModel>, String>((ref, userId) async {
  return await PaymentService.fetchStudentPayments(userId);
});
