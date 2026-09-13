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

    test('sums teamSize for team registrations', () {
      final json = {
        'id': 'EVT009',
        'title': 'Valorant Tournament',
        'registrations': [
          {'id': 'reg1', 'status': 'REGISTERED', 'isTeam': true, 'teamSize': 5},
          {'id': 'reg2', 'status': 'CANCELLED', 'isTeam': true, 'teamSize': 5},
          {'id': 'reg3', 'status': 'REGISTERED', 'isTeam': false, 'teamSize': 1},
        ],
      };
      // reg1 (5) + reg3 (1) = 6 participants (reg2 is CANCELLED)
      expect(EventModel.fromJson(json).currentParticipants, 6);
    });

    test('defaults to 0 when no registrations or count info exists', () {
      final json = {
        'id': 'EVT099',
        'title': 'Empty Event',
      };
      expect(EventModel.fromJson(json).currentParticipants, 0);
    });

    test('correctly parses banner image URL from EVENT BANNER IMAGE description header', () {
      final json = {
        'id': 'EVT100',
        'title': 'TECHRACE',
        'description': 'EVENT BANNER IMAGE: https://files.catbox.moe/s6fkd5.jpeg\n\nBRIEF DESCRIPTION OF EVENT:\nTECHRACE 2026 is an exciting technology-based challenge...',
      };
      final event = EventModel.fromJson(json);
      expect(event.hasBannerImage, isTrue);
      expect(event.imageUrl, contains('https://wsrv.nl/?url='));
      expect(event.imageUrl, contains('files.catbox.moe%2Fs6fkd5.jpeg'));
      expect(event.description.contains('EVENT BANNER IMAGE'), isFalse);
      expect(event.description.startsWith('BRIEF DESCRIPTION OF EVENT:'), isTrue);
    });

    test('ignores data: base64 in banner description header as safety fallback', () {
      final json = {
        'id': 'EVT101',
        'title': 'Base64 Event',
        'description': 'EVENT BANNER IMAGE: data:image/jpeg;base64,xxx\n\nBrief description here',
      };
      final event = EventModel.fromJson(json);
      expect(event.hasBannerImage, isFalse);
      expect(event.imageUrl, isNull);
    });
  });
}
