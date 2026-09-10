import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/payment_service.dart';
import '../services/api_service.dart';

class EventsFilter {
  final String search;
  final String categoryId;
  final String status;
  final String coordinatorId;

  const EventsFilter({
    this.search = '',
    this.categoryId = '',
    this.status = '',
    this.coordinatorId = '',
  });

  EventsFilter copyWith({
    String? search,
    String? categoryId,
    String? status,
    String? coordinatorId,
  }) {
    return EventsFilter(
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      coordinatorId: coordinatorId ?? this.coordinatorId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventsFilter &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          categoryId == other.categoryId &&
          status == other.status &&
          coordinatorId == other.coordinatorId;

  @override
  int get hashCode => search.hashCode ^ categoryId.hashCode ^ status.hashCode ^ coordinatorId.hashCode;
}

final eventsFilterProvider = StateProvider<EventsFilter>((ref) => const EventsFilter());

final eventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final filter = ref.watch(eventsFilterProvider);
  return await EventService.fetchEvents(
    search: filter.search.isEmpty ? null : filter.search,
    categoryId: filter.categoryId.isEmpty ? null : filter.categoryId,
    status: filter.status.isEmpty ? null : filter.status,
    coordinatorId: filter.coordinatorId.isEmpty ? null : filter.coordinatorId,
  );
});

final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return await EventService.fetchEvents();
});

final myEventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  return await EventService.fetchMyEvents();
});

class EventActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
  }

  Future<bool> registerForEvent(
    String eventId, {
    Map<String, dynamic>? formData,
    double amount = 0,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? registrationId;
      bool isPending = false;

      try {
        final regRes = await EventService.registerForEvent(eventId, formData: formData);
        registrationId = regRes['registrationId'] as String?;
        isPending = regRes['isPaymentPending'] == true;
      } on ApiException catch (e) {
        // If already registered (409), check if they have it in my-events
        if (e.statusCode == 409) {
          final myEvents = await EventService.fetchMyEvents();
          final matches = myEvents.where((ev) => ev.id == eventId).toList();
          if (matches.isNotEmpty) {
            // Already registered
            ref.invalidate(eventsProvider);
            ref.invalidate(myEventsProvider);
            state = const AsyncValue.data(null);
            return true;
          }
        }
        rethrow;
      }

      // If payment is pending and we have an amount, process payment via live API
      if ((isPending || amount > 0) && registrationId != null && registrationId.isNotEmpty) {
        final payRes = await PaymentService.processPayment(registrationId, amount);
        if (payRes == null || payRes['success'] != true) {
          throw ApiException(
            (payRes?['message'] as String?) ??
                'Payment verification failed. Please try again.',
          );
        }
      }

      ref.invalidate(eventsProvider);
      ref.invalidate(myEventsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[EventActionNotifier] registerForEvent error: $e\n$st');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final eventActionProvider = AsyncNotifierProvider<EventActionNotifier, void>(() {
  return EventActionNotifier();
});
