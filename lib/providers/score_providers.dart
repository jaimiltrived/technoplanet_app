// lib/providers/score_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score_model.dart';
import '../services/score_service.dart';

final studentScoresProvider = FutureProvider.family<List<ScoreModel>, String>((ref, userId) async {
  return await ScoreService.fetchStudentScores(userId);
});

final eventRankingsProvider = FutureProvider.family<List<ParticipantEntry>, String>((ref, eventId) async {
  return await ScoreService.fetchEventRankings(eventId);
});
