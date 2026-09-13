// lib/student/student_scores.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/score_model.dart';
import '../providers/score_providers.dart';
import '../theme/theme.dart';

class StudentScoresScreen extends ConsumerWidget {
  const StudentScoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = AuthService.currentUser?.id ?? '';
    final scoresAsync = ref.watch(studentScoresProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('My Scores',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: scoresAsync.when(
        data: (scores) {
          if (scores.isEmpty) return _buildEmpty();
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(scores),
                const SizedBox(height: 20),
                Text('Score History',
                    style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface, fontSize: 15)),
                const SizedBox(height: 12),
                ...scores.map((s) => _ScoreCard(score: s)),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading scores',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.score_rounded,
                size: 64, color: AppColors.outline.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No scores declared yet',
                style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Participate in events to see your scores here.',
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildSummaryCard(List<ScoreModel> scores) {
    final best = scores.reduce((a, b) => a.score > b.score ? a : b);
    final avg = scores.fold(0.0, (s, sc) => s + sc.score) / scores.length;
    final bestRank = scores.reduce((a, b) => a.rank < b.rank ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Performance Overview',
              style: AppTypography.bodySm.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Best Score', '${best.score}'),
              _vDiv(),
              _summaryItem('Avg Score', avg.toStringAsFixed(1)),
              _vDiv(),
              _summaryItem('Best Rank', '#${bestRank.rank}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) => Column(
        children: [
          Text(value,
              style: AppTypography.headlineLg.copyWith(
                  color: Colors.white, fontSize: 26)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.labelBold.copyWith(
                  color: Colors.white70, fontSize: 11)),
        ],
      );

  Widget _vDiv() => Container(
        width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3));
}

class _ScoreCard extends StatelessWidget {
  final ScoreModel score;
  const _ScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score.score / 100).clamp(0.0, 1.0);
    final rankColor = score.rank == 1
        ? const Color(0xFFFFD700)
        : score.rank == 2
            ? const Color(0xFFC0C0C0)
            : score.rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(score.eventTitle,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(color: rankColor.withValues(alpha: 0.4)),
                ),
                child: Text('Rank #${score.rank}',
                    style: AppTypography.labelBold.copyWith(
                        color: rankColor == const Color(0xFFFFD700)
                            ? const Color(0xFFB8860B)
                            : rankColor,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (score.score > 0)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.fullRadius,
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: AppColors.canvasBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 0.85
                            ? const Color(0xFF2E7D32)
                            : pct >= 0.6
                                ? const Color(0xFF1565C0)
                                : const Color(0xFFFF8F00),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${score.score} pts',
                    style: AppTypography.dataPoint.copyWith(
                        color: AppColors.onSurface, fontSize: 15)),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: score.rank <= 3 ? const Color(0xFFFFF8E1) : const Color(0xFFE3F2FD),
                borderRadius: AppRadius.smRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    score.rank <= 3 ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
                    color: score.rank == 1
                        ? const Color(0xFFFFB300)
                        : (score.rank == 2 ? Colors.grey : (score.rank == 3 ? Colors.brown : const Color(0xFF1565C0))),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    score.rank == 1
                        ? '1st Place (Winner) 🥇'
                        : (score.rank == 2
                            ? '2nd Place (Runner Up) 🥈'
                            : (score.rank == 3 ? '3rd Place 🥉' : 'Rank #${score.rank}')),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: score.rank == 1
                          ? const Color(0xFFE65100)
                          : (score.rank == 2
                              ? Colors.blueGrey
                              : (score.rank == 3 ? Colors.brown : const Color(0xFF1565C0))),
                    ),
                  ),
                ],
              ),
            ),
          if (score.declaredAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: Color(0xFF2E7D32)),
                const SizedBox(width: 4),
                Text(
                  'Results declared · ${_fmt(score.declaredAt!)}',
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
}
