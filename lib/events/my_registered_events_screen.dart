// lib/events/my_registered_events_screen.dart
import 'package:flutter/material.dart';

// ─── REGISTERED EVENT MODEL ──────────────────────────────────────────────────

class RegisteredEvent {
  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String passCode;
  final String seatNo;
  final String status; // 'CONFIRMED', 'TICKET READY', 'LIVE TODAY', 'COMPLETED'
  final Color statusColor;
  final List<Color> cardGradient;
  final IconData categoryIcon;

  const RegisteredEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.passCode,
    required this.seatNo,
    required this.status,
    required this.statusColor,
    required this.cardGradient,
    required this.categoryIcon,
  });
}

const List<RegisteredEvent> _allRegisteredEvents = [
  RegisteredEvent(
    id: 'reg1',
    title: 'Annual Innovation Summit 2024',
    category: 'TECH',
    date: 'Aug 15, 2024',
    time: '02:00 PM – 08:00 PM',
    location: 'Main Auditorium, RK University',
    passCode: 'PASS #RK-8921-X4',
    seatNo: 'Row B • Seat 14',
    status: 'TICKET READY',
    statusColor: Color(0xFF22C55E),
    cardGradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
    categoryIcon: Icons.lightbulb_outline,
  ),
  RegisteredEvent(
    id: 'reg2',
    title: 'AI Workshop & Hackathon Series',
    category: 'WORKSHOP',
    date: 'Aug 22, 2024',
    time: '10:00 AM – 04:00 PM',
    location: 'Lab 4, CS Block',
    passCode: 'PASS #RK-7412-A1',
    seatNo: 'Lab Desk 08',
    status: 'CONFIRMED',
    statusColor: Color(0xFF3B82F6),
    cardGradient: [Color(0xFF0F2B48), Color(0xFF1D4ED8)],
    categoryIcon: Icons.code_rounded,
  ),
  RegisteredEvent(
    id: 'reg3',
    title: 'Varsity Basketball Championship',
    category: 'SPORTS',
    date: 'Today',
    time: '06:00 PM – 09:00 PM',
    location: 'Sports Complex, Ground Floor',
    passCode: 'PASS #RK-5529-S8',
    seatNo: 'VIP Gallery 02',
    status: 'LIVE TODAY',
    statusColor: Color(0xFFEAB308),
    cardGradient: [Color(0xFF7C2D12), Color(0xFFC2410C)],
    categoryIcon: Icons.sports_basketball_outlined,
  ),
  RegisteredEvent(
    id: 'reg4',
    title: 'Cultural Night Aftermovie Premiere',
    category: 'CULTURAL',
    date: 'Jul 10, 2024',
    time: '07:00 PM – 10:00 PM',
    location: 'Open Air Theatre',
    passCode: 'PASS #RK-1029-C3',
    seatNo: 'Open Seating',
    status: 'COMPLETED',
    statusColor: Color(0xFF64748B),
    cardGradient: [Color(0xFF3B0764), Color(0xFF6B21A8)],
    categoryIcon: Icons.music_note_outlined,
  ),
];

// ─── MY REGISTERED EVENTS SCREEN ─────────────────────────────────────────────

class MyRegisteredEventsScreen extends StatefulWidget {
  const MyRegisteredEventsScreen({super.key});

  @override
  State<MyRegisteredEventsScreen> createState() =>
      _MyRegisteredEventsScreenState();
}

class _MyRegisteredEventsScreenState extends State<MyRegisteredEventsScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _filters = [
    'All',
    'Upcoming',
    'Live Today',
    'Past Attended'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RegisteredEvent> get _filteredEvents {
    return _allRegisteredEvents.where((event) {
      final matchesQuery = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesQuery) return false;

      if (_selectedFilterIndex == 1) {
        return event.status == 'TICKET READY' || event.status == 'CONFIRMED';
      } else if (_selectedFilterIndex == 2) {
        return event.status == 'LIVE TODAY';
      } else if (_selectedFilterIndex == 3) {
        return event.status == 'COMPLETED';
      }
      return true;
    }).toList();
  }

  void _showQrPassDialog(RegisteredEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified, color: Color(0xFFFFD54F), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'OFFICIAL ENTRY PASS',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Event Title
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date} • ${event.time}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Simulated QR Code Visual Graphic
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: CustomPaint(
                    size: const Size(160, 160),
                    painter: _QrCodePainter(),
                  ),
                ),

                const SizedBox(height: 16),
                // Pass details
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Student Name:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            'Alex Vance',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pass Number:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            event.passCode,
                            style: const TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Seat / Zone:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            event.seatNo,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close Ticket Pass',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredEvents;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Registered Events',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 14),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildEventTicketCard(list[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search my registrations...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF8C9099), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: InkWell(
              onTap: () => setState(() => _selectedFilterIndex = index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD54F)
                      : const Color(0xFFEBECEF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF5A606C),
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTicketCard(RegisteredEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Header Bar of Ticket
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: event.cardGradient),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(event.categoryIcon, color: const Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      event.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: event.statusColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    event.status,
                    style: TextStyle(
                      color: event.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      event.date,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      event.time,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pass Number',
                          style: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 10),
                        ),
                        Text(
                          event.passCode,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showQrPassDialog(event),
                      icon: const Icon(Icons.qr_code_rounded,
                          size: 16, color: Color(0xFF0F172A)),
                      label: const Text(
                        'View QR Pass',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy_rounded, size: 48, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'No registered events found',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Explore campus events and register to see your passes here!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

// ─── SIMULATED QR CODE PAINTER ───────────────────────────────────────────────

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // Draw position detection squares (top-left, top-right, bottom-left)
    _drawSquare(canvas, paint, 0, 0, 40);
    _drawSquare(canvas, paint, size.width - 40, 0, 40);
    _drawSquare(canvas, paint, 0, size.height - 40, 40);

    // Random QR modules pattern
    const step = 8.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        // Skip corner detection zones
        if ((x < 45 && y < 45) ||
            (x > size.width - 45 && y < 45) ||
            (x < 45 && y > size.height - 45)) {
          continue;
        }
        if (((x.toInt() * 7 + y.toInt() * 13) % 19) > 9) {
          canvas.drawRect(Rect.fromLTWH(x, y, step - 1.5, step - 1.5), paint);
        }
      }
    }
  }

  void _drawSquare(
      Canvas canvas, Paint paint, double x, double y, double size) {
    final outer = Rect.fromLTWH(x, y, size, size);
    canvas.drawRect(outer, paint);

    final whitePaint = Paint()..color = Colors.white;
    final inner = Rect.fromLTWH(x + 6, y + 6, size - 12, size - 12);
    canvas.drawRect(inner, whitePaint);

    final centerRect = Rect.fromLTWH(x + 12, y + 12, size - 24, size - 24);
    canvas.drawRect(centerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
