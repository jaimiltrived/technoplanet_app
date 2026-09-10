// lib/screens/events/event_discovery_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'event_detail_screen.dart';
import 'events_list_screen.dart';
import 'event_gallery_screen.dart';
import 'rankings_screen.dart';
import 'profile_screen.dart';

class CampusHomeScreen extends StatefulWidget {
  const CampusHomeScreen({super.key});

  @override
  State<CampusHomeScreen> createState() => _CampusHomeScreenState();
}

class _CampusHomeScreenState extends State<CampusHomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0;
  int _selectedFilterIndex = 0;
  late TabController _tabController;

  // Countdown target
  final DateTime _workshopTime =
      DateTime.now().add(const Duration(days: 1, hours: 4, minutes: 20));
  late Timer _countdownTimer;
  Duration _remaining = Duration.zero;

  // Toggle states for trending events
  final Map<int, bool> _registeredToggles = {0: false, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateCountdown();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final now = DateTime.now();
    setState(() {
      _remaining = _workshopTime.difference(now);
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 2) {
      return RankingsScreen(
        activeTab: _currentNavIndex,
        onTabSelected: (i) => setState(() => _currentNavIndex = i),
      );
    }
    if (_currentNavIndex == 3) {
      return EventGalleryScreen(
        activeTab: _currentNavIndex,
        onTabSelected: (i) => setState(() => _currentNavIndex = i),
      );
    }
    if (_currentNavIndex == 4) {
      return ProfileScreen(
        activeTab: _currentNavIndex,
        onTabSelected: (i) => setState(() => _currentNavIndex = i),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: IndexedStack(
                index: _currentNavIndex == 1 ? 1 : 0,
                children: [
                  // ── index 0: Home ──────────────────────────────────────
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildWelcomeBanner(),
                        const SizedBox(height: 14),
                        _buildUpcomingNextCard(),
                        const SizedBox(height: 14),
                        _buildSpringGalaCard(),
                        const SizedBox(height: 14),
                        _buildStatusSection(),
                        const SizedBox(height: 14),
                        _buildCategoriesSection(),
                        const SizedBox(height: 14),
                        _buildFilterTabs(),
                        const SizedBox(height: 18),
                        _buildTrendingSection(),
                        const SizedBox(height: 14),
                        _buildLatestUpdates(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // ── index 1: Events list ───────────────────────────────
                  const EventsListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── APP BAR ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final titles = [
      'Campus Events',
      'All Events',
      'Rankings',
      'Gallery',
      'Profile',
    ];
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            titles[_currentNavIndex.clamp(0, titles.length - 1)],
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.canvasBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.onSurface),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD4A574), Color(0xFF8B5A3C)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── WELCOME BANNER ─────────────────────────────────────────────────────────
  Widget _buildWelcomeBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Welcome back, '),
                  TextSpan(
                    text: 'Alex Sterling',
                    style: const TextStyle(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '3 events',
                    style: const TextStyle(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' scheduled for '),
                  TextSpan(
                    text: 'this week.',
                    style: const TextStyle(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Event tag pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.25),
                borderRadius: AppRadius.fullRadius,
                border: Border.all(
                    color: AppColors.secondaryContainer, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle,
                      size: 7, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'RKU TECH SYMPOSIUM #01',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── UPCOMING NEXT CARD ─────────────────────────────────────────────────────
  Widget _buildUpcomingNextCard() {
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header strip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_outlined,
                      size: 13, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    'UPCOMING NEXT',
                    style: AppTypography.labelBold.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Robotics Workshop',
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Engineering Hall, Room 402',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Countdown timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCountdownUnit(d.toString().padLeft(2, '0'), 'DAYS'),
                      const SizedBox(width: 8),
                      _buildCountdownSeparator(),
                      const SizedBox(width: 8),
                      _buildCountdownUnit(h.toString().padLeft(2, '0'), 'HOURS'),
                      const SizedBox(width: 8),
                      _buildCountdownSeparator(),
                      const SizedBox(width: 8),
                      _buildCountdownUnit(m.toString().padLeft(2, '0'), 'MIN'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // View E-Ticket Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.confirmation_number_outlined,
                          size: 16),
                      label: Text(
                        'VIEW E-TICKET',
                        style: AppTypography.labelBold.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownUnit(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasBackground,
        borderRadius: AppRadius.smRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSeparator() {
    return Text(
      ':',
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.primaryContainer,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ─── SPRING GALA FEATURED CARD ──────────────────────────────────────────────
  Widget _buildSpringGalaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EventDetailScreen(
                eventTitle: 'Spring Gala 2024',
                eventCategory: 'CULTURAL',
                eventDate: 'Apr 18, 2024',
                eventTime: '06:00 PM – 11:00 PM',
                eventLocation: 'RK University Main Auditorium',
                heroGradient: [Color(0xFF1B2A6B), Color(0xFF3F51B5), Color(0xFF7986CB)],
                badgeColor: Color(0xFF7986CB),
                badgeLabel: 'CULTURAL',
                rating: 4.8,
              ),
            ),
          );
        },
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdRadius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B2A6B),
                Color(0xFF3F51B5),
                Color(0xFF7986CB),
              ],
            ),
            boxShadow: AppShadows.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Decorative overlay pattern
                CustomPaint(painter: _GalaPatternPainter()),
                // Gradient overlay from bottom
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC000520)],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 14,
                  bottom: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent,
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          '★  FEATURED',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primaryContainer,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Spring Gala 2024',
                        style: AppTypography.headlineMd.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'RK University Main Auditorium • Apr 18',
                        style: AppTypography.bodySm.copyWith(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── STATUS SECTION ─────────────────────────────────────────────────────────
  Widget _buildStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR STATUS',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Active',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Completion',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '85%',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: AppRadius.fullRadius,
              child: LinearProgressIndicator(
                value: 0.85,
                minHeight: 7,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORIES ─────────────────────────────────────────────────────────────
  Widget _buildCategoriesSection() {
    final cats = [
      {'icon': Icons.code_outlined, 'label': 'TECH', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.sports_esports_outlined, 'label': 'GAMING', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.sports_outlined, 'label': 'SPORTS', 'color': const Color(0xFFEF4444)},
      {'icon': Icons.palette_outlined, 'label': 'ARTS', 'color': const Color(0xFFF59E0B)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORIES',
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: cats.map((cat) {
              final color = cat['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(
                            color: color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(cat['icon'] as IconData,
                              color: color, size: 22),
                          const SizedBox(height: 5),
                          Text(
                            cat['label'] as String,
                            style: AppTypography.labelBold.copyWith(
                              color: color,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── FILTER TABS ─────────────────────────────────────────────────────────────
  Widget _buildFilterTabs() {
    final filters = ['All Events', 'Technical', 'Non-Tech'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.fullRadius,
        ),
        child: Row(
          children: List.generate(filters.length, (i) {
            final selected = _selectedFilterIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilterIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryContainer
                        : Colors.transparent,
                    borderRadius: AppRadius.fullRadius,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryContainer
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      filters[i],
                      style: AppTypography.labelBold.copyWith(
                        color: selected ? Colors.white : AppColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── TRENDING EVENTS ─────────────────────────────────────────────────────────
  Widget _buildTrendingSection() {
    final trendingEvents = [
      {
        'category': 'WORKSHOP',
        'title': 'UI/UX Masterclass for Engineers',
        'rating': '4.9',
        'badge': 'FULL SOON',
        'badgeColor': const Color(0xFFEF4444),
        'registered': '+42 registered',
        'gradient': [const Color(0xFF1E3A5F), const Color(0xFF2C5282)],
      },
      {
        'category': 'SPORTS',
        'title': 'Inter-College Basketball Finals',
        'rating': '4.7',
        'badge': 'OPEN',
        'badgeColor': const Color(0xFF22C55E),
        'registered': '+50 registered',
        'gradient': [const Color(0xFF3D2B1F), const Color(0xFF6B4C3B)],
      },
      {
        'category': 'GAMING',
        'title': 'Pro League: Valorant Open',
        'rating': '5.0',
        'badge': 'POPULAR',
        'badgeColor': const Color(0xFF8B5CF6),
        'registered': '+80 registered',
        'gradient': [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📈', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Trending Events',
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.primaryContainer),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(trendingEvents.length, (i) {
          final ev = trendingEvents[i];
          final gradColors = ev['gradient'] as List<Color>;
          final badgeColor = ev['badgeColor'] as Color;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(
                    eventTitle: ev['title'] as String,
                    eventCategory: ev['category'] as String,
                    eventDate: 'Oct ${24 + i}, 2024',
                    eventTime: '10:00 AM – 05:00 PM',
                    eventLocation: 'RK University Campus',
                    heroGradient: gradColors,
                    badgeColor: badgeColor,
                    badgeLabel: ev['category'] as String,
                    rating: double.parse(ev['rating'] as String),
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image area
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradColors,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                                painter: _TrendingPatternPainter(index: i)),
                            // Badge
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: AppRadius.fullRadius,
                                ),
                                child: Text(
                                  ev['badge'] as String,
                                  style: AppTypography.labelBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ev['category'] as String,
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 13,
                                      color: AppColors.goldAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    ev['rating'] as String,
                                    style: AppTypography.labelBold.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev['title'] as String,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Toggle
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _registeredToggles[i] =
                                        !(_registeredToggles[i] ?? false)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: (_registeredToggles[i] ?? false)
                                        ? AppColors.primaryContainer
                                        : AppColors.surfaceContainerHigh,
                                    borderRadius: AppRadius.fullRadius,
                                  ),
                                  child: AnimatedAlign(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    alignment:
                                        (_registeredToggles[i] ?? false)
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      margin: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ev['registered'] as String,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── LATEST UPDATES ──────────────────────────────────────────────────────────
  Widget _buildLatestUpdates() {
    final updates = [
      {
        'emoji': '📄',
        'bgColor': const Color(0xFF002147),
        'title': 'Hackathon Guidelines Updated',
        'time': '2 hours ago',
        'committee': 'Technical Committee',
      },
      {
        'emoji': '🏅',
        'bgColor': const Color(0xFFF59E0B),
        'title': 'Medals available for pickup',
        'time': '5 hours ago',
        'committee': 'Student Welfare',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'LATEST UPDATES',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...updates.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (u['bgColor'] as Color)
                              .withValues(alpha: 0.15),
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Center(
                          child: Text(
                            u['emoji'] as String,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u['title'] as String,
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                children: [
                                  TextSpan(text: u['time'] as String),
                                  const TextSpan(text: ' • '),
                                  TextSpan(text: u['committee'] as String),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.event_outlined, 'activeIcon': Icons.event, 'label': 'Events'},
      {'icon': Icons.emoji_events_outlined, 'activeIcon': Icons.emoji_events, 'label': 'Rankings'},
      {'icon': Icons.photo_library_outlined, 'activeIcon': Icons.photo_library, 'label': 'Gallery'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 12,
            color: AppColors.cardShadow,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = _currentNavIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentNavIndex = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 14 : 0,
                            vertical: isSelected ? 5 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.goldAccent.withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Icon(
                            isSelected
                                ? items[i]['activeIcon'] as IconData
                                : items[i]['icon'] as IconData,
                            size: 22,
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i]['label'] as String,
                          style: AppTypography.labelBold.copyWith(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.outline,
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

// ─── PATTERN PAINTERS ────────────────────────────────────────────────────────

class _GalaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    // Circles
    for (int i = 0; i < 10; i++) {
      final x = (i * 43.0) % size.width;
      final y = (i * 27.0) % size.height;
      canvas.drawCircle(Offset(x, y), 4 + (i % 5).toDouble() * 3, paint);
    }

    // Lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Diagonal accent lines
    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 20;
    canvas.drawLine(
        Offset(size.width * 0.6, 0), Offset(size.width, size.height * 0.4),
        accentPaint);
    canvas.drawLine(
        Offset(size.width * 0.8, 0), Offset(size.width, size.height * 0.2),
        accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendingPatternPainter extends CustomPainter {
  final int index;
  const _TrendingPatternPainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = ((i * 37.0) + index * 20) % size.width;
      final y = ((i * 23.0) + index * 10) % size.height;
      canvas.drawCircle(Offset(x, y), 2 + (i % 4).toDouble() * 2, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}