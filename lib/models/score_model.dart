// lib/models/score_model.dart

double _scoreToDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.trim().replaceAll(',', '')) ?? fallback;
  }
  return fallback;
}

int _scoreToInt(dynamic value, [int fallback = 0]) {
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

class ScoreModel {
  final String id;
  final String userId;
  final String userName;
  final String eventId;
  final String eventTitle;
  final double score;
  final int rank;
  final bool isDeclared;
  final DateTime? declaredAt;

  const ScoreModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventId,
    required this.eventTitle,
    required this.score,
    required this.rank,
    this.isDeclared = false,
    this.declaredAt,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json, {String? userId, String? userName, String? eventId, String? eventTitle}) {
    final declaredRaw = json['declaredAt'] ?? json['updatedAt'];
    DateTime? declaredAt;
    if (declaredRaw != null) {
      declaredAt = DateTime.tryParse(declaredRaw.toString());
    }

    final isDeclared = json['isDeclared'] == true ||
        json['rankingsDeclared'] == true ||
        json['ranksDeclared'] == true ||
        declaredAt != null;

    return ScoreModel(
      id: json['id']?.toString() ?? json['scoreId']?.toString() ?? '',
      userId: userId ?? json['userId']?.toString() ?? json['studentId']?.toString() ?? '',
      userName: userName ?? json['userName'] ?? json['studentName'] ?? '',
      eventId: eventId ?? json['eventId']?.toString() ?? '',
      eventTitle: eventTitle ?? json['eventTitle'] ?? json['eventName'] ?? '',
      score: _scoreToDouble(json['score'] ?? json['points']),
      rank: _scoreToInt(json['rank']),
      isDeclared: isDeclared,
      declaredAt: declaredAt,
    );
  }
}

class ParticipantEntry {
  final String userId;
  final String userName;
  final String enrollmentNo;
  final String department;
  final String? email;
  final String? phone;
  final String? collegeName;
  final String? branch;
  final String? semester;
  double? score;
  int? rank;

  ParticipantEntry({
    required this.userId,
    required this.userName,
    required this.enrollmentNo,
    required this.department,
    this.email,
    this.phone,
    this.collegeName,
    this.branch,
    this.semester,
    this.score,
    this.rank,
  });

  factory ParticipantEntry.fromJson(Map<String, dynamic> json, {double? score, int? rank}) {
    return ParticipantEntry(
      userId: json['userId']?.toString() ?? json['studentId']?.toString() ?? json['id']?.toString() ?? '',
      userName: json['userName'] ?? json['studentName'] ?? json['name'] ?? '',
      enrollmentNo: json['enrollmentNo'] ?? json['enrollmentNumber'] ?? json['rollNo'] ?? '',
      department: json['department'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? json['phoneNumber'] ?? json['mobileNo'],
      collegeName: json['collegeName'],
      branch: json['branch'],
      semester: json['semester']?.toString(),
      score: score ?? _scoreToDouble(json['score'] ?? json['points']),
      rank: rank ?? _scoreToInt(json['rank']),
    );
  }
}
