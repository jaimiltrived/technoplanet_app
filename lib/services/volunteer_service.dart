import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import 'api_service.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'event_service.dart';
import 'score_service.dart';

class VolunteerDashboardData {
  final int assignedEventsCount;
  final int totalParticipants;
  final int checkedInCount;
  final EventModel? nextVolunteeredEvent;

  const VolunteerDashboardData({
    required this.assignedEventsCount,
    required this.totalParticipants,
    required this.checkedInCount,
    this.nextVolunteeredEvent,
  });
}

class VolunteerService {
  static final Map<String, Set<String>> _sessionCheckedIn = {};

  /// Fetch volunteer dashboard metrics
  static Future<VolunteerDashboardData> getDashboard(String volunteerId) async {
    EventModel? nextEvent;
    int count = 0;

    try {
      final res = await ApiService.get(ApiConfig.volunteerDashboard);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        count = (data['assignedEventsCount'] as num?)?.toInt() ?? 0;
        if (data['nextVolunteeredEvent'] != null && data['nextVolunteeredEvent'] is Map) {
          try {
            nextEvent = EventModel.fromJson(
              Map<String, dynamic>.from(data['nextVolunteeredEvent'] as Map),
            );
          } catch (e) {
            debugPrint('[VolunteerService] parse nextVolunteeredEvent error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[VolunteerService] getDashboard API error: $e');
    }

    final events = await getAssignedEvents(volunteerId);
    if (nextEvent == null && events.isNotEmpty) {
      final upcoming = events.where((e) => e.status != EventStatus.completed).toList();
      nextEvent = upcoming.isNotEmpty ? upcoming.first : events.first;
    }

    return VolunteerDashboardData(
      assignedEventsCount: count > 0 ? count : events.length,
      totalParticipants: 0,
      checkedInCount: 0,
      nextVolunteeredEvent: nextEvent,
    );
  }

  /// Get events assigned to this volunteer
  static Future<List<EventModel>> getAssignedEvents(String volunteerId) async {
    // 1. Try dedicated volunteer/coordinator events endpoint
    try {
      final res = await ApiService.get(ApiConfig.volunteerEvents);
      if (res['success'] == true && res['data'] != null) {
        final raw = res['data'];
        final List list = raw is List
            ? raw
            : (raw is Map ? (raw['events'] ?? raw['data'] ?? []) : []);
        final events = <EventModel>[];
        for (final item in list) {
          if (item is Map) {
            try {
              events.add(EventModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              debugPrint('[VolunteerService] parse event item error: $e');
            }
          }
        }
        if (events.isNotEmpty) {
          return events;
        }
      }
    } catch (e) {
      debugPrint('[VolunteerService] getAssignedEvents API error: $e');
    }

    // 2. Fallback: Query all events and filter by volunteer assignment if present
    try {
      final allEvents = await EventService.fetchEvents();
      if (allEvents.isNotEmpty) {
        final user = AuthService.currentUser;
        if (user != null && user.assignedEventIds.isNotEmpty) {
          final assigned = allEvents
              .where((e) => user.assignedEventIds.contains(e.id))
              .toList();
          if (assigned.isNotEmpty) {
            return assigned;
          }
        }

        // Check if any event has this volunteer assigned as coordinator or volunteer
        final userMatches = allEvents.where((e) {
          return e.coordinatorId == volunteerId ||
              (user != null && e.coordinatorName != null && e.coordinatorName == user.name);
        }).toList();

        if (userMatches.isNotEmpty) {
          return userMatches;
        }

        // If no specific assignment IDs, allow volunteer to oversee all active/upcoming events
        return allEvents;
      }
    } catch (e) {
      debugPrint('[VolunteerService] fallback fetchEvents error: $e');
    }

    return [];
  }

  /// Get participants for an event with attendance info
  static Future<List<ParticipantEntry>> getParticipants(String eventId) async {
    try {
      // Live API: GET /api/coordinator/participants?eventId=xxx
      final res = await ApiService.get(
        ApiConfig.volunteerParticipants,
        queryParameters: {'eventId': eventId},
      );
      if (res['success'] == true && res['data'] != null) {
        final raw = res['data'];
        final List list = raw is List
            ? raw
            : (raw is Map ? (raw['participants'] ?? raw['data'] ?? []) : []);
        final participants = <ParticipantEntry>[];
        for (final rawItem in list) {
          if (rawItem is Map) {
            final item = Map<String, dynamic>.from(rawItem);
            final student = item['student'] is Map
                ? Map<String, dynamic>.from(item['student'] as Map)
                : <String, dynamic>{};
            participants.add(ParticipantEntry(
              userId: item['studentId']?.toString() ?? item['id']?.toString() ?? '',
              userName: student['name']?.toString() ?? item['userName']?.toString() ?? 'Student',
              enrollmentNo: student['rollNo']?.toString() ??
                  student['enrollmentNo']?.toString() ??
                  item['enrollmentNo']?.toString() ??
                  'N/A',
              department: student['department']?.toString() ??
                  item['department']?.toString() ??
                  'RK University',
              email: student['email']?.toString() ?? item['email']?.toString() ?? '',
              collegeName: 'RK University',
              branch: student['department']?.toString() ?? item['branch']?.toString(),
            ));
          }
        }
        if (participants.isNotEmpty) {
          return participants;
        }
      }
    } catch (e) {
      debugPrint('[VolunteerService] getParticipants API error: $e');
    }

    // Fallback: Try ScoreService participant loader
    try {
      final fallbackParticipants = await ScoreService.fetchEventParticipants(eventId);
      if (fallbackParticipants.isNotEmpty) {
        return fallbackParticipants;
      }
    } catch (_) {}

    return [];
  }

  /// Check-in attendee via QR pass or code
  static Future<bool> scanCheckIn({
    required String eventId,
    required String qrPayloadOrRoll,
  }) async {
    try {
      final res = await ApiService.post(ApiConfig.facultyAttendanceScan, {
        'eventId': eventId,
        'passPayload': qrPayloadOrRoll,
      });
      if (res['success'] == true) {
        _sessionCheckedIn.putIfAbsent(eventId, () => <String>{});
        _sessionCheckedIn[eventId]!.add(qrPayloadOrRoll);
        return true;
      }
    } catch (e) {
      debugPrint('[VolunteerService] scanCheckIn API error: $e');
    }

    // Local fallback so scanning attendance is never blocked in session
    _sessionCheckedIn.putIfAbsent(eventId, () => <String>{});
    _sessionCheckedIn[eventId]!.add(qrPayloadOrRoll);
    return true;
  }

  /// Toggle manual attendance
  static bool toggleManualAttendance(String eventId, String studentId) {
    _sessionCheckedIn.putIfAbsent(eventId, () => <String>{});
    if (_sessionCheckedIn[eventId]!.contains(studentId)) {
      _sessionCheckedIn[eventId]!.remove(studentId);
      return false;
    } else {
      _sessionCheckedIn[eventId]!.add(studentId);
      return true;
    }
  }

  /// Check if attendee is checked in
  static bool isCheckedIn(String eventId, String studentId) {
    return _sessionCheckedIn[eventId]?.contains(studentId) ?? false;
  }
}
