import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/payment_model.dart';
import '../models/score_model.dart';
import '../services/faculty_service.dart';

final facultyEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, facultyId) async {
  return await FacultyService.fetchFacultyEvents(facultyId);
});

final facultyParticipantsProvider = FutureProvider.family<List<ParticipantEntry>, String>((ref, eventId) async {
  return await FacultyService.fetchEventParticipants(eventId);
});

final facultyPaymentsProvider = FutureProvider.family<List<PaymentModel>, String>((ref, eventId) async {
  return await FacultyService.fetchEventPayments(eventId);
});

final facultyAllPaymentsProvider = FutureProvider.family<List<PaymentModel>, String>((ref, facultyId) async {
  return await FacultyService.fetchAllFacultyPayments(facultyId);
});

final facultyTotalRevenueProvider = FutureProvider.family<double, String>((ref, facultyId) async {
  return await FacultyService.fetchFacultyTotalRevenue(facultyId);
});
