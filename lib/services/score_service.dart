import 'package:flutter/foundation.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';
import 'api_config.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ScoreService {
  // ── Student scores ────────────────────────────────────────────────────────

  static Future<List<ScoreModel>> fetchStudentScores(String userId) async {
    try {
      final res = await ApiService.get(ApiConfig.studentScores);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic> ? (data['scores'] ?? []) : []);

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final event = map['event'] as Map<String, dynamic>?;
        final eventTitle =
            event?['title']?.toString() ?? event?['name']?.toString() ?? '';
        return ScoreModel.fromJson(
          map,
          userId: userId,
          eventTitle: eventTitle,
        );
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ScoreService] fetchStudentScores error: $err');
      }
      return [];
    }
  }

  // ── Event leaderboard / rankings ─────────────────────────────────────────

  static Future<List<ParticipantEntry>> fetchEventRankings(
      String eventId) async {
    try {
      final isFacultyOrAdmin =
          AuthService.currentUser?.role == UserRole.faculty ||
              AuthService.currentUser?.role == UserRole.admin;

      // Faculty/admin → /api/faculty/rank/{eventId}
      // Student → /api/student/leaderboard/{eventId}
      final url = isFacultyOrAdmin
          ? ApiConfig.facultyEventRankings(eventId)
          : ApiConfig.studentLeaderboard(eventId);

      final res = await ApiService.get(url);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic>
              ? (data['rankings'] ?? data['scores'] ?? data['leaderboard'] ?? [])
              : []);

      final entries = list.map((item) {
        final map = item as Map<String, dynamic>;
        final student = map['student'] as Map<String, dynamic>?;
        final base = student ?? map;
        final scoreVal = map['score'] ?? map['points'];
        final rankVal = map['rank'];
        return ParticipantEntry.fromJson(
          base,
          score: scoreVal is num
              ? scoreVal.toDouble()
              : (scoreVal is String ? double.tryParse(scoreVal) : null),
          rank: rankVal is int
              ? rankVal
              : (rankVal is String ? int.tryParse(rankVal) : null),
        );
      }).toList();

      entries.sort((a, b) => (a.rank ?? 999).compareTo(b.rank ?? 999));
      return entries;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ScoreService] fetchEventRankings error: $err');
      }
      return [];
    }
  }

  // ── Save / declare rankings ───────────────────────────────────────────────

  /// Posts scores and optionally declares rankings for an event.
  ///
  /// Uses `POST /api/faculty/declare-rank` (fixed from previous string-replace
  /// hack that was generating the wrong URL).
  static Future<bool> saveDirectRankings({
    required String eventId,
    required Map<String, int> ranks,
    bool declareRanks = true,
  }) async {
    try {
      final scoresPayload = ranks.entries
          .map((e) => {
                'studentId': e.key,
                'rank': e.value,
                'score': 0,
              })
          .toList();

      // Previously this used a fragile string-replace on facultyDashboard.
      // Now correctly uses the dedicated ApiConfig constant.
      final res = await ApiService.post(
        ApiConfig.facultyDeclareRank,
        {
          'eventId': eventId,
          'scores': scoresPayload,
          'ranksDeclared': declareRanks,
        },
      );
      return res['success'] == true;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ScoreService] saveDirectRankings error: $err');
      }
      rethrow;
    }
  }

  // ── Event participants (faculty view) ─────────────────────────────────────

  static Future<List<ParticipantEntry>> fetchEventParticipants(
      String eventId) async {
    try {
      final url = ApiConfig.facultyParticipants(eventId);
      final res = await ApiService.get(url);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic>
              ? (data['participants'] ?? data['registrations'] ?? [])
              : []);

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final student = map['student'] as Map<String, dynamic>?;
        final reg = map['registration'] as Map<String, dynamic>?;
        final base = student ?? reg ?? map;
        final s = map['score'] ?? reg?['score'];
        final r = map['rank'] ?? reg?['rank'];
        return ParticipantEntry.fromJson(
          base,
          score: s is num
              ? s.toDouble()
              : (s is String ? double.tryParse(s) : null),
          rank: r is int ? r : (r is String ? int.tryParse(r) : null),
        );
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ScoreService] fetchEventParticipants error: $err');
      }
      return [];
    }
  }
}
