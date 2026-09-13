import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/payment_model.dart';
import '../models/score_model.dart';
import '../services/admin_service.dart';
import '../services/event_service.dart';

final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.fetchAdminDashboard();
});

final adminStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.fetchAdminStatistics();
});

final adminFacultyProvider = FutureProvider<List<UserModel>>((ref) async {
  return await AdminService.fetchFaculty();
});

final adminVolunteersProvider = FutureProvider<List<UserModel>>((ref) async {
  return await AdminService.fetchVolunteers();
});

final adminStudentsProvider = FutureProvider<List<UserModel>>((ref) async {
  return await AdminService.fetchStudents();
});

final adminPaymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  return await AdminService.fetchAllPayments();
});

final adminParticipantsProvider = FutureProvider<List<ParticipantEntry>>((ref) async {
  return await AdminService.fetchAllParticipants();
});

final adminEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return await EventService.fetchEvents();
});

final adminCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AdminService.fetchCategories();
});

