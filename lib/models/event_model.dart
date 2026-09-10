// lib/models/event_model.dart
import 'package:flutter/material.dart';

double _toDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.trim().replaceAll(',', '')) ?? fallback;
  }
  return fallback;
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) {
    final s = value.trim().replaceAll(',', '');
    return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? fallback;
  }
  return fallback;
}

enum EventCategory {
  all('All Events'),
  sports('Sports'),
  tech('Tech'),
  cultural('Cultural'),
  academic('Academic'),
  arts('Arts');

  final String label;
  const EventCategory(this.label);
}

extension EventCategoryX on EventCategory {
  IconData get icon {
    switch (this) {
      case EventCategory.all:
        return Icons.apps_rounded;
      case EventCategory.sports:
        return Icons.sports_basketball_rounded;
      case EventCategory.tech:
        return Icons.computer_rounded;
      case EventCategory.cultural:
        return Icons.music_note_rounded;
      case EventCategory.academic:
        return Icons.school_rounded;
      case EventCategory.arts:
        return Icons.palette_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.all:
        return const Color(0xFF002147);
      case EventCategory.sports:
        return const Color(0xFF2E7D32);
      case EventCategory.tech:
        return const Color(0xFF1565C0);
      case EventCategory.cultural:
        return const Color(0xFF6A1B9A);
      case EventCategory.academic:
        return const Color(0xFF00838F);
      case EventCategory.arts:
        return const Color(0xFFE65100);
    }
  }
}

enum EventStatus {
  upcoming,
  ongoing,
  completed;

  String get label {
    switch (this) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case EventStatus.upcoming:
        return const Color(0xFF1565C0);
      case EventStatus.ongoing:
        return const Color(0xFF2E7D32);
      case EventStatus.completed:
        return const Color(0xFF757575);
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;
  final EventStatus status;
  final bool isFeatured;
  final Color accentColor;
  final String? coordinatorId;
  final String? coordinatorName;
  final int maxParticipants;
  final double registrationFee;
  final DateTime? registrationDeadline;
  final bool hasScoring;
  final bool ranksDeclared;
  final int currentParticipants;
  final bool isTeamEvent;
  final int minTeamSize;
  final int maxTeamSize;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    this.status = EventStatus.upcoming,
    this.isFeatured = false,
    this.accentColor = const Color(0xFF002147),
    this.coordinatorId,
    this.coordinatorName,
    this.maxParticipants = 100,
    this.registrationFee = 0,
    this.registrationDeadline,
    this.hasScoring = false,
    this.ranksDeclared = false,
    this.currentParticipants = 0,
    this.isTeamEvent = false,
    this.minTeamSize = 2,
    this.maxTeamSize = 4,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final catRaw = json['category'] is Map
        ? (json['category']['name'] ?? '').toString().toLowerCase()
        : (json['category'] ?? '').toString().toLowerCase();
    EventCategory category;
    if (catRaw.contains('non-technical') || catRaw.contains('non technical') || catRaw.contains('quiz') || catRaw.contains('debate') || catRaw.contains('poster')) {
      category = EventCategory.academic;
    } else if (catRaw.contains('gaming') || catRaw.contains('e-sport') || catRaw.contains('esport') || catRaw.contains('sport')) {
      category = EventCategory.sports;
    } else if (catRaw.contains('tech') || catRaw.contains('coding') || catRaw.contains('hack')) {
      category = EventCategory.tech;
    } else if (catRaw.contains('cultur') || catRaw.contains('dance') || catRaw.contains('music') || catRaw.contains('drama')) {
      category = EventCategory.cultural;
    } else if (catRaw.contains('art') || catRaw.contains('paint') || catRaw.contains('design')) {
      category = EventCategory.arts;
    } else if (catRaw.contains('academ') || catRaw.contains('research') || catRaw.contains('workshop')) {
      category = EventCategory.academic;
    } else {
      category = EventCategory.all;
    }

    final dateStr = json['dateTime'] ?? json['date'] ?? json['startDate'];
    DateTime dt = DateTime.now().add(const Duration(days: 2));
    if (dateStr != null) {
      dt = DateTime.tryParse(dateStr.toString()) ?? dt;
    }

    final timeStr = json['time']?.toString() ?? '09:00';
    final timeParts = timeStr.split(RegExp(r'[:\s]'));
    if (timeParts.length >= 2) {
      final hour = int.tryParse(timeParts[0]) ?? 9;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      dt = DateTime(dt.year, dt.month, dt.day, hour, minute);
    }

    final isCompleted = json['isCompleted'] == true;
    final now = DateTime.now();
    EventStatus status;
    if (isCompleted) {
      status = EventStatus.completed;
    } else if (dt.isBefore(now)) {
      status = EventStatus.ongoing;
    } else {
      status = EventStatus.upcoming;
    }

    final rawRegs = json['registrations'];
    int currentParticipants = 0;

    if (rawRegs is List && rawRegs.isNotEmpty) {
      final activeRegistrations = rawRegs.where((r) {
        if (r is Map) {
          final status = (r['status'] ?? '').toString().toUpperCase();
          return status != 'CANCELLED';
        }
        return true;
      }).toList();
      currentParticipants = activeRegistrations.length;
    } else {
      int fallbackCount = 0;
      if (json['_count'] is Map) {
        final countMap = json['_count'] as Map;
        fallbackCount = _toInt(
          countMap['registrations'] ??
              countMap['participants'] ??
              countMap['registration'],
          0,
        );
      }
      if (fallbackCount == 0) {
        fallbackCount = _toInt(
          json['currentParticipants'] ??
              json['participantCount'] ??
              json['participantsCount'] ??
              json['totalParticipants'] ??
              json['registrationsCount'] ??
              json['registrationCount'],
          0,
        );
      }
      currentParticipants = fallbackCount;
    }

    final deadlineStr = json['registrationDeadline'];
    DateTime? registrationDeadline;
    if (deadlineStr != null) {
      registrationDeadline = DateTime.tryParse(deadlineStr.toString());
    }

    final hasScoring = json['scoresEntered'] == true || json['hasScoring'] == true;
    final ranksDeclared = json['rankingsDeclared'] == true || json['ranksDeclared'] == true;

    final parsedMaxParticipants = _toInt(json['maxParticipants'], 100);
    final parsedRegistrationFee = _toDouble(json['registrationFee'] ?? json['fee'], 0.0);
    
    final daysUntilEvent = dt.difference(now).inDays;
    final jsonIsFeatured = json['isFeatured'] == true;
    final computedIsFeatured = jsonIsFeatured ||
        (daysUntilEvent > 0 && daysUntilEvent <= 14 && parsedMaxParticipants >= 60) ||
        parsedRegistrationFee >= 150;

    final titleStr = (json['title'] ?? json['name'] ?? 'Event').toString().toLowerCase();
    final descStr = (json['description'] ?? '').toString().toLowerCase();
    final computedIsTeam = json['isTeamEvent'] == true ||
        json['isGroupEvent'] == true ||
        titleStr.contains('hackathon') ||
        titleStr.contains('summit') ||
        titleStr.contains('tournament') ||
        titleStr.contains('gala') ||
        titleStr.contains('championship') ||
        descStr.contains('team') ||
        descStr.contains('group') ||
        category == EventCategory.sports;

    final parsedMinTeamSize = _toInt(json['minTeamSize'], computedIsTeam ? 2 : 1);
    final parsedMaxTeamSize = _toInt(json['maxTeamSize'], computedIsTeam ? 4 : 1);

    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Event',
      description: json['description'] ?? '',
      category: category,
      dateTime: dt,
      location: json['location'] ?? json['venue'] ?? 'Campus',
      imageUrl: json['imageUrl'] ?? json['bannerUrl'],
      status: status,
      isFeatured: computedIsFeatured,
      accentColor: category.color,
      coordinatorId: json['coordinatorId']?.toString(),
      coordinatorName: json['coordinatorName'] ??
          (json['coordinator'] is Map ? json['coordinator']['name'] : null),
      maxParticipants: parsedMaxParticipants,
      registrationFee: parsedRegistrationFee,
      registrationDeadline: registrationDeadline,
      hasScoring: hasScoring,
      ranksDeclared: ranksDeclared,
      currentParticipants: _toInt(currentParticipants, 0),
      isTeamEvent: computedIsTeam,
      minTeamSize: parsedMinTeamSize,
      maxTeamSize: parsedMaxTeamSize,
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? dateTime,
    String? location,
    String? imageUrl,
    EventStatus? status,
    bool? isFeatured,
    Color? accentColor,
    String? coordinatorId,
    String? coordinatorName,
    int? maxParticipants,
    double? registrationFee,
    DateTime? registrationDeadline,
    bool? hasScoring,
    bool? ranksDeclared,
    int? currentParticipants,
    bool? isTeamEvent,
    int? minTeamSize,
    int? maxTeamSize,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      accentColor: accentColor ?? this.accentColor,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registrationFee: registrationFee ?? this.registrationFee,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      hasScoring: hasScoring ?? this.hasScoring,
      ranksDeclared: ranksDeclared ?? this.ranksDeclared,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isTeamEvent: isTeamEvent ?? this.isTeamEvent,
      minTeamSize: minTeamSize ?? this.minTeamSize,
      maxTeamSize: maxTeamSize ?? this.maxTeamSize,
    );
  }
}