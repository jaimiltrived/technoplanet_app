// lib/services/event_service.dart
import '../models/event_model.dart';
import 'api_config.dart';
import 'api_service.dart';

class EventService {
  /// Fetches events from backend API with optional filters
  static Future<List<EventModel>> fetchEvents({
    String? search,
    String? categoryId,
    String? status,
    String? coordinatorId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (coordinatorId != null && coordinatorId.isNotEmpty) {
      queryParams['coordinatorId'] = coordinatorId;
    }

    final res = await ApiService.get(
      ApiConfig.events,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : (res['data']['events'] ?? []);
      return list.map((item) => EventModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    return [];
  }

  /// Registers user for an event
  static Future<Map<String, dynamic>> registerForEvent(String eventId, {Map<String, dynamic>? formData}) async {
    final payload = <String, dynamic>{
      'eventId': eventId,
    };
    if (formData != null) {
      if (formData['isTeamRegistration'] == true) {
        payload['isTeam'] = true;
        if (formData['teamName'] != null) payload['teamName'] = formData['teamName'];
        if (formData['groupMembers'] != null) payload['teamMembers'] = formData['groupMembers'];
      }
    }

    final res = await ApiService.post(ApiConfig.eventRegister, payload);
    final data = res['data'] as Map<String, dynamic>?;
    final message = (res['message'] as String?) ?? 'Registration initiated';
    final regId = data?['registrationId']?.toString() ??
        data?['id']?.toString() ??
        (data?['payment'] is Map ? data!['payment']['registrationId']?.toString() : null);
    final isPending = data?['status'] == 'PENDING' ||
        message.toLowerCase().contains('pending');

    return {
      'success': res['success'] == true || message.toLowerCase().contains('success') || isPending,
      'message': message,
      'registrationId': regId,
      'isPaymentPending': isPending,
      'data': data,
    };
  }

  /// Fetches registered events for the logged-in student
  static Future<List<EventModel>> fetchMyEvents() async {
    final res = await ApiService.get(ApiConfig.myEvents);
    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'] is List ? res['data'] : (res['data']['events'] ?? []);
      final events = <EventModel>[];
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        if (map['event'] != null) {
          events.add(EventModel.fromJson(map['event'] as Map<String, dynamic>));
        } else {
          events.add(EventModel.fromJson(map));
        }
      }
      return events;
    }
    return [];
  }
}
