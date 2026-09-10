import 'package:flutter_test/flutter_test.dart';
import 'package:technoplanet_app/models/event_model.dart';

void main() {
  group('EventModel participant counting tests', () {
    test('parses count from Prisma _count aggregation (like in /api/faculty/events)', () {
      final json = {
        'id': 'EVT007',
        'title': 'Entrepreneurship Bootcamp',
        'description': 'Startup bootcamp',
        'categoryId': 'CAT006',
        'coordinatorId': 'STA004',
        'maxParticipants': 40,
        '_count': {
          'registrations': 1,
        },
      };

      final event = EventModel.fromJson(json);
      expect(event.currentParticipants, 1);
    });

    test('parses count from registrations list (like in /api/events)', () {
      final json = {
        'id': 'EVT007',
        'title': 'Entrepreneurship Bootcamp',
        'description': 'Startup bootcamp',
        'categoryId': 'CAT006',
        'coordinatorId': 'STA004',
        'maxParticipants': 40,
        'registrations': [
          {'id': 'reg1', 'status': 'REGISTERED'},
          {'id': 'reg2', 'status': 'CANCELLED'},
          {'id': 'reg3', 'status': 'CONFIRMED'},
        ],
      };

      final event = EventModel.fromJson(json);
      // reg2 is CANCELLED, so 2 active
      expect(event.currentParticipants, 2);
    });

    test('parses count from direct count keys as fallback', () {
      final jsonWithCurrent = {
        'id': 'EVT001',
        'title': 'Hackathon',
        'currentParticipants': 15,
      };
      expect(EventModel.fromJson(jsonWithCurrent).currentParticipants, 15);

      final jsonWithParticipantCount = {
        'id': 'EVT002',
        'title': 'Gaming',
        'participantCount': '22',
      };
      expect(EventModel.fromJson(jsonWithParticipantCount).currentParticipants, 22);

      final jsonWithRegistrationsCount = {
        'id': 'EVT003',
        'title': 'Debate',
        'registrationsCount': 8,
      };
      expect(EventModel.fromJson(jsonWithRegistrationsCount).currentParticipants, 8);
    });

    test('defaults to 0 when no registrations or count info exists', () {
      final json = {
        'id': 'EVT099',
        'title': 'Empty Event',
      };
      expect(EventModel.fromJson(json).currentParticipants, 0);
    });
  });
}
