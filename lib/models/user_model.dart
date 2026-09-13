// lib/models/user_model.dart
import 'package:flutter/material.dart';

enum UserRole { student, faculty, volunteer, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get accentColor {
    switch (this) {
      case UserRole.student:
        return const Color(0xFF002147);
      case UserRole.faculty:
        return const Color(0xFF00897B);
      case UserRole.volunteer:
        return const Color(0xFF8D6E63);
      case UserRole.admin:
        return const Color(0xFFFF8F00);
    }
  }

  Color get badgeColor {
    switch (this) {
      case UserRole.student:
        return const Color(0xFFE3F2FD);
      case UserRole.faculty:
        return const Color(0xFFE0F2F1);
      case UserRole.volunteer:
        return const Color(0xFFEFEBE9);
      case UserRole.admin:
        return const Color(0xFFFFF8E1);
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? enrollmentNo;
  final String? department;
  final String? semester;
  final String? phone;
  final String? profileImageUrl;
  final List<String> participatedEventIds;
  final List<String> assignedEventIds; // for faculty/coordinator

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.enrollmentNo,
    this.department,
    this.semester,
    this.phone,
    this.profileImageUrl,
    this.participatedEventIds = const [],
    this.assignedEventIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? roleStr}) {
    final roleRaw = (roleStr ?? json['role'] ?? 'STUDENT').toString().toUpperCase();
    UserRole parsedRole;
    if (roleRaw.contains('ADMIN')) {
      parsedRole = UserRole.admin;
    } else if (roleRaw.contains('FACULTY') || roleRaw.contains('COORDINATOR')) {
      parsedRole = UserRole.faculty;
    } else if (roleRaw.contains('VOLUNTEER') || roleRaw.contains('STAFF')) {
      parsedRole = UserRole.volunteer;
    } else {
      parsedRole = UserRole.student;
    }

    final semesterRaw = json['semester'];
    String? semesterStr;
    if (semesterRaw != null) {
      if (semesterRaw is int) {
        semesterStr = '${semesterRaw}th Semester';
      } else {
        final s = semesterRaw.toString();
        if (s.isNotEmpty && !s.toLowerCase().contains('semester')) {
          semesterStr = '${s}th Semester';
        } else {
          semesterStr = s.isEmpty ? null : s;
        }
      }
    }

    final rawAssigned = json['assignedEvents'] ??
        json['assignedEventIds'] ??
        json['events'] ??
        json['volunteerEvents'];
    final List<String> assignedIds = [];
    if (rawAssigned is List) {
      for (final item in rawAssigned) {
        if (item is String && item.isNotEmpty) {
          assignedIds.add(item);
        } else if (item is Map) {
          final id = item['id'] ?? item['eventId'];
          if (id != null) assignedIds.add(id.toString());
        }
      }
    }

    final rawParticipated = json['participatedEvents'] ??
        json['participatedEventIds'] ??
        json['registrations'];
    final List<String> participatedIds = [];
    if (rawParticipated is List) {
      for (final item in rawParticipated) {
        if (item is String && item.isNotEmpty) {
          participatedIds.add(item);
        } else if (item is Map) {
          final id = item['eventId'] ?? item['id'];
          if (id != null) participatedIds.add(id.toString());
        }
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? 'User',
      email: json['email'] ?? '',
      role: parsedRole,
      enrollmentNo: json['enrollmentNo'] ?? json['enrollmentNumber'] ?? json['rollNo'],
      department: json['department'],
      semester: semesterStr,
      phone: json['phone'] ?? json['mobileNo'],
      profileImageUrl: json['profileImageUrl'] ?? json['avatarUrl'] ?? json['profilePic'],
      participatedEventIds: participatedIds,
      assignedEventIds: assignedIds,
    );
  }
}

