// lib/events/rankings_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

// ─── RANKED STUDENT MODEL ───────────────────────────────────────────────────

class RankedStudent {
  final int rank;
  final String name;
  final String branch;
  final int score;
  final String avatarUrl;
  final String trend;
  final String badgeText;
  final List<Color> avatarGradient;

  const RankedStudent({
    required this.rank,
    required this.name,
    required this.branch,
    required this.score,
    required this.avatarUrl,
    required this.trend,
    required this.badgeText,
    required this.avatarGradient,
  });
}

// ─── MOCK EVENT RANKINGS DATA ───────────────────────────────────────────────

final Map<String, List<RankedStudent>> _eventRankingsMap = {
  'Annual Hackathon 2024': const [
    RankedStudent(
      rank: 1,
      name: 'Alex Vance',
      branch: 'Computer Science',
      score: 2940,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
      trend: '+240 pts',
      badgeText: 'GOLD WINNER',
      avatarGradient: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    RankedStudent(
      rank: 2,
      name: 'Sophia Patel',
      branch: 'AI & Data Science',
      score: 2780,
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
      trend: '+180 pts',
      badgeText: 'SILVER WINNER',
      avatarGradient: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    ),
    RankedStudent(
      rank: 3,
      name: 'Marcus Chen',
      branch: 'Robotics Eng.',
      score: 2610,
      avatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=400&auto=format&fit=crop',
      trend: '+150 pts',
      badgeText: 'BRONZE WINNER',
      avatarGradient: [Color(0xFFCD7F32), Color(0xFFA0522D)],
    ),
    RankedStudent(
      rank: 4,
      name: 'Elena Rostova',
      branch: 'Software Engineering',
      score: 2420,
      avatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=400&auto=format&fit=crop',
      trend: '▲ +85 pts',
      badgeText: 'Top Innovator',
      avatarGradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    RankedStudent(
      rank: 5,
      name: 'Devon Knight',
      branch: 'Cyber Security',
      score: 2310,
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
      trend: '▲ +60 pts',
      badgeText: 'Bug Hunter',
      avatarGradient: [Color(0xFF10B981), Color(0xFF047857)],
    ),
    RankedStudent(
      rank: 6,
      name: 'Aisha Malik',
      branch: 'Cloud Computing',
      score: 2190,
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
      trend: '▼ -10 pts',
      badgeText: 'Cloud Specialist',
      avatarGradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    RankedStudent(
      rank: 7,
      name: 'Lucas Silva',
      branch: 'Information Tech',
      score: 2080,
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
      trend: '▲ +40 pts',
      badgeText: 'Full Stack',
      avatarGradient: [Color(0xFFEC4899), Color(0xFFBE185D)],
    ),
    RankedStudent(
      rank: 8,
      name: 'Zoe Nakamura',
      branch: 'UI/UX Design',
      score: 1950,
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop',
      trend: '▲ +95 pts',
      badgeText: 'Best UI Design',
      avatarGradient: [Color(0xFFF59E0B), Color(0xFFB45309)],
    ),
  ],
  'Robotics Championship': const [
    RankedStudent(
      rank: 1,
      name: 'Marcus Chen',
      branch: 'Robotics Eng.',
      score: 3100,
      avatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=400&auto=format&fit=crop',
      trend: '+310 pts',
      badgeText: 'GOLD WINNER',
      avatarGradient: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    RankedStudent(
      rank: 2,
      name: 'Devon Knight',
      branch: 'Mechatronics',
      score: 2890,
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
      trend: '+210 pts',
      badgeText: 'SILVER WINNER',
      avatarGradient: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    ),
    RankedStudent(
      rank: 3,
      name: 'Alex Vance',
      branch: 'Computer Science',
      score: 2750,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
      trend: '+120 pts',
      badgeText: 'BRONZE WINNER',
      avatarGradient: [Color(0xFFCD7F32), Color(0xFFA0522D)],
    ),
    RankedStudent(
      rank: 4,
      name: 'Sophia Patel',
      branch: 'AI & Data Science',
      score: 2500,
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
      trend: '▲ +75 pts',
      badgeText: 'Autonomous Bot',
      avatarGradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
  ],
  'AI Innovation Challenge': const [
    RankedStudent(
      rank: 1,
      name: 'Sophia Patel',
      branch: 'AI & Data Science',
      score: 3250,
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
      trend: '+350 pts',
      badgeText: 'GOLD WINNER',
      avatarGradient: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    RankedStudent(
      rank: 2,
      name: 'Elena Rostova',
      branch: 'Software Engineering',
      score: 3010,
      avatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=400&auto=format&fit=crop',
      trend: '+220 pts',
      badgeText: 'SILVER WINNER',
      avatarGradient: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    ),
    RankedStudent(
      rank: 3,
      name: 'Alex Vance',
      branch: 'Computer Science',
      score: 2880,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
      trend: '+190 pts',
      badgeText: 'BRONZE WINNER',
      avatarGradient: [Color(0xFFCD7F32), Color(0xFFA0522D)],
    ),
  ],
  'Varsity Sports Meet': const [
    RankedStudent(
      rank: 1,
      name: 'Lucas Silva',
      branch: 'Physical Education',
      score: 2890,
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
      trend: '+290 pts',
      badgeText: 'GOLD WINNER',
      avatarGradient: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    RankedStudent(
      rank: 2,
      name: 'Devon Knight',
      branch: 'Sports Science',
      score: 2710,
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
      trend: '+190 pts',
      badgeText: 'SILVER WINNER',
      avatarGradient: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    ),
    RankedStudent(
      rank: 3,
      name: 'Aisha Malik',
      branch: 'Athletics Department',
      score: 2540,
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
      trend: '+130 pts',
      badgeText: 'BRONZE WINNER',
      avatarGradient: [Color(0xFFCD7F32), Color(0xFFA0522D)],
    ),
  ],
};

// ─── RANKINGS SCREEN ─────────────────────────────────────────────────────────

class RankingsScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final int activeTab;

  const RankingsScreen({
    super.key,
    this.onTabSelected,
    this.activeTab = 2,
  });

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedEvent = 'Annual Hackathon 2024';
  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(hours: 4, minutes: 22, seconds: 15);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _countdownTimer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  List<RankedStudent> get _currentList =>
      _eventRankingsMap[_selectedEvent] ?? [];

  @override
  Widget build(BuildContext context) {
    final list = _currentList;
    final gold = list.isNotEmpty ? list[0] : null;
    final silver = list.length > 1 ? list[1] : null;
    final bronze = list.length > 2 ? list[2] : null;
    final remainingList = list.length > 3 ? list.sublist(3) : <RankedStudent>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildTopHeader(),
                      const SizedBox(height: 16),
                      _buildEventFilterDropdown(),
                      const SizedBox(height: 16),
                      _buildCountdownBanner(),
                      const SizedBox(height: 24),
                      if (gold != null)
                        _buildPodiumSection(gold, silver, bronze),
                      const SizedBox(height: 28),
                      _buildRemainingRankingsHeader(),
                      const SizedBox(height: 12),
                      _buildRemainingRankingsList(remainingList),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── TOP HEADER WITH LIVE BADGE ──────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Row(
      children: [
        const Text(
          'Rankings',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 10),
        // Live Badge
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF22C55E)
                      .withValues(alpha: _pulseAnimation.value),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E)
                          .withValues(alpha: _pulseAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E),
                          blurRadius: 4 * _pulseAnimation.value,
                          spreadRadius: 1 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        // Notification bell button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF0F172A),
            size: 22,
          ),
        ),
      ],
    );
  }

  // ─── EVENT FILTER DROPDOWN ──────────────────────────────────────────────────
  Widget _buildEventFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            color: Color(0xFFD97706),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEvent,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                isExpanded: true,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _selectedEvent = newValue);
                  }
                },
                items: _eventRankingsMap.keys.map((String eventName) {
                  return DropdownMenuItem<String>(
                    value: eventName,
                    child: Text(
                      eventName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── COUNTDOWN UNTIL RESULTS BANNER ─────────────────────────────────────────
  Widget _buildCountdownBanner() {
    final hours =
        _remainingTime.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes =
        _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B132B).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.timer_outlined,
                color: Color(0xFFFED65B),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'Countdown until final results announcement',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnitCard(hours, 'HOURS'),
              _buildTimeSeparator(),
              _buildTimeUnitCard(minutes, 'MINUTES'),
              _buildTimeSeparator(),
              _buildTimeUnitCard(seconds, 'SECONDS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnitCard(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFED65B),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: Color(0xFFFED65B),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ─── PODIUM SECTION (GOLD, SILVER, BRONZE WINNERS) ─────────────────────────
  Widget _buildPodiumSection(
    RankedStudent gold,
    RankedStudent? silver,
    RankedStudent? bronze,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place - Silver Winner
              if (silver != null)
                Expanded(
                  child: _buildPodiumPillar(
                    student: silver,
                    rank: 2,
                    pillarHeight: 110,
                    crownIcon: Icons.workspace_premium,
                    crownColor: const Color(0xFFC0C0C0),
                    pillarGradient: const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                    rankColor: const Color(0xFF64748B),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 8),

              // 1st Place - Gold Winner (Center & Highest)
              Expanded(
                child: _buildPodiumPillar(
                  student: gold,
                  rank: 1,
                  pillarHeight: 145,
                  crownIcon: Icons.emoji_events,
                  crownColor: const Color(0xFFFFD700),
                  pillarGradient: const [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  rankColor: const Color(0xFFB45309),
                  isGold: true,
                ),
              ),

              const SizedBox(width: 8),

              // 3rd Place - Bronze Winner
              if (bronze != null)
                Expanded(
                  child: _buildPodiumPillar(
                    student: bronze,
                    rank: 3,
                    pillarHeight: 90,
                    crownIcon: Icons.military_tech,
                    crownColor: const Color(0xFFCD7F32),
                    pillarGradient: const [Color(0xFFFED7AA), Color(0xFFF97316)],
                    rankColor: const Color(0xFFC2410C),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar({
    required RankedStudent student,
    required int rank,
    required double pillarHeight,
    required IconData crownIcon,
    required Color crownColor,
    required List<Color> pillarGradient,
    required Color rankColor,
    bool isGold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy/Crown Icon
        Icon(
          crownIcon,
          color: crownColor,
          size: isGold ? 28 : 22,
        ),
        const SizedBox(height: 2),

        // Avatar with border
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: EdgeInsets.all(isGold ? 3 : 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: student.avatarGradient),
                boxShadow: isGold
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: isGold ? 34 : 26,
                backgroundImage: NetworkImage(student.avatarUrl),
              ),
            ),
            // Rank Badge (#1, #2, #3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rankColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Winner Name
        Text(
          student.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: isGold ? 13.5 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),

        // Branch / Department
        Text(
          student.branch,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        // Student Score Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${student.score} pts',
            style: const TextStyle(
              color: Color(0xFFFED65B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 3D Podium Block
        Container(
          height: pillarHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: pillarGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isGold ? 36 : 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                student.badgeText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── REMAINING RANKINGS HEADER ──────────────────────────────────────────────
  Widget _buildRemainingRankingsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Leaderboard Standings',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'Score / Trend',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── REMAINING RANKINGS LIST (4TH PLACE ONWARDS) ────────────────────────────
  Widget _buildRemainingRankingsList(List<RankedStudent> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'No additional participants yet.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = list[index];
        final isPositiveTrend = student.trend.contains('+') ||
            student.trend.contains('▲');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank Number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${student.rank}',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(student.avatarUrl),
              ),
              const SizedBox(width: 12),

              // Name & Department
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.branch,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Student Score & Trend
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${student.score} pts',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      student.trend,
                      style: TextStyle(
                        color: isPositiveTrend
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── BOTTOM NAVIGATION BAR ──────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today,
        'label': 'Events'
      },
      {
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'label': 'Rankings'
      },
      {
        'icon': Icons.photo_library_outlined,
        'activeIcon': Icons.photo_library,
        'label': 'Gallery'
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -3),
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: List.generate(navItems.length, (i) {
              final isSelected = widget.activeTab == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.onTabSelected != null) {
                      widget.onTabSelected!(i);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 16 : 0,
                            vertical: isSelected ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFD54F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSelected
                                ? navItems[i]['activeIcon'] as IconData
                                : navItems[i]['icon'] as IconData,
                            size: 20,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          navItems[i]['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFD97706)
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
