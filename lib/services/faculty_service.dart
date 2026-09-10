import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/payment_model.dart';
import '../models/score_model.dart';
import '../services/event_service.dart';
import '../services/payment_service.dart';
import '../services/score_service.dart';
import 'api_service.dart';
import 'api_config.dart';

class FacultyService {
  static Future<List<EventModel>> fetchFacultyEvents(String facultyId) async {
    try {
      final res = await ApiService.get(ApiConfig.facultyEvents);
      if (res['success'] == true && res['data'] != null) {
        final List list = res['data'] is List ? res['data'] : (res['data']['events'] ?? []);
        if (list.isNotEmpty) {
          return list.map((item) {
            if (item is Map) {
              return EventModel.fromJson(Map<String, dynamic>.from(item));
            }
            return EventModel.fromJson(item as Map<String, dynamic>);
          }).toList();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[FacultyService] fetchFacultyEvents error: $err');
      }
    }

    return await EventService.fetchEvents(coordinatorId: facultyId);
  }

  static Future<List<ParticipantEntry>> fetchEventParticipants(String eventId) {
    return ScoreService.fetchEventParticipants(eventId);
  }

  static Future<List<PaymentModel>> fetchEventPayments(String eventId) {
    return PaymentService.fetchEventPayments(eventId);
  }

  static Future<List<PaymentModel>> fetchAllFacultyPayments(String facultyId) async {
    final events = await fetchFacultyEvents(facultyId);
    final List<PaymentModel> all = [];
    for (final e in events) {
      try {
        final payments = await fetchEventPayments(e.id);
        all.addAll(payments);
      } catch (err) {
        if (kDebugMode) {
          debugPrint('[FacultyService] fetchEventPayments(${e.id}) error: $err');
        }
      }
    }
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  static Future<double> fetchFacultyTotalRevenue(String facultyId) async {
    final events = await fetchFacultyEvents(facultyId);
    double total = 0;
    for (final e in events) {
      try {
        final payments = await fetchEventPayments(e.id);
        total += payments
            .where((p) => p.status == PaymentStatus.success)
            .fold(0.0, (s, p) => s + p.amount);
      } catch (err) {
        if (kDebugMode) {
          debugPrint('[FacultyService] fetchFacultyTotalRevenue(${e.id}) error: $err');
        }
      }
    }
    return total;
  }

  static Future<bool> declareRankings(String eventId, List<Map<String, dynamic>> scores) async {
    // Uses ApiConfig.facultyDeclareRank → POST /api/faculty/declare-rank
    final res = await ApiService.post(ApiConfig.facultyDeclareRank, {
      'eventId': eventId,
      'scores': scores,
    });
    return res['success'] == true;
  }

  static Future<bool> saveDirectRankings({
    required String eventId,
    required Map<String, int> ranks,
    bool declareRanks = true,
  }) async {
    return await ScoreService.saveDirectRankings(
      eventId: eventId,
      ranks: ranks,
      declareRanks: declareRanks,
    );
  }
}
