import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../services/volunteer_service.dart';

final volunteerDashboardProvider =
    FutureProvider.autoDispose.family<VolunteerDashboardData, String>((ref, volunteerId) async {
  return await VolunteerService.getDashboard(volunteerId);
});

final volunteerEventsProvider =
    FutureProvider.autoDispose.family<List<EventModel>, String>((ref, volunteerId) async {
  return await VolunteerService.getAssignedEvents(volunteerId);
});

final volunteerParticipantsProvider =
    FutureProvider.autoDispose.family<List<ParticipantEntry>, String>((ref, eventId) async {
  return await VolunteerService.getParticipants(eventId);
});

/// State notifier for reactive live attendance tracking across tabs
class AttendanceNotifier extends StateNotifier<int> {
  AttendanceNotifier() : super(0);

  void notifyChanged() {
    state++;
  }
}

final attendanceChangeProvider =
    StateNotifierProvider<AttendanceNotifier, int>((ref) => AttendanceNotifier());
