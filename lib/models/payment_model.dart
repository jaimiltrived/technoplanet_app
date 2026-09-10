// lib/models/payment_model.dart

enum PaymentStatus { pending, success, failed, refunded }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

class PaymentModel {
  final String id;
  final String userId;
  final String userName;
  final String eventId;
  final String eventTitle;
  final double amount;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime timestamp;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventId,
    required this.eventTitle,
    required this.amount,
    required this.status,
    this.transactionId,
    required this.timestamp,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, {String? userId, String? userName, String? eventId, String? eventTitle}) {
    final statusRaw = (json['status'] ?? 'PENDING').toString().toUpperCase();
    PaymentStatus parsedStatus;
    if (statusRaw.contains('SUCCESS') || statusRaw.contains('COMPLETED') || statusRaw.contains('PAID')) {
      parsedStatus = PaymentStatus.success;
    } else if (statusRaw.contains('FAIL')) {
      parsedStatus = PaymentStatus.failed;
    } else if (statusRaw.contains('REFUND')) {
      parsedStatus = PaymentStatus.refunded;
    } else {
      parsedStatus = PaymentStatus.pending;
    }

    final tsRaw = json['timestamp'] ?? json['createdAt'] ?? json['paymentDate'] ?? DateTime.now().toIso8601String();
    DateTime ts = DateTime.now();
    if (tsRaw != null) {
      ts = DateTime.tryParse(tsRaw.toString()) ?? ts;
    }

    final amountRaw = json['amount'];
    double amt = 0.0;
    if (amountRaw is double) {
      amt = amountRaw;
    } else if (amountRaw is int) {
      amt = amountRaw.toDouble();
    } else if (amountRaw is num) {
      amt = amountRaw.toDouble();
    } else if (amountRaw != null) {
      amt = double.tryParse(amountRaw.toString().replaceAll(',', '')) ?? 0.0;
    }

    return PaymentModel(
      id: json['id']?.toString() ?? json['paymentId']?.toString() ?? '',
      userId: userId ?? json['userId']?.toString() ?? json['studentId']?.toString() ?? '',
      userName: userName ?? json['userName'] ?? json['studentName'] ?? '',
      eventId: eventId ?? json['eventId']?.toString() ?? '',
      eventTitle: eventTitle ?? json['eventTitle'] ?? json['eventName'] ?? '',
      amount: amt,
      status: parsedStatus,
      transactionId: json['transactionId'] ?? json['gatewayTxnId'],
      timestamp: ts,
    );
  }
}
