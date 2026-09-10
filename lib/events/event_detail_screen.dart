// lib/events/event_detail_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'event_registration_screen.dart';

// ─── DATA MODELS ─────────────────────────────────────────────────────────────




// ─── SCREEN ──────────────────────────────────────────────────────────────────

class EventDetailScreen extends StatefulWidget {
  final String eventTitle;
  final String eventCategory;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final List<Color> heroGradient;
  final Color badgeColor;
  final String badgeLabel;
  final double rating;
  final String facultyCoordinatorName;
  final String facultyCoordinatorEmail;
  final String facultyCoordinatorMobile;

  const EventDetailScreen({
    super.key,
    this.eventTitle = 'Annual Innovation Summit 2024',
    this.eventCategory = 'TECH',
    this.eventDate = 'Today, August 1',
    this.eventTime = '02:00 PM – 08:00 PM',
    this.eventLocation = 'Main Auditorium, RK University',
    this.heroGradient = const [
      Color(0xFF0A2540),
      Color(0xFF1B3B6F),
      Color(0xFF3B5C99),
    ],
    this.badgeColor = const Color(0xFF3B82F6),
    this.badgeLabel = 'TECH',
    this.rating = 4.9,
    this.facultyCoordinatorName = 'Dr. Anjali Mehta',
    this.facultyCoordinatorEmail = 'anjali.mehta@rku.ac.in',
    this.facultyCoordinatorMobile = '+91 98765 43210',
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isBookmarked = false;
  bool _isRegistered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;


  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildQuickStats(),
                    const SizedBox(height: 14),
                    _buildAboutTab(),
                    const SizedBox(height: 14),
                    _buildRelatedSection(),
                    const SizedBox(height: 104),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCTA(),
          ),
        ],
      ),
    );
  }

  // ─── SLIVER APP BAR ───────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryContainer,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isBookmarked = !_isBookmarked),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey(_isBookmarked),
                color: _isBookmarked ? AppColors.goldAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeroBanner(),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.heroGradient,
        ),
      ),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _HeroPatternPainter()),
            // Radial glow
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom fade
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000520)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Text content
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildHeroBadge(widget.badgeLabel, widget.badgeColor),
                      const SizedBox(width: 8),
                      _buildLiveBadge(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.eventTitle,
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.eventLocation,
                          style: AppTypography.bodySm
                              .copyWith(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildHeroBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        label,
        style: AppTypography.labelBold.copyWith(
          color: Colors.white,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _pulseAnimation.value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'LIVE',
              style: AppTypography.labelBold.copyWith(
                color: Colors.white,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK STATS ─────────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.primaryContainer,
                  label: 'DATE',
                  value: widget.eventDate,
                  bgColor: AppColors.primaryContainer.withValues(alpha: 0.07),
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  icon: Icons.access_time_outlined,
                  iconColor: AppColors.secondary,
                  label: 'TIME',
                  value: widget.eventTime,
                  bgColor:
                      AppColors.secondaryContainer.withValues(alpha: 0.25),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildSmallStat('342', 'Registered', Icons.people_outline,
                    const Color(0xFF3B82F6)),
                _buildStatDivider(),
                _buildSmallStat('${widget.rating}', 'Rating',
                    Icons.star_rounded, AppColors.goldAccent),
                _buildStatDivider(),
                _buildSmallStat('58', 'Seats Left',
                    Icons.event_seat_outlined, const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.smRadius,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.cardBorder);
  }

  // ─── ABOUT ────────────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('About the Event'),
                const SizedBox(height: 10),
                Text(
                  'Join global tech leaders for a groundbreaking day of keynotes, panel discussions, '
                  'hands-on workshops and networking. The Annual Innovation Summit 2024 brings together '
                  '400+ students, faculty and industry experts from across India to explore the cutting '
                  'edge of Artificial Intelligence, Product Design and Entrepreneurship.\n\n'
                  "Whether you're a first-year student curious about tech careers or a final-year "
                  'looking to build connections, this event is designed for YOU.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Event Highlights'),
                const SizedBox(height: 12),
                ...[
                  ('🎤', 'Keynote from Google AI Research Lead'),
                  ('🤝', '1-on-1 Networking with Industry Experts'),
                  ('💻', 'Live AI Workshop — Hands on!'),
                  ('🏆', 'Innovation Awards worth ₹50,000'),
                  ('📜', 'Certificate of Participation for all'),
                ].map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(h.$1,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            h.$2,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Organized By'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Technical Committee, RK University',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'techsummit@rku.ac.in  •  +91 98765 43210',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer
                            .withValues(alpha: 0.08),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: AppColors.primaryContainer,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Faculty Coordinator'),
                const SizedBox(height: 14),
                // Avatar + Name row
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF002147),
                            Color(0xFF1B3B6F),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.facultyCoordinatorName
                              .trim()
                              .split(' ')
                              .where((w) => w.isNotEmpty)
                              .take(2)
                              .map((w) => w[0].toUpperCase())
                              .join(),
                          style: AppTypography.headlineMd.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.facultyCoordinatorName,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Faculty Coordinator',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 14),
                // Email row
                _coordinatorContactRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: widget.facultyCoordinatorEmail,
                ),
                const SizedBox(height: 12),
                // Mobile row
                _coordinatorContactRow(
                  icon: Icons.phone_outlined,
                  label: 'Mobile',
                  value: widget.facultyCoordinatorMobile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Location'),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8F0FE), Color(0xFFD2E3FC)],
                    ),
                    borderRadius: AppRadius.smRadius,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.smRadius,
                        child: CustomPaint(
                          painter: _MapPatternPainter(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF002147),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Main Auditorium',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'RK University, Rajkot, Gujarat',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_outlined,
                      size: 16,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Get Directions',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2.3 km from campus gate',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── RELATED EVENTS ───────────────────────────────────────────────────────

  Widget _buildRelatedSection() {
    final related = [
      {
        'title': 'UX/UI Design Workshop',
        'category': 'DESIGN',
        'date': 'Oct 25',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Green Campus Initiative',
        'category': 'ENVIRONMENT',
        'date': 'Oct 27',
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Open Mic Night',
        'category': 'CULTURAL',
        'date': 'Oct 30',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You May Also Like',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'VIEW ALL',
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...related.map((ev) {
            final color = ev['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Center(
                        child: Icon(Icons.event_outlined,
                            color: color, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: AppRadius.fullRadius,
                            ),
                            child: Text(
                              ev['category'] as String,
                              style: AppTypography.labelBold.copyWith(
                                color: color,
                                fontSize: 9,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev['title'] as String,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ev['date'] as String,
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.outline),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── BOTTOM CTA ───────────────────────────────────────────────────────────

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
            top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: AppColors.cardShadow,
          ),
        ],
      ),
      child: Row(
        children: [
          // Stacked attendee avatars
          SizedBox(
            width: 76,
            height: 36,
            child: Stack(
              children: List.generate(3, (i) {
                final colors = [
                  const Color(0xFF3B82F6),
                  const Color(0xFF8B5CF6),
                  const Color(0xFF10B981),
                ];
                return Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        ['A', 'B', 'C'][i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+342 registered',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '58 seats remaining',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_isRegistered) {
                // Already registered — allow toggling off
                setState(() => _isRegistered = false);
              } else {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => EventRegistrationScreen(
                          eventTitle: widget.eventTitle,
                          eventDate: widget.eventDate,
                          eventCategory: widget.eventCategory,
                          badgeColor: widget.badgeColor,
                        ),
                      ),
                    )
                    .then((_) {
                  // Mark as registered once the form screen is popped
                  if (mounted) setState(() => _isRegistered = true);
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                gradient: _isRegistered
                    ? const LinearGradient(colors: [
                        Color(0xFF22C55E),
                        Color(0xFF16A34A),
                      ])
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF002147),
                          Color(0xFF1B3B6F),
                        ],
                      ),
                borderRadius: AppRadius.fullRadius,
                boxShadow: [
                  BoxShadow(
                    color: (_isRegistered
                            ? const Color(0xFF22C55E)
                            : AppColors.primaryContainer)
                        .withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRegistered
                        ? Icons.check_circle_outline
                        : Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRegistered ? 'Registered!' : 'Register Now',
                    style: AppTypography.labelBold.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.cardShadow,
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _coordinatorContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            borderRadius: AppRadius.smRadius,
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            borderRadius: AppRadius.fullRadius,
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label == 'Email' ? 'Mail' : 'Call',
            style: AppTypography.labelBold.copyWith(
              color: AppColors.primaryContainer,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PAINTERS ────────────────────────────────────────────────────────────────

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (i * 53.0) % size.width;
      final y = (i * 31.0) % size.height;
      canvas.drawCircle(Offset(x, y), 6 + (i % 5).toDouble() * 5, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width, size.height * 0.5),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width, size.height * 0.3),
      accentPaint,
    );

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final rng = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.5 + 0.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF002147).withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF002147).withValues(alpha: 0.12)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
