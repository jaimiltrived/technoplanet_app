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
  tech('Tech'),
  nonTech('Non-Tech');

  final String label;
  const EventCategory(this.label);
}

extension EventCategoryX on EventCategory {
  IconData get icon {
    switch (this) {
      case EventCategory.all:
        return Icons.apps_rounded;
      case EventCategory.tech:
        return Icons.computer_rounded;
      case EventCategory.nonTech:
        return Icons.lightbulb_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.all:
        return const Color(0xFF002147);
      case EventCategory.tech:
        return const Color(0xFF1565C0);
      case EventCategory.nonTech:
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

  bool get hasBannerImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get isCompleted => status == EventStatus.completed;
  bool get isRegistrationFull => maxParticipants > 0 && currentParticipants >= maxParticipants;

  /// Strips HTML tags and normalizes list formatting from rich text editors like Quill.js
  static String stripHtml(String html) {
    if (!html.contains('<') && !html.contains('>')) {
      return html.trim();
    }
    var text = html;

    // 1. Remove Quill's internal UI helper elements (<span class="ql-ui" ...></span>)
    text = text.replaceAll(RegExp(r'<span[^>]*class=["\x27][^"\x27]*ql-ui[^"\x27]*["\x27][^>]*>[\s\S]*?</span>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<span[^>]*class=["\x27][^"\x27]*ql-ui[^"\x27]*["\x27][^>]*>', caseSensitive: false), '');

    // 2. Remove redundant repetitive heading paragraphs if entered
    text = text.replaceAll(RegExp(r'<p[^>]*>\s*Rules and Regulation for participation and execution\.?\s*<\/p>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<p[^>]*>\s*Evaluation of participants numbers of rounds to decide the winner\.?\s*<\/p>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<p[^>]*>\s*WINNER CERTIFICATE WILL BE PROVIDED TO THE RANKERS\.?\s*<\/p>', caseSensitive: false), '');

    // 3. Convert list items to bullet points
    text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '● ');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    // 4. Convert paragraphs, headings, and breaks to line breaks
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n');

    // 5. Strip all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // 6. Decode common HTML entities
    text = text.replaceAll('&nbsp;', ' ')
               .replaceAll('&amp;', '&')
               .replaceAll('&lt;', '<')
               .replaceAll('&gt;', '>')
               .replaceAll('&quot;', '"')
               .replaceAll('&#39;', "'")
               .replaceAll('&bull;', '●');

    // 7. Clean up whitespace and excess blank lines
    return text
        .split('\n')
        .map((line) => line.trimRight())
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String get cleanDescription => stripHtml(description);

  static String? _normalizeImageUrl(String? url) {
    if (url == null) return null;
    String trimmed = url.trim();
    if (trimmed.isEmpty || trimmed.startsWith('data:')) return null;

    // If previously wrapped in wsrv.nl proxy and it points to catbox, unwrap it.
    // wsrv.nl currently 404s catbox urls, and Catbox natively supports CORS.
    if (trimmed.contains('wsrv.nl') && trimmed.contains('catbox.moe')) {
      try {
        final uri = Uri.tryParse(trimmed);
        if (uri != null && uri.queryParameters.containsKey('url')) {
          trimmed = Uri.decodeComponent(uri.queryParameters['url']!);
        }
      } catch (_) {}
    }

    // Do NOT wrap in wsrv.nl anymore.
    return trimmed;
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final String rawDescription = json['description']?.toString() ?? '';
    String? parsedImageUrl = json['imageUrl']?.toString() ?? json['bannerUrl']?.toString();
    String cleanDescription = rawDescription;

    // Extract banner image URL from description header if formatted as "EVENT BANNER IMAGE: <url>"
    final bannerRegex = RegExp(r'EVENT BANNER IMAGE:\s*([^\n\r]+)', caseSensitive: false);
    final bannerMatch = bannerRegex.firstMatch(rawDescription);
    if (bannerMatch != null) {
      final matchedUrl = bannerMatch.group(1)?.trim();
      if (matchedUrl != null && matchedUrl.isNotEmpty && !matchedUrl.startsWith('data:')) {
        parsedImageUrl ??= matchedUrl;
      }
      cleanDescription = rawDescription.replaceFirst(bannerRegex, '').trim();
    }

    cleanDescription = stripHtml(cleanDescription);

    parsedImageUrl = _normalizeImageUrl(parsedImageUrl);

    final catRaw = json['category'] is Map
        ? (json['category']['name'] ?? '').toString().toLowerCase()
        : (json['category'] ?? '').toString().toLowerCase();
    EventCategory category;
    if (catRaw.contains('non') || catRaw.contains('non-tech') || catRaw.contains('non technical')) {
      category = EventCategory.nonTech;
    } else {
      category = EventCategory.tech;
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
      int activeCount = 0;
      for (final r in rawRegs) {
        if (r is Map) {
          final status = (r['status'] ?? '').toString().toUpperCase();
          if (status != 'CANCELLED') {
            final tSize = _toInt(r['teamSize'], 1);
            activeCount += tSize > 0 ? tSize : 1;
          }
        } else {
          activeCount++;
        }
      }
      currentParticipants = activeCount;
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
      final parsedDl = DateTime.tryParse(deadlineStr.toString());
      if (parsedDl != null) {
        final utc = parsedDl.toUtc();
        if ((utc.hour == 0 && utc.minute == 0 && utc.second == 0) ||
            (parsedDl.hour == 0 && parsedDl.minute == 0 && parsedDl.second == 0)) {
          registrationDeadline = DateTime(
            parsedDl.year,
            parsedDl.month,
            parsedDl.day,
            23, 59, 59, 999,
          );
        } else {
          registrationDeadline = parsedDl.toLocal();
        }
      }
    }

    final hasScoring = json['scoresEntered'] == true || json['hasScoring'] == true;
    final ranksDeclared = json['rankingsDeclared'] == true || json['ranksDeclared'] == true;

    final parsedMaxParticipants = _toInt(json['maxParticipants'], 100);
    final parsedRegistrationFee = _toDouble(json['registrationFee'] ?? json['fee'], 0.0);
    
    final daysUntilEvent = dt.difference(now).inDays;
    final jsonIsFeatured = json['isFeatured'] == true;
    final computedIsFeatured = jsonIsFeatured ||
        (daysUntilEvent >= 0 && daysUntilEvent <= 14 && parsedMaxParticipants >= 60) ||
        parsedRegistrationFee >= 150 ||
        status == EventStatus.ongoing;

    final titleStr = (json['title'] ?? json['name'] ?? 'Event').toString().toLowerCase();
    final descStr = cleanDescription.toLowerCase();
    final computedIsTeam = json['isTeamEvent'] == true ||
        json['isGroupEvent'] == true ||
        titleStr.contains('hackathon') ||
        titleStr.contains('summit') ||
        titleStr.contains('tournament') ||
        titleStr.contains('gala') ||
        titleStr.contains('championship') ||
        descStr.contains('team') ||
        descStr.contains('group');

    final rawMin = _toInt(json['minTeamSize'], 0);
    final rawMax = _toInt(json['maxTeamSize'], 0);
    final int defaultMin = computedIsTeam ? (descStr.contains('5v5') ? 5 : 2) : 1;
    final int defaultMax = computedIsTeam ? (descStr.contains('5v5') ? 5 : 4) : 1;
    final parsedMinTeamSize = rawMin >= 2 ? rawMin : defaultMin;
    final parsedMaxTeamSize = rawMax >= parsedMinTeamSize ? rawMax : defaultMax;

    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Event',
      description: cleanDescription,
      category: category,
      dateTime: dt,
      location: json['location'] ?? json['venue'] ?? 'Campus',
      imageUrl: parsedImageUrl,
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