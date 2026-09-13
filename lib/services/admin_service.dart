import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/score_model.dart';
import 'api_service.dart';
import 'api_config.dart';

class AdminService {
  static Future<Map<String, dynamic>> fetchAdminDashboard() async {
    final res = await ApiService.get(ApiConfig.adminDashboard);
    if (res['success'] == true && res['data'] != null) {
      return res['data'] as Map<String, dynamic>;
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchAdminStatistics() async {
    final res = await ApiService.get(ApiConfig.adminStatistics);
    if (res['success'] == true && res['data'] != null) {
      return res['data'] as Map<String, dynamic>;
    }
    return {};
  }

  static Future<List<UserModel>> fetchStudents() async {
    final res = await ApiService.get(ApiConfig.adminStudents);
    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : (res['data']['students'] ?? []);
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return UserModel.fromJson(map, roleStr: 'STUDENT');
      }).toList();
    }
    return [];
  }

  static Future<List<UserModel>> fetchStaff({String? role}) async {
    final res = await ApiService.get(ApiConfig.adminStaff);
    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : (res['data']['staff'] ?? []);
      final users = list.map((item) {
        final map = item as Map<String, dynamic>;
        final roleStr = (map['role'] ?? '').toString().toUpperCase();
        return UserModel.fromJson(map, roleStr: roleStr);
      }).toList();

      if (role != null) {
        return users.where((u) => u.role.name.toLowerCase() == role.toLowerCase()).toList();
      }
      return users;
    }
    return [];
  }

  static Future<List<UserModel>> fetchFaculty() async {
    return await fetchStaff(role: 'faculty');
  }

  static Future<List<UserModel>> fetchVolunteers() async {
    return await fetchStaff(role: 'volunteer');
  }

  static Future<List<PaymentModel>> fetchAllPayments() async {
    final res = await ApiService.get(ApiConfig.adminPayments);
    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : (res['data']['payments'] ?? []);
      return list.map((item) => PaymentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<List<ParticipantEntry>> fetchAllParticipants() async {
    final students = await fetchStudents();
    return students.map((s) {
      return ParticipantEntry(
        userId: s.id,
        userName: s.name,
        enrollmentNo: s.enrollmentNo ?? 'N/A',
        department: s.department ?? 'Engineering',
        email: s.email,
        phone: s.phone,
        collegeName: 'School of Engineering, RK University',
        branch: s.department,
        semester: s.semester ?? 'N/A',
      );
    }).toList();
  }

  static Future<bool> assignFacultyToEvent(String eventId, String facultyId) async {
    final res = await ApiService.put('${ApiConfig.events}/$eventId', {
      'coordinatorId': facultyId,
    });
    return res['success'] == true;
  }

  static Future<bool> createAnnouncement({
    required String title,
    required String message,
    String? eventId,
    String? targetAudience,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'message': message,
    };
    if (eventId != null) body['eventId'] = eventId;
    if (targetAudience != null) body['targetAudience'] = targetAudience;
    final res = await ApiService.post(ApiConfig.adminSendNotification, body);
    return res['success'] == true;
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final res = await ApiService.get(ApiConfig.adminCategories);
    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<bool> createEvent(Map<String, dynamic> body) async {
    final res = await ApiService.post(ApiConfig.adminEvents, body);
    return res['success'] == true;
  }

  static Future<bool> updateEvent(String id, Map<String, dynamic> body) async {
    final res = await ApiService.put('${ApiConfig.adminEvents}/$id', body);
    return res['success'] == true;
  }

  static Future<bool> deleteEvent(String id) async {
    final res = await ApiService.delete('${ApiConfig.adminEvents}/$id');
    return res['success'] == true;
  }
}
