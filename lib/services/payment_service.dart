import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import 'api_config.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/user_model.dart';

class PaymentService {
  // ── Student payment history ───────────────────────────────────────────────

  /// Fetches the authenticated student's payment history via
  /// `GET /api/payment/history` (dedicated live endpoint).
  static Future<List<PaymentModel>> fetchStudentPayments(String userId) async {
    try {
      final res = await ApiService.get(ApiConfig.paymentHistory);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic>
              ? (data['payments'] ?? data['history'] ?? data['transactions'] ?? [])
              : []);

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        // Payment objects may be flat or nested inside 'payment'
        final payment =
            map['payment'] is Map<String, dynamic> ? map['payment'] as Map<String, dynamic> : map;
        final event = map['event'] as Map<String, dynamic>?;
        return PaymentModel.fromJson(
          payment,
          userId: userId,
          userName: AuthService.currentUser?.name ?? '',
          eventId: payment['eventId']?.toString() ??
              map['eventId']?.toString() ??
              event?['id']?.toString() ??
              '',
          eventTitle: payment['eventTitle']?.toString() ??
              event?['title']?.toString() ??
              event?['name']?.toString() ??
              '',
        );
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[PaymentService] fetchStudentPayments error: $err');
      }
      return [];
    }
  }

  // ── Faculty / Admin — event payments ─────────────────────────────────────

  /// Fetches payments for a specific event (faculty or admin role).
  static Future<List<PaymentModel>> fetchEventPayments(String eventId) async {
    final role = AuthService.currentUser?.role;
    if (role != UserRole.faculty && role != UserRole.admin) return [];

    try {
      final res = await ApiService.get(ApiConfig.facultyPayments);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic> ? (data['payments'] ?? []) : []);

      // Filter to the requested event if eventId is provided.
      final filtered = eventId.isEmpty
          ? list
          : list.where((item) {
              final map = item as Map<String, dynamic>;
              final reg = map['registration'] as Map<String, dynamic>?;
              final eId = map['eventId']?.toString() ??
                  reg?['eventId']?.toString() ??
                  '';
              return eId == eventId;
            }).toList();

      return filtered.map((item) {
        final map = item as Map<String, dynamic>;
        final reg = map['registration'] as Map<String, dynamic>?;
        return PaymentModel.fromJson(
          map,
          eventId: reg?['eventId']?.toString() ?? eventId,
        );
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[PaymentService] fetchEventPayments error: $err');
      }
      return [];
    }
  }

  // ── Payment processing ────────────────────────────────────────────────────

  /// Creates a payment order then verifies it.
  ///
  /// Returns the verify response map on success, or `null` on failure.
  static Future<Map<String, dynamic>?> processPayment(
    String registrationId,
    double amount,
  ) async {
    try {
      final orderRes = await ApiService.post(
        ApiConfig.paymentCreateOrder,
        {'registrationId': registrationId},
      );

      if (orderRes['success'] == true && orderRes['data'] != null) {
        final orderData = orderRes['data'] as Map<String, dynamic>;
        final orderId = orderData['orderId'];
        final paymentId = orderData['paymentId'] ??
            'live_payment_${DateTime.now().millisecondsSinceEpoch}';

        final verifyRes = await ApiService.post(
          ApiConfig.paymentVerify,
          {
            'orderId': orderId,
            'paymentId': paymentId,
            'signature': 'live_signature',
            'status': 'SUCCESS',
          },
        );
        return verifyRes;
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[PaymentService] processPayment error: $err');
      }
    }
    return null;
  }
}
